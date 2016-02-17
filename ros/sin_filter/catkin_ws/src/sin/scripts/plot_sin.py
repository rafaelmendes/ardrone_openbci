#!/usr/bin/env python

## Simple talker demo that listens to std_msgs/Strings published 
## to the 'chatter' topic

import rospy
# from std_msgs.msg import Int64
from std_msgs.msg import Float32MultiArray

import matplotlib.pyplot as plt # for plot
import collections # circular buffer

# Global variables
bufflen = 100 # Circular buffer setup
# tempBuff = collections.deque(maxlen = bufflen) # create a qeue 
# tempBuff.append(0) # initialize the buffer with a zero element
tempBuff = range(bufflen)

def callback(data):
    # rospy.loginfo(data.data);
    # dataBuff = Float32MultiArray()
    dataBuff = data.data;

    plt.ion()
    plt.show()
    plt.hold(False) # hold is off

    while len(tempBuff) != len(dataBuff):
        pass

    plt.plot(tempBuff, dataBuff, linewidth=3)
    plt.axis([tempBuff[0], tempBuff[-1], -5, 5])
    plt.xlabel('Sample Count')
    plt.ylabel('Voltage on Channel')
    plt.grid(True)
    plt.draw()

def listener():

    # In ROS, nodes are uniquely named. If two nodes with the same
    # node are launched, the previous one is kicked off. The
    # anonymous=True flag means that rospy will choose a unique
    # name for our 'talker' node so that multiple talkers can
    # run simultaneously.
    rospy.init_node('plotter', anonymous=True)

    rospy.Subscriber("data_buffer", Float32MultiArray, callback)

    # rospy.Subscriber("time", Int64, callback_time)

    # spin() simply keeps python from exiting until this node is stopped
    rospy.spin()

if __name__ == '__main__':
    # Plot figure setup
    # plt.axis([0, 1000, 0, 1])
    try:
        listener()
    except rospy.ROSInterruptException:
        pass

