"""Minimal static file server with HTTP Range support (video seeking + downloads).

Serves the episode renders so they can be reached through the sandbox preview URL.
Run: python tools/serve.py [port]
"""
import os
import re
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import unquote, urlparse, parse_qs

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FILES = {
    "/": ("index.html", "text/html; charset=utf-8"),
    "/episode-01.mp4": ("render/episode-01.mp4", "video/mp4"),
    "/episode-01-720p.mp4": ("render/episode-01-720p.mp4", "video/mp4"),
    "/poster.png": ("render/poster.png", "image/png"),
    "/subtitles.srt": ("render/episode-01.en.srt", "text/plain; charset=utf-8"),
}

INDEX = """<!doctype html>
<html><head><meta charset="utf-8"><title>THE SEARCH FOR TRUTH — Episode 01</title>
<meta name="viewport" content="width=device-width,initial-scale=1">
<style>
 body{margin:0;background:#05070b;color:#e8e6e0;font-family:system-ui,-apple-system,Segoe UI,sans-serif}
 .wrap{max-width:1000px;margin:0 auto;padding:32px 20px 64px}
 h1{font-family:Georgia,serif;font-weight:400;letter-spacing:.02em;margin:0 0 6px;font-size:clamp(24px,4vw,40px)}
 .kick{color:#d6b270;font-size:12px;letter-spacing:.28em;text-transform:uppercase;margin-bottom:18px}
 video{width:100%;border-radius:10px;background:#000;box-shadow:0 20px 60px rgba(0,0,0,.6)}
 .row{display:flex;flex-wrap:wrap;gap:12px;margin-top:20px}
 a.btn{flex:1 1 220px;text-align:center;padding:14px 18px;border:1px solid #2a3140;border-radius:8px;
       color:#e8e6e0;text-decoration:none;font-size:14px;background:#0b1119}
 a.btn:hover{border-color:#d6b270;color:#d6b270}
 a.primary{background:#d6b270;color:#14171d;border-color:#d6b270;font-weight:600}
 a.primary:hover{background:#e6c684;color:#14171d}
 small{display:block;color:#7d8496;margin-top:22px;line-height:1.6}
</style></head><body><div class="wrap">
 <div class="kick">A documentary series</div>
 <h1>THE SEARCH FOR TRUTH — Episode 01</h1>
 <div class="kick" style="color:#7d8496">Where did it all begin? · 6:40 · Hindi narration</div>
 <video controls playsinline poster="/poster.png" preload="metadata">
   <source src="/episode-01.mp4" type="video/mp4">
   <track kind="subtitles" srclang="en" label="English" src="/subtitles.srt" default>
 </video>
 <div class="row">
   <a class="btn primary" href="/episode-01.mp4?dl=1">Download 1080p · 90 MB</a>
   <a class="btn" href="/episode-01-720p.mp4?dl=1">Download 720p · 23 MB</a>
   <a class="btn" href="/subtitles.srt?dl=1">Subtitles (.srt)</a>
   <a class="btn" href="/poster.png?dl=1">Poster</a>
 </div>
 <small>Facts are presented as facts, beliefs as beliefs.<br>
 Image and data sources are credited at the end of the film (ESA/Planck, ESO, NASA, Wikimedia Commons).</small>
</div></body></html>
"""


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt, *args):
        sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))

    def _resolve(self):
        path = unquote(urlparse(self.path).path)
        if path == "/index.html":
            path = "/"
        return FILES.get(path)

    def _cors(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Range")
        self.send_header("Access-Control-Expose-Headers", "Content-Length, Content-Range, Accept-Ranges")

    def do_HEAD(self):
        self.do_GET(head=True)

    def do_GET(self, head=False):
        entry = self._resolve()
        if not entry:
            body = b"not found\n"
            self.send_response(404)
            self.send_header("Content-Type", "text/plain")
            self.send_header("Content-Length", str(len(body)))
            self._cors()
            self.end_headers()
            if not head:
                self.wfile.write(body)
            return

        rel, ctype = entry
        if rel == "index.html":
            body = INDEX.encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", ctype)
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store")
            self._cors()
            self.end_headers()
            if not head:
                self.wfile.write(body)
            return

        path = os.path.join(ROOT, rel)
        size = os.path.getsize(path)
        rng = self.headers.get("Range")
        download = "dl=1" in urlparse(self.path).query

        start, end = 0, size - 1
        status = 200
        if rng:
            m = re.match(r"bytes=(\d*)-(\d*)", rng.strip())
            if m:
                a, b = m.group(1), m.group(2)
                if a:
                    start = int(a)
                    end = int(b) if b else size - 1
                elif b:  # suffix range
                    start = max(0, size - int(b))
                    end = size - 1
                if start >= size:
                    self.send_response(416)
                    self.send_header("Content-Range", f"bytes */{size}")
                    self.send_header("Content-Length", "0")
                    self._cors()
                    self.end_headers()
                    return
                end = min(end, size - 1)
                status = 206

        length = end - start + 1
        self.send_response(status)
        self.send_header("Content-Type", ctype)
        self.send_header("Accept-Ranges", "bytes")
        self.send_header("Content-Length", str(length))
        if status == 206:
            self.send_header("Content-Range", f"bytes {start}-{end}/{size}")
        if download:
            self.send_header("Content-Disposition",
                             f'attachment; filename="{os.path.basename(rel)}"')
        else:
            self.send_header("Cache-Control", "public, max-age=3600")
        self._cors()
        self.end_headers()
        if head:
            return

        with open(path, "rb") as f:
            f.seek(start)
            remaining = length
            while remaining > 0:
                chunk = f.read(min(262144, remaining))
                if not chunk:
                    break
                try:
                    self.wfile.write(chunk)
                except (BrokenPipeError, ConnectionResetError):
                    return
                remaining -= len(chunk)


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
    srv = ThreadingHTTPServer(("0.0.0.0", port), Handler)
    print(f"serving {ROOT} on 0.0.0.0:{port}", flush=True)
    srv.serve_forever()


if __name__ == "__main__":
    main()
