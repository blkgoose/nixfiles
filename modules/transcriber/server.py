import hmac
import json
import os
import re
import secrets
import shutil
import socket
import threading
import time
import uuid
from http.cookies import SimpleCookie
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, quote, urlparse

import bcrypt

HOST = os.environ.get("HOST", "127.0.0.1")
PORT = int(os.environ.get("PORT", "8086"))
DATA = Path(os.environ["DATA_DIR"])
JOBS = DATA / "jobs"
USERS_FILE = DATA / "users.json"
INDEX = Path(__file__).with_name("index.html")
LOGIN = Path(__file__).with_name("login.html")
MODELS = json.loads(os.environ["MODELS"])
ADMINS = set(os.environ.get("ADMINS", "").split(","))
WAKE_MAC = os.environ["WAKE_MAC"]
WAKE_BROADCAST = os.environ["WAKE_BROADCAST"]
WORKER_TIMEOUT = 90
STALE_JOB = 300
SESSION_TTL = 30 * 24 * 3600
MAX_FAILS = 5
LOCK_SECONDS = 300
MAX_PASSWORD_BYTES = 72
ID_RE = re.compile(r"^[0-9a-f]{32}$")
ACTIVE = ("converting", "transcribing", "diarizing")
WORKER_FIELDS = {"status", "stage", "progress", "duration", "error"}

JOBS.mkdir(parents=True, exist_ok=True)
lock = threading.Lock()
users_lock = threading.Lock()
worker_seen = {"at": 0.0}
sessions = {}
failures = {}
DUMMY_HASH = bcrypt.hashpw(b"dummy", bcrypt.gensalt())

def load_users():
    try:
        return json.loads(USERS_FILE.read_text())
    except (OSError, ValueError):
        return {}

def save_users(users):
    tmp = DATA / "users.json.tmp"
    tmp.write_text(json.dumps(users, indent=2))
    tmp.chmod(0o600)
    tmp.replace(USERS_FILE)

def hash_password(password):
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

def check_login(name, password):
    pw = password.encode()
    with users_lock:
        users = load_users()
        stored = users.get(name)
        if not isinstance(stored, str) or len(pw) > MAX_PASSWORD_BYTES:
            bcrypt.checkpw(b"dummy", DUMMY_HASH)
            return False
        if stored.startswith("$2"):
            return bcrypt.checkpw(pw, stored.encode())
        if hmac.compare_digest(stored.encode(), pw):
            users[name] = hash_password(password)
            save_users(users)
            return True
        return False

def is_locked(name):
    entry = failures.get(name)
    if entry and entry[0] >= MAX_FAILS:
        if time.time() < entry[1]:
            return True
        del failures[name]
    return False

def record_failure(name):
    count = failures.get(name, (0, 0))[0] + 1
    failures[name] = (count, time.time() + LOCK_SECONDS)

def job_dir(job_id):
    return JOBS / job_id

def read_meta(job_id):
    try:
        return json.loads((job_dir(job_id) / "meta.json").read_text())
    except (OSError, ValueError):
        return None

def write_meta(meta):
    d = job_dir(meta["id"])
    tmp = d / "meta.json.tmp"
    tmp.write_text(json.dumps(meta))
    tmp.replace(d / "meta.json")

def list_metas():
    return [m for m in (read_meta(p.name) for p in JOBS.iterdir() if ID_RE.match(p.name)) if m]

def update_from_worker(job_id, fields):
    with lock:
        meta = read_meta(job_id)
        if meta is None:
            return False
        meta.update({k: v for k, v in fields.items() if k in WORKER_FIELDS})
        meta["updated"] = time.time()
        if meta["status"] == "done":
            meta["finished"] = meta["updated"]
        write_meta(meta)
        return True

def claim():
    now = time.time()
    with lock:
        for m in sorted(list_metas(), key=lambda m: m["created"]):
            stale = m["status"] in ACTIVE and now - m.get("updated", m["created"]) > STALE_JOB
            if m["status"] == "queued" or stale:
                m.update(status="converting", stage="Conversione audio", progress=0, started=now, updated=now)
                write_meta(m)
                return m
    return None

def status():
    pending = sum(1 for m in list_metas() if m["status"] not in ("done", "error"))
    age = time.time() - worker_seen["at"] if worker_seen["at"] else None
    return {"pending": pending, "worker_online": age is not None and age < WORKER_TIMEOUT}

def send_wol():
    mac = bytes.fromhex(WAKE_MAC.replace(":", ""))
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
        s.sendto(b"\xff" * 6 + mac * 16, (WAKE_BROADCAST, 9))

class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def send(self, code, body=b"", ctype="application/json", headers=None):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        for k, v in (headers or {}).items():
            self.send_header(k, v)
        self.end_headers()
        self.wfile.write(body)

    def send_json(self, obj, code=200, headers=None):
        self.send(code, json.dumps(obj).encode(), headers=headers)

    def read_body(self):
        return self.rfile.read(int(self.headers.get("Content-Length", 0)))

    def read_json(self):
        try:
            data = json.loads(self.read_body() or b"{}")
        except ValueError:
            return {}
        return data if isinstance(data, dict) else {}

    def session_user(self):
        cookie = SimpleCookie(self.headers.get("Cookie", "")).get("session")
        session = sessions.get(cookie.value) if cookie else None
        if not session or session[1] < time.time() or session[0] not in load_users():
            return None
        return session[0]

    def cookie_header(self, token, max_age):
        flags = "; Secure" if self.headers.get("X-Forwarded-Proto") == "https" else ""
        return {"Set-Cookie": f"session={token}; Path=/; HttpOnly; SameSite=Lax; Max-Age={max_age}{flags}"}

    def begin(self):
        url = urlparse(self.path)
        parts = url.path.strip("/").split("/")
        if parts[:2] == ["api", "worker"] or url.path == "/api/wake":
            if "X-Forwarded-For" in self.headers:
                self.send(404)
                return None
            if parts[:2] == ["api", "worker"]:
                worker_seen["at"] = time.time()
            return url, parts, None
        if url.path == "/api/login":
            return url, parts, None
        user = self.session_user()
        if user:
            return url, parts, user
        if self.command == "GET" and url.path == "/":
            self.send(200, LOGIN.read_bytes(), "text/html; charset=utf-8")
        else:
            self.send_json({"error": "unauthorized"}, 401)
        return None

    def job_id_from(self, parts, index):
        if len(parts) > index and ID_RE.match(parts[index]) and job_dir(parts[index]).is_dir():
            return parts[index]
        return None

    def do_GET(self):
        ctx = self.begin()
        if not ctx:
            return
        url, parts, user = ctx
        if url.path == "/":
            return self.send(200, INDEX.read_bytes(), "text/html; charset=utf-8")
        if url.path == "/api/me":
            return self.send_json({"user": user, "admin": user in ADMINS})
        if url.path == "/api/jobs":
            return self.send_json(sorted(list_metas(), key=lambda m: m["created"], reverse=True))
        if parts[:2] == ["api", "jobs"]:
            job_id = self.job_id_from(parts, 2)
            if not job_id:
                return self.send(404)
            if len(parts) == 3:
                return self.send_json(read_meta(job_id))
            if len(parts) == 4 and parts[3] == "transcript.txt":
                f = job_dir(job_id) / "transcript.txt"
                if not f.exists():
                    return self.send(404)
                name = Path(read_meta(job_id)["filename"]).stem + ".txt"
                return self.send(
                    200, f.read_bytes(), "text/plain; charset=utf-8",
                    {"Content-Disposition": f"attachment; filename*=UTF-8''{quote(name)}"},
                )
        if parts[:3] == ["api", "worker", "jobs"] and len(parts) == 5 and parts[4] == "upload":
            job_id = self.job_id_from(parts, 3)
            if not job_id:
                return self.send(404)
            f = job_dir(job_id) / "upload"
            self.send_response(200)
            self.send_header("Content-Type", "application/octet-stream")
            self.send_header("Content-Length", str(f.stat().st_size))
            self.end_headers()
            with open(f, "rb") as src:
                shutil.copyfileobj(src, self.wfile)
            return
        self.send(404)

    def do_POST(self):
        ctx = self.begin()
        if not ctx:
            return
        url, parts, user = ctx
        if url.path == "/api/login":
            return self.login()
        if url.path == "/api/logout":
            cookie = SimpleCookie(self.headers.get("Cookie", "")).get("session")
            if cookie:
                sessions.pop(cookie.value, None)
            return self.send_json({}, headers=self.cookie_header("", 0))
        if url.path == "/api/wake":
            st = status()
            if st["pending"] == 0 or st["worker_online"]:
                return self.send_json({"sent": False})
            send_wol()
            return self.send_json({"sent": True})
        if url.path == "/api/worker/claim":
            job = claim()
            return self.send_json(job) if job else self.send(204)
        if parts[:3] == ["api", "worker", "jobs"] and len(parts) == 5 and parts[4] == "update":
            job_id = self.job_id_from(parts, 3)
            if not job_id or not update_from_worker(job_id, self.read_json()):
                return self.send(404)
            return self.send_json({})
        if url.path != "/api/jobs":
            return self.send(404)
        q = {k: v[0] for k, v in parse_qs(url.query).items()}
        length = int(self.headers.get("Content-Length", 0))
        if length <= 0:
            return self.send_json({"error": "empty upload"}, 400)
        model = q.get("model", MODELS[0])
        if model not in MODELS:
            return self.send_json({"error": "bad model"}, 400)

        job_id = uuid.uuid4().hex
        d = job_dir(job_id)
        d.mkdir()
        with open(d / "upload", "wb") as f:
            remaining = length
            while remaining:
                chunk = self.rfile.read(min(1 << 20, remaining))
                if not chunk:
                    shutil.rmtree(d, ignore_errors=True)
                    return
                f.write(chunk)
                remaining -= len(chunk)

        meta = {
            "id": job_id,
            "filename": q.get("filename", "audio"),
            "requester": user,
            "created": time.time(),
            "status": "queued",
            "stage": "In coda",
            "progress": 0,
            "model": model,
            "language": q.get("language", "it"),
            "diarize": q.get("diarize", "1") == "1",
            "speakers": int(q.get("speakers") or 0),
            "prompt": q.get("prompt", ""),
        }
        with lock:
            write_meta(meta)
        print(f"{user} uploaded job {job_id} ({meta['filename']})", flush=True)
        self.send_json(meta, 201)

    def login(self):
        data = self.read_json()
        name = str(data.get("username", "")).strip().lower()
        password = str(data.get("password", ""))
        if is_locked(name):
            return self.send_json({"error": "Troppi tentativi, riprova tra qualche minuto"}, 429)
        if not check_login(name, password):
            record_failure(name)
            return self.send_json({"error": "Credenziali non valide"}, 401)
        failures.pop(name, None)
        token = secrets.token_urlsafe(32)
        sessions[token] = (name, time.time() + SESSION_TTL)
        self.send_json({"user": name}, headers=self.cookie_header(token, SESSION_TTL))

    def do_PUT(self):
        ctx = self.begin()
        if not ctx:
            return
        _, parts, _ = ctx
        if parts[:3] == ["api", "worker", "jobs"] and len(parts) == 5 and parts[4] == "transcript":
            job_id = self.job_id_from(parts, 3)
            if not job_id:
                return self.send(404)
            d = job_dir(job_id)
            tmp = d / "transcript.txt.tmp"
            tmp.write_bytes(self.read_body())
            tmp.replace(d / "transcript.txt")
            return self.send_json({})
        self.send(404)

    def do_DELETE(self):
        ctx = self.begin()
        if not ctx:
            return
        _, parts, user = ctx
        job_id = self.job_id_from(parts, 2) if parts[:2] == ["api", "jobs"] else None
        if not job_id:
            return self.send(404)
        owner = (read_meta(job_id) or {}).get("requester")
        if owner and owner != user and user not in ADMINS:
            return self.send_json({"error": "Solo chi ha caricato il lavoro o un amministratore può annullarlo"}, 403)
        meta = read_meta(job_id) or {}
        print(f"{user} deleted job {job_id} ({meta.get('filename')}, owner {owner}, status {meta.get('status')})", flush=True)
        shutil.rmtree(job_dir(job_id), ignore_errors=True)
        self.send(204)


if __name__ == "__main__":
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
