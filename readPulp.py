
from adafruit_servokit import ServoKit
import time
import logging
import json
from pprint import pprint
import cocoWalker
from iv import iv,LEFTFEET,RIGHTFEET,LEFTHIP,RIGHTHIP


logging.basicConfig(level=logging.DEBUG)

with open("./file.json","r") as fin:
    dd = json.load(fin)

def lin_equ(l1, l2):
    """Line encoded as l=(x,y)."""
    m = float((l2[1] - l1[1])) / float(l2[0] - l1[0])
    c = (l2[1] - (m * l2[0]))
    return m, c



nameMap = {
	"feetL":LEFTFEET,
	"feetR":RIGHTFEET,
	"hipL":LEFTHIP,
	"hipR":RIGHTHIP,
}



# calculate equations for each mot
rngsbymot = {}
for mot,points in dd.items():
    motid = nameMap[mot]
    rngs=[]

    for _ in range(len(points)-1):
        a,b = lin_equ((points[_]["x"],points[_]["y"]),(points[_+1]["x"],points[_+1]["y"]))
        
        rng = ( points[_]["x"],points[_+1]["x"] )
        
        rngs.append([rng,a,b])

    rngsbymot[motid]=rngs


repeat = 3
dursec= 5

sleepPause= 10 / float(1000)

sampling= float(dursec) /sleepPause


sampledPos = []
for _ in range(int(sampling)):

    tn = _/float(sampling)
    posattime={_:0 for _ in range(4)}
    for motid,rngs in rngsbymot.items():

        pos = [ a*tn+b for rng,a,b in rngs if tn>=rng[0] and tn<rng[1] ]
        
        pos = pos[0] if len(pos)>0 else 0 
        posattime[motid] = pos


    sampledPos.append(posattime)

#pprint(sampledPos)


scales = [80,80,-64,-64]

kit = ServoKit(channels=16)
coco = cocoWalker.CocoWalker(kit,iv)
coco.setAtIv()

time.sleep(.5)
count = 0
while count <repeat:
    for posattime in sampledPos:
        strt = time.time()
        for motid,pos in posattime.items():
            rot = pos*scales[motid]
            coco.setRot(motid,rot)
        dur = sleepPause-(time.time()-strt)
        if dur>0 : time.sleep(dur)

    count +=1

print("done")
coco.setAtIv()
time.sleep(.5)

