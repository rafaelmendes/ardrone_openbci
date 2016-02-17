"""PyAudio example: Record a few seconds of audio and save to a WAVE file."""

import pyaudio
import wave
import numpy
import collections
from time import sleep

from threading import Thread

import scipy.io.wavfile as wav

import matplotlib.pyplot as plt # for plot

CHUNKSIZE = 1
FORMAT = pyaudio.paInt16
CHANNELS = 1
RATE = 44100
RECORD_SECONDS = 5
WAVE_OUTPUT_FILENAME = "output.wav"

if __name__ == '__main__': # this code is only executed if this module is not imported
    # tempBuff = numpy.linspace(0.0, 1024.0, num=1024)
    # audioBuff = [0] * 1024
    f = open("/files/music/audio.txt", "w")

    # initialize portaudio
    p = pyaudio.PyAudio()
    stream = p.open(format=pyaudio.paInt16, channels=1, rate=RATE, input=True, frames_per_buffer=CHUNKSIZE)

    frames = [] # A python-list of chunks(numpy.ndarray)
    try:
        while 1:
            data = stream.read(CHUNKSIZE)
            frames.append(numpy.fromstring(data, dtype=numpy.int16))
    except:
        #Convert the list of numpy-arrays into a 1D array (column-wise)
        numpydata = numpy.hstack(frames)

        # close stream
        stream.stop_stream()
        stream.close()
        p.terminate()

        print numpydata

        wav.write('/files/music/out.wav',RATE,numpydata)





    






