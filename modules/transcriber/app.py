import json
import os
import queue
import re
import shutil
import subprocess
import threading
import time
import uuid
import wave
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, quote, urlparse

import numpy as np

HOST = os.environ.get("HOST", "127.0.0.1")
PORT = int(os.environ.get("PORT", "8086"))
DATA = Path(os.environ["DATA_DIR"])
JOBS = DATA / "jobs"
INDEX = Path(__file__).with_name("index.html")
THREADS = int(os.environ.get("DIARIZATION_THREADS", "16"))
SEG_MODEL = os.environ["SEGMENTATION_MODEL"]
EMB_MODEL = os.environ["EMBEDDING_MODEL"]
CLUSTER_THRESHOLD = float(os.environ.get("CLUSTER_THRESHOLD", "0.8"))
MODELS = json.loads(os.environ["WHISPER_MODELS"])
WHISPER_CLI = os.environ["WHISPER_CLI"]
VAD_MODEL = os.environ["VAD_MODEL"]
ID_RE = re.compile(r"^[0-9a-f]{32}$")
SAMPLE_RATE = 16000
GRID = 0.1  # seconds per diarization timeline cell
PAUSE_PARAGRAPH = 2.5
MAX_PARAGRAPH_CHARS = 700

JOBS.mkdir(parents=True, exist_ok=True)
queue_ = queue.Queue()
lock = threading.Lock()
cancelled = set()


class Cancelled(Exception):
    pass


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


def update(job_id, **fields):
    with lock:
        meta = read_meta(job_id)
        if meta is None:
            return
        meta.update(fields)
        write_meta(meta)


def check_cancel(job_id):
    if job_id in cancelled:
        raise Cancelled()


def fmt_ts(seconds):
    s = int(seconds)
    return f"{s // 3600:02d}:{s % 3600 // 60:02d}:{s % 60:02d}"


def convert(job_id):
    d = job_dir(job_id)
    wav = d / "audio.wav"
    subprocess.run(
        ["ffmpeg", "-nostdin", "-v", "error", "-y", "-i", str(d / "upload"),
         "-vn", "-ac", "1", "-ar", str(SAMPLE_RATE), "-c:a", "pcm_s16le", str(wav)],
        check=True, capture_output=True,
    )
    with wave.open(str(wav)) as w:
        pcm = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16)
    return wav, pcm.astype(np.float32) / 32768.0


def diarize(job_id, audio, num_speakers, state):
    import sherpa_onnx

    config = sherpa_onnx.OfflineSpeakerDiarizationConfig(
        segmentation=sherpa_onnx.OfflineSpeakerSegmentationModelConfig(
            pyannote=sherpa_onnx.OfflineSpeakerSegmentationPyannoteModelConfig(model=SEG_MODEL),
            num_threads=THREADS,
        ),
        embedding=sherpa_onnx.SpeakerEmbeddingExtractorConfig(model=EMB_MODEL, num_threads=THREADS),
        clustering=sherpa_onnx.FastClusteringConfig(num_clusters=num_speakers, threshold=CLUSTER_THRESHOLD),
        min_duration_on=0.3,
        min_duration_off=0.5,
    )
    sd = sherpa_onnx.OfflineSpeakerDiarization(config)

    def progress(done, total):
        if job_id in cancelled:
            return 1
        state["progress"] = done / max(total, 1)
        return 0

    result = sd.process(audio, callback=progress).sort_by_start_time()
    check_cancel(job_id)
    return [(s.start, s.end, s.speaker) for s in result]


def speaker_timeline(segments, duration):
    n = int(duration / GRID) + 2
    line = np.full(n, -1, dtype=np.int32)
    for start, end, spk in segments:
        line[int(start / GRID):int(end / GRID) + 1] = spk
    if (line >= 0).any():
        idx = np.where(line >= 0, np.arange(n), -1)
        fwd = np.maximum.accumulate(idx)
        idx_b = np.where(line >= 0, np.arange(n), n * 2)
        bwd = np.minimum.accumulate(idx_b[::-1])[::-1]
        pick = np.where(
            (fwd >= 0) & ((bwd >= n) | (np.arange(n) - fwd <= bwd - np.arange(n))),
            fwd, np.minimum(bwd, n - 1),
        )
        line = line[pick]
    return line


def transcribe(job_id, wav, meta, on_progress):
    d = job_dir(job_id)
    cmd = [
        WHISPER_CLI, "-m", MODELS[meta["model"]], "-f", str(wav),
        "-l", meta["language"] or "auto", "-t", "4",
        "-ml", "1", "-sow", "-pp",
        "--vad", "--vad-model", VAD_MODEL,
        "-ojf", "-of", str(d / "whisper"),
    ]
    if meta["prompt"]:
        cmd += ["--prompt", meta["prompt"]]
    proc = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, text=True)
    tail = []
    for line in proc.stderr:
        if job_id in cancelled:
            proc.kill()
            raise Cancelled()
        m = re.search(r"progress =\s*(\d+)%", line)
        if m:
            on_progress(int(m.group(1)) / 100)
        else:
            tail = (tail + [line])[-5:]
    if proc.wait() != 0:
        raise RuntimeError("whisper-cli: " + "".join(tail)[-500:])

    data = json.loads((d / "whisper.json").read_text())
    return [
        (t["offsets"]["from"] / 1000, t["offsets"]["to"] / 1000, t["text"])
        for t in data["transcription"]
        if t["text"].strip() and not t["text"].lstrip().startswith("[")
    ]


def build_turns(words, timeline):
    turns = []  # [speaker, [(start, end, text), ...]]
    for start, end, text in words:
        if timeline is None:
            spk = 0
        else:
            spk = int(timeline[min(int(((start + end) / 2) / GRID), len(timeline) - 1)])
            if turns:
                _, prev_end, prev_text = turns[-1][1][-1]
                at_boundary = prev_text.rstrip().endswith((".", "?", "!")) or start - prev_end > 0.5
                if spk != turns[-1][0] and not at_boundary:
                    spk = turns[-1][0]
        if turns and turns[-1][0] == spk:
            turns[-1][1].append((start, end, text))
        else:
            turns.append([spk, [(start, end, text)]])

    # absorb tiny interjections sandwiched between two turns of the same speaker
    merged = []
    i = 0
    while i < len(turns):
        t = turns[i]
        if (
            0 < i < len(turns) - 1
            and len(t[1]) < 3
            and turns[i - 1][0] == turns[i + 1][0]
        ):
            turns[i + 1][1][:0] = t[1]
            turns[i + 1][0] = turns[i - 1][0]
            i += 1
            continue
        if merged and merged[-1][0] == t[0]:
            merged[-1][1].extend(t[1])
        else:
            merged.append(t)
        i += 1
    return merged


def paragraphs(turn_words):
    out, cur, cur_start, last_end = [], [], None, None
    for start, end, text in turn_words:
        long_pause = last_end is not None and start - last_end > PAUSE_PARAGRAPH
        size = sum(len(t) for _, _, t in cur)
        too_long = (size > MAX_PARAGRAPH_CHARS and cur[-1][2].rstrip().endswith((".", "?", "!"))) or (
            size > 1.5 * MAX_PARAGRAPH_CHARS and last_end is not None and start - last_end > 0.4
        )
        if cur and (long_pause or too_long):
            out.append((cur_start, "".join(t for _, _, t in cur).strip()))
            cur = []
        if not cur:
            cur_start = start
        cur.append((start, end, text))
        last_end = end
    if cur:
        out.append((cur_start, "".join(t for _, _, t in cur).strip()))
    return out


def render(meta, words, timeline, duration):
    turns = build_turns(words, timeline)
    order = {}
    for spk, _ in turns:
        order.setdefault(spk, len(order) + 1)
    header = [f"Trascrizione: {meta['filename']}", f"Durata: {fmt_ts(duration)}"]
    if timeline is not None:
        header.append(f"Parlanti: {len(order)}")
    header.append(f"Modello: {meta['model']}")
    lines = [" · ".join(header), ""]
    for spk, turn_words in turns:
        for n, (start, text) in enumerate(paragraphs(turn_words)):
            if timeline is not None and n == 0:
                lines.append(f"[{fmt_ts(start)}] Parlante {order[spk]}")
            elif timeline is None:
                lines.append(f"[{fmt_ts(start)}]")
            lines += [text, ""]
    return "\n".join(lines)


def process(job_id):
    meta = read_meta(job_id)
    d = job_dir(job_id)
    t0 = time.time()
    update(job_id, status="converting", stage="Conversione audio", progress=0, started=t0)
    wav, audio = convert(job_id)
    duration = len(audio) / SAMPLE_RATE
    check_cancel(job_id)
    update(job_id, status="transcribing", stage="Trascrizione", progress=0, duration=duration)

    # speaker recognition runs on the CPU while whisper.cpp uses the GPU
    diar = {}
    diar_thread = None
    if meta["diarize"]:
        def run_diarization():
            try:
                diar["segments"] = diarize(job_id, audio, meta["speakers"] or -1, diar)
            except Exception as e:
                diar["error"] = e

        diar_thread = threading.Thread(target=run_diarization)
        diar_thread.start()

    words = transcribe(job_id, wav, meta, lambda p: update(job_id, progress=p))

    if diar_thread:
        update(job_id, status="diarizing", stage="Riconoscimento parlanti")
        while diar_thread.is_alive():
            update(job_id, progress=diar.get("progress", 0))
            diar_thread.join(1)
        check_cancel(job_id)
        if "error" in diar:
            raise diar["error"]
        timeline = speaker_timeline(diar["segments"], duration)
    else:
        timeline = None

    (d / "transcript.txt").write_text(render(meta, words, timeline, duration))
    update(job_id, status="done", stage="Completato", progress=1, finished=time.time())


def worker():
    while True:
        job_id = queue_.get()
        meta = read_meta(job_id)
        if meta is None or job_id in cancelled:
            continue
        try:
            process(job_id)
        except Cancelled:
            pass
        except subprocess.CalledProcessError as e:
            update(job_id, status="error", stage="Errore", error="ffmpeg: " + e.stderr.decode(errors="replace")[-500:])
        except Exception as e:
            update(job_id, status="error", stage="Errore", error=f"{type(e).__name__}: {e}")
        finally:
            (job_dir(job_id) / "audio.wav").unlink(missing_ok=True)


def recover():
    jobs = sorted(
        (m for m in (read_meta(p.name) for p in JOBS.iterdir() if ID_RE.match(p.name)) if m),
        key=lambda m: m["created"],
    )
    for m in jobs:
        if m["status"] not in ("done", "error"):
            update(m["id"], status="queued", stage="In coda", progress=0)
            queue_.put(m["id"])


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

    def send_json(self, obj, code=200):
        self.send(code, json.dumps(obj).encode())

    def job_id_from(self, parts):
        if len(parts) >= 3 and ID_RE.match(parts[2]) and job_dir(parts[2]).is_dir():
            return parts[2]
        return None

    def do_GET(self):
        url = urlparse(self.path)
        parts = url.path.strip("/").split("/")
        if url.path == "/":
            return self.send(200, INDEX.read_bytes(), "text/html; charset=utf-8")
        if url.path == "/api/config":
            return self.send_json({"models": list(MODELS)})
        if url.path == "/api/jobs":
            metas = [m for m in (read_meta(p.name) for p in JOBS.iterdir() if ID_RE.match(p.name)) if m]
            return self.send_json(sorted(metas, key=lambda m: m["created"], reverse=True))
        if parts[:2] == ["api", "jobs"]:
            job_id = self.job_id_from(parts)
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
        self.send(404)

    def do_POST(self):
        url = urlparse(self.path)
        if url.path != "/api/jobs":
            return self.send(404)
        q = {k: v[0] for k, v in parse_qs(url.query).items()}
        length = int(self.headers.get("Content-Length", 0))
        if length <= 0:
            return self.send_json({"error": "empty upload"}, 400)
        model = q.get("model", next(iter(MODELS)))
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
        queue_.put(job_id)
        self.send_json(meta, 201)

    def do_DELETE(self):
        parts = urlparse(self.path).path.strip("/").split("/")
        job_id = self.job_id_from(parts) if parts[:2] == ["api", "jobs"] else None
        if not job_id:
            return self.send(404)
        cancelled.add(job_id)
        shutil.rmtree(job_dir(job_id), ignore_errors=True)
        self.send(204)


if __name__ == "__main__":
    recover()
    threading.Thread(target=worker, daemon=True).start()
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
