#!/usr/bin/env python

## Simple talker demo that listens to std_msgs/Strings published 
## to the 'chatter' topic

import rospy
# from std_msgs.msg import Int64
from std_msgs.msg import Float32MultiArray
from std_msgs.msg import Float32
import collections # circular buffer

#support for multithreads
from threading import Thread

# Global variables
bufflen = 100 # Circular buffer setup
dataBuff = collections.deque(maxlen = bufflen) # create a qeue 
dataBuff.append(0) # initialize the buffer with a zero element
# tempBuff = collections.deque(maxlen = bufflen) # create a qeue 
# tempBuff.append(0) # initialize the buffer with a zero element
# tempBuff = range(bufflen)

def callback(data):
    # rospy.loginfo(data.data);
    dataBuff.append(data.data)
    # print 1

def listener_talker():

    # In ROS, nodes are uniquely named. If two nodes with the same
    # node are launched, the previous one is kicked off. The
    # anonymous=True flag means that rospy will choose a unique
    # name for our 'talker' node so that multiple talkers can
    # run simultaneously.
    rospy.init_node('bufferizator', anonymous=True)

    rospy.Subscriber("data", Float32, callback)

    pub = rospy.Publisher('data_buffer', Float32MultiArray, queue_size=10)
    rate = rospy.Rate(10) # 10hz
    while not rospy.is_shutdown():
        msg = Float32MultiArray()
        msg.data = dataBuff 
        # rospy.loginfo(msg)
        pub.publish(msg)
        rate.sleep()

    # spin() simply keeps python from exiting until this node is stopped
    rospy.spin()



if __name__ == '__main__':
    try:
        listener_talker()
    except rospy.ROSInterruptException:
        pass


