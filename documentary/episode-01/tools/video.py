"""Video renderer.

Each timeline segment is rendered as its own H.264 clip with baked camera
motion (zoompan), caption typography and a filmic finish. Segments are then
joined (concat demuxer, stream copy) and muxed with the final mix.

Run:
  python tools/video.py                 # render every segment
  python tools/video.py --only name ...  # render selected segments
  python tools/video.py --assemble       # join + mux -> render/episode-01.mp4
"""
import json
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import plan  # noqa: E402

ROOT = plan.ROOT
SHOTS = plan.SHOTS
BUILD = plan.BUILD
RENDER = plan.RENDER
os.makedirs(RENDER, exist_ok=True)
os.makedirs(BUILD, exist_ok=True)

FONT_B = "/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf"
FONT_S = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"

FF = None


def ffmpeg():
    global FF
    if FF is None:
        import imageio_ffmpeg
        FF = imageio_ffmpeg.get_ffmpeg_exe()
    return FF


def shot_path(name):
    return os.path.join(SHOTS, name + ".png")


def esc(p):
    return p.replace("\\", "/").replace(":", "\\:").replace("'", "")


def wrap(text, max_chars):
    words, lines, cur = text.split(), [], ""
    for w in words:
        if len(cur) + len(w) + 1 > max_chars:
            lines.append(cur)
            cur = w
        else:
            cur = (cur + " " + w).strip()
    if cur:
        lines.append(cur)
    return lines


def resolve_captions(sc):
    """Snap each caption fully inside a single shot so nothing gets cut off.

    Returns captions as absolute-time dicts: start, dur, kicker, sub.
    """
    shots = sc["shots"]
    shot_dur = sc["dur"] / len(shots)
    out = []
    for (off, dur, kicker, sub) in sc["captions"]:
        want0 = off
        want1 = off + dur
        best = None
        for k in range(len(shots)):
            a, b = k * shot_dur, (k + 1) * shot_dur
            overlap = min(want1, b) - max(want0, a)
            if overlap <= 0:
                continue
            if best is None or overlap > best[0]:
                best = (overlap, k)
        if best is None:
            continue
        k = best[1]
        a, b = k * shot_dur, (k + 1) * shot_dur
        room = shot_dur - 0.5           # keep a little air at both ends
        start = min(max(want0, a + 0.25), b - 0.25 - min(dur, room))
        out.append(dict(start=start, dur=min(dur, room), kicker=kicker, sub=sub,
                        shot=k))
    return out


def caption_filters(caption, scene_start_abs, shot_start_abs, shot_dur):
    """drawtext chain for one caption, visible only inside this shot."""
    start_off, dur, kicker, sub = (caption["start"], caption["dur"],
                                   caption["kicker"], caption["sub"])
    cap_abs0 = scene_start_abs + start_off
    cap_abs1 = cap_abs0 + dur
    lo = max(cap_abs0, shot_start_abs)
    hi = min(cap_abs1, shot_start_abs + shot_dur)
    if hi - lo < 0.8:
        return None
    t0 = lo - shot_start_abs
    t1 = hi - shot_start_abs
    fade = 0.9
    alpha = (f"if(lt(t,{t0:.2f}),0,"
             f"if(lt(t,{t0 + fade:.2f}),(t-{t0:.2f})/{fade},"
             f"if(lt(t,{t1 - fade:.2f}),1,"
             f"if(lt(t,{t1:.2f}),({t1:.2f}-t)/{fade},0))))")
    step = 0.18
    alpha2 = (f"if(lt(t,{t0 + step:.2f}),0,"
              f"if(lt(t,{t0 + step + fade:.2f}),(t-{t0 + step:.2f})/{fade},"
              f"if(lt(t,{t1 - fade:.2f}),1,"
              f"if(lt(t,{t1:.2f}),({t1:.2f}-t)/{fade},0))))")
    alpha3 = (f"if(lt(t,{t0 + 2 * step:.2f}),0,"
              f"if(lt(t,{t0 + 2 * step + fade:.2f}),(t-{t0 + 2 * step:.2f})/{fade},"
              f"if(lt(t,{t1 - fade:.2f}),1,"
              f"if(lt(t,{t1:.2f}),({t1:.2f}-t)/{fade},0))))")
    filters = []
    y0 = plan.H - 268
    shadow = "shadowcolor=black@0.9:shadowx=2:shadowy=2"
    if sub:
        filters.append(
            f"drawtext=fontfile={FONT_S}:text='{esc(kicker)}':fontcolor=0xD6B270@0.95:"
            f"fontsize=24:x=(w-text_w)/2:y={y0}:alpha='{alpha}':{shadow}")
        filters.append(
            f"drawbox=x=(iw-150)/2:y={y0 + 42}:w=150:h=2:color=0xD6B270@0.5:t=fill:"
            f"enable='between(t,{t0:.2f},{t1:.2f})'")
        for i, line in enumerate(wrap(sub.upper(), 60)):
            filters.append(
                f"drawtext=fontfile={FONT_S}:text='{esc(line)}':fontcolor=white@0.93:"
                f"fontsize=33:x=(w-text_w)/2:y={y0 + 74 + i * 46}:"
                f"alpha='{(alpha2 if i == 0 else alpha3)}':{shadow}")
    else:
        for i, line in enumerate(wrap(kicker, 50)):
            filters.append(
                f"drawtext=fontfile={FONT_B}:text='{esc(line)}':fontcolor=0xEDE7DA@0.92:"
                f"fontsize=41:x=(w-text_w)/2:y={y0 + 34 + i * 52}:"
                f"alpha='{(alpha2 if i == 0 else alpha3)}':{shadow}")
    return ",".join(filters)


def motion_filter(kind, frames):
    """Slow deliberate camera moves over the 2400x1350 plates."""
    d = max(1, frames)
    cx = "iw/2-(iw/zoom/2)"
    cy = "ih/2-(ih/zoom/2)"
    if kind == "in":
        z, x, y = f"1.0+0.11*on/{d}", cx, cy
    elif kind == "out":
        z, x, y = f"1.11-0.11*on/{d}", cx, cy
    elif kind == "left":
        z, x, y = "1.07", f"(iw-iw/zoom)*0.5*(0.85-0.70*on/{d})", cy
    elif kind == "right":
        z, x, y = "1.07", f"(iw-iw/zoom)*0.5*(0.15+0.70*on/{d})", cy
    elif kind == "drift-up":
        z, x, y = "1.08", cx, f"(ih-ih/zoom)*0.5*(0.88-0.55*on/{d})"
    else:  # slow — title / end cards
        z, x, y = f"1.0+0.035*on/{d}", cx, cy
    return (f"zoompan=z='{z}':x='{x}':y='{y}':d=1:s={plan.W}x{plan.H}:fps={plan.FPS}")


GRADE = ("eq=contrast=1.06:brightness=0.004:saturation=1.04:gamma=0.995,"
         "colorbalance=rs=-0.015:bs=0.025,"
         "vignette=angle=PI/5.4,"
         "noise=alls=5:allf=t+u")


def render_segment(item, crf=20, preset="veryfast"):
    out = os.path.join(RENDER, item["name"] + ".mp4")
    dur = item["dur"]
    frames = int(round(dur * plan.FPS))

    caps = []
    for cap in item["caps"]:
        f = caption_filters(cap, item["scene_start"], item["start"], dur)
        if f:
            caps.append(f)

    inputs = ["-loop", "1", "-framerate", str(plan.FPS), "-t", f"{dur:.3f}",
              "-i", item["plate"]]
    base = (f"[0:v]scale=2400:1350:flags=lanczos,"
            f"{motion_filter(item['motion'], frames)},{GRADE}")

    if caps:
        inputs += ["-loop", "1", "-framerate", str(plan.FPS), "-t", f"{dur:.3f}",
                   "-i", shot_path("scrim")]
        chain = (f"{base}[vs];"
                 f"[1:v]scale={plan.W}:{plan.H}[sc];"
                 f"[vs][sc]overlay=0:0[vbg];"
                 f"[vbg]{','.join(caps)}[vcap];"
                 f"[vcap]format=yuv420p[vpre]")
    else:
        chain = f"{base},format=yuv420p[vpre]"

    fades = ""
    if item.get("fade_in"):
        fades += f",fade=t=in:st=0:d={item['fade_in']:.2f}:color=black"
    if item.get("fade_out"):
        fades += (f",fade=t=out:st={max(0.0, dur - item['fade_out']):.2f}:"
                  f"d={item['fade_out']:.2f}:color=black")
    chain += f";[vpre]null{fades}[vout]"

    cmd = [ffmpeg(), "-y", "-hide_banner", "-loglevel", "error"] + inputs + [
           "-filter_complex", chain, "-map", "[vout]",
           "-r", str(plan.FPS), "-c:v", "libx264", "-preset", preset,
           "-crf", str(crf), "-pix_fmt", "yuv420p", "-an", out]
    subprocess.run(cmd, check=True)
    return out


MOTIONS = ["in", "out", "left", "right", "drift-up"]


def plan_segments():
    segs, total = plan.timeline()
    items = []

    items.append(dict(name="seg-000-coldopen", plate=shot_path("proc-stars"),
                      dur=segs[0]["dur"], motion="in", caps=[],
                      start=0.0, scene_start=0.0, fade_in=1.5))

    for seg in segs:
        kind, start, dur = seg["kind"], seg["start"], seg["dur"]
        if kind == "scene":
            sc = seg["scene"]
            shots = sc["shots"]
            shot_dur = dur / len(shots)
            scene_ctx = dict(sc, dur=dur)
            resolved = resolve_captions(scene_ctx)
            for i, s in enumerate(shots):
                mine = [dict(start=c["start"], dur=c["dur"], kicker=c["kicker"],
                         sub=c["sub"]) for c in resolved if c["shot"] == i]
                items.append(dict(
                    name=f"seg-{sc['id']}-{i}",
                    plate=shot_path(s), dur=shot_dur,
                    motion=MOTIONS[(abs(hash(sc["id"] + str(i))) + i) % len(MOTIONS)],
                    caps=mine, start=start + i * shot_dur,
                    scene_start=start,
                    fade_in=1.4 if i == 0 else 0.0,
                    fade_out=1.2 if i == len(shots) - 1 else 0.0))
        elif kind == "title":
            items.append(dict(name="seg-title", plate=shot_path("card-title"), dur=dur,
                              motion="slow", caps=[], start=start, scene_start=start,
                              fade_in=1.2, fade_out=1.2))
        elif kind == "endcard":
            items.append(dict(name="seg-end", plate=shot_path("card-end"), dur=dur,
                              motion="slow", caps=[], start=start, scene_start=start,
                              fade_in=1.5, fade_out=3.0))
        elif kind == "credits":
            items.append(dict(name="seg-credits", plate=shot_path("card-credits"),
                              dur=dur, motion="slow", caps=[], start=start,
                              scene_start=start, fade_in=2.0, fade_out=2.5))
    return items, total


def assemble():
    items, total = plan_segments()
    missing = [i["name"] for i in items
               if not os.path.exists(os.path.join(RENDER, i["name"] + ".mp4"))]
    if missing:
        print("missing segments:", missing)
        return 1
    lst = os.path.join(BUILD, "concat.txt")
    with open(lst, "w") as f:
        for it in items:
            f.write(f"file '{os.path.join(RENDER, it['name'] + '.mp4')}'\n")

    video = os.path.join(BUILD, "picture.mp4")
    subprocess.run([ffmpeg(), "-y", "-hide_banner", "-loglevel", "error",
                    "-f", "concat", "-safe", "0", "-i", lst,
                    "-c", "copy", "-movflags", "+faststart", video], check=True)

    mix = os.path.join(BUILD, "mix.wav")
    final = os.path.join(RENDER, "episode-01.mp4")
    subprocess.run([ffmpeg(), "-y", "-hide_banner", "-loglevel", "error",
                    "-i", video, "-i", mix,
                    "-map", "0:v:0", "-map", "1:a:0",
                    "-c:v", "copy", "-c:a", "aac", "-b:a", "192k", "-ar", "48000",
                    "-shortest", "-movflags", "+faststart", final], check=True)

    srt = os.path.join(RENDER, "episode-01.en.srt")
    write_srt(items, srt)
    print("wrote", final, srt)
    return 0


def write_srt(items, path):
    """English subtitle track from the caption cards."""
    def ts(t):
        h = int(t // 3600); m = int((t % 3600) // 60); s = t % 60
        return f"{h:02d}:{m:02d}:{s:06.3f}".replace(".", ",")

    idx, out = 1, []
    for it in items:
        for cap in it["caps"]:
            a = it["scene_start"] + cap["start"] + 0.3
            b = a + cap["dur"] - 0.6
            text = (cap["kicker"] + ("\n" + cap["sub"] if cap["sub"] else "")).strip()
            out.append(f"{idx}\n{ts(a)} --> {ts(b)}\n{text}\n")
            idx += 1
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(out))


def main():
    if "--assemble" in sys.argv:
        sys.exit(assemble())
    items, total = plan_segments()
    only = None
    if "--only" in sys.argv:
        only = sys.argv[sys.argv.index("--only") + 1:]
        items = [i for i in items if any(o in i["name"] for o in only)]
    print(f"{len(items)} segments, timeline {total:.1f}s")
    for i, it in enumerate(items):
        render_segment(it)
        print(f"[{i + 1}/{len(items)}] {it['name']} {it['dur']:.2f}s", flush=True)
    with open(os.path.join(BUILD, "segments.json"), "w") as f:
        json.dump(items, f, indent=1)
    print("done")


if __name__ == "__main__":
    main()
