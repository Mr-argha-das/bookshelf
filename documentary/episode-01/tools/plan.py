"""Edit plan for THE SEARCH FOR TRUTH — Episode 01.

One source of truth for the timeline: scenes, shots, captions, timings.
Everything else (audio mix, video render, subtitles) is derived from here.
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VIS = os.path.join(ROOT, "visuals")
SHOTS = os.path.join(ROOT, "shots")
NARR = os.path.join(ROOT, "narration")
RENDER = os.path.join(ROOT, "render")
BUILD = os.path.join(ROOT, "build")

FPS = 24
W, H = 1920, 1080
SR = 48000

LEAD = 1.0      # silence before narration in a scene
TAIL = 1.8      # air after narration

COLD_OPEN = 6.0     # black + rumble before the first line
TITLE_CARD = 8.0    # main title reveal after the cold open
END_CARD = 14.0
CREDITS = 20.0

# ---------------------------------------------------------------- scenes ----
# narration: file in narration/ (without extension)
# shots: list of stills from shots/ (without extension), cycled to fill scene
# captions: (start_offset_from_scene_start, duration, kicker, sub)
SCENES = [
    dict(
        id="01-opening",
        narration="01-opening",
        shots=["s1-cosmos", "proc-stars", "s3-nebula"],
        captions=[
            (1.4, 7.5, "A FILM ABOUT THE QUESTIONS WE CANNOT STOP ASKING", ""),
            (13.0, 7.5, "THE SEARCH FOR TRUTH", "EPISODE 01  \u00b7  WHERE DID IT ALL BEGIN?"),
        ],
    ),
    dict(
        id="02-beginning-of-time",
        narration="02-beginning-of-time",
        shots=["s2-bigbang", "proc-stars", "s3-nebula", "s1-cosmos"],
        captions=[
            (1.2, 7.5, "13.8 BILLION YEARS AGO", "SPACE, TIME AND MATTER BEGIN"),
            (20.0, 8.0, "THE BIG BANG", "NOT AN EXPLOSION IN SPACE \u2014 AN EXPANSION OF SPACE"),
        ],
    ),
    dict(
        id="03-birth-of-stars",
        narration="03-birth-of-stars",
        shots=["s3-nebula", "proc-stars", "s4-supernova", "s3-nebula", "s2-bigbang"],
        captions=[
            (1.2, 7.0, "THE FIRST STARS", "GRAVITY TURNS GAS INTO LIGHT"),
            (22.0, 8.5, "SUPERNOVAE", "STARS FORGE THE ELEMENTS OF LIFE \u2014 THEN SCATTER THEM"),
        ],
    ),
    dict(
        id="04-birth-of-earth",
        narration="04-birth-of-earth",
        shots=["s5-earth-young", "s6-rivers", "s5-earth-young", "s6-rivers"],
        captions=[
            (1.2, 7.5, "4.54 BILLION YEARS AGO", "DUST AND ROCK COLLIDE INTO A PLANET"),
            (18.0, 8.0, "THE FIRST OCEANS", "WATER COLLECTS. THE SURFACE COOLS."),
        ],
    ),
    dict(
        id="05-journey-of-life",
        narration="05-journey-of-life",
        shots=["s7-microbe", "s8-life-ocean", "s7-microbe", "s9-hominin"],
        captions=[
            (1.2, 7.0, "THE ORIGIN OF LIFE", "STILL ONE OF SCIENCE'S GREATEST OPEN QUESTIONS"),
            (24.0, 8.0, "4 BILLION YEARS", "FROM A SINGLE CELL TO EVERY LIVING THING"),
        ],
    ),
    dict(
        id="06-first-question",
        narration="06-first-question",
        shots=["s10-first-question", "s9-hominin", "s11-cave-painting", "s10-first-question"],
        captions=[
            (1.2, 7.0, "THE FIRST QUESTION", "THE OLDEST INVENTION WAS NOT A TOOL"),
            (14.0, 8.0, "AND STILL WE ASK", "WHO ARE WE?  WHY IS THERE SOMETHING RATHER THAN NOTHING?"),
        ],
    ),
    dict(
        id="07-search-begins",
        narration="07-search-begins",
        shots=["s12-temple", "s13-manuscript", "s11-cave-painting", "s14-observatory", "s1-cosmos"],
        captions=[
            (1.2, 7.5, "ANCIENT INDIA", "THE RISHIS ASK WHAT CONSCIOUSNESS AND BRAHMAN ARE"),
            (12.0, 9.0, "RIGVEDA \u00b7 NASADIYA SUKTA", "\u201cWHO TRULY KNOWS? PERHAPS NOT EVEN THE GODS.\u201d"),
            (23.0, 7.5, "THE SCIENTIFIC METHOD", "TELESCOPES. EQUATIONS. OBSERVATION. DOUBT."),
        ],
    ),
    dict(
        id="08-unanswered",
        narration="08-unanswered",
        shots=["s15-earth-crescent", "s17-cmb", "s4-supernova", "s15-earth-crescent"],
        captions=[
            (1.2, 7.0, "WHAT WE KNOW", "AN EXPANDING UNIVERSE. AN ANCIENT EARTH. A SHARED ANCESTRY."),
            (16.0, 9.0, "WHAT WE DON'T", "LIFE. CONSCIOUSNESS. THE EDGE OF THE UNIVERSE. GOD."),
        ],
    ),
    dict(
        id="09-finale",
        narration="09-finale",
        shots=["s16-earth-blue", "s1-cosmos", "s2-bigbang", "s3-nebula", "s16-earth-blue"],
        captions=[
            (1.2, 8.0, "THE SEARCH CONTINUES", "FACTS AS FACTS.  BELIEFS AS BELIEFS."),
            (33.0, 8.0, "EPISODE 02", "THE UNIVERSE BEGINS \u2014 COMING NEXT"),
        ],
    ),
]


def narration_duration(name):
    """Read duration of the narration mp3 from the timeline plan (see audio.py)."""
    import json
    with open(os.path.join(BUILD, "narration_times.json")) as f:
        return json.load(f)[name]


def timeline():
    """Return ordered list of segments: dict(kind, start, dur, ...)."""
    segs = []
    t = 0.0
    segs.append(dict(kind="coldopen", start=t, dur=COLD_OPEN))
    t += COLD_OPEN
    first = True
    for sc in SCENES:
        nd = narration_duration(sc["narration"]) if os.path.exists(
            os.path.join(BUILD, "narration_times.json")) else 0.0
        dur = LEAD + nd + TAIL
        segs.append(dict(kind="scene", start=t, dur=dur, scene=sc,
                         narr_start=t + LEAD, narr_dur=nd))
        t += dur
        if first:
            segs.append(dict(kind="title", start=t, dur=TITLE_CARD))
            t += TITLE_CARD
            first = False
    segs.append(dict(kind="endcard", start=t, dur=END_CARD))
    t += END_CARD
    segs.append(dict(kind="credits", start=t, dur=CREDITS))
    t += CREDITS
    return segs, t
