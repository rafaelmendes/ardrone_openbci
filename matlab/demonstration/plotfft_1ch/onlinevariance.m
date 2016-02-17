% clear all 
% addpath(genpath('/arquivos/tcc/software/BCILAB-Program'));

clear stamps ch chunk
close all
% environment variables:
n_trials= 100;

channel=1;

N = 512; % points for FFT

fa = 250;

resample=1; % Downsampling the signal to guarantee that the number of training
% samples is greater than the number of samples (avoid singular matrices)

%% Filter specifications
low_cutoff=7; % band pass filter lower cutoff frequency (Hz)
upper_cutoff=13; % band pass filter upper cutoff frequency (Hz)

filter_order = 3;                   
filter_cutoff = [2*low_cutoff/fa 2*upper_cutoff/fa];

[b, a] = butter(filter_order,filter_cutoff); 


%% instantiate the library:
disp('Loading the library...');
lib = lsl_loadlib();

% resolve a stream...
disp('Resolving an EEG stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'name','OpenBCI_EEG'); end

% create a new inlet
disp('Opening an inlet...');
inlet = lsl_inlet(result{1},1000,0);


% Receive data chunk
disp('Now receiving chunked data...');
% [chunk,stamps] = inlet.pull_sample();


[chunk,stamps] = inlet.pull_chunk();
pause(0.1)
%% Trials:
ch=0;
buffSize = 1000; % size of the circular buffer
circBuff = nan(1,buffSize); % create circular buffer
t_circBuff = nan(1,buffSize); % create circular buffer

[chunk,stamps] = inlet.pull_chunk();
i=0;
stamp0 = min(stamps);
% figure;
% plot(stamps,ch);
% hold on;
% try
while(1)
        i=i+1;
        pause(0.05); % wait for samples to buffer in

        % Get chunk from the inlet
        [chunk,stamps] = inlet.pull_chunk();
        
        t_circBuff = [t_circBuff(size(stamps,2)+1:end) stamps];
        
        % Channel select
        ch=(chunk(channel,:)-mean(chunk(channel,:)));
        
%         if(i>100)
%             ch=ch+10*cos(2*pi*10*stamps);
%             if(i==200)
%                 i=0;
%             end
%         end

%         ch=ch+10*cos(2*pi*10*stamps);
        
        circBuff = [circBuff(size(ch,2)+1:end) ch];
        
        % Data bandpass filtering
        if(~isnan(circBuff))
            circBuff=filtfilt(b, a, circBuff);
        end

        % Data normalization
%         ch=normal(ch);
        
        H = fft(circBuff, N);
        
        H = abs(H(1:N/2));

        f = (0:N/2-1)*fa/N;
        
        S_squared = smooth(circBuff.^2, 500)';

        % Plot signal x time
        figure(1);
        subplot(2,1,1);
        plot(t_circBuff, circBuff.^2, t_circBuff, S_squared);
        axis([-inf inf 0 100]);
        xlabel('Time (s)');
        ylabel({['Voltage on channel ', num2str(channel)]});
        
        % Plot fft x time
        subplot(2,2,3);
        plot(f, H, 'r');
        axis([low_cutoff upper_cutoff 0 1000]);
        xlabel('Frequency (Hz)');
        ylabel('Mag');
                
        % Find fourier components at 8 < f < 12 Hz
        bin_f = find(f>8 & f< 12);
        
        % Compute the energy of the signal at these components
%         E = sum(H(bin_f).^2)/length(bin_f);
        E = sum(S_squared)/1000;
        
        % Plot energy using bar
        subplot(2,2,4);
        bar(E);
%         axis([-inf inf 0 1E6]);
        axis([-inf inf 0 50]);
        ylabel('Energy over alpha band');
        
end

% catch exception
%     display('Error!')
% end
