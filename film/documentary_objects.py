"""Independent object animation for conceptual documentary shots; no filmed-footage claims."""
import cv2,numpy as np
from teaser_vfx import TeaserVFX
class DocumentaryObjects:
 def __init__(self,root,w,h):
  self.w,self.h=w,h;self.vfx=TeaserVFX(root/'teaser-inputs',w,h)
  self.rng=np.random.default_rng(71);self.cells=self.rng.random((27,5))
 def render(self,kind,t):
  w,h=self.w,self.h
  if kind=='planet':return self.vfx.planet(t)
  if kind=='flight':return self.vfx.starfield(t*2.8)
  if kind=='gravity':return self.vfx.accretion(t*2.3)+self.vfx.starfield(t)*.25
  out=self.vfx.starfield(t*.3)*.18
  if kind=='cells':
   for px,py,z,phase,size in sorted(self.cells,key=lambda p:p[2]):
    cx=int((px*w+t*(12+z*16))%(w+220)-110);cy=int(py*h+np.sin(t*.55+phase*9)*48);r=int(15+size*54)
    pulse=1+.055*np.sin(t*1.6+phase*10);r=int(r*pulse)
    # Refractive translucent membrane, shaded volume and internal organelles.
    x0=max(0,cx-r-3);x1=min(w,cx+r+4);y0=max(0,cy-r-3);y1=min(h,cy+r+4)
    if x1<=x0 or y1<=y0:continue
    gy,gx=np.mgrid[y0:y1,x0:x1].astype(np.float32)
    nx=(gx-cx)/r;ny=(gy-cy)/r;dist=np.sqrt(nx*nx+ny*ny)
    inside=dist<1;nz=np.sqrt(np.maximum(0,1-dist*dist))
    membrane=np.exp(-((dist-.96)/.025)**2)
    texture=(np.sin(nx*43+t+phase*8)*np.sin(ny*39-t*.3)+np.sin(nx*71+ny*56+t*.5))*.5
    volume=inside*(.24+.5*nz)*(1+.14*texture)
    highlight=np.exp(-((nx+.33)**2+(ny+.38)**2)/.08)*inside
    color=volume[:,:,None]*np.array([22,61,69])+membrane[:,:,None]*np.array([110,162,164])+highlight[:,:,None]*np.array([48,61,61])
    out[y0:y1,x0:x1]+=color
    for j in range(14):
     ang=t*.25+j*2.4+phase*5;rr=r*(.17+.045*(j%12))
     cv2.circle(out,(int(cx+np.cos(ang)*rr),int(cy+np.sin(ang)*rr)),max(1,int(r*.035)),(52,91,87),-1,cv2.LINE_AA)
   return out+cv2.GaussianBlur(out,(0,0),5)*.25
  if kind=='orbits':
   center=(int(w*.52),int(h*.47))
   for i in range(1,6):
    rad=58+i*65
    cv2.ellipse(out,center,(rad,int(rad*.32)), -14,0,360,(22,42,53),1,cv2.LINE_AA)
    a=t*(.7/i)+i*1.8;xx=rad*np.cos(a);yy=rad*.32*np.sin(a)
    cx=int(center[0]+xx*.97+yy*.24);cy=int(center[1]-xx*.24+yy*.97)
    cv2.circle(out,(cx,cy),5+i,(65+i*16,110+i*12,145+i*8),-1,cv2.LINE_AA)
   cv2.circle(out,center,19,(240,208,151),-1,cv2.LINE_AA)
   return out+cv2.GaussianBlur(out,(0,0),12)*.6
  # Rotating model of an observation/data network, not an atomic scale model.
  nodes=[]
  for j in range(60):
   y=1-2*j/59;r=np.sqrt(1-y*y);a=j*2.399+t*.3
   xx=r*np.cos(a);zz=r*np.sin(a);scale=190/(1.6+zz*.25)
   nodes.append((int(w*.52+xx*scale),int(h*.47+y*scale),zz))
  for j,(x,y,z) in enumerate(nodes):
   for k in [j+1,j+5]:
    if k<len(nodes):cv2.line(out,(x,y),nodes[k][:2],(22,57,76),1,cv2.LINE_AA)
   cv2.circle(out,(x,y),max(1,int(3+z)),(103,185,210),-1,cv2.LINE_AA)
  return out+cv2.GaussianBlur(out,(0,0),4)*.3
