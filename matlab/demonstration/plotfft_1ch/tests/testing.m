% clear all 
% addpath(genpath('/arquivos/tcc/software/BCILAB-Program'));

clear stamps ch chunk
close all
% environment variables:
n_trials= 100;

N = 512;

channel=2;

fa = 100;

resample=1; % Downsampling the signal to guarantee that the number of training
% samples is greater than the number of samples (avoid singular matrices)

%% Trials:


ch=0;
buffSize = 1000; % size of the circular buffer
circBuff = nan(1,100); % create circular buffer
t_circBuff = nan(1,100); % create circular buffer


 for(t=0: 0.01:10000)
        x = sin(2*pi*40*t);
        
        pause(0.01); % wait for samples to buffer in
        
        t_circBuff = [t_circBuff(2:end) t];      
        
        circBuff = [circBuff(2:end) x];
       
        H = fft(circBuff, N);
        
        H = H(1:N/2);

        f = (0:N/2-1)*fa/N;

        % Plot data
        figure(1);
        plot(t_circBuff, circBuff);
        
        figure(2);
        plot(f, abs(H), 'r');

end
