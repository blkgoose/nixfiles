import json
import os
import re
import shutil
import socket
import subprocess
import sys
import threading
import time
import urllib.error
import urllib.request
import wave
from pathlib import Path
from urllib.parse import quote

import numpy as np

SERVER = os.environ["SERVER_URL"].rstrip("/")
WORK = Path(os.environ["WORK_DIR"])
POLL_SECONDS = int(os.environ.get("POLL_SECONDS", "10"))
THREADS = int(os.environ.get("DIARIZATION_THREADS", "16"))
SEG_MODEL = os.environ["SEGMENTATION_MODEL"]
EMB_MODEL = os.environ["EMBEDDING_MODEL"]
CLUSTER_THRESHOLD = float(os.environ.get("CLUSTER_THRESHOLD", "0.8"))
MODELS = json.loads(os.environ["WHISPER_MODELS"])
WHISPER_CLI = os.environ["WHISPER_CLI"]
VAD_MODEL = os.environ["VAD_MODEL"]
SAMPLE_RATE = 16000
GRID = 0.1  # seconds per diarization timeline cell
PAUSE_PARAGRAPH = 2.5
MAX_PARAGRAPH_CHARS = 700

cancelled = set()
last_progress_sent = {}


class Cancelled(Exception):
    pass


def api(method, path, body=None, ctype=None):
    headers = {"Content-Type": ctype} if ctype else {}
    req = urllib.request.Request(SERVER + path, data=body, method=method, headers=headers)
    return urllib.request.urlopen(req, timeout=60)


def claim():
    with api("POST", "/api/worker/claim?worker=" + quote(socket.gethostname())) as r:
        return None if r.status == 204 else json.load(r)


def update(job_id, **fields):
    now = time.time()
    if set(fields) == {"progress"}:
        if now - last_progress_sent.get(job_id, 0) < 2:
            return
        last_progress_sent[job_id] = now
    try:
        api("POST", f"/api/worker/jobs/{job_id}/update", json.dumps(fields).encode(), "application/json").close()
    except urllib.error.HTTPError as e:
        if e.code == 404:
            cancelled.add(job_id)
    except OSError:
        pass


def download(job_id, dest):
    with api("GET", f"/api/worker/jobs/{job_id}/upload") as r, open(dest, "wb") as f:
        shutil.copyfileobj(r, f, 1 << 20)


def upload_transcript(job_id, text):
    for _ in range(10):
        try:
            api("PUT", f"/api/worker/jobs/{job_id}/transcript", text.encode(), "text/plain; charset=utf-8").close()
            return
        except urllib.error.HTTPError as e:
            if e.code == 404:
                raise Cancelled()
            raise
        except OSError:
            time.sleep(30)
    raise RuntimeError("transcript upload failed")


procs = {}


def spawn(job_id, cmd, **kwargs):
    proc = subprocess.Popen(cmd, **kwargs)
    procs.setdefault(job_id, set()).add(proc)
    return proc


def watch_cancel(job_id, stop):
    while not stop.wait(3):
        update(job_id)
        if job_id in cancelled:
            for proc in list(procs.get(job_id, ())):
                proc.kill()
            return


def check_cancel(job_id):
    if job_id in cancelled:
        raise Cancelled()


def fmt_ts(seconds):
    s = int(seconds)
    return f"{s // 3600:02d}:{s % 3600 // 60:02d}:{s % 60:02d}"


def convert(job_id, d):
    wav = d / "audio.wav"
    proc = spawn(
        job_id,
        ["ffmpeg", "-nostdin", "-v", "error", "-y", "-i", str(d / "upload"),
         "-vn", "-ac", "1", "-ar", str(SAMPLE_RATE), "-c:a", "pcm_s16le", str(wav)],
        stdout=subprocess.DEVNULL, stderr=subprocess.PIPE,
    )
    _, err = proc.communicate()
    check_cancel(job_id)
    if proc.returncode != 0:
        raise subprocess.CalledProcessError(proc.returncode, "ffmpeg", stderr=err)
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


def transcribe(job_id, d, wav, meta, on_progress):
    cmd = [
        WHISPER_CLI, "-m", MODELS[meta["model"]], "-f", str(wav),
        "-l", meta["language"] or "auto", "-t", "4",
        "-ml", "1", "-sow", "-pp",
        "--vad", "--vad-model", VAD_MODEL,
        "-ojf", "-of", str(d / "whisper"),
    ]
    if meta["prompt"]:
        cmd += ["--prompt", meta["prompt"]]
    proc = spawn(job_id, cmd, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, text=True)
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
    code = proc.wait()
    check_cancel(job_id)
    if code != 0:
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


def process(meta, d):
    job_id = meta["id"]
    update(job_id, status="converting", stage="Conversione audio", progress=0)
    wav, audio = convert(job_id, d)
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

    try:
        words = transcribe(job_id, d, wav, meta, lambda p: update(job_id, progress=p))

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
    except BaseException:
        if diar_thread:
            cancelled.add(job_id)
            diar_thread.join()
        raise

    upload_transcript(job_id, render(meta, words, timeline, duration))
    update(job_id, status="done", stage="Completato", progress=1)


def inhibit_sleep():
    proc = subprocess.Popen(
        ["systemd-inhibit", "--what=idle:sleep", "--who=transcriber", "--why=Transcribing",
         "--mode=block", "sleep", "infinity"]
    )
    time.sleep(0.5)
    if proc.poll() is not None:
        print("systemd-inhibit failed, the machine may suspend mid-job", file=sys.stderr, flush=True)
    return proc


def run(meta):
    job_id = meta["id"]
    d = WORK / job_id
    d.mkdir(parents=True, exist_ok=True)
    inhibitor = inhibit_sleep()
    stop = threading.Event()
    watcher = threading.Thread(target=watch_cancel, args=(job_id, stop), daemon=True)
    watcher.start()
    try:
        download(job_id, d / "upload")
        process(meta, d)
    except Cancelled:
        pass
    except subprocess.CalledProcessError as e:
        update(job_id, status="error", stage="Errore", error="ffmpeg: " + e.stderr.decode(errors="replace")[-500:])
    except Exception as e:
        update(job_id, status="error", stage="Errore", error=f"{type(e).__name__}: {e}")
    finally:
        stop.set()
        watcher.join()
        inhibitor.terminate()
        shutil.rmtree(d, ignore_errors=True)
        procs.pop(job_id, None)
        cancelled.discard(job_id)
        last_progress_sent.pop(job_id, None)


if __name__ == "__main__":
    shutil.rmtree(WORK, ignore_errors=True)
    WORK.mkdir(parents=True)
    while True:
        try:
            job = claim()
        except OSError:
            job = None
        if job:
            run(job)
        else:
            time.sleep(POLL_SECONDS)
