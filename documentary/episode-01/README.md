# THE SEARCH FOR TRUTH — Episode 01
## Where Did It All Begin?

A ~6:30 Hindi-language science documentary short, built entirely from the
script in this repo. Facts are stated as facts, beliefs as beliefs; where
science has no answer, the film says so.

**Final film:** `render/episode-01.mp4` (1920×1080, 24 fps, H.264 + AAC, 6:40,
−16 LUFS integrated, −1.5 dBTP)
**Poster:** `render/poster.png` (1600×2000)
**Subtitles:** `render/episode-01.en.srt` (English caption cards)
**Narration only:** `narration/*.mp3`

---

## How it is built

| Stage | Tool | Output |
|---|---|---|
| Narration | `generate_speech` (Hindi voice) | `narration/*.mp3` |
| Plates (crop, grade, cards) | `tools/prep.py` | `shots/*.png` |
| Audio (score, SFX, mix, ducking) | `tools/audio.py` | `build/mix.wav` |
| Picture (camera moves, captions) | `tools/video.py` | `render/seg-*.mp4` |
| Assembly (concat + mux + SRT) | `tools/video.py --assemble` | `render/episode-01.mp4` |

`tools/plan.py` is the single source of truth for the timeline: scenes,
shots, captions, timing constants. Change it and re-render.

```bash
python3 -m venv ~/.venv && . ~/.venv/bin/activate
pip install pillow numpy scipy imageio-ffmpeg

python tools/prep.py      # plates + title/end/credits cards
python tools/audio.py     # narration decode, score, mix
python tools/video.py     # all 42 segments (~12 min on 2 cores)
python tools/video.py --assemble
```

## Structure (as edited)

| Time | Scene | Beat |
|---|---|---|
| 0:00 | Cold open | Black, cosmic rumble, first question |
| 0:06 | 01 Opening | "Ye aasman… ye sitare… hum?" |
| 0:32 | Title card | THE SEARCH FOR TRUTH · Ep 01 |
| 0:40 | 02 Beginning of time | 13.8 billion years, Big Bang as expansion |
| 1:18 | 03 Birth of stars | Gravity, first stars, supernovae, elements |
| 2:01 | 04 Birth of Earth | 4.54 billion years, cooling, first oceans |
| 2:44 | 05 Journey of life | Origin of life, evolution, Homo sapiens |
| 3:27 | 06 First question | The oldest invention was a question |
| 3:57 | 07 Search begins | Civilisations, Nasadiya Sukta, telescopes |
| 4:34 | 08 Unanswered | What we know / what we don't |
| 5:14 | 09 Finale | Facts as facts, beliefs as beliefs |
| 6:06 | End card | THE SEARCH FOR TRUTH · Episode 02 teaser |
| 6:20 | Credits | Image and data sources |

## On-screen science captions

Captions are English (documentary convention) while the narration stays
Hindi. They carry the hard numbers so the visuals can stay poetic:

- 13.8 billion years — space, time and matter begin
- Supernovae — stars forge the elements of life, then scatter them
- 4.54 billion years — dust and rock collide into a planet
- Rigveda · Nasadiya Sukta — "Who truly knows? Perhaps not even the gods."
- CMB map (ESA/Planck) used in the "what we know" beat

## Assets and attribution

Original AI-generated cinematic plates: cosmos, Big Bang, nebula, supernova,
young Earth, first rivers, microbes, Cambrian ocean, hominin, campfire.

Third-party assets (credited on the end card):

| Asset | Source |
|---|---|
| CMB temperature map | ESA / Planck Collaboration (2013) |
| VLT dome under the Milky Way | ESO / Y. Beletsky, CC BY 4.0 |
| Earth "blue marble" | NASA Earth Observatory / MODIS |
| Rigveda manuscript page | Wikimedia Commons, public domain |
| Konark Sun Temple carvings | Wikimedia Commons |
| Chauvet cave paintings | Wikimedia Commons, public domain |

The score is synthesised in `tools/audio.py` (drone, chord pads, shimmer,
sub hits, noise swells) — no library music, no licensing concerns.

## Notes / next pass

- All motion is baked Ken Burns over stills. Adding real motion plates
  (e.g. Planck flythrough, supernova simulation frames) would lift the
  middle act most.
- Devanagari subtitles for Hindi viewers would need a font with Devanagari
  coverage plus a separate `.hi.srt`; the narration itself is untouched.
- Music is deliberately sparse and consonant (D minor field). If the cut
  moves to YouTube, check Content ID against the synth tones (should be
  clear, but verify).
