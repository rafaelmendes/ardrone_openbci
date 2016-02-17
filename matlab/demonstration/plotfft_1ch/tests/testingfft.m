close all;

N=512;
fa=100;

t = 0:1/fa:1;
% x = sin(2*pi*50*t) + sin(2*pi*120*t);
x = sin(2*pi*5*t);

y = x;


Y = fft(y,N);

Y = Y(1:N/2);

Pyy = abs(Y);
% f = fa/N*(1:N);

f = (0:N/2-1)*fa/N;

figure;
plot(f,Pyy)
title('Power spectral density')
xlabel('Frequency (Hz)')