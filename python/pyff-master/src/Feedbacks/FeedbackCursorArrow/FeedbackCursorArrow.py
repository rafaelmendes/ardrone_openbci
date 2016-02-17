
#!/usr/bin/env python


# FeedbackCursorArrow.py -
# Copyright (C) 2008-2009  Bastian Venthur, Simon Scholler
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

"""CursorArrow BCI Feedback."""


import random
import sys
import math

import pygame

from FeedbackBase.PygameFeedback import PygameFeedback


class FeedbackCursorArrow(PygameFeedback):

################################################################################
# Derived from Feedback
#vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

# Markers written to parallel port
#    1: target on left side
#    2: target on right side
#   11: trial ended with cursor correctly on the left side
#   12: trial ended with cursor correctly on the right side
#   21: trial ended with cursor erroneously on the left side
#   22: trial ended with cursor erroneously on the right side
#   24: trial ended by time-out policy='reject'
#   30: countdown starts
#   33: in position control, cursor becomes active in center area
#   41: first touch with cursor correctly on the left side
#   42: first touch with cursor correctly on the right side
#   51: first touch with cursor erroneously on the left side
#   52: first touch with cursor erroneously on the right side
#   70: start of adaptation phase 1 (rotating cursor)
#   71: end of adaptation phase 1
#  200: init of the feedback
#  210: game status changed to 'play'
#  211: game status changed to 'pause'
#  254: game ends

    TARGET_LEFT = 1
    TARGET_RIGHT = 2
    HIT_CURSOR_LEFT = 11
    HIT_CURSOR_RIGHT = 12
    MISS_CURSOR_LEFT = 21       # TODO: what if ['right', 'foot'], ['left', 'foot']
                                # evtl. rename constants to *_direction1/*_direction2
    MISS_CURSOR_RIGHT = 22
    TRIAL_END_REJECT = 24
    COUNTDOWN_START = 30
    START_POSITION_CONTROL = 33
    HIT_FT_CURSOR_LEFT = 41
    HIT_FT_CURSOR_RIGHT = 42
    MISS_FT_CURSOR_LEFT = 51
    MISS_FT_CURSOR_RIGHT = 52
    INIT_FEEDBACK = 200
    GAME_STATUS_PLAY = 210
    GAME_STATUS_PAUSE = 211
    GAME_OVER = 254


    def init(self):
        """
        Initializes the variables and stuff, but not pygame itself.
        """
        PygameFeedback.init(self)
        self.logger.debug("on_init")
        self.caption = 'Cursor Arrow Feedback'
        self.send_parallel(self.INIT_FEEDBACK)

        self.durationUntilBorder = 1000
        self.durationPerTrial = 4000
        self.durationIndicateGoal = 1000
        self.trials = 20
        self.pauseAfter = 4
        self.pauseDuration = 9000
        self.availableDirections =  ['right', 'foot']
        self.FPS =  50
        self.fullscreen =  False
        self.screenWidth =  1000
        self.screenHeight =  700
        self.countdownFrom = 2
        self.hitMissDuration =  1000
        self.dampedMovement = False
        self.showPunchline = True
        #self.damping = 'linear'
        self.damping = 'distance'

        self.pause = False
        self.quit = True
        self.quitting = True

        self.gameover = False
        self.countdown = True
        self.hit = False
        self.miss = False
        self.shortPause = False
        self.indicateGoal = False

        self.firstTickOfTrial = True

        self.showsPause, self.showsShortPause = False, False
        self.showsHitMiss, self.showsGameover = False, False

        self.elapsed, self.trialElapsed, self.countdownElapsed = 0,0,0
        self.hitMissElapsed, self.shortPauseElapsed, self.indicateGoalElapsed = 0,0,0

        self.completedTrials = 0

        self.f = 0
        self.hitMiss = [0,0]
        self.resized = False
        self.pos = 0
        self.targetDirection = 0

        self.arrowPointlist = [(.5,0), (.5,.33), (1,.33), (1,.66), (.5,.66), (.5,1), (0,.5)]
        self.arrowColor = (127, 127, 127)
        self.borderColor = self.arrowColor
        self.backgroundColor = (64, 64, 64)
        self.cursorColor = (100, 149, 237)
        self.fontColor = self.cursorColor
        self.countdownColor = (237, 100, 148)
        self.punchLineColor = self.cursorColor
        self.punchLineColorImpr = (100, 200 , 100)  # if punchline is improved

        self.punchlineThickness = 5   # in pixels
        self.borderWidthRatio = 0.4     # in pixels
        self.punchlinePos1, self.punchlinePos2 = 0,0

        #=============
        # NOTE: only one of the following variables should be True
        self.hitIfLateral = True
        self.reject = False
        #=============


        # How many degrees counter clockwise to turn an arrow pointing to the
        # left to point at left, right and foot
        self.LEFT, self.RIGHT, self.DOWN, self.UP = 'left', 'right', 'foot', 'up'
        self.directions = {self.LEFT: 0, self.RIGHT: 180, self.DOWN: 90, self.UP: 270}


    def pre_mainloop(self):
        PygameFeedback.pre_mainloop(self)
        self.logger.debug("on_play")
        self.send_parallel(self.GAME_STATUS_PLAY)


    def post_mainloop(self):
        self.logger.debug("on_quit")
        PygameFeedback.post_mainloop(self)
        self.send_parallel(self.GAME_OVER)


    def tick(self):
        self.process_pygame_events()
        if self.keypressed:
            step = 0
            if self.lastkey_unicode == u"a": step = -0.1
            elif self.lastkey_unicode == u"d" : step = 0.1
            self.f += step
            if self.f < -1: self.f = -1
            if self.f > 1: self.f = 1
        pygame.time.wait(10)
        self.elapsed = self.clock.tick(self.FPS)


    def play_tick(self):
        """
        Decides in wich state the feedback currently is and calls the apropriate
        tick method.
        """
        if self.pause:
            self.pause_tick()
        elif self.hit or self.miss:
            self.hit_miss_tick()
        elif self.gameover:
            self.gameover_tick()
        elif self.countdown:
            self.countdown_tick()
        elif self.shortPause:
            self.short_pause_tick()
        elif self.indicateGoal:
            self.indicate_goal_tick()
        else:
            self.trial_tick()


    def on_control_event(self, data):
        #self.logger.debug("on_control_event: %s" % str(data))
        self.f = data["data"][ - 1]


    def trial_tick(self):
        """
        One tick of the trial loop.
        """
        self.trialElapsed += self.elapsed

        # Teste ob erster Tick im Trial
        if self.firstTickOfTrial:
            self.send_parallel(self.START_POSITION_CONTROL)
            self.firstTickOfTrial = False
            self.trialElapsed = 0
            self.pos = 0
            self.counter = 1
            self.nDampTicks = 0
            self.reset_punchline_color()
            self.cursorTransition = False

        # Teste ob zeit fuer alten Trial abgelaufen ist
        if self.trialElapsed >= self.durationPerTrial:
            self.check_for_hit_miss(); return

        # Calculate motion of cursor
        self.f = (self.targetDirection-0.5)*2   #TODO: remove HACK

        if not self.dampedMovement:
            v = self.f * self.v0
        else:
            v = self.damp_movement()

        self.pos += self.f * v

        # send marker if cursor hits the border for the first time
        if abs(self.pos)>self.s1 and not self.cursorTransition:
            self.cursorTransition = True
            if self.pos<0 and self.targetDirection==0:
                self.send_parallel(self.HIT_FT_CURSOR_LEFT)
            elif self.pos>0 and self.targetDirection==1:
                self.send_parallel(self.HIT_FT_CURSOR_RIGHT)
            elif self.pos<0 and self.targetDirection==1:
                self.send_parallel(self.MISS_FT_CURSOR_LEFT)
            else:
                self.send_parallel(self.MISS_FT_CURSOR_RIGHT)

        self.update_cursor()

        if abs(self.pos) >= self.size/2:
            self.check_for_hit_miss(); return

        self.draw_all()


    def indicate_goal_tick(self):
        """
        Indicate goal before start of trial (i.e. before position control).
        """
        if self.indicateGoalElapsed==0:
            self.targetDirection = self.targetDirections[self.completedTrials % self.pauseAfter]
            self.myarrow = pygame.transform.rotate(self.arrow, self.directions[self.availableDirections[self.targetDirection]])
            self.myarrowRect = self.myarrow.get_rect(center=self.screen.get_rect().center)
            self.cursorRect.center = self.screen.get_rect().center
            self.reset_punchline_color()

            if self.targetDirection==0:
                self.send_parallel(self.TARGET_LEFT)
            else:
                self.send_parallel(self.TARGET_RIGHT)

        self.indicateGoalElapsed += self.elapsed
        if self.durationIndicateGoal<self.indicateGoalElapsed:
            self.indicateGoalElapsed = 0
            self.indicateGoal = False
        self.draw_all()



    def pause_tick(self):
        """
        One tick of the pause loop.
        """
        if self.showsPause:
            return
        self.do_print("Pause", self.fontColor, self.size/4)
        self.showsPause = True


    def short_pause_tick(self):
        """
        One tick of the short pause loop.
        """
        self.shortPauseElapsed += self.elapsed
        if self.shortPauseElapsed >= self.pauseDuration:
            self.showsShortPause = False
            self.shortPause = False
            self.shortPauseElapsed = 0
            self.countdown = True
            return
        if self.showsShortPause:
            return
        self.draw_init()
        self.do_print("Short Break...", self.fontColor)
        self.showsShortPause = True


    def countdown_tick(self):
        """
        One tick of the countdown loop.
        """
        if self.countdownElapsed==0:
            self.send_parallel(self.COUNTDOWN_START)

        self.countdownElapsed += self.elapsed
        if self.countdownElapsed >= self.countdownFrom * 1000:
            self.countdown = False
            self.indicateGoal = True
            self.countdownElapsed = 0
            # initialize targets for the upcoming trial block randomly (equal 'left' and 'right' trials)
            self.targetDirections = [1] * int(self.pauseAfter)
            self.targetDirections[0:int(self.pauseAfter / 2)] = [0] * int(self.pauseAfter / 2)
            random.shuffle(self.targetDirections)
            return
        t = (self.countdownFrom * 1000 - self.countdownElapsed) / 1000
        self.draw_init()
        self.do_print(str(t), self.countdownColor, self.size/3, True)


    def gameover_tick(self):
        """
        One tick of the game over loop.
        """
        if self.showsGameover:
            return
        self.do_print(["Game Over! (%i : %i)" % (self.hitMiss[0], self.hitMiss[1]),
                       'Line success (%s,%s): %i%%, %i%%' % (self.availableDirections[0], self.availableDirections[1], 100*self.punchlinePos1, 100*self.punchlinePos2)],
                       self.fontColor, self.size/15)
        self.showsGameover = True


    def hit_miss_tick(self):
        """
        One tick of the Hit/Miss loop.
        """
        self.hitMissElapsed += self.elapsed
        if self.hitMissElapsed >= self.hitMissDuration:
            self.hitMissElapsed = 0
            self.hit, self.miss, self.reject = False, False, False
            self.showsHitMiss = False
            self.indicateGoal = True
            return
        if self.showsHitMiss:
            return

        self.completedTrials += 1
        self.firstTickOfTrial = True
        s = ""
        if self.hit:
            s = "Hit"
            self.hitMiss[0] += 1
        elif self.miss:
            s = "Miss"
            self.hitMiss[-1] += 1
        elif self.reject:
            s = "Draw"

        if self.completedTrials % self.pauseAfter == 0:
            self.shortPause = True
        if self.completedTrials >= self.trials:
            self.gameover = True

        self.draw_all()
        self.do_print(s, None, None, True)
        pygame.display.update()
        self.showsHitMiss = True

    def damp_movement(self):
        if self.damping == 'linear':
            if abs(self.pos)>self.s1:
                s = abs(self.pos)-self.s1
                t = self.t2 - (math.sqrt(4*self.s2*(self.s2-s))/self.v0)
                return self.v0 * ((self.t2-t)/self.t2)
            else:
                return self.v0
        elif self.damping == 'distance':
            if self.trialElapsed == 0:
                self.v0 = self.s1/(self.FPS*self.durationUntilBorder/1000.0)
            if abs(self.pos)>self.s1:
                s = abs(self.pos)-self.s1
                return (1.0*(self.borderWidth-s)/self.borderWidth)*self.v0
            else:
                return self.v0

    def check_for_hit_miss(self):
        if self.reject:
            if abs(self.pos) <= self.arrowRect.width/2:
                self.send_parallel(self.TRIAL_END_REJECT)
                self.reject = True; return

        if (self.pos<0 and self.targetDirection==0) or (self.pos>0 and self.targetDirection==1):
            if (self.pos<0 and self.targetDirection==0):
                self.send_parallel(self.HIT_CURSOR_LEFT)
            else:
                self.send_parallel(self.HIT_CURSOR_RIGHT)

            if self.hitIfLateral:
                self.hit = True
                if self.availableDirections[self.targetDirection] == self.direction:
                    if self.pos<0 and self.punchline1Rect.centerx>self.screenWidth/2+self.pos:
                        self.punchline1Rect = self.update_punchline(self.punchline1, self.pos, self.availableDirections[0])
                        self.punchlinePos1 = abs(self.pos+self.innerRect.width/2.0)/self.borderWidth
                        self.punchline1.fill(self.punchLineColorImpr)
                    elif self.pos>0 and self.punchline2Rect.centerx<self.screenWidth/2+self.pos:
                        self.punchline2Rect = self.update_punchline(self.punchline2, self.pos, self.availableDirections[1])
                        self.punchlinePos2 = abs(self.pos-self.innerRect.width/2.0)/self.borderWidth
                        self.punchline2.fill(self.punchLineColorImpr)
        else:
            self.miss = True
            if self.pos<0:
                self.send_parallel(self.MISS_CURSOR_LEFT)
            else:
                self.send_parallel(self.MISS_CURSOR_RIGHT)


    def update_punchline(self, punchline, newpos, direction):
        newpos = abs(newpos)
        if direction==self.LEFT:
            return punchline.get_rect(midtop=(self.screenWidth/2-newpos, 0))
        elif direction==self.RIGHT:
            return punchline.get_rect(midtop=(self.screenWidth/2+newpos, 0))
        elif direction==self.UP:
            return punchline.get_rect(midleft=(self.borderRect.left,self.screenHeight/2-newpos))
        elif direction==self.DOWN:
            return punchline.get_rect(midleft=(self.borderRect.left,self.screenHeight/2+newpos))

    def reset_punchline_color(self):
        self.punchline1.fill(self.punchLineColor)
        self.punchline2.fill(self.punchLineColor)

    def update_cursor(self):
        """
        Update the cursor position.
        """
        self.cursorRect.center = self.backgroundRect.center
        self.direction = self.availableDirections[0]
        if self.pos > 0:
            self.direction = self.availableDirections[1]
        border = self.borderRect.width/2
        self.pos = min(border, max(-border, self.pos));
        arrowPos = { self.LEFT  : (-abs(self.pos),0),
                     self.RIGHT : (abs(self.pos),0),
                     self.DOWN  : (0,abs(self.pos)),
                     self.UP    : (0,-abs(self.pos))
                   }[self.direction]
        self.cursorRect.move_ip(arrowPos)


    def do_print(self, text, color=None, size=None, superimpose=False):
        """
        Print the given text in the given color and size on the screen.
        If text is a list, multiple items will be used, one for each list entry.
        """
        if not color:
            color = self.fontColor
        if not size:
            size = self.size/10

        font = pygame.font.Font(None, size)
        if not superimpose:
            self.draw_init()

        if type(text) is list:
            height = pygame.font.Font.get_linesize(font)
            top = -(2*len(text)-1)*height/2
            for t in range(len(text)):
                surface = font.render(text[t], 1, color)
                self.screen.blit(surface, surface.get_rect(midtop=(self.screenWidth/2, self.screenHeight/2+top+t*2*height)))
        else:
            surface = font.render(text, 1, color)
            self.screen.blit(surface, surface.get_rect(center=self.screen.get_rect().center))
        pygame.display.update()


    def init_graphics(self):
        """
        Initialize the surfaces and fonts depending on the screen size.
        """
        self.screen = pygame.display.get_surface()
        (self.screenWidth, self.screenHeight) = (self.screen.get_width(), self.screen.get_height())
        self.size = min(self.screen.get_height(), self.screen.get_width())
        self.borderWidth = int(self.size*self.borderWidthRatio/2)
        self.offsetX = (self.screenWidth-self.size)/2
        self.s1 = self.size/2-self.borderWidth
        self.s2 = self.borderWidth

        if self.dampedMovement:
            self.v0 = self.s2/(1.0*self.t2) + self.s1/(2.0*self.t1)
            self.dampingTime = self.durationPerTrial-self.durationUntilBorder
            self.t1 = self.FPS * self.durationUntilBorder/1000
            self.t2 = self.FPS * self.dampingTime/1000
        else:
            self.v0 = (self.size * 0.5) / (self.durationPerTrial*self.FPS/1000.0)

        # arrow
        scale = self.size / 3
        scaledArrow = [(P[0]*scale, P[1]*scale) for P in self.arrowPointlist]
        self.arrow = pygame.Surface((scale, scale))
        self.arrowRect = self.arrow.get_rect(center=self.screen.get_rect().center)
        self.arrow.fill(self.backgroundColor)
        pygame.draw.polygon(self.arrow, self.arrowColor, scaledArrow)

        # cursor
        scale = self.size / 5
        self.cursor = pygame.Surface((scale, scale))
        self.cursorRect = self.cursor.get_rect(center=self.screen.get_rect().center)
        self.cursor.set_colorkey((0,0,0))
        pygame.draw.line(self.cursor, self.cursorColor, (0,scale/2),(scale,scale/2), 10)
        pygame.draw.line(self.cursor, self.cursorColor, (scale/2,0),(scale/2,scale), 10)

        # background + border
        self.background = pygame.Surface((self.screen.get_width(), self.screen.get_height()))
        self.backgroundRect = self.background.get_rect(center=self.screen.get_rect().center)
        self.background.fill((0,0,0))
        self.border = pygame.Surface((self.size, self.size))
        self.border.fill(self.borderColor)
        self.borderRect = self.border.get_rect(center=self.screen.get_rect().center)
        self.inner = pygame.Surface((self.size-2*self.borderWidth, self.size-2*self.borderWidth))
        self.inner.fill(self.backgroundColor)
        self.innerRect = self.inner.get_rect(center=self.screen.get_rect().center)

        # punchline
        self.punchlineSize = {self.LEFT:  (self.punchlineThickness, self.screenHeight),
                              self.RIGHT: (self.punchlineThickness, self.screenHeight),
                              self.UP:    (self.borderRect.width, self.punchlineThickness),
                              self.DOWN:  (self.borderRect.width, self.punchlineThickness)}
        self.sign = {self.LEFT: -1,
                     self.RIGHT: 1,
                     self.UP:   -1,
                     self.DOWN:  1}

        self.punchline1 = pygame.Surface(self.punchlineSize[self.availableDirections[0]])
        self.punchline1Rect = self.update_punchline(self.punchline1, self.sign[self.availableDirections[0]]*self.innerRect.width/2, self.availableDirections[0])
        self.punchline1.fill(self.punchLineColor)

        self.punchline2 = pygame.Surface(self.punchlineSize[self.availableDirections[1]])
        self.punchline2.fill(self.punchLineColor)
        self.punchline2Rect = self.update_punchline(self.punchline2, self.sign[self.availableDirections[1]]*self.innerRect.width/2, self.availableDirections[1])

        if self.resized:
            self.resized = False
            target = self.availableDirections[self.targetDirection]
            self.pos = (1.0*self.size/self.size_old) * self.pos
            self.update_cursor()
            self.punchline1Rect = self.update_punchline(self.punchline1, self.sign[self.availableDirections[0]]*(self.innerRect.width/2+self.punchlinePos1*self.borderWidth), self.availableDirections[0])
            self.punchline2Rect = self.update_punchline(self.punchline2, self.sign[self.availableDirections[1]]*(self.innerRect.width/2+self.punchlinePos2*self.borderWidth), self.availableDirections[1])
            self.myarrow = pygame.transform.rotate(self.arrow, self.directions[target])
            self.myarrowRect = self.myarrow.get_rect(center=self.screen.get_rect().center)
            self.draw_all()


    def draw_all(self):
        """
        Executes the drawing of all feedback components.
        """
        self.screen.blit(self.background, self.backgroundRect)
        self.screen.blit(self.border, self.borderRect)
        self.screen.blit(self.inner, self.innerRect)
        self.screen.blit(self.myarrow, self.myarrowRect)
        self.screen.blit(self.punchline1, self.punchline1Rect)
        self.screen.blit(self.punchline2, self.punchline2Rect)
        self.screen.blit(self.cursor, self.cursorRect)
        pygame.display.update()

    def draw_init(self):
        """
        Draws the initial screen.
        """
        self.screen.blit(self.background, self.backgroundRect)
        self.screen.blit(self.border, self.borderRect)
        self.screen.blit(self.inner, self.innerRect)


if __name__ == '__main__':
    ca = FeedbackCursorArrow(None)
    ca.on_init()
    ca.on_play()

