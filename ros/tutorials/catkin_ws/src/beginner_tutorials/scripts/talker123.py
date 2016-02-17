#!/usr/bin/env python

import rospy
from std_msgs.msg import String
import pygame, sys
from pygame.locals import *

def talker():
    pygame.init()
    DISPLAYSURF = pygame.display.set_mode((300, 200))
    pub = rospy.Publisher('chatte', String, queue_size=1000)
    rospy.init_node('talker', anonymous=0)
    rate = rospy.Rate(300) # 10hz
    cmd_str = ' '
    while not rospy.is_shutdown():
        w8_str = "Waiting... %s" % rospy.get_time()
        for event in pygame.event.get(): # event handling loop
            if event.type == QUIT:
                terminate()
            elif event.type == KEYDOWN:
                if (event.key == K_RIGHT or event.key == K_d):
                    cmd_str = "right"
		    #rospy.loginfo(cmd_str)
                    print(cmd_str)
                    pub.publish(cmd_str)
		elif (event.key == K_LEFT or event.key == K_a):
                    cmd_str = "left"
                    #rospy.loginfo(cmd_str)
                    print(cmd_str)
                    pub.publish(cmd_str)
		elif (event.key == K_UP or event.key == K_w):
                    cmd_str = "up"
                    #rospy.loginfo(cmd_str)
                    print(cmd_str)
                    pub.publish(cmd_str)
		elif (event.key == K_DOWN or event.key == K_s):
                    cmd_str = "down"
                    #rospy.loginfo(cmd_str)
                    print(cmd_str)
                    pub.publish(cmd_str)
            
        rate.sleep()

def terminate():
    pygame.quit()
    sys.exit()


if __name__ == '__main__':
    try:
        talker()
    except rospy.ROSInterruptException:
        pass




              
