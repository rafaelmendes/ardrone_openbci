#!/usr/bin/env python
# Software License Agreement (BSD License)

## Simple talker demo that published std_msgs/Strings messages
## to the 'chatter' topic

import rospy
from std_msgs.msg import Float32
from numpy import pi, sin

# Sin frequency
f = 10; # Hz
w = 2 * pi * f;

def talker():
    pub = rospy.Publisher('data', Float32, queue_size=10)
    rospy.init_node('gen_sin', anonymous=True)
    rate = rospy.Rate(100) # 10hz
    while not rospy.is_shutdown():
        x = 5*sin (w*rospy.get_time())
        # rospy.loginfo(x)
        pub.publish(x)
        rate.sleep()

if __name__ == '__main__':
    try:
        talker()
    except rospy.ROSInterruptException:
        pass







