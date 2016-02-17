#!/usr/bin/env python

"""PyAudio example: Record a few seconds of audio and save to a WAVE file."""

import pyaudio
import wave
import numpy
import collections
from time import sleep

from threading import Thread

import matplotlib.pyplot as plt # for plot

# Ros packages:
import rospy
from std_msgs.msg import Int16

bufflen = 1024

audioBuff = collections.deque(maxlen = bufflen) # create a queue

class PlotData(Thread):
    '''Plot the data in a different thread to avoid sample discarding. If the plotting is done
    within the main loop, the amplifier will push samples through serial port and we will not 
    have enough time to process it -> sample loss'''

    def __init__(self):  # executed on instantiation of the class PlotData
        Thread.__init__(self)

    def run(self):
        global audioBuff
        global tempBuff

        # Plot figure setup
        plt.ion()
        plt.show()
        plt.hold(False) # hold is off

        while len(tempBuff) != len(audioBuff):
            pass

        while True:
            plt.plot(tempBuff, audioBuff, linewidth=3)
            plt.axis([tempBuff[0], tempBuff[-1], -10000, 10000])
            plt.xlabel('Sample Count')
            plt.ylabel('Voltage on Channel')
            plt.grid(True)
            plt.draw()
            # sleep(1)

def callback(data):
    # rospy.loginfo(rospy.get_caller_id() + "I heard %s", data.data)
    audioBuff.append(data.data)

def listener():
    rospy.init_node('plotter', anonymous=True)
    rospy.Subscriber("sound", Int16, callback)

    rospy.spin()

if __name__ == '__main__': # this code is only executed if this module is not imported
    # Channel which will be plotted
    tempBuff = range(0, bufflen)

    pltdata = PlotData()
    # pltdata.daemon = True # just to interrupt both threads at the end
    pltdata.start() # starts running the plot_data thread

    listener()






