#!/usr/bin/env python

## Simple talker demo that published std_msgs/Strings messages
## to the 'chatter' topic

import rospy
from std_msgs.msg import Int64
from std_msgs.msg import String



def talker():
    pub = rospy.Publisher('chatter_num', Int64, queue_size=10)
    pub2 = rospy.Publisher('chatter_text', String, queue_size=10)

    rospy.init_node('talker', anonymous=True)
    rate = rospy.Rate(20) # 10hz
    value = 0
    while not rospy.is_shutdown():
        value = value + 1 % rospy.get_time()
        text = 'Hello World'
        rospy.loginfo(value)
        pub.publish(value)

        rospy.loginfo(text)
        pub2.publish(text)

        rate.sleep()

if __name__ == '__main__':
    try:

        talker()
    except rospy.ROSInterruptException:
        pass
