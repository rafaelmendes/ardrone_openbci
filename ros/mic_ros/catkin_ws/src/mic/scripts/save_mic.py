#!/usr/bin/env python

"""PyAudio example: Record a few seconds of audio and save to a WAVE file."""

import pyaudio
import wave
import numpy
from time import sleep

import scipy.io.wavfile as wav

import matplotlib.pyplot as plt # for plot

# Ros packages:
import rospy
from std_msgs.msg import Int16

RATE = 44100
numpyarray = []
frames = [] # A python-list of chunks(numpy.ndarray)

def callback(data):
    # rospy.loginfo(rospy.get_caller_id() + "I heard %s", data.data)

    #Open new data file
    # print data.data 
    numpyarray.append(data.data)
    # f.write(str(data.data))
    # f.write('\n')

    
def listener():
    rospy.init_node('saver', anonymous=True)
    rospy.Subscriber("sound", Int16, callback)

    rospy.spin()

if __name__ == '__main__': # this code is only executed if this module is not imported
    try:
        listener()
    except:
        numpydata = numpy.hstack(numpyarray)
        print numpyarray
        print numpydata
        wav.write('/files/music/out.wav',RATE,numpydata)
    






