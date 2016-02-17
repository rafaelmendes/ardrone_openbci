#!/usr/bin/python

"""
     read_mic.py        Written beginning 17 July 2011
  Use pyaudio and numpy to read data from the laptop microphone and 
 plot its audio frequency foruier transform

 The steps are:  
       read microphone data in blocks
       Collect the blocks into an array for writing to a .wav file
       Also, collect the data into one long string to hand to numpy
       convert the long string into one numpy 1D array
       Take fft and plot.
       write the list of blocks to a .wav file.

                 Mark Halpern        UBC Vancouver BC.
 """

import datetime as dt
import pyaudio
import wave
import sys
import pylab
import numpy
import math
import time

cur_time=dt.datetime.now()
#print repr(cur_time)

print ''
print ''
print cur_time , 'Program is read_mic.py'

pylab.ion()  # test interactive mode.



f_a=440.

names=['A','A#','B','C','C#','D','D#','E','F','F#','G','G#','a']


chunk=2048
FORMAT=pyaudio.paInt16
CHANNELS=1
RATE=44100
RECORD_S=2.
WAVE_OUTPUT_NAME="output_17july.wav"


pa=pyaudio.PyAudio()



# pylab.ioff()
stream=pa.open(format=FORMAT,
             channels=CHANNELS,
             rate=RATE,
             input=True,
             frames_per_buffer=chunk)


#print "*recording"
all_v=[]
all_data=""
x_array=numpy.array([],dtype=numpy.int16)
n_chunks=int(RECORD_S*RATE/chunk)
npts=n_chunks*chunk

pylab.ion()

for i in range(0,n_chunks):
 data=stream.read(chunk)
 all_v.append(data)
 all_data += data
 x=numpy.fromstring(data, dtype=numpy.int16)
 numpy.append(x_array,x)

print "*Done"


stream.close()
pa.terminate




#pylab.plot(freq,z)

all_x=numpy.fromstring(all_data, dtype=numpy.int16)

p2p=2.*numpy.sqrt(2.*all_x.var())
print "Peak to Peak Signal is {0:.2f} units".format(p2p)

z=abs(pylab.fft(all_x))
max_arg=numpy.argmax(z[0:npts/2])
peak=z[max_arg]




freq=pylab.arange(npts)*1.*RATE/npts
fmax=freq[max_arg] + .01


"""
Find the note name and nearest freq. assuming even tuning.
"""

f_log=math.log(fmax/f_a,2)
posn=f_log - math.floor(f_log)
steps=12.*posn
note_name=names[int(math.floor(steps))]
fn_log= math.floor(12.*f_log)/12.
f_next_log= fn_log + 1./12.

f_note=f_a*2.**fn_log
f_next=f_a*2.**f_next_log

"""
Find which of these is nearer
"""
L1= 4
L2=1
if fmax/f_note > f_next/fmax :
  L1=2
  L2=4
  note_name=names[int(math.floor(steps))+1]
  #print 'high'

print 'Note 1: {0:.2f} Peak: {1:.2f} Note 2: {2:.2f}  (Hz)'.format(f_note,fmax,f_next)



pylab.figure(1, figsize=(7,8))


pylab.subplot(3,1,1)
#pylab.clf()

pylab.xlim(.93*fmax,1.07*fmax)
#pylab.xlim(0,10000)


pylab.plot(freq,z)
pylab.plot(freq,z,'s')
pylab.xlabel('Frequency (Hz)')
pylab.title(note_name)
pylab.axvline(f_note,linewidth=L1, color='r')
pylab.axvline(f_next,linewidth=L2,color='r')
#pylab.show()

#pylab.figure(2)

pylab.subplot(3,1,2)
pylab.plot(all_x)

pylab.subplot(3,1,3)
pylab.xlim(.1, 10000)
pylab.semilogx(freq,z)
#pylab.loglog(freq,z)

#print 'Delete plot to continue'
pylab.show()

#print 'drawn!'
#time.sleep(2)
#pylab.close()
#print all


# Write to a file...

#datum=''.join(all_v)
#wf=wave.open(WAVE_OUTPUT_NAME, 'wb')
#wf.setnchannels(CHANNELS)
#wf.setsampwidth(pa.get_sample_size(FORMAT))
#wf.setframerate(RATE)
#wf.writeframes(datum)
#wf.close()

x=raw_input('wait')
fout=open('mac_f_response.dat','a')
fout.write(x+"{0:.2f}  {1:.2f}".format(p2p,fmax))
fout.close()

print 'bye'
