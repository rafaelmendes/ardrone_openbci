#!/usr/bin/env python

## Simple talker demo that listens to std_msgs/Strings published 
## to the 'chatter' topic

import rospy
from std_msgs.msg import Int64
from std_msgs.msg import String

import matplotlib.pyplot as plt # for plot
import collections # circular buffer

def callback_num(data):
    # rospy.loginfo(rospy.get_caller_id() + "I heard %s", data.data)

    i = data.data
    print i
    dataBuff.append(i)
    tempBuff.append(i)
    plt.plot(tempBuff, dataBuff)
    plt.draw()

def callback_text(data):
    # rospy.loginfo(rospy.get_caller_id() + "I heard %s", data.data)
    print data.data

def listener():

    # In ROS, nodes are uniquely named. If two nodes with the same
    # node are launched, the previous one is kicked off. The
    # anonymous=True flag means that rospy will choose a unique
    # name for our 'talker' node so that multiple talkers can
    # run simultaneously.
    rospy.init_node('listener', anonymous=True)

    rospy.Subscriber("chatter_num", Int64, callback_num)
    rospy.Subscriber("chatter_text", String, callback_text)


    

    # spin() simply keeps python from exiting until this node is stopped
    rospy.spin()

if __name__ == '__main__':
    # Plot figure setup
    # plt.axis([0, 1000, 0, 1])
    bufflen = 10

    dataBuff = collections.deque(maxlen = bufflen)
    tempBuff = collections.deque(maxlen = bufflen)



    listener()
