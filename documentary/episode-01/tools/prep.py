"""Asset prep: crop/grade the stills into cinematic 16:9 shot plates with
a slow push-in baked at high resolution (Ken Burns is applied at render time
via zoompan, so plates are pre-scaled to 2.5x for smooth motion).

Also renders the title / end cards and derived "procedural" plates.
Run: python tools/prep.py
"""
import os
import math
import subprocess

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageStat

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VIS = os.path.join(ROOT, "visuals")
SEARCH = os.path.abspath(os.path.join(ROOT, "..", "..", "image-search"))
SHOTS = os.path.join(ROOT, "shots")

PLATE_W, PLATE_H = 2400, 1350
FONT_B = "/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf"
FONT_S = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
FONT_SB = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

# source -> shot name. Search assets are cropped, generated ones used as-is.
SOURCES = {
    "s1-cosmos": "s1-cosmos.png",
    "s2-bigbang": "s2-bigbang.png",
    "s3-nebula": "s3-nebula.png",
    "s4-supernova": "s4-supernova.png",
    "s5-earth-young": "s5-earth-young.png",
    "s6-rivers": "s6-rivers.png",
    "s7-microbe": "s7-microbe.png",
    "s8-life-ocean": "s8-life-ocean.png",
    "s9-hominin": "s9-hominin.png",
    "s10-first-question": "s10-first-question.png",
    "s11-cave-painting": "chauvet-cave-paintings-horses-high-resol-1.jpg",
    "s12-temple": "wikimedia-commons-konark-sun-temple-ston-1.jpg",
    "s13-manuscript": "nasadiya-sukta-rigveda-manuscript-page-h-1.jpg",
    "s14-observatory": "paranal-vlt-telescope-dome-milky-way-nig-2.jpg",
    "s15-earth-crescent": "earth-from-space-blue-marble-dark-space--1.jpg",
    "s16-earth-blue": "earth-from-space-blue-marble-dark-space--2.jpg",
    "s17-cmb": "cosmic-microwave-background-planck-map-i-1.jpg",
    "s18-landscape": "wikimedia-commons-konark-sun-temple-ston-4.jpg",
}


def find(name):
    for base in (VIS, SEARCH):
        p = os.path.join(base, name)
        if os.path.exists(p):
            return p
    for root, _dirs, files in os.walk(os.path.join(ROOT, "..", "..")):
        if name in files:
            return os.path.join(root, name)
    raise FileNotFoundError(name)


def cover(im, w, h):
    im = im.convert("RGB")
    s = max(w / im.width, h / im.height)
    im = im.resize((max(w, int(im.width * s + 0.5)), max(h, int(im.height * s + 0.5))),
                   Image.LANCZOS)
    left = (im.width - w) // 2
    top = (im.height - h) // 2
    return im.crop((left, top, left + w, top + h))


def grade(im, contrast=1.05, bright=0.99, sat=1.02, warm=(1.0, 1.0, 1.0), vignette=0.42):
    """Documentary grade: slight crush, cool shadows, soft vignette."""
    r, g, b = im.split()
    lut = [min(255, max(0, int(((i / 255 - 0.5) * contrast + 0.5) * 255 * bright + 3)))
           for i in range(256)]
    r, g, b = r.point(lut), g.point(lut), b.point(lut)
    # saturation
    gray = Image.merge("RGB", (r, g, b)).convert("L")
    base = Image.merge("RGB", (r, g, b))
    im = Image.blend(base, Image.merge("RGB", (gray, gray, gray)), 1 - sat)
    # warm/cool balance
    r, g, b = im.split()
    r = r.point(lambda i: min(255, int(i * warm[0])))
    g = g.point(lambda i: min(255, int(i * warm[1])))
    b = b.point(lambda i: min(255, int(i * warm[2])))
    im = Image.merge("RGB", (r, g, b))
    # vignette
    if vignette > 0:
        mask = Image.new("L", (im.width, im.height), 255)
        d = ImageDraw.Draw(mask)
        pad = -int(im.width * 0.18)
        d.ellipse((pad, pad, im.width - pad, im.height - pad), fill=int(255 * (1 - vignette)))
        mask = mask.filter(ImageFilter.GaussianBlur(im.width * 0.09))
        dark = Image.new("RGB", im.size, (0, 0, 0))
        im = Image.composite(im, Image.blend(im, dark, 0.8), mask)
    return im


def lift(im, amount=0.03):
    """Small black-level lift so the frame feels filmic, not crushed."""
    return im.point(lambda i: int(i + 255 * amount * (1 - i / 255)))


def prep_still(name, src):
    im = Image.open(src)
    im = cover(im, PLATE_W, PLATE_H)
    st = ImageStat.Stat(im.convert("L"))
    mean = st.mean[0]
    warm = (1.02, 1.0, 0.97) if mean > 60 else (0.98, 1.0, 1.05)
    out = grade(im, contrast=1.06, bright=0.98, sat=1.04, warm=warm)
    out = lift(out, 0.02)
    out.save(os.path.join(SHOTS, name + ".png"), optimize=True)


def proc_stars():
    """Procedural drifting starfield plate (no source, pure footage fill)."""
    import random
    random.seed(7)
    im = Image.new("RGB", (PLATE_W, PLATE_H), (3, 5, 10))
    d = ImageDraw.Draw(im)
    for _ in range(2600):
        x = random.uniform(0, PLATE_W)
        y = random.uniform(0, PLATE_H)
        r = random.choice([0.6, 0.7, 0.8, 1.0, 1.3, 1.9, 2.6])
        tint = random.choice([(255, 255, 255), (200, 215, 255), (255, 236, 210), (170, 200, 255)])
        a = random.uniform(0.25, 1.0)
        c = tuple(int(v * a) for v in tint)
        d.ellipse((x - r, y - r, x + r, y + r), fill=c)
    # faint milky band
    band = Image.new("RGB", im.size, (0, 0, 0))
    bd = ImageDraw.Draw(band)
    for i in range(70):
        y = PLATE_H * 0.52 + i * 4
        bd.line((0, y - 200, PLATE_W, y + 120), fill=(9, 11, 20), width=3)
    band = band.filter(ImageFilter.GaussianBlur(28))
    im = Image.blend(im, Image.blend(im, band, 0.55), 0.5)
    im = im.filter(ImageFilter.GaussianBlur(0.4))
    im.save(os.path.join(SHOTS, "proc-stars.png"))


def text_center(d, y, txt, font, fill, spacing=0):
    if spacing:
        txt = (" " * 0).join(txt)
    w = d.textlength(txt, font=font)
    d.text(((PLATE_W - w) / 2, y), txt, font=font, fill=fill)


def title_plate():
    """Main title card: black, letterbox lines, thin gold rule."""
    im = Image.new("RGB", (PLATE_W, PLATE_H), (0, 0, 0))
    d = ImageDraw.Draw(im)
    # subtle blue nebula bloom in the centre
    glow = Image.new("RGB", im.size, (0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse((PLATE_W * 0.30, PLATE_H * 0.30, PLATE_W * 0.70, PLATE_H * 0.72),
               fill=(14, 20, 34))
    glow = glow.filter(ImageFilter.GaussianBlur(120))
    im = Image.blend(im, glow, 0.9)
    d = ImageDraw.Draw(im)

    f_main = ImageFont.truetype(FONT_B, 104)
    f_kick = ImageFont.truetype(FONT_S, 30)
    f_sub = ImageFont.truetype(FONT_S, 26)
    gold = (214, 178, 112)
    white = (240, 240, 238)
    grey = (150, 156, 168)

    # top kicker
    kick = "A   D O C U M E N T A R Y   S E R I E S"
    d.text(((PLATE_W - d.textlength(kick, font=f_kick)) / 2, PLATE_H * 0.30),
           kick, font=f_kick, fill=(120, 126, 140))

    d.line((PLATE_W * 0.36, PLATE_H * 0.395, PLATE_W * 0.64, PLATE_H * 0.395), fill=gold, width=2)

    lines = ["THE SEARCH", "FOR TRUTH"]
    y = PLATE_H * 0.435
    for ln in lines:
        d.text(((PLATE_W - d.textlength(ln, font=f_main)) / 2, y), ln, font=f_main, fill=white)
        y += 128

    d.line((PLATE_W * 0.36, PLATE_H * 0.665, PLATE_W * 0.64, PLATE_H * 0.665), fill=gold, width=2)

    sub = "Across time.  Beyond existence.  In search of truth."
    d.text(((PLATE_W - d.textlength(sub, font=f_sub)) / 2, PLATE_H * 0.70),
           sub, font=f_sub, fill=grey)

    ep = "EPISODE 01  \u00b7  WHERE DID IT ALL BEGIN?"
    d.text(((PLATE_W - d.textlength(ep, font=f_kick)) / 2, PLATE_H * 0.785),
           ep, font=f_kick, fill=gold)
    im.save(os.path.join(SHOTS, "card-title.png"))


def end_plate():
    im = cover(Image.open(os.path.join(SHOTS, "s16-earth-blue.png")), PLATE_W, PLATE_H)
    im = Image.blend(im, Image.new("RGB", im.size, (0, 0, 0)), 0.55)
    d = ImageDraw.Draw(im)
    f_main = ImageFont.truetype(FONT_B, 88)
    f_kick = ImageFont.truetype(FONT_S, 28)
    f_sub = ImageFont.truetype(FONT_S, 26)
    white = (240, 240, 238)
    gold = (214, 178, 112)
    grey = (160, 166, 178)

    d.text(((PLATE_W - d.textlength("THE SEARCH FOR TRUTH", font=f_main)) / 2, PLATE_H * 0.40),
           "THE SEARCH FOR TRUTH", font=f_main, fill=white)
    d.line((PLATE_W * 0.40, PLATE_H * 0.545, PLATE_W * 0.60, PLATE_H * 0.545), fill=gold, width=2)
    a = "Episode 02  \u00b7  THE UNIVERSE BEGINS"
    d.text(((PLATE_W - d.textlength(a, font=f_kick)) / 2, PLATE_H * 0.585), a, font=f_kick, fill=gold)
    b = "narration in Hindi  \u00b7  science, not spectacle"
    d.text(((PLATE_W - d.textlength(b, font=f_sub)) / 2, PLATE_H * 0.66), b, font=f_sub, fill=grey)
    im.save(os.path.join(SHOTS, "card-end.png"))


def cmb_plate():
    """Real Planck CMB data: oval isolated with a soft radial alpha, on black."""
    import numpy as np
    im = Image.open(find(SOURCES["s17-cmb"])).convert("RGB")
    a = np.asarray(im).astype(np.float32)
    mx, mn = a.max(axis=2), a.min(axis=2)
    sat = (mx - mn) / (mx + 1e-6)
    ys, xs = np.where(sat > 0.12)
    im = im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
    # the flat page grey has almost no saturation: kill it to pure black
    b = np.asarray(im).astype(np.float32)
    bmx, bmn = b.max(axis=2), b.min(axis=2)
    bsat = (bmx - bmn) / (bmx + 1e-6)
    b[bsat < 0.10] = 0.0
    im = Image.fromarray(np.clip(b, 0, 255).astype(np.uint8), mode="RGB")

    target_w = int(PLATE_W * 0.80)
    target_h = int(target_w * im.height / im.width)
    im = im.resize((target_w, target_h), Image.LANCZOS)

    # radial alpha: fully opaque to 88% of the radius, feathered to 0 at 100%
    yy, xx = np.mgrid[0:target_h, 0:target_w]
    cx, cy = (target_w - 1) / 2.0, (target_h - 1) / 2.0
    r = np.sqrt(((xx - cx) / (target_w / 2.0)) ** 2 + ((yy - cy) / (target_h / 2.0)) ** 2)
    alpha = np.clip((1.0 - r) / 0.10, 0, 1) ** 1.4
    mask = Image.fromarray((alpha * 255).astype(np.uint8), mode="L")

    pos = ((PLATE_W - target_w) // 2, (PLATE_H - target_h) // 2)
    glow_src = Image.new("RGB", im.size, (0, 0, 0))
    glow_src.paste(im, (0, 0), mask)
    glow = glow_src.filter(ImageFilter.GaussianBlur(140)).point(
        lambda i: min(255, int(i * 1.6)))
    plate = Image.new("RGB", (PLATE_W, PLATE_H), (0, 0, 0))
    plate.paste(glow, pos, mask)
    plate.paste(im, pos, mask)
    plate = plate.filter(ImageFilter.GaussianBlur(0.6))
    plate = grade(plate, contrast=1.06, bright=1.0, sat=1.10, vignette=0.42)
    plate.save(os.path.join(SHOTS, "s17-cmb.png"), optimize=True)


def scrim_plate():
    """1920x1080 alpha gradient for caption legibility (matches the output)."""
    import numpy as np
    w, h = 1920, 1080
    col = np.zeros((h, 1, 4), dtype=np.uint8)
    for y in range(h):
        f = (y - h * 0.42) / (h * 0.58)
        f = min(1.0, max(0.0, f))
        col[y, 0] = (0, 0, 0, int(240 * (f ** 1.15)))
    rgba = np.repeat(col, w, axis=1)
    Image.fromarray(rgba, mode="RGBA").save(os.path.join(SHOTS, "scrim.png"))


def black_plate():
    Image.new("RGB", (PLATE_W, PLATE_H), (0, 0, 0)).save(os.path.join(SHOTS, "black.png"))


def credits_plate():
    """End credits: sources for every non-AI image in the film."""
    im = Image.new("RGB", (PLATE_W, PLATE_H), (0, 0, 0))
    d = ImageDraw.Draw(im)
    f_h = ImageFont.truetype(FONT_SB, 30)
    f_b = ImageFont.truetype(FONT_S, 27)
    f_s = ImageFont.truetype(FONT_S, 24)
    gold = (214, 178, 112)
    grey = (156, 162, 176)
    white = (232, 232, 228)

    y = 150
    t = "IMAGE AND DATA SOURCES"
    d.text(((PLATE_W - d.textlength(t, font=f_h)) / 2, y), t, font=f_h, fill=gold)
    y += 74
    lines = [
        ("Cosmic microwave background map", "ESA / Planck Collaboration (2013)"),
        ("Very Large Telescope, Milky Way arc", "ESO / Y. Beletsky (eso.org, CC BY 4.0)"),
        ("Earth from space ('blue marble')", "NASA Earth Observatory / MODIS"),
        ("Rigveda manuscript page", "Wikimedia Commons \u00b7 public domain"),
        ("Konark Sun Temple carvings", "Wikimedia Commons"),
        ("Chauvet cave paintings", "Wikimedia Commons \u00b7 public domain"),
    ]
    for a, b in lines:
        d.text((PLATE_W * 0.26, y), a, font=f_b, fill=white)
        w = d.textlength(a, font=f_b)
        d.text((PLATE_W * 0.26 + w + 40, y + 2), b, font=f_s, fill=grey)
        y += 46
    y += 26
    t = "All other imagery: original visuals made for this episode."
    d.text(((PLATE_W - d.textlength(t, font=f_s)) / 2, y), t, font=f_s, fill=grey)
    y += 60
    t = "Script, narration, score and edit \u2014 THE SEARCH FOR TRUTH"
    d.text(((PLATE_W - d.textlength(t, font=f_s)) / 2, y), t, font=f_s, fill=gold)
    y += 56
    t = "Narration in Hindi  \u00b7  facts presented as facts, beliefs as beliefs"
    d.text(((PLATE_W - d.textlength(t, font=f_s)) / 2, y), t, font=f_s, fill=grey)
    im.save(os.path.join(SHOTS, "card-credits.png"))


def main():
    os.makedirs(SHOTS, exist_ok=True)
    for name, src in SOURCES.items():
        prep_still(name, find(src))
        print("plate", name)
    cmb_plate()
    print("plate s17-cmb (data)")
    black_plate()
    scrim_plate()
    proc_stars()
    print("plate proc-stars")
    title_plate()
    print("plate card-title")
    end_plate()
    print("plate card-end")
    credits_plate()
    print("plate card-credits")


if __name__ == "__main__":
    main()
