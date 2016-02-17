# Import a lot of functions to keep it simple to use
from pylab import * 
import matplotlib as plt

from scipy.signal import remez
from scipy.signal import freqz
from scipy.signal import lfilter


# 1 second of data samples at spacing of 1/1000 seconds
t = arange(0, 1, 1.0/1000)

noise_amp = 5.0

A = 100
s = A*sin(2*pi*100*t)+A*sin(2*pi*200*t)+noise_amp * randn(len(t))
# s = sin(2*pi*100*t)+sin(2*pi*200*t)

# Note: you may need to use fft.fft is you are using ipython
ft = fft(s)/len(s)
subplot(411)
plot(s)

subplot(412)
plot(20*log10(abs(ft)))
show()

lpf = remez(21, [0, 0.2, 0.3, 0.5], [1.0, 0.0])
w, h = freqz(lpf)
subplot(413)
plot(w/(2*pi), 20*log10(abs(h)))
show()

sout = lfilter(lpf, 1, s)
subplot(414)
plot(20*log10(abs(fft(s))))
plot(20*log10(abs(fft(sout))))
show()