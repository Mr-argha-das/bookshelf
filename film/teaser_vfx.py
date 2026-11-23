"""Visible procedural motion for the 40-second teaser, without live-action claims.
Rotating shaded sphere, perspective star flight and animated accretion particles.
The accretion visualization is artistic, not a general-relativistic simulation.
"""
from pathlib import Path
import cv2
import numpy as np
from PIL import Image

class TeaserVFX:
    def __init__(self,input_dir,width=1280,height=720):
        self.w,self.h=width,height
        self.yy,self.xx=np.mgrid[0:height,0:width].astype(np.float32)
        self.u=self.xx/width;self.v=self.yy/height
        self.texture=np.array(Image.open(Path(input_dir)/'earth-surface.jpg').convert('RGB')).astype(np.float32)
        rng=np.random.default_rng(24342)
        self.stars=rng.uniform(-1,1,(1600,3)).astype(np.float32)
        self.stars[:,2]=rng.uniform(.1,4,1600)
        self.phase=rng.uniform(0,2*np.pi,7000)
        self.radius=rng.uniform(.09,.68,7000)
        self.energy=rng.uniform(.3,1,7000)

    def starfield(self,t):
        out=np.zeros((self.h,self.w,3),np.float32)
        z=(self.stars[:,2]-t*.11)%4+.12
        x=(self.stars[:,0]/z*self.w*.65+self.w/2).astype(int)
        y=(self.stars[:,1]/z*self.w*.65+self.h/2).astype(int)
        ok=(x>=1)&(x<self.w-1)&(y>=1)&(y<self.h-1)
        lum=np.clip(1.1/z[ok],.2,1)
        color=lum[:,None]*np.array([143,172,203])
        np.add.at(out,(y[ok],x[ok]),color)
        np.add.at(out,(y[ok]+1,x[ok]),color*.18)
        return out

    def planet(self,t):
        out=self.starfield(t)*.58
        r=self.h*.371
        nx=(self.xx-self.w*.55)/r;ny=(self.yy-self.h*.5)/r
        r2=nx*nx+ny*ny;inside=r2<1
        nz=np.sqrt(np.maximum(0,1-r2))
        lon=np.arctan2(nx,nz)+t*.16
        lat=np.arcsin(np.clip(ny,-1,1))
        th,tw=self.texture.shape[:2]
        tx=((lon/(2*np.pi)+.5)*tw)%tw
        ty=np.clip((lat/np.pi+.5)*(th-1),0,th-1)
        surface=cv2.remap(self.texture,tx.astype(np.float32),ty.astype(np.float32),cv2.INTER_LINEAR,borderMode=cv2.BORDER_WRAP)
        light=np.maximum(0,-nx*.68-ny*.26+nz*.62)
        shade=.065+.98*light
        surf=surface*shade[:,:,None]
        rim=(1-nz)**3*inside*(.35+.65*light)
        surf+=rim[:,:,None]*np.array([18,91,147])
        out[inside]=surf[inside]
        dist=np.maximum(np.sqrt(r2)-1,0)
        glow=np.exp(-dist*62)*(~inside)
        out+=glow[:,:,None]*np.array([8,42,72])
        sun=np.exp(-np.sqrt((self.u-.19)**2+(self.v-.24)**2)*29)
        out+=sun[:,:,None]*np.array([290,186,78])
        return out

    def accretion(self,t):
        out=np.zeros((self.h,self.w,3),np.float32)
        # Differential angular velocity makes inner streamlines move faster.
        angle=self.phase+t*.35/(self.radius+.13)**1.2
        x=self.radius*np.cos(angle)
        y=.19*x+.085*self.radius*np.sin(angle)
        behind=(np.sin(angle)>0)&(np.abs(x)<.085)
        arc=np.sqrt(np.maximum(0,1-(x/.085)**2))
        y=np.where(behind,-.109*arc+.19*x,y)
        # Secondary weak lower arc is a separate lensed image, not another object.
        x0=.58+x;y0=.50+y
        ok=(((x0-.58)/.051)**2+((y0-.50)/.079)**2>1)
        px=(x0*self.w).astype(int);py=(y0*self.h).astype(int)
        ok&=(px>1)&(px<self.w-2)&(py>1)&(py<self.h-2)
        intensity=self.energy[ok]*np.exp(-self.radius[ok]*1.6)*.25
        color=intensity[:,None]*np.array([172,119,66])
        np.add.at(out,(py[ok],px[ok]),color)
        np.add.at(out,(py[ok]+1,px[ok]),color*.32)
        out+=cv2.GaussianBlur(out,(0,0),2)*.48
        return out
