#!/usr/bin/env python

"""PyAudio example: Record a few seconds of audio and save to a WAVE file."""

import pyaudio
import wave
import numpy
import collections
from time import sleep

# Ros packages:
import rospy
from std_msgs.msg import Int16

CHUNK = 1
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 44100

if __name__ == '__main__': # this code is only executed if this module is not imported

    # Ros config:
    pub = rospy.Publisher('sound', Int16, queue_size=10)
    # pub_time = rospy.Publisher('time', Int64, queue_size=10)

    rospy.init_node('mic', anonymous=True)
    rate = rospy.Rate(20) # 10hz

    p = pyaudio.PyAudio()
    stream = p.open(format=FORMAT,
        channels=CHANNELS,
        rate=RATE,
        input=True,
        frames_per_buffer=CHUNK)

    print("Sending data")
    try:     
        while 1:
            data = stream.read(CHUNK)
            x = numpy.fromstring(data, dtype=numpy.int16)
            rospy.loginfo(x)
            pub.publish(x)

    except:
        stream.stop_stream()
        stream.close()
        p.terminate()







