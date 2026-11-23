"""Validate the committed teaser package: python film/test_teaser40.py."""
from pathlib import Path
import json,re,subprocess,wave
from PIL import Image
import imageio_ffmpeg
import numpy as np
from teaser_vfx import TeaserVFX

root=Path(__file__).resolve().parent
meta=json.loads((root/'teaser40-edit.json').read_text())
assert meta['duration']==40 and meta['fps']==24 and meta['frames']==960
assert meta['resolution']==[1920,1080]
assert meta['shots'][0][0]==0 and meta['shots'][-1][1]==40
for left,right in zip(meta['shots'],meta['shots'][1:]):
    assert left[1]==right[0],(left,right)
    assert left[0]<left[1]
for shot in meta['shots']:
    if shot[2] not in ('black','title'):
        with Image.open(root/'teaser-inputs'/f'{shot[2]}.jpg') as im:im.verify()
for at,name in meta['voice_cues']:
    with wave.open(str(root/'teaser-inputs'/name)) as audio:
        assert audio.getframerate()==48000 and audio.getnchannels()==1
        assert audio.getsampwidth()==2
        assert at+audio.getnframes()/audio.getframerate()<=40
assert meta['version']==2 and len(meta['text_beats'])>=10
for name in meta['vfx_inputs']:
    with Image.open(root/'teaser-inputs'/name) as im:im.verify()
engine=TeaserVFX(root/'teaser-inputs')
p0,p1=engine.planet(0),engine.planet(1)
assert np.mean(np.abs(p1-p0))>1,'Planet surface is not visibly moving'
a0,a1=engine.accretion(0),engine.accretion(1)
assert np.max(np.abs(a1-a0))>5,'Accretion flow is not moving'
movie=root/'the-search-for-truth-teaser-40s.mp4'
assert 0<movie.stat().st_size<100_000_000
p=subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(),'-hide_banner','-i',str(movie),'-progress','pipe:1','-f','null','-'],capture_output=True,text=True)
assert p.returncode==0,p.stderr
assert '1920x1080' in p.stderr and '24 fps' in p.stderr
assert 'Duration: 00:00:40.00' in p.stderr,p.stderr[:1500]
frames=re.findall(r'^frame=(\d+)\s*$',p.stdout,re.M)
assert frames and int(frames[-1])==960,frames
print('PASS: all inputs readable; 40.00 seconds; 960 frames; 1080p24; complete video/audio decode; no timeline gaps or clipped narration; 10 text beats; verified animated planet and accretion flow.')
