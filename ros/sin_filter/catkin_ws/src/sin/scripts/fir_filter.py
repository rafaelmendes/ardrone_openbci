#!/usr/bin/env python

## Simple talker demo that listens to std_msgs/Strings published 
## to the 'chatter' topic

import rospy
# from std_msgs.msg import Int64
from std_msgs.msg import Float32MultiArray
import collections # circular buffer

from scipy.signal import remez, lfilter

# Global variables
bufflen = 100 # Circular buffer setup

# Filter Design
fs = 100; 
lowCutoff = 0 / fs
upperCutoff = 20 / fs
stopBand = upperCutoff + 20 / fs
lpf = remez(21, [lowCutoff, upperCutoff, upperCutoff + 20, fs / 2], [fs, 0.0])

def callback(data):
    # rospy.loginfo(data.data);
    dataBuff_in = Float32MultiArray()
    dataBuff_in = data.data

    dataBuff_out = lfilter(lpf, 1, dataBuff_in)

def listener_talker():

    # In ROS, nodes are uniquely named. If two nodes with the same
    # node are launched, the previous one is kicked off. The
    # anonymous=True flag means that rospy will choose a unique
    # name for our 'talker' node so that multiple talkers can
    # run simultaneously.
    rospy.init_node('fir_filter', anonymous=True)

    rospy.Subscriber("data_buffer", Float32MultiArray, callback)

    pub = rospy.Publisher('data_buffer_filt', Float32MultiArray, queue_size=10)
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


