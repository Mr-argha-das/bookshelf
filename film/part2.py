"""70-second continuation. AI plates + procedural environmental animation, not live-action.
Reproduce: python film/part2.py; review frames: python film/part2.py --stills
"""
from pathlib import Path
import sys,json,subprocess,wave
import cv2,numpy as np
from PIL import Image,ImageDraw,ImageFont,ImageOps
import imageio_ffmpeg
R=Path(__file__).resolve().parent;I=R/'part2-inputs';T=R/'render';T.mkdir(exist_ok=True)
W,H,FPS,D=1280,720,24,70;SR=48000
cv2.setNumThreads(2)
SHOTS=[(0,4,'ocean','A WORLD WITHOUT LIFE'),(4,8,'underwater','BENEATH THE SURFACE'),(8,12.5,'life','LIFE FINDS A WAY'),(12.5,17,'underwater','AN ORIGIN STILL EXPLORED'),(17,22.3,'humans','THE HUMAN STORY'),(22.3,27,'city','CIVILIZATIONS RISE'),(27,32,'philosophy','EXISTENCE. CONSCIOUSNESS.'),(32,36,'manuscript','THE SEARCH WITHIN'),(36,40,'observatory','THE SEARCH BEYOND'),(40,44,'evidence','EVIDENCE. MATHEMATICS. OBSERVATION.'),(44,48,'universe','ACROSS TIME'),(48,51,'ocean','THE ORIGIN OF LIFE'),(51,54,'humans','EVOLUTION'),(54,57,'city','CIVILIZATION'),(57,60,'philosophy','THE SEARCH FOR GOD'),(60,63,'eye','OUR PLACE IN THE UNIVERSE'),(63,70,'universe','THE SEARCH FOR TRUTH')]
VO=[(1,'voice-01.wav'),(23,'voice-02.wav'),(36,'voice-03.wav'),(44,'voice-04.wav'),(60,'voice-05.wav')]
plates={k:np.array(ImageOps.fit(Image.open(I/f'{k}.jpg').convert('RGB'),(1536,864))) for k in {s[2] for s in SHOTS}}
y,x=np.mgrid[:H,:W].astype(np.float32);u=x/W;v=y/H
rng=np.random.default_rng(73);pts=rng.random((110,4))
font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf';bold=font.replace('.ttf','-Bold.ttf')
def textlayer(text,sub=''):
 im=Image.new('RGBA',(W,H));d=ImageDraw.Draw(im);size=38 if len(text)<30 else 28
 if text=='THE SEARCH FOR TRUTH':
  d.text((W/2,274),'THE SEARCH',font=ImageFont.truetype(font,65),fill='white',anchor='mt');d.text((W/2,350),'FOR TRUTH',font=ImageFont.truetype(font,65),fill='white',anchor='mt')
  d.text((W/2,461),'Across time. Beyond existence. In search of truth.',font=ImageFont.truetype(font,21),fill=(194,209,218),anchor='mt')
  d.text((W/2,221),'PART II  /  THE JOURNEY CONTINUES',font=ImageFont.truetype(font,16),fill=(172,194,206),anchor='mt')
 else:
  d.line((74,501,120,501),fill=(197,212,215),width=2);d.text((72,518),text,font=ImageFont.truetype(bold,size),fill=(244,243,236))
  if sub:d.text((74,570),sub,font=ImageFont.truetype(font,16),fill=(199,211,216))
 return np.array(im)
layers={a:textlayer(txt,'Conceptual reconstruction' if k in ['life','underwater'] else '') for a,b,k,txt in SHOTS}
def frame(t):
 a,b,k,txt=next(s for s in SHOTS if s[0]<=t<s[1]);p=(t-a)/(b-a)
 scale=1.09+.075*p;cw=1536/scale;ch=cw*H/W
 cx=768+55*np.sin(p*1.7+a);cy=432-18*p
 mx=(cx-cw/2+x/W*cw).astype(np.float32);my=(cy-ch/2+y/H*ch).astype(np.float32)
 if k in ['ocean','underwater','life']:
  mask=np.clip((v-.38)*3,0,1) if k=='ocean' else np.ones_like(v)
  mx+=mask*(4*np.sin(y*.042-t*2)+2*np.sin(y*.013+t));my+=mask*2*np.sin(x*.021+t*1.3)
 im=cv2.remap(plates[k],mx,my,cv2.INTER_LINEAR,borderMode=cv2.BORDER_REFLECT).astype(np.float32)
 # Drifting mist and suspended particles move independently of the camera.
 if k in ['ocean','underwater','life','city','philosophy','humans']:
  fog=(.5+.5*np.sin(u*11+t*.28+np.sin(v*13-t*.3)))*np.exp(-((v-.62)/.27)**2)
  im=im*(1-fog[:,:,None]*.08)+fog[:,:,None]*np.array([12,18,21])
 if k=='ocean':im+=np.exp(-((t%4.0-1.35)/.24)**2)*np.array([14,20,25])
 im=np.clip(im*(.91+.09*(1-((u-.5)**2+(v-.5)**2))[:,:,None]),0,255).astype(np.uint8)
 overlay=np.zeros_like(im)
 for px,py,s,z in pts:
  if k in ['underwater','life','observatory','universe','philosophy','manuscript']:
   xx=int((px*W+np.sin(t*.3+py*8)*18) % W);yy=int((py*H-t*(6+z*16))%H)
   cv2.circle(overlay,(xx,yy),1 if z<.8 else 2,(int(30+60*s),int(45+70*s),int(50+80*s)),-1)
 im=cv2.add(im,overlay)
 if k=='underwater':
  for j in range(4):
   beam=np.exp(-((u-(.12+j*.25+.03*np.sin(t*.3+j))-.14*v)/.021)**2)*(.9-v)*8
   im=np.clip(im.astype(float)+beam[:,:,None]*np.array([.3,.8,1.0]),0,255).astype(np.uint8)
 # Smooth exposure at cuts, not strobe flashes.
 fade=min(1,(t-a)/.22,(b-t)/.18)
 im=(im*np.clip(fade,0,1)).astype(np.uint8)
 if k=='universe' and a==63:im=(im*.19).astype(np.uint8)
 lay=layers[a];alpha=lay[:,:,3:4].astype(np.float32)/255*min(1,max(0,(t-a-.25)/.45))*min(1,(b-t)/.25)
 # Local graduated matte keeps type readable on bright plates.
 shade=np.clip((v-.57)*1.8,0,.48) if a!=63 else np.zeros_like(v)
 im=(im*(1-shade[:,:,None])).astype(np.uint8)
 im=(im*(1-alpha)+lay[:,:,:3]*alpha).astype(np.uint8)
 im[:90]=0;im[-90:]=0
 return im
if '--stills' in sys.argv:
 for t in [2,6,10,19,25,29,38,42,61,66]:Image.fromarray(frame(t)).save(T/f'part2-review-{t}.jpg',quality=94)
 sys.exit()
N=SR*D;voice=np.zeros(N,np.float32);score=np.zeros(N,np.float32)
for at,f in VO:
 with wave.open(str(I/f)) as w:aud=np.frombuffer(w.readframes(w.getnframes()),np.int16).astype(np.float32)/32768
 aud*=.72/max(.01,np.max(np.abs(aud)));n=int(at*SR);assert n+len(aud)<=N;voice[n:n+len(aud)]+=aud
def add(at,a):
 n=int(at*SR);l=min(len(a),N-n)
 if n>=0:score[n:n+l]+=a[:l]
for j,at in enumerate(range(0,70,7)):
 tt=np.arange(10*SR)/SR;env=(1-np.exp(-tt*.8))*np.exp(-np.maximum(tt-6,0)*1.2)
 for midi in ([38,45,52,57],[41,48,55,60],[45,52,59,64])[j%3]:
  f=440*2**((midi-69)/12);add(at,.017*env*(np.sin(2*np.pi*f*tt)+.13*np.sin(2*np.pi*f*2.002*tt)))
for a,b,k,txt in SHOTS:
 tt=np.arange(2*SR)/SR;add(a,.10*np.sin(2*np.pi*38*tt)*np.exp(-tt*4))
 if a>.5:
  tt=np.arange(int(.4*SR))/SR;air=rng.standard_normal(len(tt));air=np.convolve(air,np.ones(25)/25,'same');add(a-.4,.13*air*(tt/.4)**2)
for at in np.arange(22.3,60,.75):
 tt=np.arange(int(.4*SR))/SR;add(at,.045*np.sin(2*np.pi*48*tt)*np.exp(-tt*16))
env=cv2.blur(np.abs(voice).reshape(1,-1),(16001,1)).ravel();score*=np.where(env>.015,.42,1)
score*=np.minimum(1,(D-np.arange(N)/SR)/2)
mix=np.column_stack([voice+score,voice+np.roll(score,139)])
with wave.open(str(T/'part2-mix.wav'),'wb') as w:w.setnchannels(2);w.setsampwidth(2);w.setframerate(SR);w.writeframes((np.clip(mix,-.98,.98)*32767).astype(np.int16).tobytes())
(R/'part2-edit.json').write_text(json.dumps({'duration':D,'fps':FPS,'shots':SHOTS,'voice_cues':VO,'provenance':'AI-generated artistic reconstructions, environmental procedural animation, approved voice excerpts and original synthesized score. People are not articulated. Hydrothermal setting is a hypothesis illustration, not a proven origin. 720p composition upscaled to 1080p.'},indent=2))
ff=imageio_ffmpeg.get_ffmpeg_exe();out=R/'the-search-for-truth-part2-70s.mp4'
p=subprocess.Popen([ff,'-hide_banner','-loglevel','error','-y','-f','rawvideo','-pix_fmt','rgb24','-s',f'{W}x{H}','-r',str(FPS),'-i','-','-i',str(T/'part2-mix.wav'),'-vf','scale=1920:1080:flags=lanczos','-c:v','libx264','-preset','fast','-crf','19','-threads','2','-pix_fmt','yuv420p','-af','loudnorm=I=-16:TP=-1.7:LRA=10','-c:a','aac','-b:a','224k','-t',str(D),'-movflags','+faststart',str(out)],stdin=subprocess.PIPE)
try:
 for n in range(D*FPS):
  p.stdin.write(frame(n/FPS).tobytes())
  if n%(5*FPS)==0:print(f'Part 2: {n/FPS:.0f}/{D}',flush=True)
finally:p.stdin.close()
assert p.wait()==0
print('PART 2 COMPLETE',flush=True)
