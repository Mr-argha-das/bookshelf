# The Search for Truth — 40-second teaser V2

A short, human-led cosmic teaser with a clear cinematic story beats and visibly stronger procedural motion: an ocean-to-cosmos opening, a brief origin sequence, human questions, a gravitational-lensing motif, a breath of silence and the title. Narration is excerpted from the user's final Hinglish script in the already selected voice. No new factual or religious conclusion is asserted.

## Deliverable

- **`the-search-for-truth-teaser-40s.mp4`** — exactly **40.00 seconds**, **960 frames**, 1920×1080 delivery, 24fps, H.264/AAC stereo, 16:9 canvas with 2.39:1 active picture.
- **`teaser40-poster.jpg`** — VFX/story frame extracted from the finished teaser.
- **`teaser40-edit.json`** — exact editorial timeline and narration cues.

## Reproduce

All required image and audio inputs are included in `teaser-inputs/`. No credentials, external media API or uncommitted earlier film assets are required to render this version.

```sh
python -m venv .venv
.venv/bin/pip install -r film/requirements-teaser.txt
.venv/bin/python film/teaser40.py --stills  # optional composition review
.venv/bin/python film/teaser40.py
.venv/bin/python film/test_teaser40.py
```

The renderer uses DejaVu Sans at `/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf` (available in the Debian/Ubuntu `fonts-dejavu-core` package). FFmpeg is supplied by `imageio-ffmpeg`. The renderer calculates photographic/VFX composites at 1280×720 and resamples for 1080p delivery; typography is rasterized at delivery resolution. It is not native 4K footage.

## Motion, sound and provenance

- New AI-generated ocean and black-hole image plates, plus selected imagery from the approved documentary cut.
- A rotating, textured, shaded planet rendered as a true sphere with an atmospheric rim and moving perspective star field. Its generated ocean/cloud texture is conceptual, not a present-day Earth map.
- Differentially moving accretion particles, an artistic lensed upper arc, stronger water/cloud/plasma displacement, one broad lightning swell, expanding light waves, highlight halation and lens scatter. `teaser_vfx.py` implements the procedural motion; it is not a numerical general-relativistic simulation.
- Ten readable on-screen story beats, including **Before Earth**, **Before Life**, **13.8 Billion Years Ago**, **Who Are We?**, and **Is There a Creator?**, with animated type reveals and sound-synced accents. The opening is a hypothetical journey back before these things, not a claim that a formed Earth existed before the Universe.
- Excerpts of the approved AI narration, original synthesized harmonic score, original pulse/impact/air effects and a deliberate pre-title silence.
- No footage, recording or recognizable music transcription from *Interstellar* or any other film is used. Its broad emotional scale was a mood reference, not a source of media.
- This is **animated generated imagery and compositing**, not live-action or fully generated character movement. People in still reconstructions do not act or walk.
- All cosmological/biological/historical images are artistic reconstructions. The black-hole image is an artistic cosmic motif during a question, **not** a model of the Big Bang, a deity or evidence of a creator. The early-universe sequence contains no already-formed stars or galaxies. Origin-of-life imagery does not assert a confirmed mechanism or location.

The source image files are optimized JPEGs for repository size. The selected narration excerpts are supplied as PCM WAV files. Other versions, raw originals and render intermediates stay ignored; only this requested teaser and its reproducible package are committed.

## Validation

`test_teaser40.py` checks every required image/audio input, timeline continuity, no narration overflow, file size, 40.00-second duration, 1920×1080/24fps metadata, exactly 960 decoded frames and end-to-end audio/video decodability. V2 also checks the text-beat map and non-static planet/accretion outputs. Composition review frames are inspected before encoding. Technical validation does not establish historical accuracy or subjective cinematic quality.
