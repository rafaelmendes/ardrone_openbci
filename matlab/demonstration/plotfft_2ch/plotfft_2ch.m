% This script includes: 
% - incomming signal from OpenBCI
% - real time plot of the fast fourier transform of the incomming signal from OpenBCI
% - bars with magnitudes proportional to the energy of the incomming signal
% over the filtered bands


% clear all 
% addpath(genpath('/arquivos/tcc/software/BCILAB-Program'));

clear stamps ch chunk
close all

% environment variables:
n_trials= 100;

% channel indexes correspondent to the OpenBCI inputs
C3_i = 1; % index of channel C3
C4_i = 2; % index of channel C4

N = 512; % points for FFT

fa = 250; % sampling frequency

%% Filter specifications
low_cutoff=1; % band pass filter lower cutoff frequency (Hz)
up_cutoff=25; % band pass filter upper cutoff frequency (Hz)

filter_order = 3;                   
filter_cutoff = [2*low_cutoff/fa 2*up_cutoff/fa];

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
% lsl_inlet(inlet, buffer_size, chunk_size)
% chunk_size = 0 -> amount of samples is determined by sender

% Receive data chunk
disp('Now receiving chunked data...');
% [chunk,stamps] = inlet.pull_sample();

[chunk,stamps] = inlet.pull_chunk();
pause(0.1)
%% Trials:
ch=0;
buffSize = 500; % size of the circular buffer
circBuff = nan(2, buffSize); % create circular buffer
t_circBuff = nan(1, buffSize); % create circular buffer

[chunk,stamps] = inlet.pull_chunk();
i=0;

while(1)
        i=i+1;
        pause(0.05); % wait for samples to buffer in

        % Get chunk from the inlet
        [chunk,stamps] = inlet.pull_chunk();
        
        t_circBuff = [t_circBuff(size(stamps,2)+1:end) stamps];
                
        % Channels select
        ch = chunk([C3_i C4_i],:);
        
        % Remove mean
        for(i=1:1:size(ch, 1))
            ch(i,:) = ch(i,:) - mean(ch(i,:));
        end

%         ch = ch + 10*cos(2*pi*10*stamps);
        
        circBuff = [circBuff(:, size(ch,2)+1:end) ch];
        
        % Data bandpass filtering
        if(~isnan(circBuff))
            circBuff=filtfilt(b, a, circBuff')';
        end

        % Data normalization
%         ch=normal(ch);
        
        H = fft(circBuff, N, 2);
        
        H = abs(H(:,1:N/2));

        f = (0:N/2-1)*fa/N;

        % Plot signal x time of channel C3
        figure(1);
        subplot(3,1,1);
        plot(t_circBuff, circBuff(1,:), 'b');
        axis([-inf inf -250 250]);
        xlabel('Time (s)');
        ylabel({['Voltage on channel ', num2str(C3_i)]});
        
        % Plot signal x time of channel C4
        subplot(3,1,2);
        plot(t_circBuff, circBuff(2,:), 'r');
        axis([-inf inf -50 50]);
        xlabel('Time (s)');
        ylabel({['Voltage on channel ', num2str(C4_i)]});
        
        % Plot fft x time
        subplot(3,2,5);
        plot(f, H(1,:), 'b',f, H(2,:), 'r');
        axis([low_cutoff up_cutoff 0 10000]);
        xlabel('Frequency (Hz)');
        ylabel('Mag');
                
        % Find fourier components at 8 < f < 12 Hz
        bin_f = find(f>low_cutoff & f< up_cutoff);
        
        % Compute the energy of the signal at these components
        E = sum(H(:, bin_f).^2, 2)/length(bin_f);
        
        % Plot energy using bar
        subplot(3,2,6);
        bar([E(1) E(2)]);
        axis([-inf inf 0 500000]);
        ylabel('Energy over alpha band');
        
end

% catch exception
%     display('Error!')
% end
