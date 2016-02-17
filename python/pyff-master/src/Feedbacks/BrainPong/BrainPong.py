#!/usr/bin/env python    

# TODO: import logger

# BrainPong.py -
# Copyright (C) 2008-2009  Simon Scholler
#                    2011  Bastian Venthur
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

"""BrainPong BCI Feedback."""


import random
import os

import pygame

from FeedbackBase.PygameFeedback import PygameFeedback


class BrainPong(PygameFeedback):

    # TRIGGER VALUES FOR THE PARALLELPORT (MARKERS)
    START_EXP, END_EXP = 100, 101
    COUNTDOWN_START = 30
    START_TRIAL = 35
    HIT, MISS = 11, 21 
    SHORTPAUSE_START, SHORTPAUSE_END = 249, 250


    def init(self):
        """
        Initializes variables etc., but not pygame itself.
        """
        PygameFeedback.init(self)
        self.caption = 'Brain Pong'
        self.send_parallel(self.START_EXP)
        #self.logger.debug("on_init")
        
        self.durationPerTrial = 0 # if 0, duration last until a miss
        self.trials = 20
        self.pauseAfter = 10
        self.pauseDuration = 3000
        self.availableDirections = ['left', 'right']
        self.FPS = 60
        self.fullscreen = False
        self.screenSize[0] = 1200
        self.screenSize[1] = 700
        self.countdownFrom = 3
        self.hitMissDuration = 1500
        self.timeUntilNextTrial = 500
        self.control = "relative"
        self.g_rel = 0.2
        self.g_abs = 0.7
        self.jitter = 0.0          # jitter to force ball out of the predefined "left-right"-path
        self.bowlSpeed = 2.7       # time from ceiling to bar
        self.barWidth = 30         # in percent of the width of the playing field
        self.bowlDiameter = 20     # in percent of the width of the bar
        self.showCounter = True
        self.showGameOverDuration = 5000
        
        # Feedback state booleans
        self.quit, self.quitting = False, False
        self.pause, self.shortPause = False, False
        self.gameover, self.hit, self.miss = False, False, False
        self.countdown, self.firstTickOfTrial = True, True
        self.showsPause, self.showsShortPause = False, False
       
        self.elapsed, self.trialElapsed, self.countdownElapsed = 0,0,0
        self.hitMissElapsed, self.shortPauseElapsed, self.completedTrials = 0,0,0
        self.showsHitMiss = False
        
        self.resized = False
        self.f = 0.0
        self.hitMiss = [0,0]
        
        # Colours
        self.fontColor = (100, 100, 200)        #(0,150,150)
        self.countdownColor = self.fontColor    #(237, 100, 148)
        
        # Bowl direction
        self.left = True
        self.down = True
        
        # HitMissCounter
        self.counterSize = self.screenSize[1]/15
        self.hitmissCounterColor = (100, 100, 200) #(120, 120, 255)
        self.missstr = " Miss: "
        self.hitstr = "Hit: "
        self.x_transl = 0.8


    def post_mainloop(self):
        #self.logger.debug("Quitting pygame.")
        self.send_parallel(self.END_EXP)
        PygameFeedback.post_mainloop(self)


    def tick(self):
        self.process_pygame_events()
        if self.keypressed:
            step = 0
            if self.lastkey_unicode == u"a":
                step = -0.1
            elif self.lastkey_unicode == u"d":
                step = 0.1
            self.f += step
            if self.f < -1:
                self.f = -1
            if self.f > 1:
                self.f = 1
            self.keypressed = False
        # FIXME: is this line needed?
        pygame.time.wait(10)
        self.elapsed = self.clock.tick(self.FPS)


    def pause_tick(self):
        self.do_print("Pause", self.fontColor, self.size/6)


    def play_tick(self):
        if self.countdown:
            self.countdown_tick()
        elif self.hit or self.miss:
            self.miss_tick()
        elif self.gameover:
            self.gameover_tick()
        elif self.shortPause:
            self.short_pause_tick()
        else:
            self.trial_tick()


    def on_control_event(self, data):
        #self.logger.debug("on_control_event: %s" % str(data))
        self.f = data["cl_output"]
    
    
    def trial_tick(self):
        """
        One tick of the trial loop.
        """
        self.trialElapsed += self.elapsed
        
        if self.firstTickOfTrial:
            self.trialElapsed = 0
            self.BarX = 0
            self.init_graphics()
            self.draw_all(True) 
            pygame.time.wait(self.timeUntilNextTrial)
            self.firstTickOfTrial = False     
            (self.bowlX_float, self.bowlY_float) = (0,0)
            self.direction = (random.randint(0,1)-0.5)*2
            
        
        # Check, if trial is over (if y-pos of bowl is on bottom of the screen)
        # or if the trial time is over
        (bowlPosX, bowlPosY) = self.bowlMoveRect.midbottom
        if bowlPosY >= self.screenSize[1]:
            self.send_parallel(self.MISS)
            self.miss = True; return
        if self.trialElapsed > self.durationPerTrial and self.durationPerTrial != 0:
            self.send_parallel(self.HIT)
            self.hit = True; return
            
        # Calculate motion of bowl
        stepY = 1.0 * (self.barSurface-self.bowlDiameter) / (self.FPS * self.bowlSpeed)
        stepX = stepY / 2 * self.direction
        stepY = stepY + self.direction*self.jitter*stepY
        if self.left == True:   stepX = -stepX
        if self.down == False:  stepY = -stepY
        
        # if bowl is hitting the bar "surface"
        (barLeftX, barRightX) = (self.barMoveRect.left, self.barMoveRect.right)
        if bowlPosY+stepY >= self.barSurface:
            # check if bar is at the same x-coordinate, 
            # if yes: bounce ball, else: miss
            if bowlPosX > barLeftX and bowlPosX < barRightX:
                self.hit_tick()
                stepY = -stepY
            else:
                self.tol = 5      # tolerance
                if barLeftX-bowlPosX>self.tol or bowlPosX-barRightX>self.tol:
                    self.miss = True; return
            self.down = False
            stepY = -stepY
                
        # if bowl is hitting the "ceiling"    
        elif bowlPosY-self.bowlMoveRect.height+stepY < 0:
            self.down = True
            stepY = -stepY
            
        # if bowl is hitting the side of the screen
        border1 = bowlPosX+stepX-(self.bowlMoveRect.width/2+self.wallW)
        border2 = bowlPosX+stepX+self.bowlMoveRect.width/2+self.wallW
        if border1 < 0 or border2 > self.screenSize[0]:
            self.left = not self.left
            stepX = -stepX
                
        # Move bowl
        (self.bowlX_float, self.bowlY_float) = (self.bowlX_float+stepX, self.bowlY_float+stepY)
        self.bowlMoveRect = self.bowlRect.move(self.bowlX_float, self.bowlY_float)
        
        # Move bar according to classifier output
        if self.control == "absolute":
            class_out = self.f
            moveLength = (self.screenSize[0]-2*self.wallW-self.barRect.width) / 2
            self.barMoveRect = self.barRect.move(max(min(moveLength, class_out*moveLength*self.g_abs), -moveLength),0)
        elif self.control == "relative":
            class_out = self.f
            newBarX = class_out*self.playWidth*self.g_rel*0.1+self.BarX
            barLeft = self.screenSize[0]/2+newBarX-self.barRect.width/2
            barRight = self.screenSize[0]/2+newBarX+self.barRect.width/2
            if barLeft > self.wallW and barRight < self.screenSize[0] - self.wallW:
                self.barMoveRect = self.barRect.move(newBarX,0)
            else: # if bar would move into the wall
                if newBarX < 0:
                    newBarX = -self.playWidth/2+self.barRect.width/2
                else:
                    newBarX = self.playWidth/2-self.barRect.width/2
                self.barMoveRect = self.barRect.move(newBarX,0)
            self.BarX = newBarX
        else:
            raise Exception("Control type unknown (know types: 'absolute' and 'relative').")   
        
        # Update hit-miss counter
        if self.showCounter:
            s = self.hitstr + str(self.hitMiss[0]).rjust(2) + self.missstr + str(self.hitMiss[-1]).rjust(2)
            center = (self.wallW+self.playWidth*self.x_transl, self.size/20)
        
        self.draw_all(True)

        
    def short_pause_tick(self):
        """
        One tick of the short pause loop.
        """
        if self.shortPauseElapsed == 0:
            self.send_parallel(self.SHORTPAUSE_START)
        self.shortPauseElapsed += self.elapsed
        if self.shortPauseElapsed >= self.pauseDuration:
            self.firstTickOfTrial = True
            self.showsShortPause = False
            self.shortPause = False
            self.shortPauseElapsed = 0
            self.countdown = True
            self.send_parallel(self.SHORTPAUSE_END)
            return
        if self.showsShortPause:
            return
        self.draw_all()
        self.do_print("Short Break...", self.fontColor, self.size/10)
        pygame.display.update()
        self.showsShortPause = True

    
    def countdown_tick(self):
        """
        One tick of the countdown loop.
        """
        if self.countdownElapsed == 0:
            self.send_parallel(self.COUNTDOWN_START)
            self.init_graphics()
        self.countdownElapsed += self.elapsed
        if self.countdownElapsed >= (self.countdownFrom+1) * 1000:
            self.countdown = False
            self.countdownElapsed = 0
            return
        t = ((self.countdownFrom+1) * 1000 - self.countdownElapsed) / 1000
        self.draw_all()
        self.do_print(str(t), self.countdownColor, self.size/3)
        pygame.display.update()
        
    def gameover_tick(self):
        """
        One tick of the game over loop.
        """
        self.draw_all()
        self.do_print("Game Over! (%i : %i)" % (self.hitMiss[0], self.hitMiss[1]), self.fontColor, self.size/10)
        pygame.display.update()
        pygame.time.wait(self.showGameOverDuration)
        self.quitting = True

    def hit_tick(self):
        self.down = False
        self.hitMiss[0] += 1
        self.completedTrials += 1
        if self.completedTrials % self.pauseAfter == 0:
            self.shortPause = True
        if self.completedTrials >= self.trials:
            self.gameover = True
        
        
    def miss_tick(self):
        """
        One tick of the Miss loop.
        """
        self.hitMissElapsed += self.elapsed
        if self.hitMissElapsed >= self.hitMissDuration:
            self.hitMissElapsed = 0
            self.hit, self.miss = False, False
            self.showsHitMiss = False
            return
        if self.showsHitMiss:
            return
        
        self.completedTrials += 1; 
        self.firstTickOfTrial = True   # TODO: Check this!!
        self.hitMiss[-1] += 1
            
        if self.completedTrials % self.pauseAfter == 0:
            self.shortPause = True
        if self.completedTrials >= self.trials:
            self.gameover = True
            
        self.draw_all(True)
        self.showsHitMiss = True


    def do_print(self, text, color, size=None, center=None, superimpose=True):
        """
        Print the given text in the given color and size on the screen.
        """
        if not color:
            color = self.fontColor
        if not size:
            size = self.size/10
        if not center:
            center = self.screen.get_rect().center

        font = pygame.font.Font(None, size)
        if not superimpose:
            self.screen.blit(self.background, self.backgroundRect)
        surface = font.render(text, 1, color)
        self.screen.blit(surface, surface.get_rect(center=center))
        

    def init_graphics(self):
        """
        Initialize the surfaces and fonts depending on the screen size.
        """
        self.screen = pygame.display.get_surface()
        self.size = min(self.screen.get_height(), self.screen.get_width())
        barHeight = self.screenSize[1]/15
        try:
            self.oldPlayWidth = self.playWidth
            self.oldBarSurface = self.barSurface
        except:
            pass
        self.barSurface = self.screenSize[1]-barHeight * 3/2
        
        path = os.path.dirname( globals()["__file__"] )
        
        # init background
        img = pygame.image.load(os.path.join(path, 'bg.png')).convert()
        self.background = pygame.Surface((self.screenSize[0], self.screenSize[1]))
        self.background = pygame.transform.scale(img, (self.screenSize[0], self.screenSize[1]))
        self.backgroundRect = self.background.get_rect(center=self.screen.get_rect().center)
                
        # init walls
        self.wallSize = (max(0,(self.screenSize[0]-self.barSurface)/2),self.screenSize[1])
        self.wallW = self.wallSize[0] # width of wall
        img = pygame.image.load(os.path.join(path, 'wall_metal_blue.png')).convert()
        self.wall = pygame.Surface(self.wallSize)
        self.wall = pygame.transform.scale(img, self.wallSize)
        self.wallRect1 = self.wall.get_rect(topleft=(0,0), size=self.wallSize)
        self.wallRect2 = self.wall.get_rect(topleft=(self.screenSize[0]-self.wallW,0))   
        self.fontsize_target = self.size/16
        
        # init bar
        barWidth = int((self.screenSize[0]-2*self.wallW) * (self.barWidth/100.0))
        barSize = (barWidth, barHeight)
        img = pygame.image.load(os.path.join(path, 'bar_metallic3.png')).convert()
        self.bar = pygame.Surface(barSize)
        self.bar = pygame.transform.scale(img, barSize)
        self.barMB = (self.screenSize[0]/2, self.barSurface+barHeight)
        self.barRect = self.bar.get_rect(midbottom=self.barMB)
        
        # init bowl
        diameter = int(barWidth * (self.bowlDiameter / 100.0))
        bowlSize = (diameter, diameter)
        img = pygame.image.load(os.path.join(path, 'bowl_metallic_blue.png')).convert()
        self.bowl = pygame.Surface(bowlSize)
        self.bowl = pygame.transform.scale(img, bowlSize)
        self.bowlRect = self.bowl.get_rect(center=((self.screenSize[0]-2*self.wallW)/3+self.wallW, diameter/2))
        self.bowl.set_colorkey((168,180,255))
        
        # calculate width of playing area
        self.playWidth = self.screenSize[0]-2*self.wallW
       
        if not self.resized:
            # init helper rectangle for bar and bowl (deep copy)
            self.barMoveRect = self.barRect.move(0,0)
            self.bowlMoveRect = self.bowlRect.move(0,0)
        else:
            self.resized = False
            self.counterSize = self.screenSize[1]/20
            # update position of bar and bowl
            self.bowlY_float = (1.0*self.barSurface / self.oldBarSurface) * self.bowlY_float
            self.bowlX_float = (1.0* self.playWidth / self.oldPlayWidth) * self.bowlX_float
            self.bowlMoveRect = self.bowlRect.move(self.bowlX_float, self.bowlY_float)
            if self.control == "relative":
                self.BarX = (1.0* self.playWidth / self.oldPlayWidth) * self.BarX
                self.barMoveRect = self.barRect.move(self.BarX,0)
                
    def draw_all(self, draw=False):
        # draw images on the screen
        self.screen.blit(self.background, self.backgroundRect)
        self.screen.blit(self.wall, self.wallRect1)
        self.screen.blit(self.wall, self.wallRect2)
        if self.showCounter:
            s = self.hitstr + str(self.hitMiss[0]).rjust(2) + self.missstr + str(self.hitMiss[-1]).rjust(2)
            center = (self.wallW+self.playWidth*self.x_transl, self.size/20)
            self.do_print(s, self.hitmissCounterColor, self.counterSize, center)
        self.screen.blit(self.bowl, self.bowlMoveRect)
        self.screen.blit(self.bar, self.barMoveRect)
        if draw:
            pygame.display.flip()



if __name__ == '__main__':
    bp = BrainPong()
    bp.on_init()
    #self.send_parallel(200)
    bp.on_play()
