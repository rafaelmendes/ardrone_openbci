% clear all 
% addpath(genpath('/arquivos/tcc/software/BCILAB-Program'));

clear stamps ch chunk
close all
% environment variables:
n_trials= 100;


C3_i = 7; % index of channel C3
C4_i = 8; % index of channel C4

N = 512; % points for FFT

fa = 250;

resample=1; % Downsampling the signal to guarantee that the number of training
% samples is greater than the number of samples (avoid singular matrices)

%% Filter specifications
low_cutoff=7; % band pass filter lower cutoff frequency (Hz)
up_cutoff=13; % band pass filter upper cutoff frequency (Hz)

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


% Receive data chunk
disp('Now receiving chunked data...');
% [chunk,stamps] = inlet.pull_sample();


%% Calibration:
display('Fique completamente relaxado.')
[go_stop_max, left_right_max] = calib(inlet, b, a, low_cutoff, up_cutoff);

display('Movimente as duas mãos (ou imagine o movimento).')
[go_stop_min, left_right_min] = calib(inlet, b, a, low_cutoff, up_cutoff);

[chunk,stamps] = inlet.pull_chunk();
pause(0.1)
%% Trials:
ch=0;
buffSize = 1000; % size of the circular buffer
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

        ch(1,:) = ch(1,:) + 10*cos(2*pi*10*stamps);
        ch(2,:) = ch(2,:) + 10*cos(2*pi*10*stamps);
        
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
        axis([-inf inf -100 100]);
        xlabel('Time (s)');
        ylabel({['Voltage on channel ', num2str(C3_i)]});
        
        % Plot signal x time of channel C4
        subplot(3,1,2);
        plot(t_circBuff, circBuff(2,:), 'r');
        axis([-inf inf -100 100]);
        xlabel('Time (s)');
        ylabel({['Voltage on channel ', num2str(C4_i)]});
        
        % Plot fft x time
        subplot(3,2,5);
        plot(f, H(1,:), 'b',f, H(2,:), 'r');
        axis([low_cutoff upper_cutoff -inf inf]);
        xlabel('Frequency (Hz)');
        ylabel('Mag');
                
        % Find fourier components at 8 < f < 12 Hz
        bin_f = find(f>low_cutoff & up_cutoff< 12);
        
        % Compute the energy of the signal at these components
        E = sum(H(:, bin_f).^2, 2)/length(bin_f);
        
        go_stop = E(2) + E(1);
        left_right = E(2) - E(1);
        
        % Plot energy using bar
        subplot(3,2,6);
        bar([go_stop left_right]);
        axis([-inf inf -1.5*go_stop_max 1.5*go_stop_max]);
        ylabel('Energy over alpha band');
        xlabel('[Go/Stop          Left/Right]');
        
        %% Classification
        % Thresholds:
        block_control = 0; 
        go_stop_th = go_stop_min + (go_stop_max - go_stop_min) / 2;
        left_right_th = go_stop_max / 2;
        
        if(left_right > left_right_th)
            % send cmd to right
            display('right');
            block_control = 1; 
        end
        if(left_right < -left_right_th)
            % send cmd to left
            display('left');
            block_control = 1; 
        end
        
        if (block_control==0)
            if(go_stop > go_stop_th)
                % send cmd to stop
                display('stop');
            else
                % send cmd to go
                display('go');
            end
        end
               
            
        
end
