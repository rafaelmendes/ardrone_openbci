"""PyAudio example: Record a few seconds of audio and save to a WAVE file."""

import pyaudio
import wave
import numpy
import collections
from time import sleep

from threading import Thread

import matplotlib.pyplot as plt # for plot

CHUNK = 1
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 44100
RECORD_SECONDS = 5
WAVE_OUTPUT_FILENAME = "output.wav"

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

class ReadMic(Thread):
    '''Reads data from the microphone and stores it into a circular buffer'''

    def __init__(self):  # executed on instantiation of the class PlotData
        Thread.__init__(self)

    def run(self):
        # print 1
        p = pyaudio.PyAudio()
        print 2
        stream = p.open(format=FORMAT,
            channels=CHANNELS,
            rate=RATE,
            input=True,
            frames_per_buffer=CHUNK)

        print("* recording")

        i= 0
        while 1:
            data = stream.read(CHUNK)
            x = numpy.fromstring(data, dtype=numpy.int16)
            audioBuff.append(x)
            # print len(audioBuff)

        print("* done recording")
        stream.stop_stream()
        stream.close()
        p.terminate()


if __name__ == '__main__': # this code is only executed if this module is not imported
    # Channel which will be plotted
    tempBuff = range(0, bufflen)
    # tempBuff = numpy.linspace(0.0, 1024.0, num=1024)
    # audioBuff = [0] * 1024

    readmic = ReadMic()
    # readmic.daemon = True # just to interrupt both threads at the end
    readmic.start() # starts running the plot_data thread
    
    # sleep(2) # wait for the buffer to fill in
    pltdata = PlotData()
    pltdata.daemon = True # just to interrupt both threads at the end
    pltdata.start() # starts running the plot_data thread

    # plt.ion()
    # plt.show()
    # plt.hold(False) # hold is off

    # if len(audioBuff) == len(tempBuff):
    #     while True:
    #         print audioBuff
    #         plt.plot(tempBuff, audioBuff, linewidth=3)
    #         # print audioBuff
    #         # print len(audioBuff)
    #         plt.axis([tempBuff[0], tempBuff[-1], -10000, 10000])
    #         plt.xlabel('Sample Count')
    #         plt.ylabel('Voltage on Channel')
    #         plt.grid(True)
    #         plt.draw()
    #         # sleep(1)







