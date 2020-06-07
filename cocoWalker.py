
import threading
import time
import logging



class CocoWalker():
    def __init__(self,mkit,iv):
        self.mkit = mkit
        self.iv=iv
        self.state = [[iv[i], iv[i], 10,0] for i in range(4)]
        self.locks = [threading.Lock() for i in range(4)]
        self.run=False 

        self.log = logging.getLogger("cocow")
        self.dataHandler = logging.getLogger("cocodata")

    def setAtIv(self):
        for k,v in enumerate(self.iv):
            self.setAngle(k,v)

    def setAngle(self,mot,angle):
        self.mkit.servo[mot].angle=angle
        self.state[mot][:2] = [angle,angle]
    
    def setRot(self,mot,rot):
        self.mkit.servo[mot].angle = self.iv[mot] + rot

    def startThread(self):

        
        for mot in range(4):
            self.state[mot][-1] = time.time()


        self.run=True 
        self.thread = threading.Thread(target=self.th_loop)
        self.thread.start()

    def th_loop(self):

        
        while self.run:
            now = time.time()
            # for each motor
            for mot,(pos,dest,speed,lastup) in enumerate(self.state):
                self.locks[mot].acquire() 
                self.log.debug("got %s, state %s",mot,(pos,dest,speed,lastup)) 
                # recalculate next step
                now=time.time()
                dur = (now-lastup)
                steplen = min(dur*speed,abs(dest-pos))

                # nextpos
                nextpos = pos+steplen if dest>pos else pos-steplen
                nextpos = int(nextpos) 
                nextposcapped=min(max(nextpos,0),180)#nextpos
                # set 
                if nextpos != pos:

                    self.log.debug("next pos %s,nextpos : %s, capped: %s ,%s"%(mot,nextpos,nextposcapped,int(steplen))) 

                    
                    self.mkit.servo[mot].angle=nextposcapped
                    self.dataHandler.info("next pos %s,nextpos : %s, capped: %s ,%s"%(mot,nextpos,nextposcapped,int(steplen))) 
                # keep state
                self.state[mot][0] = nextposcapped
                self.state[mot][3] = now
    
                self.locks[mot].release() 
                self.log.debug("left %s"%mot) 
                
            time.sleep(.02)

    def stopThread(self):
        self.run=False

    def move(self,mot,rangle,speed=None):
        self.log.debug('move %s',mot)
        self.locks[mot].acquire() 
        if speed :
           self.state[mot][2]= speed
        
        # take lock
        self.state[mot][1] = self.iv[mot]+rangle
        self.locks[mot].release() 
        self.log.debug('done move %s',mot)


class DataHandler(logging.Handler):
    def __init__(self):
        logging.Handler.__init__(self)
        self.data=[]
    def handle(self,logobject):
        self.data.append([float(_) for _ in logobject.msg.split(",")])
    def dump(self):
        print(self.data)
        
        
def setSymFeet(kit,angle,interSleep=0,finalSleep=0):
    for serid,angl in zip(range(2),[90+angle,90-angle]):
        kit.servo[serid].angle = angl
        if interSleep:
            time.sleep(interSleep)

    if finalSleep:
        time.sleep(finalSleep)

def setAll(kit,angle,interSleep=0,finalSleep=0):
    for serid in range(4):
        kit.servo[serid].angle = angle

        if interSleep:
            time.sleep(interSleep)
    if finalSleep:
        time.sleep(finalSleep)


