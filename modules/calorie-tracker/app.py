#!/usr/bin/env python3
"""Minimal multi-user calorie tracker. Stdlib only; weight comes from Home Assistant."""
import json
import os
import re
import sqlite3
import urllib.request
from contextlib import closing
from datetime import date, datetime, timedelta
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

PORT = int(os.environ.get("PORT", "8085"))
STATE_DIR = os.environ.get("STATE_DIRECTORY", ".")
CRED_DIR = os.environ.get("CREDENTIALS_DIRECTORY", "")
HA_URL = os.environ.get("HA_URL", "http://localhost:8123")
STATIC_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(STATE_DIR, "calories.db")

STATIC_FILES = {
    "/manifest.webmanifest": ("manifest.webmanifest", "application/manifest+json"),
    "/sw.js": ("sw.js", "application/javascript"),
    "/icon-192.png": ("icon-192.png", "image/png"),
    "/icon-512.png": ("icon-512.png", "image/png"),
    "/icon-512-maskable.png": ("icon-512-maskable.png", "image/png"),
    "/apple-touch-icon.png": ("apple-touch-icon.png", "image/png"),
}

ACTIVITY_LEVELS = [1.2, 1.375, 1.55, 1.725, 1.9]
DEFAULT_ACTIVITY = 1.375

SCHEMA = """
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  weight_entity TEXT,
  bmr_entity TEXT,
  sex TEXT NOT NULL DEFAULT 'm',
  birthdate TEXT,
  height_cm REAL,
  carb_pct REAL NOT NULL DEFAULT 45,
  prot_pct REAL NOT NULL DEFAULT 30,
  fat_pct REAL NOT NULL DEFAULT 25,
  target_weight_kg REAL,
  target_date TEXT
);
CREATE TABLE IF NOT EXISTS foods (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  carb REAL NOT NULL,
  prot REAL NOT NULL,
  fat REAL NOT NULL,
  carb100 REAL,
  prot100 REAL,
  fat100 REAL,
  grams REAL NOT NULL DEFAULT 100
);
CREATE TABLE IF NOT EXISTS logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  day TEXT NOT NULL,
  food_id INTEGER REFERENCES foods(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  carb REAL NOT NULL,
  prot REAL NOT NULL,
  fat REAL NOT NULL,
  qty REAL NOT NULL DEFAULT 1,
  ts TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS logs_user_day ON logs(user_id, day);
CREATE TABLE IF NOT EXISTS days (
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  day TEXT NOT NULL,
  activity REAL NOT NULL,
  PRIMARY KEY (user_id, day)
);
CREATE TABLE IF NOT EXISTS recurring (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  food_id INTEGER NOT NULL REFERENCES foods(id) ON DELETE CASCADE,
  qty REAL NOT NULL DEFAULT 1,
  UNIQUE (user_id, food_id)
);
CREATE TABLE IF NOT EXISTS recurring_applied (
  recurring_id INTEGER NOT NULL REFERENCES recurring(id) ON DELETE CASCADE,
  day TEXT NOT NULL,
  PRIMARY KEY (recurring_id, day)
);
"""


def db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def init_db():
    with closing(db()) as conn:
        conn.executescript(SCHEMA)
        cols = {r["name"] for r in conn.execute("PRAGMA table_info(foods)")}
        if "grams" not in cols:
            for col in ("carb100 REAL", "prot100 REAL", "fat100 REAL", "grams REAL NOT NULL DEFAULT 100"):
                conn.execute(f"ALTER TABLE foods ADD COLUMN {col}")
        conn.execute(
            """UPDATE foods SET carb100=carb, prot100=prot, fat100=fat
               WHERE carb100 IS NULL OR prot100 IS NULL OR fat100 IS NULL"""
        )
        ucols = {r["name"] for r in conn.execute("PRAGMA table_info(users)")}
        for col in ("target_weight_kg REAL", "target_date TEXT"):
            if col.split()[0] not in ucols:
                conn.execute(f"ALTER TABLE users ADD COLUMN {col}")
        conn.commit()


def ha_token():
    path = os.path.join(CRED_DIR, "ha_token")
    with open(path) as f:
        return f.read().strip()


def ha_request(path):
    req = urllib.request.Request(
        HA_URL + path, headers={"Authorization": f"Bearer {ha_token()}"}
    )
    with urllib.request.urlopen(req, timeout=5) as resp:
        return json.load(resp)


def ha_number(entity):
    if not entity:
        return None
    try:
        state = ha_request(f"/api/states/{entity}")
        value = float(state["state"])
    except Exception:
        return None
    # HA scales may report grams
    if state.get("attributes", {}).get("unit_of_measurement") == "g":
        value /= 1000
    return value


def ha_weight_entities():
    try:
        states = ha_request("/api/states")
    except Exception:
        return []
    out = []
    for s in states:
        eid = s["entity_id"]
        attrs = s.get("attributes", {})
        if not eid.startswith("sensor."):
            continue
        if attrs.get("device_class") == "weight" or attrs.get("unit_of_measurement") in ("kg", "lb"):
            out.append({"id": eid, "name": attrs.get("friendly_name", eid), "state": s["state"]})
    return sorted(out, key=lambda e: e["name"].lower())


def ha_weight_history(entity, days):
    if not entity:
        return []
    try:
        current = ha_request(f"/api/states/{entity}")
        grams = current.get("attributes", {}).get("unit_of_measurement") == "g"
    except Exception:
        grams = False
    end = datetime.utcnow()
    start = end - timedelta(days=days)
    try:
        states = ha_request(
            f"/api/history/period/{start.isoformat()}Z"
            f"?filter_entity_id={entity}&end_time={end.isoformat()}Z&minimal_response"
        )
    except Exception:
        return []
    if not states or not states[0]:
        return []
    by_day = {}
    for s in states[0]:
        try:
            value = float(s["state"])
        except (KeyError, ValueError, TypeError):
            continue
        if grams:
            value /= 1000
        ts = s.get("last_changed") or s.get("last_updated")
        if not ts:
            continue
        by_day[ts[:10]] = value
    return [{"day": d, "weight": by_day[d]} for d in sorted(by_day)]


def ha_numeric_entities():
    try:
        states = ha_request("/api/states")
    except Exception:
        return []
    out = []
    for s in states:
        if not s["entity_id"].startswith("sensor."):
            continue
        try:
            float(s["state"])
        except ValueError:
            continue
        out.append({"id": s["entity_id"], "name": s.get("attributes", {}).get("friendly_name", s["entity_id"]), "state": s["state"]})
    return sorted(out, key=lambda e: e["name"].lower())


def age_from(birthdate):
    try:
        b = datetime.strptime(birthdate, "%Y-%m-%d").date()
    except (TypeError, ValueError):
        return None
    today = date.today()
    return today.year - b.year - ((today.month, today.day) < (b.month, b.day))


def compute_bmr(user, weight):
    bmr_sensor = ha_number(user["bmr_entity"])
    if bmr_sensor:
        return bmr_sensor, "sensor"
    age = age_from(user["birthdate"])
    if weight is None or age is None or not user["height_cm"]:
        return None, None
    base = 10 * weight + 6.25 * user["height_cm"] - 5 * age
    return base + (5 if user["sex"] == "m" else -161), "mifflin"


def target_deficit(user, weight, today=None):
    """Daily kcal to subtract (positive) or add (negative) from maintenance to reach the weight target."""
    if weight is None or not user["target_weight_kg"] or not user["target_date"]:
        return None
    try:
        target_date = datetime.strptime(user["target_date"], "%Y-%m-%d").date()
    except ValueError:
        return None
    days_left = (target_date - (today or date.today())).days
    if days_left <= 0:
        return None
    return round((weight - user["target_weight_kg"]) * 7700 / days_left)


def day_activity(conn, user_id, day):
    row = conn.execute(
        "SELECT activity FROM days WHERE user_id=? AND day=?", (user_id, day)
    ).fetchone()
    if row:
        return row["activity"]
    row = conn.execute(
        "SELECT activity FROM days WHERE user_id=? AND day<? ORDER BY day DESC LIMIT 1",
        (user_id, day),
    ).fetchone()
    return row["activity"] if row else DEFAULT_ACTIVITY


def apply_recurring(conn, user_id, day):
    """Log each recurring food for this user/day once, the first time that day is seen."""
    rules = conn.execute("SELECT * FROM recurring WHERE user_id=?", (user_id,)).fetchall()
    for rule in rules:
        applied = conn.execute(
            "SELECT 1 FROM recurring_applied WHERE recurring_id=? AND day=?", (rule["id"], day)
        ).fetchone()
        if applied:
            continue
        conn.execute("INSERT INTO recurring_applied (recurring_id, day) VALUES (?,?)", (rule["id"], day))
        food = conn.execute("SELECT * FROM foods WHERE id=?", (rule["food_id"],)).fetchone()
        if not food:
            continue
        conn.execute(
            """INSERT INTO logs (user_id, day, food_id, name, carb, prot, fat, qty)
               VALUES (?,?,?,?,?,?,?,?)""",
            (user_id, day, food["id"], food["name"], food["carb"], food["prot"], food["fat"], rule["qty"]),
        )


def user_row(conn, user_id):
    row = conn.execute("SELECT * FROM users WHERE id=?", (user_id,)).fetchone()
    if not row:
        raise ApiError(404, "user not found")
    return row


class ApiError(Exception):
    def __init__(self, status, message):
        super().__init__(message)
        self.status = status


def num(body, key, default=None, minimum=0):
    value = body.get(key, default)
    try:
        value = float(value)
    except (TypeError, ValueError):
        raise ApiError(400, f"{key} must be a number")
    if value < minimum:
        raise ApiError(400, f"{key} must be >= {minimum}")
    return value


def valid_day(value):
    if not isinstance(value, str) or not re.fullmatch(r"\d{4}-\d{2}-\d{2}", value):
        raise ApiError(400, "invalid date")
    return value


def user_fields(body):
    name = str(body.get("name", "")).strip()
    if not name:
        raise ApiError(400, "name required")
    pcts = [num(body, k, d) for k, d in (("carb_pct", 45), ("prot_pct", 30), ("fat_pct", 25))]
    if abs(sum(pcts) - 100) > 0.5:
        raise ApiError(400, "macro percentages must sum to 100")
    sex = body.get("sex", "m")
    if sex not in ("m", "f"):
        raise ApiError(400, "sex must be m or f")
    birthdate = body.get("birthdate") or None
    if birthdate:
        valid_day(birthdate)
    height = body.get("height_cm")
    height = num(body, "height_cm") if height not in (None, "") else None
    target_weight = body.get("target_weight_kg")
    target_weight = num(body, "target_weight_kg", minimum=0) if target_weight not in (None, "") else None
    target_date = body.get("target_date") or None
    if target_date:
        valid_day(target_date)
    return (
        name,
        body.get("weight_entity") or None,
        body.get("bmr_entity") or None,
        sex,
        birthdate,
        height,
        *pcts,
        target_weight,
        target_date,
    )


def build_state(conn, user_id, day):
    user = user_row(conn, user_id)
    if day == date.today().isoformat():
        apply_recurring(conn, user_id, day)
    weight = ha_number(user["weight_entity"])
    bmr, bmr_source = compute_bmr(user, weight)
    activity = day_activity(conn, user_id, day)
    maintenance = round(bmr * activity) if bmr else None
    deficit = target_deficit(user, weight)
    goal = maintenance - deficit if maintenance is not None and deficit is not None else maintenance

    logs = [
        dict(r)
        for r in conn.execute(
            """SELECT l.*, r.id AS recurring_id FROM logs l
               LEFT JOIN recurring r ON r.user_id = l.user_id AND r.food_id = l.food_id
               WHERE l.user_id=? AND l.day=? ORDER BY l.ts, l.id""",
            (user_id, day),
        )
    ]
    totals = {
        k: sum(l[k] * l["qty"] for l in logs) for k in ("carb", "prot", "fat")
    }
    totals["kcal"] = totals["carb"] * 4 + totals["prot"] * 4 + totals["fat"] * 9

    macro_goals = None
    if goal:
        macro_goals = {
            "carb": goal * user["carb_pct"] / 100 / 4,
            "prot": goal * user["prot_pct"] / 100 / 4,
            "fat": goal * user["fat_pct"] / 100 / 9,
        }

    return {
        "user": dict(user),
        "day": day,
        "weight": weight,
        "bmr": bmr,
        "bmr_source": bmr_source,
        "activity": activity,
        "activity_levels": ACTIVITY_LEVELS,
        "maintenance_kcal": maintenance,
        "target_deficit_kcal": deficit,
        "goal_kcal": goal,
        "macro_goals": macro_goals,
        "totals": totals,
        "logs": logs,
    }


def list_foods(conn):
    rows = conn.execute(
        """
        SELECT f.*, COUNT(l.id) AS uses, MAX(l.ts) AS last_used
        FROM foods f LEFT JOIN logs l ON l.food_id = f.id
        GROUP BY f.id
        ORDER BY uses DESC, f.name COLLATE NOCASE
        """
    )
    return [dict(r) for r in rows]


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

    def send_json(self, payload, status=200):
        data = json.dumps(payload).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def send_static(self, filename, content_type):
        with open(os.path.join(STATIC_DIR, filename), "rb") as f:
            data = f.read()
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def body(self):
        length = int(self.headers.get("Content-Length") or 0)
        if not length:
            return {}
        try:
            parsed = json.loads(self.rfile.read(length))
        except json.JSONDecodeError:
            raise ApiError(400, "invalid json")
        if not isinstance(parsed, dict):
            raise ApiError(400, "expected object")
        return parsed

    def dispatch(self, method):
        parsed = urlparse(self.path)
        path = parsed.path
        query = {k: v[0] for k, v in parse_qs(parsed.query).items()}

        if method == "GET" and path in ("/", "/index.html"):
            return self.send_static("index.html", "text/html; charset=utf-8")

        if method == "GET" and path in STATIC_FILES:
            filename, content_type = STATIC_FILES[path]
            return self.send_static(filename, content_type)

        if not path.startswith("/api/"):
            raise ApiError(404, "not found")

        with closing(db()) as conn, conn:
            self.route(conn, method, path, query)

    def route(self, conn, method, path, query):
        if path == "/api/users" and method == "GET":
            rows = conn.execute("SELECT id, name FROM users ORDER BY id").fetchall()
            return self.send_json([dict(r) for r in rows])

        if path == "/api/users" and method == "POST":
            fields = user_fields(self.body())
            cur = conn.execute(
                """INSERT INTO users (name, weight_entity, bmr_entity, sex, birthdate,
                   height_cm, carb_pct, prot_pct, fat_pct, target_weight_kg, target_date)
                   VALUES (?,?,?,?,?,?,?,?,?,?,?)""",
                fields,
            )
            return self.send_json({"id": cur.lastrowid}, 201)

        m = re.fullmatch(r"/api/users/(\d+)", path)
        if m and method == "PUT":
            uid = int(m.group(1))
            user_row(conn, uid)
            fields = user_fields(self.body())
            conn.execute(
                """UPDATE users SET name=?, weight_entity=?, bmr_entity=?, sex=?, birthdate=?,
                   height_cm=?, carb_pct=?, prot_pct=?, fat_pct=?, target_weight_kg=?, target_date=?
                   WHERE id=?""",
                (*fields, uid),
            )
            return self.send_json({"ok": True})
        if m and method == "DELETE":
            conn.execute("DELETE FROM users WHERE id=?", (int(m.group(1)),))
            return self.send_json({"ok": True})

        if path == "/api/ha/entities" and method == "GET":
            return self.send_json(
                {"weight": ha_weight_entities(), "numeric": ha_numeric_entities()}
            )

        if path == "/api/state" and method == "GET":
            uid = int(query.get("user", 0))
            day = valid_day(query.get("day", date.today().isoformat()))
            return self.send_json(build_state(conn, uid, day))

        if path == "/api/weight_history" and method == "GET":
            uid = int(query.get("user", 0))
            user = user_row(conn, uid)
            return self.send_json(ha_weight_history(user["weight_entity"], 7))

        if path == "/api/day" and method == "PUT":
            body = self.body()
            uid = int(body.get("user", 0))
            user_row(conn, uid)
            day = valid_day(body.get("day"))
            activity = num(body, "activity", minimum=1)
            conn.execute(
                """INSERT INTO days (user_id, day, activity) VALUES (?,?,?)
                   ON CONFLICT(user_id, day) DO UPDATE SET activity=excluded.activity""",
                (uid, day, activity),
            )
            return self.send_json({"ok": True})

        if path == "/api/foods" and method == "GET":
            return self.send_json(list_foods(conn))

        if path == "/api/foods" and method == "POST":
            body = self.body()
            name = str(body.get("name", "")).strip()
            if not name:
                raise ApiError(400, "name required")
            carb100, prot100, fat100 = (num(body, k) for k in ("carb100", "prot100", "fat100"))
            grams = num(body, "grams", 100, minimum=1)
            same = conn.execute(
                """SELECT id FROM foods WHERE name = ? COLLATE NOCASE
                   AND ABS(carb100 - ?) < 0.001 AND ABS(prot100 - ?) < 0.001
                   AND ABS(fat100 - ?) < 0.001 AND ABS(grams - ?) < 0.001""",
                (name, carb100, prot100, fat100, grams),
            ).fetchone()
            if same:
                return self.send_json({"id": same["id"]})
            k = grams / 100
            cur = conn.execute(
                """INSERT INTO foods (name, carb, prot, fat, carb100, prot100, fat100, grams)
                   VALUES (?,?,?,?,?,?,?,?)""",
                (name, carb100 * k, prot100 * k, fat100 * k, carb100, prot100, fat100, grams),
            )
            return self.send_json({"id": cur.lastrowid}, 201)

        if path == "/api/logs" and method == "POST":
            body = self.body()
            uid = int(body.get("user", 0))
            user_row(conn, uid)
            day = valid_day(body.get("day"))
            food = conn.execute(
                "SELECT * FROM foods WHERE id=?", (int(body.get("food_id", 0)),)
            ).fetchone()
            if not food:
                raise ApiError(404, "food not found")
            qty = num(body, "qty", 1, minimum=0.01)
            cur = conn.execute(
                """INSERT INTO logs (user_id, day, food_id, name, carb, prot, fat, qty)
                   VALUES (?,?,?,?,?,?,?,?)""",
                (uid, day, food["id"], food["name"], food["carb"], food["prot"], food["fat"], qty),
            )
            return self.send_json({"id": cur.lastrowid}, 201)

        if path == "/api/recurring" and method == "POST":
            body = self.body()
            uid = int(body.get("user", 0))
            user_row(conn, uid)
            food_id = int(body.get("food_id", 0))
            food = conn.execute("SELECT id FROM foods WHERE id=?", (food_id,)).fetchone()
            if not food:
                raise ApiError(404, "food not found")
            qty = num(body, "qty", 1, minimum=0.01)
            conn.execute(
                """INSERT INTO recurring (user_id, food_id, qty) VALUES (?,?,?)
                   ON CONFLICT(user_id, food_id) DO UPDATE SET qty=excluded.qty""",
                (uid, food_id, qty),
            )
            rid = conn.execute(
                "SELECT id FROM recurring WHERE user_id=? AND food_id=?", (uid, food_id)
            ).fetchone()["id"]
            today = date.today().isoformat()
            conn.execute(
                "INSERT OR IGNORE INTO recurring_applied (recurring_id, day) VALUES (?,?)", (rid, today)
            )
            return self.send_json({"id": rid}, 201)

        m = re.fullmatch(r"/api/recurring/(\d+)", path)
        if m and method == "DELETE":
            conn.execute("DELETE FROM recurring WHERE id=?", (int(m.group(1)),))
            return self.send_json({"ok": True})

        m = re.fullmatch(r"/api/foods/(\d+)", path)
        if m and method == "PUT":
            fid = int(m.group(1))
            body = self.body()
            name = str(body.get("name", "")).strip()
            if not name:
                raise ApiError(400, "name required")
            carb100, prot100, fat100 = (num(body, k) for k in ("carb100", "prot100", "fat100"))
            grams = num(body, "grams", 100, minimum=1)
            k = grams / 100
            cur = conn.execute(
                """UPDATE foods SET name=?, carb=?, prot=?, fat=?, carb100=?, prot100=?, fat100=?, grams=?
                   WHERE id=?""",
                (name, carb100 * k, prot100 * k, fat100 * k, carb100, prot100, fat100, grams, fid),
            )
            if cur.rowcount == 0:
                raise ApiError(404, "food not found")
            return self.send_json({"ok": True})
        if m and method == "DELETE":
            conn.execute("DELETE FROM foods WHERE id=?", (int(m.group(1)),))
            return self.send_json({"ok": True})

        m = re.fullmatch(r"/api/logs/(\d+)", path)
        if m and method == "DELETE":
            conn.execute("DELETE FROM logs WHERE id=?", (int(m.group(1)),))
            return self.send_json({"ok": True})

        raise ApiError(404, "not found")

    def handle_method(self, method):
        try:
            self.dispatch(method)
        except ApiError as e:
            self.send_json({"error": str(e)}, e.status)
        except Exception as e:  # noqa: BLE001
            self.send_json({"error": f"internal error: {e}"}, 500)

    def do_GET(self):
        self.handle_method("GET")

    def do_POST(self):
        self.handle_method("POST")

    def do_PUT(self):
        self.handle_method("PUT")

    def do_DELETE(self):
        self.handle_method("DELETE")


if __name__ == "__main__":
    init_db()
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
