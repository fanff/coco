#!/usr/bin/env python

# WS server example

import asyncio
import websockets
import time
import numpy as np
import logging
import json
from pprint import pprint

import cocoWalker
from iv import iv,LEFTFEET,RIGHTFEET,LEFTHIP,RIGHTHIP,nameMap

class ServoMockup():
    def __setattr__(self,thing,value):
        logging.info("setting %s : %s"%(thing,value))
class SKitMockup():
    def __init__(self):
        self.servo = [ServoMockup() for i in range(16)]

instantConfig={
        "freqfact":0.0,
        "amplfact":0.0
        }

currentConfig=instantConfig

async def hello(websocket, path):
    log = logging.getLogger("handler")
    global instantConfig
    while True:
        name = await websocket.recv()
        data = json.loads(name)
        instantConfig = {k:float(v) for k,v in data.items()}
        log.info(instantConfig)
        


def posgen(d,freq = .5, phase = .25,ampl=1,shift=0.3):
    return np.sin(freq*(d*2*np.pi + 2*np.pi*phase))*(ampl/2)+shift
def forward(freqfact=1,amplfact = 1.0):
    rf= {"freq" :.4*freqfact, "phase" : 0.5,"ampl":1.0*amplfact,"shift":0.2}
    lf= {"freq" :.4*freqfact, "phase" : 0.5,"ampl":1.0*amplfact,"shift":-0.2}


    hr= {"freq" :.4*freqfact, "phase" : .2,"ampl":.9*amplfact,"shift":0.2}
    hl= {"freq" :.4*freqfact, "phase" : .2,"ampl":.9*amplfact,"shift":0.2}
    
    return {"feetR":rf,"feetL":lf,"hipR":hr,"hipL":hl}

async def bgjob():
    log = logging.getLogger("bgjob")
    try:
        from adafruit_servokit import ServoKit
        kit = ServoKit(channels=16)
    except Exception as e:
        log.warning("mocking up") 
        kit = SKitMockup()

    coco = cocoWalker.CocoWalker(kit,iv)
    coco.setAtIv()
    time.sleep(.5)

    global currentConfig
    gamma = .20
    log.info("OP!")
    scales = [80,80,-64,-64]
    while True:
        now = time.time()
        #log.info("instantConfig : %s",instantConfig)
        currentConfig = { k:(v*gamma+(float(instantConfig[k])*(1-gamma))) for k,v in currentConfig.items()}
        #log.info("currentConfig : %s",currentConfig)
        freqfact=float(currentConfig["freqfact"])
        amplfact=float(currentConfig["amplfact"])

        signdef = forward(freqfact,amplfact)
        motpos = {k:posgen(now,**v) for k,v in signdef.items()}

        #log.info("motpos : %s",motpos)
        for motname,pos in motpos.items():

            motid=nameMap[motname]
            rot = pos*scales[motid]
            coco.setRot(motid,rot)

        sleepdur = .05-(time.time()-now)
        if sleepdur>0:
            await asyncio.sleep(sleepdur)
        else:
            print(".")



logging.basicConfig(level=logging.INFO)
start_server = websockets.serve(hello, "0.0.0.0", 8765)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_until_complete(bgjob())
asyncio.get_event_loop().run_forever()


