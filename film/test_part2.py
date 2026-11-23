"""Validate edit coverage, approved VO bounds and the entire encoded stream."""
from pathlib import Path
import json,subprocess,wave
import imageio_ffmpeg
R=Path(__file__).resolve().parent
m=json.loads((R/'part2-edit.json').read_text());last=0
for a,b,k,_ in m['shots']:
 assert a==last and b>a
 assert (R/'part2-inputs'/f'{k}.jpg').is_file()
 last=b
assert last==70
end=0
for at,name in m['voice_cues']:
 with wave.open(str(R/'part2-inputs'/name)) as f:d=f.getnframes()/f.getframerate()
 assert at>=end and at+d<=70
 end=at+d
p=R/'the-search-for-truth-part2-70s.mp4';ff=imageio_ffmpeg.get_ffmpeg_exe()
g=imageio_ffmpeg.read_frames(str(p),pix_fmt='rgb24');meta=next(g)
assert meta['size']==(1920,1080) and meta['fps']==24 and abs(meta['duration']-70)<.06
# Full decoder pass is more efficient than reading RGB into Python.
g.close()
r=subprocess.run([ff,'-hide_banner','-v','error','-xerror','-i',str(p),'-map','0:v','-map','0:a','-f','null','-'],capture_output=True,text=True)
assert r.returncode==0,r.stderr
print('PASS: contiguous 70-second edit, narration bounds, 1080p24 metadata, full video/audio decode')
