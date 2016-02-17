% clear all 
% addpath(genpath('/arquivos/tcc/software/BCILAB-Program'));

clear stamps ch chunk
close all
% environment variables:

channel=1;

N = 512; % points for FFT

fa = 250;

resample=1; % Downsampling the signal to guarantee that the number of training
% samples is greater than the number of samples (avoid singular matrices)

%% Filter specifications
low_cutoff=7; % band pass filter lower cutoff frequency (Hz)
upper_cutoff=13; % band pass filter upper cutof f frequency (Hz)

filter_order = 3;                   
filter_cutoff = [2*low_cutoff/fa 2*upper_cutoff/fa];

[b, a] = butter(filter_order,filter_cutoff); 

%% Trials:
ch=0;

buffSize = 1000; % size of the circular buffer
circBuff = nan(1,buffSize); % create circular buffer
t_circBuff = nan(1,buffSize); % create circular buffer
meanBuff = nan(1,4*buffSize); % create circular buffer

i=0;
stamps_cte = linspace(0,0.05,12);
stamps = 0;
% figure;
% plot(stamps,ch);
% hold on;
% try
while(1)
        i=i+1;
        pause(0.05); % wait for samples to buffer in

        stamps = stamps_cte + stamps(end);


        % t_circBuff = [t_circBuff(size(stamps,2)+1:end) stamps];
        t_circBuff = [t_circBuff(size(stamps,2)+1:end) stamps];

        % Channel select
        % ch=(chunk(channel,:)-mean(chunk(channel,:)));

        ch = ch + 10*cos(2*pi*10*stamps);
        
        circBuff = [circBuff(size(ch,2)+1:end) ch];
        meanBuff = [meanBuff(size(ch,2)+1:end) ch];
        
        % Data bandpass filtering
        if(~isnan(circBuff))
            circBuff=filtfilt(b, a, circBuff);
        end

        if(~isnan(circBuff))
            meanBuff=filtfilt(b, a, meanBuff);
        end

        % Compute the mean
        goal = mean(meanBuff);

        % Data normalization
		% ch=normal(ch);
        
        H = fft(circBuff, N);
        
        H = abs(H(1:N/2));

        f = (0:N/2-1)*fa/N;

        % Plot signal x time
        figure(1);
        subplot(2,1,1);
        plot(t_circBuff, circBuff);
        axis([-inf inf -100 100]);
        xlabel('Time (s)');
        ylabel({['Voltage on channel ', num2str(channel)]});
        
        % Plot fft x time
        subplot(2,2,3);
        plot(f, H, 'r');
        axis([low_cutoff upper_cutoff 0 1000]);
        xlabel('Frequency (Hz)');
        ylabel('Mag');
                
        % Find fourier components at 8 < f < 12 Hz
        bin_f = find(f>low_cutoff & f< upper_cutoff);
        
        % Compute the energy of the signal at these components
        E = sum(H(bin_f).^2)/length(bin_f);
        
        % Plot energy using bar
        subplot(2,2,4);
        bar(E);
        plot(goal);
        axis([-inf inf 0 goal*2]);
        ylabel('Energy over alpha band');
        
end

% catch exception
%     display('Error!')
% end
