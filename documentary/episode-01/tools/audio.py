"""Audio pipeline: decode narration, compose an original ambient score,
place sound design, duck music under voice, produce the final mix.

Run: python tools/audio.py
Outputs: build/narration_times.json, build/narration.wav, build/score.wav, build/mix.wav
"""
import json
import os
import subprocess
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import plan  # noqa: E402

SR = plan.SR
ROOT = plan.ROOT
BUILD = plan.BUILD
os.makedirs(BUILD, exist_ok=True)

FF = None


def ffmpeg():
    global FF
    if FF is None:
        import imageio_ffmpeg
        FF = imageio_ffmpeg.get_ffmpeg_exe()
    return FF


def wav_dur(path):
    out = subprocess.run([ffmpeg(), "-i", path, "-f", "null", "-"],
                         capture_output=True, text=True).stderr
    for tok in reversed(out.replace("\r", "\n").split("\n")):
        if "time=" in tok:
            t = tok.split("time=")[1].split()[0]
            h, m, s = t.split(":")
            return int(h) * 3600 + int(m) * 60 + float(s)
    return 0.0


def decode_narration():
    """mp3 -> 48k mono float wav, return dict name -> (path, duration)."""
    out = {}
    for sc in plan.SCENES:
        name = sc["narration"]
        src = os.path.join(plan.NARR, name + ".mp3")
        dst = os.path.join(BUILD, "narr_" + name + ".wav")
        subprocess.run([ffmpeg(), "-y", "-hide_banner", "-loglevel", "error",
                        "-i", src, "-ac", "1", "-ar", str(SR),
                        "-af", "highpass=f=70,lowpass=f=14000", dst], check=True)
        out[name] = (dst, wav_dur(dst))
    with open(os.path.join(BUILD, "narration_times.json"), "w") as f:
        json.dump({k: v[1] for k, v in out.items()}, f, indent=1)
    return out


def read_wav(path):
    import wave
    with wave.open(path, "rb") as w:
        n = w.getnframes()
        data = np.frombuffer(w.readframes(n), dtype=np.int16).astype(np.float32) / 32768.0
        if w.getnchannels() == 2:
            data = data.reshape(-1, 2).mean(axis=1)
    return data


def write_wav(path, stereo):
    import wave
    stereo = np.clip(stereo, -1.0, 1.0)
    pcm = (stereo * 32767.0).astype(np.int16)
    with wave.open(path, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())


# ------------------------------------------------------------------ score ---
def env_adsr(n, a, d, s_level, r, total=None):
    a_n = max(1, int(a * SR))
    d_n = max(1, int(d * SR))
    r_n = max(1, int(r * SR))
    total = total or n
    e = np.ones(total, dtype=np.float32) * s_level
    e[:min(a_n, total)] = np.linspace(0, s_level, min(a_n, total))
    if a_n < total:
        seg = min(d_n, total - a_n)
        e[a_n:a_n + seg] = np.linspace(s_level, s_level, seg)  # flat body
    if r_n < total:
        e[-r_n:] *= np.linspace(1, 0, r_n)
    return e[:n]


def tone(freq, n, harmonics=(1.0, 0.35, 0.18, 0.09), detune=0.0, vib=0.0):
    t = np.arange(n, dtype=np.float32) / SR
    ph = 2 * np.pi * freq * t
    if vib:
        ph = ph + vib * np.sin(2 * np.pi * 0.18 * t)
    out = np.zeros(n, dtype=np.float32)
    for i, amp in enumerate(harmonics, start=1):
        f = freq * i
        if f > SR / 2 * 0.94:
            break
        out += amp * np.sin(ph * i + i * 0.7)
    if detune:
        out += 0.5 * np.sin(ph * (1 + detune))
    return out / (sum(harmonics) + 1.0)


def lowpass(x, cutoff, order=2):
    from scipy.signal import butter, sosfilt
    sos = butter(order, cutoff / (SR / 2), btype="low", output="sos")
    return sosfilt(sos, x).astype(np.float32)


def highpass(x, cutoff, order=2):
    from scipy.signal import butter, sosfilt
    sos = butter(order, cutoff / (SR / 2), btype="high", output="sos")
    return sosfilt(sos, x).astype(np.float32)


def space(x, depth=0.35):
    """Cheap large-room: a few filtered feedback delays."""
    out = x.copy()
    for delay_ms, gain in ((63, 0.34), (97, 0.28), (141, 0.22), (211, 0.16)):
        d = int(delay_ms * SR / 1000)
        tail = np.zeros_like(x)
        tail[d:] = x[:-d]
        out += lowpass(tail, 3200) * gain * depth
    return out


CHORDS = {
    "Dm": [146.83, 174.61, 220.00, 293.66],
    "Bb": [116.54, 146.83, 174.61, 233.08],
    "F":  [174.61, 220.00, 261.63, 349.23],
    "C":  [130.81, 196.00, 261.63, 329.63],
    "Gm": [98.00, 146.83, 196.00, 233.08],
    "Am": [110.00, 164.81, 220.00, 261.63],
}

# per-scene chord bed (kept consonant, slowly moving = documentary tension)
SCENE_CHORDS = {
    "01-opening": ["Dm", "Dm", "Bb"],
    "02-beginning-of-time": ["Dm", "Bb", "F", "Dm"],
    "03-birth-of-stars": ["Bb", "F", "C", "Dm"],
    "04-birth-of-earth": ["Dm", "Am", "Bb", "F"],
    "05-journey-of-life": ["F", "C", "Dm", "Bb"],
    "06-first-question": ["Dm", "Bb", "Gm", "Dm"],
    "07-search-begins": ["Gm", "Dm", "Bb", "F", "Dm"],
    "08-unanswered": ["Bb", "Dm", "Am", "Dm"],
    "09-finale": ["Dm", "Bb", "F", "C", "Dm", "Dm"],
}


def build_score(segs, total_dur, scene_windows):
    n_total = int(total_dur * SR) + SR
    music = np.zeros(n_total, dtype=np.float32)
    sfx = np.zeros(n_total, dtype=np.float32)
    rng = np.random.default_rng(11)

    # ---- continuous low drone for the whole film
    t = np.arange(n_total, dtype=np.float32) / SR
    drone = (np.sin(2 * np.pi * 36.71 * t) * 0.55
             + np.sin(2 * np.pi * 55.00 * t) * 0.30
             + np.sin(2 * np.pi * 73.42 * t) * 0.22)
    lfo = 0.72 + 0.28 * np.sin(2 * np.pi * t / 23.0)
    music += (drone * lfo * 0.16).astype(np.float32)

    # ---- chord pads, one bed per scene, crossfaded
    for name, win in scene_windows.items():
        s0, s1 = win
        chords = SCENE_CHORDS.get(name, ["Dm"])
        seg_len = (s1 - s0) / len(chords)
        for ci, ch in enumerate(chords):
            cs = s0 + ci * seg_len
            ce = cs + seg_len * 1.35
            a = int(cs * SR)
            b = min(n_total, int(ce * SR))
            if b - a < SR // 2:
                continue
            n = b - a
            e = env_adsr(n, 4.2, 1.0, 1.0, min(5.0, seg_len))
            bed = np.zeros(n, dtype=np.float32)
            for f in CHORDS[ch]:
                for octave, amp in ((1, 1.0), (2, 0.55), (0.5, 0.8)):
                    bed += amp * tone(f * octave, n, detune=0.0016, vib=0.4)
            bed = lowpass(bed, 1500) * e / 8.0
            music[a:b] += bed * 0.55

    # ---- high shimmer: sparse arpeggio notes, panned by adding later
    shimmer = np.zeros(n_total, dtype=np.float32)
    note_pool = [587.33, 698.46, 880.00, 1174.66, 1396.91]
    tt = 0.0
    while tt < total_dur - 6:
        start = tt + rng.uniform(0, 2.5)
        f = float(rng.choice(note_pool))
        dur = rng.uniform(3.5, 6.0)
        a = int(start * SR)
        n = int(dur * SR)
        if a + n >= n_total:
            break
        e = env_adsr(n, dur * 0.35, 0.2, 1.0, dur * 0.55)
        shimmer[a:a + n] += (tone(f, n, harmonics=(1.0, 0.12), vib=1.2) * e * 0.06).astype(np.float32)
        tt += rng.uniform(5.0, 11.0)
    shimmer = space(shimmer, 0.6)
    music += shimmer

    # ---- ambience: filtered noise, very low
    noise = rng.normal(0, 1, n_total).astype(np.float32)
    amb = lowpass(highpass(noise, 120), 900) * 0.02
    amb *= (0.6 + 0.4 * np.sin(2 * np.pi * t / 41.0)).astype(np.float32)
    music += amb

    # ---- sound design events
    def boom(at, amp=0.55, length=6.0, f0=48.0, f1=26.0):
        a = int(at * SR)
        n = int(length * SR)
        if a + n >= n_total:
            n = n_total - a - 1
        if n <= 0:
            return
        tl = np.arange(n, dtype=np.float32) / SR
        sweep = f1 + (f0 - f1) * np.exp(-tl / 1.4)
        ph = 2 * np.pi * np.cumsum(sweep) / SR
        body = np.sin(ph) * np.exp(-tl / 1.9)
        nz = lowpass(rng.normal(0, 1, n).astype(np.float32), 400) * np.exp(-tl / 0.35) * 0.5
        sfx[a:a + n] += ((body + nz) * amp).astype(np.float32)

    def swell(at, length, amp=0.25):
        a = int(at * SR)
        n = int(length * SR)
        if a + n >= n_total:
            n = n_total - a - 1
        if n <= 0:
            return
        tl = np.arange(n, dtype=np.float32) / SR
        nz = highpass(rng.normal(0, 1, n).astype(np.float32), 900)
        e = (tl / length) ** 2.4
        sfx[a:a + n] += (nz * e * amp).astype(np.float32)

    # cold open rumble -> first line
    swell(0.0, plan.COLD_OPEN, 0.18)
    boom(0.4, 0.34, 9.0)

    # scene entries: soft transients (bigger for the big moments)
    for seg in segs:
        if seg["kind"] != "scene":
            continue
        sid = seg["scene"]["id"]
        at = seg["start"] + 0.15
        if sid in ("02-beginning-of-time", "04-birth-of-earth", "09-finale"):
            boom(at, 0.34, 7.0)
            swell(at - 1.0 if at > 1 else 0.0, 3.5, 0.12)
        elif sid in ("03-birth-of-stars", "05-journey-of-life", "08-unanswered"):
            swell(at - 0.6 if at > 0.6 else 0.0, 3.0, 0.10)

    # title card hit, end card resolve
    for seg in segs:
        if seg["kind"] == "title":
            boom(seg["start"], 0.75, 10.0)
        if seg["kind"] == "endcard":
            boom(seg["start"], 0.6, 12.0)

    # gentle fade of everything at the very end
    fade_n = int(6.0 * SR)
    music[-fade_n:] *= np.linspace(1, 0, fade_n).astype(np.float32)
    sfx[-fade_n:] *= np.linspace(1, 0, fade_n).astype(np.float32)

    # stereo: score wide, sfx centre-ish
    l = music + sfx * 0.85
    r = music * 0.96 + sfx * 0.9
    return np.stack([l, r], axis=1).astype(np.float32)


def build_narration(decoded, segs, total_dur):
    n_total = int(total_dur * SR) + SR
    voice = np.zeros(n_total, dtype=np.float32)
    for seg in segs:
        if seg["kind"] != "scene":
            continue
        name = seg["scene"]["narration"]
        data = read_wav(decoded[name][0])
        # gentle level: normalise each chunk to a consistent RMS
        rms = np.sqrt(np.mean(data ** 2)) + 1e-6
        data = data * (0.075 / rms)
        a = int(seg["narr_start"] * SR)
        voice[a:a + len(data)] += data[:max(0, n_total - a)]
    # light compression + de-ess-free smoothing
    from scipy.signal import butter, sosfilt
    sos = butter(2, 120 / (SR / 2), btype="high", output="sos")
    voice = sosfilt(sos, voice).astype(np.float32)
    peak = np.max(np.abs(voice)) + 1e-9
    voice *= (10 ** (-1.5 / 20)) / peak
    return voice


def duck(voice, music, depth=0.30, attack=0.25, release=0.85):
    """Smooth sidechain: reduce music while the narrator speaks."""
    from scipy.signal import lfilter
    env = np.abs(voice)
    # envelope follower
    a_att = np.exp(-1.0 / (attack * SR))
    a_rel = np.exp(-1.0 / (release * SR))
    e = np.zeros_like(env)
    atk = np.empty_like(env)
    # vectorised-ish two-pass follower via lfilter on up/down
    from scipy.ndimage import maximum_filter1d, uniform_filter1d
    e = uniform_filter1d(env, int(0.12 * SR))
    e = np.clip(e / (0.02 + 1e-9), 0, 1)
    e = uniform_filter1d(e, int(0.35 * SR))
    gain = 1.0 - depth * e
    return music * gain[:, None]


def measure_lufs(stereo, tmp="/tmp/_lufs.wav"):
    """Integrated loudness via ffmpeg's EBU R128 implementation."""
    write_wav(tmp, stereo.astype(np.float32))
    out = subprocess.run([ffmpeg(), "-hide_banner", "-i", tmp, "-af", "ebur128",
                          "-f", "null", "-"], capture_output=True, text=True).stderr
    val = None
    for line in out.split("\n"):
        if " I: " in line and "LUFS" in line and "Summary" not in line:
            try:
                val = float(line.split(" I: ")[1].split(" LUFS")[0])
            except (IndexError, ValueError):
                pass
    return val if val is not None else -23.0


def normalise(mix, target=-16.0, ceiling=0.89):
    for _ in range(6):
        cur = measure_lufs(mix)
        gain_db = target - cur
        if abs(gain_db) < 0.15:
            break
        mix = mix * (10 ** (gain_db / 20.0))
        peak = np.max(np.abs(mix))
        if peak > ceiling:
            mix = np.tanh(mix * (ceiling / peak) * 1.02) * (ceiling / 1.02)
    peak = np.max(np.abs(mix))
    if peak > ceiling:
        mix *= ceiling / peak
    return mix.astype(np.float32)


def main():
    decoded = decode_narration()
    segs, total = plan.timeline()
    print("total runtime %.1fs (%d:%02d)" % (total, total // 60, total % 60))

    scene_windows = {}
    for seg in segs:
        if seg["kind"] == "scene":
            scene_windows[seg["scene"]["id"]] = (seg["start"], seg["start"] + seg["dur"])

    voice = build_narration(decoded, segs, total)
    score = build_score(segs, total, scene_windows)

    n = min(len(voice), len(score))
    voice, score = voice[:n], score[:n]

    # fade voice in/out at the edges of the film
    score = duck(voice, score)
    # music sits well under the narration; keep the low end soft
    score *= 0.30
    mix = np.stack([voice, voice], axis=1) * 0.94 + score

    # loudness normalisation for delivery: measure with ffmpeg (EBU R128)
    mix = normalise(mix, target=-16.0)
    write_wav(os.path.join(BUILD, "mix.wav"), mix.astype(np.float32))
    print("wrote build/mix.wav  %.1fs  (%.1f LUFS)" % (n / SR, measure_lufs(mix)))
    write_wav(os.path.join(BUILD, "narration.wav"), np.stack([voice, voice], axis=1))
    write_wav(os.path.join(BUILD, "score.wav"), score)


if __name__ == "__main__":
    main()
