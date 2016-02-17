#!/usr/bin/env python

## Simple talker demo that listens to std_msgs/Strings published 
## to the 'chatter' topic

import rospy
# from std_msgs.msg import Int64
from std_msgs.msg import Float64MultiArray

import matplotlib.pyplot as plt # for plot
import collections # circular buffer

#support for multithreads
from threading import Thread

# Global variables
# i = 1
bufflen = 1000 # Circular buffer setup
dataBuff = collections.deque(maxlen = bufflen) # create a qeue 
dataBuff.append(0) # initialize the buffer with a zero element
tempBuff = collections.deque(maxlen = bufflen) # create a qeue 
tempBuff.append(0) # initialize the buffer with a zero element
fa = 250 # sample frequency (approx)

class PlotData(Thread):
    '''Plot the data in a different thread to avoid sample discarding. If the plotting is done
    within the main loop, the amplifier will push samples through serial port and we will not 
    not have enough time to process it -> sample loss'''

    def __init__(self):  # executed on instantiation of the class PlotData
        Thread.__init__(self)

    def run(self):
    # Plot figure setup
        plt.ion()
        plt.show()
        plt.hold(False) # hold is off
        global tempBuff
        global dataBuff

        while True:
                plt.plot(tempBuff, dataBuff, linewidth=3)
                plt.axis([tempBuff[0], tempBuff[-1], -3000, 3000])
                plt.xlabel('Sample Count')
                plt.ylabel('Voltage on Channel')
                plt.grid(True)
                plt.draw()
            # sleep(1)

def callback(data):
    # rospy.loginfo(rospy.get_caller_id() + "I heard %s", data.data)

    # i = data.data
    # print i
    # print 1
    print data.data
    tempBuff.append(data.data[0])
    dataBuff.append(data.data[1])

# def callback_time(data):
#     # rospy.loginfo(rospy.get_caller_id() + "I heard %s", data.data)
#     # global i
#     # print i
#     # if i == 1:
#     #     t_init = data.data
#     #     i = 0;
#     # print i
#     tempBuff.append(data.data)

def listener():

    # In ROS, nodes are uniquely named. If two nodes with the same
    # node are launched, the previous one is kicked off. The
    # anonymous=True flag means that rospy will choose a unique
    # name for our 'talker' node so that multiple talkers can
    # run simultaneously.
    rospy.init_node('plotter', anonymous=True)

    rospy.Subscriber("eeg_data", Float64MultiArray, callback)

    # rospy.Subscriber("time", Int64, callback_time)

    # spin() simply keeps python from exiting until this node is stopped
    rospy.spin()

if __name__ == '__main__':
    # Plot figure setup
    # plt.axis([0, 1000, 0, 1])

    pltdata = PlotData()
    pltdata.daemon = True # just to interrupt both threads at the end
    pltdata.start() # starts running the plot_data thread

    listener()
