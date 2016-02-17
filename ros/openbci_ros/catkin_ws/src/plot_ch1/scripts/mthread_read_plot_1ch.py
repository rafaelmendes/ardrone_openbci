#!/usr/bin/env python2.7.
# import sys; sys.path.append('..') # help python find open_bci_v3.py relative to scripts folder
import open_bci_v3 as bci
import matplotlib.pyplot as plt # for plot
import collections # circular buffer
from time import sleep # sleep functions
from threading import Thread

# Gets data from one channel of OpenBci and plots the data in real time.
# Author: Rafael Duarte

# Global variables
i = 0
bufflen = 1000 # Circular buffer setup
dataBuff = collections.deque(maxlen = bufflen) # create a qeue 
dataBuff.append(0) # initialize the buffer with a zero element
tempBuff = collections.deque(maxlen = bufflen) # create a qeue 
tempBuff.append(0) # initialize the buffer with a zero element
fa = 250 # sample frequency (approx)


def get_data(sample):
	'''Get the data from amplifier and push it into the circular buffer.
	Also implements a counter to plot against the read value
    ps: This function is called by the OpenBci start_streaming() function'''

    global i # the counter is global
    i += 1
    dataBuff.append(sample.channel_data[channel])
    tempBuff.append(i)


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

# Main loop
if __name__ == '__main__': # this code is only executed if this module is not imported
    # Channel which will be plotted
    channel = 1; 
	pltdata = PlotData()
    pltdata.daemon = True # just to interrupt both threads at the end
    pltdata.start() # starts running the plot_data thread

    port = '/dev/ttyUSB0' # port which opnbci is connected (linux). windows = COM1
    baud = 115200
    board = bci.OpenBCIBoard(port=port, baud=baud)
    board.test_signal(3) # square waveform to channel input (test signal)
    sleep(1) # need to include this to wait for test config setup
    board.start_streaming(get_data) # start getting data from amplifier

