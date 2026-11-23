"""Exactly 40 seconds: original atmospheric teaser from the user's final script.
Run: python film/teaser40.py [--stills]
All required inputs are committed in teaser-inputs/. Generated photographic plates
receive depth-biased motion, fluid displacement, atmosphere and lens composites.
People are not generatively animated. No footage or music from a movie is used.
"""
from pathlib import Path
import json, math, subprocess, sys, wave
import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageOps
import imageio_ffmpeg
from teaser_vfx import TeaserVFX

ROOT=Path(__file__).resolve().parent;INPUT=ROOT/'teaser-inputs';TMP=ROOT/'render'
TMP.mkdir(exist_ok=True)
W,H,OW,OH,FPS,DURATION=1280,720,1920,1080,24,40
SR=48000;FF=imageio_ffmpeg.get_ffmpeg_exe()
FONT='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
BOLD='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
cv2.setNumThreads(2)
rng=np.random.default_rng(271126)
yy,xx=np.mgrid[0:H,0:W].astype(np.float32);u=xx/W;v=yy/H
rad=np.sqrt(((u-.5)*1.4)**2+(v-.5)**2)
vignette=np.clip(1-.16*rad**1.4,.83,1)
vfx=TeaserVFX(INPUT,W,H)

# Every cue is an excerpt of the user's locked script, in the approved voice.
VOICES=[(1.0,'voice-01.wav'),(12.6,'voice-02.wav'),(20.0,'voice-03.wav'),
        (27.0,'voice-04.wav'),(31.3,'voice-05.wav')]
SHOTS=[(0,.8,'black',''),(.8,4.6,'ocean','wide'),(4.6,7.2,'earth','retreat'),
 (7.2,9.0,'life','detail'),(9.0,11.6,'early','retreat'),(11.6,14.8,'early','wide'),
 (14.8,17.5,'stars','detail'),(17.5,19.4,'universe','retreat'),
 (19.4,22.6,'skywatchers','wide'),(22.6,24.9,'humans','wide'),
 (24.9,26.3,'manuscript','detail'),(26.3,29.8,'cosmos','wide'),
 (29.8,31.3,'black',''),(31.3,40,'title','')]
# Visible story beats, timed to the approved voice excerpts.
TEXT_BEATS=[(.8,4.6,'KABHI SOCHO...','A journey before our beginning','lower'),
 (4.6,7.2,'BEFORE EARTH','Before our world existed','lower'),
 (7.2,9.0,'BEFORE LIFE','Before there was anyone to ask','lower'),
 (9.0,11.6,'WHAT WOULD WE SEE?','','center'),
 (11.6,14.8,'13.8 BILLION','YEARS AGO','center'),
 (14.8,17.5,'THE FIRST LIGHT','A Universe in the making','lower'),
 (19.4,21.35,'WHO ARE WE?','','lower'),
 (21.35,22.9,'WHERE DID WE COME FROM?','','lower'),
 (22.9,25.3,'WHY DOES IT EXIST?','','lower'),
 (26.3,29.8,'IS THERE A CREATOR?','An open question','lower')]
metadata={'duration':DURATION,'fps':FPS,'frames':DURATION*FPS,'resolution':[OW,OH],
 'version':2,'voice_cues':VOICES,'shots':SHOTS,'text_beats':TEXT_BEATS,
 'vfx_inputs':['earth-surface.jpg'],'vfx':['rotating shaded textured planet','differential accretion flow','animated water and clouds','lens halation','tracked type reveals'],
 'narration':'Kabhi socho... Agar hum waqt mein peeche ja sakein... Itna peeche, jahan na koi duniya thi, na koi zameen... na koi zindagi. Toh hum kya dekhenge? 13.8 billion years pehle... Universe apni journey shuru kar raha tha. Hum kaun hain? Hum kahan se aaye hain? Ye Universe kyun exist karta hai? Kya is poore existence ke peeche koi Creator hai? THE SEARCH FOR TRUTH. Across time. Beyond existence. In search of truth.',
 'provenance':'AI photographic plates, procedural VFX, original synthesized score and excerpts of the approved voice. Not live-action. The black-hole motif is not a depiction of the Big Bang or a creator.'}
(ROOT/'teaser40-edit.json').write_text(json.dumps(metadata,indent=2))
plates={}
for key in {s[2] for s in SHOTS}-{'black','title'}:
    im=Image.open(INPUT/f'{key}.jpg').convert('RGB')
    plates[key]=np.array(ImageOps.fit(im,(1600,900),method=Image.Resampling.LANCZOS))

# Fine original title design, rasterized at delivery resolution.
def title_layer(tag=False):
    im=Image.new('RGBA',(OW,OH));d=ImageDraw.Draw(im)
    def tracked(text,y,size,spacing,color):
        font=ImageFont.truetype(FONT,size);widths=[d.textlength(c,font=font) for c in text]
        x=(OW-sum(widths)-spacing*(len(text)-1))/2
        for c,wi in zip(text,widths):
            d.text((x,y),c,font=font,fill=color);x+=wi+spacing
    tracked('A DOCUMENTARY SERIES',251,20,3,(147,171,187,255))
    tracked('THE SEARCH',350,96,12,(238,239,235,255))
    tracked('FOR TRUTH',476,96,12,(238,239,235,255))
    if tag:
        d.text((OW//2,677),'Across time. Beyond existence. In search of truth.',font=ImageFont.truetype(FONT,27),fill=(184,197,207,255),anchor='mt')
    d.text((OW//2,815),'From the Universe to the Search for God',font=ImageFont.truetype(FONT,22),fill=(121,145,163,255),anchor='mt')
    return np.array(im)
TITLE=title_layer();TITLE_TAG=title_layer(True)
star_points=rng.random((240,5))


# Text is a visible editorial element, not confined to the final title.
TYPE_LAYERS={}
for a,b,main,sub,style in TEXT_BEATS:
    im=Image.new('RGBA',(OW,OH));d=ImageDraw.Draw(im)
    if style=='center':
        d.text((OW//2,418),main,font=ImageFont.truetype(FONT,104 if len(main)<18 else 80),fill=(245,244,238,255),anchor='mt')
        if sub:d.text((OW//2,565),sub,font=ImageFont.truetype(FONT,32),fill=(192,207,217,255),anchor='mt')
    else:
        d.line((113,738,170,738),fill=(175,193,203,255),width=3)
        size=64 if len(main)<25 else 54
        d.text((111,765),main,font=ImageFont.truetype(BOLD,size),fill=(246,245,240,255))
        if sub:d.text((114,856),sub,font=ImageFont.truetype(FONT,25),fill=(196,211,219,255))
    TYPE_LAYERS[a]=np.array(im)


def scene(key,t,p,mode):
    if key=='earth':
        im=vfx.planet(t-4.6)*vignette[:,:,None]
        bright=np.maximum(im-160,0)
        im+=cv2.GaussianBlur(bright,(0,0),4)*.16
        return np.clip(im,0,255).astype(np.uint8)
    zoom=1.025+.07*p;cx,cy=.5,.5
    if mode=='detail':zoom=1.14+.07*p
    if mode=='retreat':zoom=1.12-.08*p
    if key=='humans':zoom=1.015+.018*p;cy=.38
    if key=='skywatchers':zoom=1.025+.03*p;cy=.48
    if key=='cosmos':zoom=1.015+.06*p
    depth=np.clip((v-.18)/.82,0,1)
    mx=(xx-W/2)*1.25/zoom+1600*cx+(p-.5)*(9+depth*16)
    my=(yy-H/2)*1.25/zoom+900*cy
    if key=='ocean':
        water=np.clip((v-.52)/.15,0,1)*np.clip((.90-v)/.12,0,1)
        human=np.exp(-(((u-.59)/.055)**2+((v-.63)/.17)**2)*3)
        water*=1-human
        mx+=water*12*np.sin(yy*.06-t*1.8)
        my+=water*6*np.sin(xx*.014+yy*.03-t*1.3)
        sky=np.clip((.49-v)/.18,0,1)
        mx+=sky*12*np.sin(yy*.011+t*.2)
    elif key=='earth':
        mx+=np.clip((.70-v)/.2,0,1)*2.5*np.sin(yy*.018+t*.2)
    elif key=='life':
        mx+=3*np.sin(yy*.02+t*.7);my+=2.3*np.cos(xx*.014-t*.55)
    elif key=='early':
        mx+=13*np.sin(yy*.014+t*.7)+5*np.sin(xx*.009-t*.4)
        my+=8*np.sin(xx*.012-t*.52)
    elif key=='stars':
        mx+=2.2*np.sin(yy*.03+t*.8);my+=1.7*np.sin(xx*.014-t*.7)
    elif key=='cosmos':
        # Very restrained animated refraction around the accretion arc.
        dx=u-.58;dy=v-.50;r=np.sqrt(dx*dx+dy*dy)
        ring=np.exp(-((r-.083)/.046)**2)
        mx+=ring*np.sin(np.arctan2(dy,dx)*5+t*.55)*1.6
        my+=ring*np.cos(np.arctan2(dy,dx)*4+t*.45)*1.3
    im=cv2.remap(plates[key],mx.astype(np.float32),my.astype(np.float32),cv2.INTER_LINEAR,borderMode=cv2.BORDER_REFLECT).astype(np.float32)
    if key=='early':
        im*=1+.16*np.sin(t*.7)
        if 11.6<=t<14.8:
            rr=np.sqrt(((u-.5)*1.5)**2+(v-.5)**2)
            wave=np.exp(-((rr-(t-11.6)*.20)/.022)**2)*np.exp(-(t-11.6)*.7)
            im+=wave[:,:,None]*np.array([55,62,69])
    if key=='cosmos':im+=vfx.accretion(t-26.3)

    if key in ('cosmos','universe','skywatchers'):
        light=np.zeros_like(im)
        for x,y,a,b,c in star_points:
            px=int((x*W+(p-.5)*(4+a*9))%W);py=int((y*H)%H)
            if key=='skywatchers' and py>H*.57:continue
            if key=='cosmos' and ((px/W-.58)/.075)**2+((py/H-.50)/.13)**2<1:continue
            intensity=(.2+.35*(.5+.5*math.sin(t*(.5+a)+b*9)))
            cv2.circle(light,(px,py),1,(155*intensity,175*intensity,193*intensity),-1,cv2.LINE_AA)
        im+=light
    if key=='ocean':
        im*=1+(water*.12*np.sin(yy*.10-t*2.4))[:,:,None]
        # A single broad distant lightning swell; never a rapid strobe.
        flash=.12*np.exp(-((t-2.25)/.12)**2)
        im+=np.clip((.65-v)/.35,0,1)[:,:,None]*np.array([155,170,185])*flash

    # Controlled photochemical-style halation and short horizontal lens scatter.
    bright=np.maximum(im-170,0)
    small=cv2.resize(bright,(W//4,H//4))
    glow=cv2.GaussianBlur(small,(0,0),3)
    im+=cv2.resize(glow,(W,H))*.21
    if key in ('stars','cosmos'):
        im+=cv2.blur(bright,(111,3))*.085
    im*=vignette[:,:,None]
    return np.clip(im,0,255).astype(np.uint8)


def frame_at(t):
    a,b,key,mode=next(s for s in SHOTS if s[0]<=t<s[1]);local=t-a;p=local/(b-a)
    if key=='black':return np.zeros((OH,OW,3),np.uint8)
    if key=='title':
        # The scale reveal comes from negative space and light, not a title template pack.
        frame=(cv2.resize(scene('cosmos',t,p,'retreat'),(OW,OH))* .13).astype(np.uint8)
        layer=TITLE_TAG if t>=33.6 else TITLE
        alpha=layer[:,:,3:4]/255*min(1,local/.60)*min(1,(40-t)/.7)
        frame=(frame*(1-alpha)+layer[:,:,:3]*alpha).astype(np.uint8)
    else:
        frame=cv2.resize(scene(key,t,p,mode),(OW,OH),interpolation=cv2.INTER_CUBIC)
        # The opening imagines rewinding toward absence; light arrives with the age line.
        if a==.8:frame=(frame*min(1,local/1.0)).astype(np.uint8)
        if a==9.0:frame=(frame*min(1,(b-t)/1.1)*.65).astype(np.uint8)
        if a==11.6:frame=(frame*min(1,local/.65)).astype(np.uint8)
        if b==29.8:frame=(frame*min(1,(b-t)/.35)).astype(np.uint8)
    if key not in ('black','title'):
        for ta,tb,main,sub,style in TEXT_BEATS:
            if ta<=t<tb:
                reveal=min(1,(t-ta)/.28)*min(1,(tb-t)/.18)
                dim=.43 if style=='center' else .12
                frame=(frame*(1-dim*reveal)).astype(np.uint8)
                layer=TYPE_LAYERS[ta]
                offset=round(24*(1-min(1,(t-ta)/.35))**2)
                if offset:layer=cv2.warpAffine(layer,np.float32([[1,0,offset],[0,1,0]]),(OW,OH))
                alpha=layer[:,:,3:4]/255*reveal
                frame=(frame*(1-alpha)+layer[:,:,:3]*alpha).astype(np.uint8)
                break
    frame[:138]=0;frame[-138:]=0
    if key=='title':
        im=Image.fromarray(frame);d=ImageDraw.Draw(im)
        d.text((OW//2,1012),'ORIGINAL TEASER / ANIMATED AI IMAGERY / 40 SECONDS',font=ImageFont.truetype(FONT,11),fill=(78,91,104),anchor='mt');frame=np.array(im)
    return frame

if '--stills' in sys.argv:
    for t in [3,6,8,13,16,21,24,27.8,35]:
        Image.fromarray(frame_at(t)).save(TMP/f'teaser40-review-{t}.jpg',quality=93)
    print('Teaser review frames ready');sys.exit(0)

N=SR*DURATION;tt=np.arange(N)/SR
voice=np.zeros(N,np.float32);score=np.zeros(N,np.float32)
for at,name in VOICES:
    with wave.open(str(INPUT/name)) as f:
        assert f.getframerate()==SR and f.getnchannels()==1 and f.getsampwidth()==2
        a=np.frombuffer(f.readframes(f.getnframes()),np.int16).astype(np.float32)/32768
    a*=.78/max(.01,np.max(np.abs(a)));k=round(at*SR)
    assert k+len(a)<=N
    voice[k:k+len(a)]+=a

def add(at,a,gain=1):
    k=round(at*SR);n=min(len(a),N-k)
    if k>=0 and n>0:score[k:k+n]+=a[:n]*gain
# Original slow harmonic arc. No borrowed recording or recognizable movie theme.
for j,(at,ch) in enumerate([(0,[45,52,59,60]),(10.5,[41,48,55,57]),(19.4,[38,45,52,53]),(26,[40,47,54,56]),(31.3,[45,52,59,64])]):
    t=np.arange(int(12*SR))/SR;env=(1-np.exp(-t*.65))*np.exp(-np.maximum(t-8,0)*1.1)
    pad=np.zeros(len(t))
    for midi in ch:
        f=440*2**((midi-69)/12)
        for h,amp in [(1,1),(2,.20),(3,.06)]:pad+=.011*amp*np.sin(2*np.pi*f*h*t+.10*np.sin(t*.3))*env
    add(at,pad,.9+j*.14)
for at,note in [(1.8,69),(7.3,76),(12.6,71),(18.7,64),(23.5,67),(27,71),(31.3,69),(35.2,76)]:
    t=np.arange(int(5*SR))/SR;f=440*2**((note-69)/12)
    piano=(np.sin(2*np.pi*f*t)+.25*np.sin(2*np.pi*f*2.002*t))*(1-np.exp(-t*130))*np.exp(-t*1.35)*.055
    add(at,piano);add(at+.38,piano,.16)
for at in np.arange(12.6,29.4,.83):
    t=np.arange(int(.6*SR))/SR
    add(at,np.sin(2*np.pi*(37*t+.7*(1-np.exp(-t*20))))*np.exp(-t*11)*.06)
for at in [.8,4.6,7.2,11.6,19.4,26.3,31.3]:
    t=np.arange(int(2.6*SR))/SR
    hit=.14*np.sin(2*np.pi*36.7*t)*np.exp(-t*3.2)
    air=rng.standard_normal(len(t)).astype(np.float32)
    air=np.convolve(air,np.ones(41)/41,mode='same')
    add(at,hit+air*np.exp(-t*4)*.05)
    # Short rising air before the cut, linked to the type/visual reveal.
    pre=np.arange(int(.45*SR))/SR
    sw=rng.standard_normal(len(pre))
    sw=np.convolve(sw,np.ones(21)/21,mode='same')*(pre/.45)**2*.08
    add(at-.45,sw)

# Natural wind/surf room tone grounds the opening; it bridges the first cut.
noise=rng.standard_normal(N).astype(np.float32)
wind=cv2.GaussianBlur(noise.reshape(1,-1),(0,0),13).ravel()
score+=wind*.022*np.clip((11-tt)/3,0,1)*(.5+.5*np.sin(tt*.65)**2)
env=cv2.blur(np.abs(voice).reshape(1,-1),(18001,1)).ravel()
score*=np.where(env>.018,.50,1.0)
score[(tt>=29.8)&(tt<31.3)]=0
score*=np.clip((40-tt)/1.2,0,1)
stereo=np.column_stack([voice+score,voice+np.roll(score,173)*.98])
stereo=np.tanh(stereo*1.1)*.95
with wave.open(str(TMP/'teaser40-mix.wav'),'wb') as f:
    f.setnchannels(2);f.setsampwidth(2);f.setframerate(SR);f.writeframes((stereo*32767).astype(np.int16).tobytes())
print('40-second original score and edited narration ready',flush=True)

encoder=subprocess.Popen([FF,'-hide_banner','-loglevel','error','-y','-f','rawvideo','-pixel_format','rgb24','-video_size',f'{OW}x{OH}','-framerate',str(FPS),'-i','-','-i',str(TMP/'teaser40-mix.wav'),'-map','0:v','-map','1:a','-c:v','libx264','-preset','fast','-crf','19','-threads','2','-pix_fmt','yuv420p','-af','loudnorm=I=-16:TP=-1.7:LRA=10','-c:a','aac','-b:a','224k','-ar','48000','-t','40','-movflags','+faststart',str(ROOT/'the-search-for-truth-teaser-40s.mp4')],stdin=subprocess.PIPE)
try:
    for fi in range(FPS*DURATION):
        encoder.stdin.write(frame_at(fi/FPS).tobytes())
        if fi%(FPS*5)==0:print(f'Teaser: {fi/FPS:.0f}/40 seconds',flush=True)
finally:encoder.stdin.close()
if encoder.wait():raise RuntimeError('Teaser encoding failed')
print('40-SECOND TEASER COMPLETE',flush=True)
