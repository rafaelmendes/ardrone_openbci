#!/usr/bin/env python
import rospy, pygame, sys
from std_msgs.msg import String
from pygame.locals import *

FPS = 15
WINDOWWIDTH = 930
WINDOWHEIGHT = 450
CELLSIZE = 30
assert WINDOWWIDTH % CELLSIZE == 0, '  '
assert WINDOWHEIGHT % CELLSIZE == 0, '  '
CELLWIDTH = int(WINDOWWIDTH / CELLSIZE)
CELLHEIGHT = int(WINDOWHEIGHT / CELLSIZE)

#             R    G    B
WHITE     = (255, 255, 255)
BLACK     = (  0,   0,   0)
RED       = (255,   0,   0)
GREEN     = (  0, 255,   0)
DARKGREEN = (  0, 155,   0)
DARKGRAY  = ( 40,  40,  40)
BGCOLOR = BLACK

UP = 'up'
DOWN = 'down'
LEFT = 'left'
RIGHT = 'right'

HEAD = 0 
i=0
flag=0
flag2=1

def callback(data):   #callback do publisher
    global i, flag
    i = data.data
    flag=1
    
def listener():       
    global FPSCLOCK, DISPLAYSURF, BASICFONT, score
    pygame.init()
    FPSCLOCK = pygame.time.Clock()
    DISPLAYSURF = pygame.display.set_mode((WINDOWWIDTH, WINDOWHEIGHT))
    BASICFONT = pygame.font.Font('freesansbold.ttf', 18)
    pygame.display.set_caption('Listener')
    score=0
    rospy.init_node('listener', anonymous=True)
    rospy.Subscriber("chatte", String, callback)
    global i
    global flag,flag2
    while True:
        runGame()
    
def runGame():
    startx = 0
    starty = 7
    wormCoords = [{'x': startx,'y': starty}]
    direction = RIGHT
    global i,flag,flag2
    
    while True:
        for event in pygame.event.get(): 
            if event.type == QUIT:
                terminate()

        if flag==1 and flag2==1:
            flag2=0
            if i=='right':
                print('ok')
                newHead = {'x': wormCoords[HEAD]['x'] + 1, 'y': wormCoords[HEAD]['y']}
            elif i=='left':
                newHead = {'x': wormCoords[HEAD]['x'] - 1, 'y': wormCoords[HEAD]['y']}
            elif i=='up':
                newHead = {'x': wormCoords[HEAD]['x'] , 'y': wormCoords[HEAD]['y'] - 1}
            elif i=='down':
                newHead = {'x': wormCoords[HEAD]['x'] , 'y': wormCoords[HEAD]['y'] + 1}
            del wormCoords[-1]
            wormCoords.insert(0, newHead)
            flag=0

        if wormCoords[HEAD]['x'] == -1 or wormCoords[HEAD]['x'] == CELLWIDTH or wormCoords[HEAD]['y'] == -1 or wormCoords[HEAD]['y'] == CELLHEIGHT:
            global score 
            score = score + 1
            break
                 
        DISPLAYSURF.fill(BGCOLOR)
        drawWorm(wormCoords)
        drawGrid()
        drawScore(score)
        pygame.display.update()
        FPSCLOCK.tick(FPS)
        flag2=1
        
def drawWorm(wormCoords):
    for coord in wormCoords:
        x = coord['x'] * CELLSIZE
        y = coord['y'] * CELLSIZE
        wormSegmentRect = pygame.Rect(x, y, CELLSIZE, CELLSIZE)
        pygame.draw.rect(DISPLAYSURF, DARKGREEN, wormSegmentRect)
        wormInnerSegmentRect = pygame.Rect(x + 4, y + 4, CELLSIZE - 8, CELLSIZE - 8)
        pygame.draw.rect(DISPLAYSURF, GREEN, wormInnerSegmentRect)

def drawGrid():
    for x in range(0, WINDOWWIDTH, CELLSIZE): 
        pygame.draw.line(DISPLAYSURF, DARKGRAY, (x, 0), (x, WINDOWHEIGHT))
    for y in range(0, WINDOWHEIGHT, CELLSIZE):
        pygame.draw.line(DISPLAYSURF, DARKGRAY, (0, y), (WINDOWWIDTH, y))  

def drawScore(score):
    scoreSurf = BASICFONT.render('Score: %s' % (score), True, WHITE)
    scoreRect = scoreSurf.get_rect()
    scoreRect.topleft = (WINDOWWIDTH - 120, 10)
    DISPLAYSURF.blit(scoreSurf, scoreRect)      
       
def terminate():
    pygame.quit()
    sys.exit()

if __name__ == '__main__':
    try:
        listener()
    except rospy.ROSInterruptException:
        pass
