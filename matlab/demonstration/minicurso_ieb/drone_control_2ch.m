% clear all 
% addpath(genpath('/arquivos/tcc/software/BCILAB-Program'));

clear stamps ch chunk
close all
% environment variables:
n_trials= 100;


channel_EOG = 1;
channel_Pz = 2;

N = 512; % points for FFT

fa = 250;

voo=audioread('/files/Documents/tcc/matlab_implement/acquisition/sounds/2000_100ms.wav');

resample=1; % Downsampling the signal to guarantee that the number of training
% samples is greater than the number of samples (avoid singular matrices)
%% Drone initialization
up = 0; % Drone is initially landed 

%% UDP client initialization
U = udp('127.0.0.1', 5005);
fopen(U);

fwrite(U, 'l'); % Send cmd to drone to takeoff

%% Filter specifications
low_cutoff=7; % band pass filter lower cutoff frequency (Hz)
upper_cutoff=13; % band pass filter upper cutof f frequency (Hz)

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
ch_Pz=0;

buffSize = 500; % size of the circular buffer
circBuff_1 = nan(1,buffSize); % create circular buffer
circBuff_2 = nan(1,buffSize); % create circular buffer
t_circBuff = nan(1,buffSize); % create circular buffer
meanBuff = nan(1,4*buffSize); % create circular buffer

[chunk,stamps] = inlet.pull_chunk();
block_ctrl=200;
% stamp0 = min(stamps);
% figure;
% plot(stamps,ch);
% hold on;
% try
while(1)
        pause(0.05); % wait for samples to buffer in

        % Get chunk from the inlet
        [chunk,stamps] = inlet.pull_chunk();
        
        t_circBuff = [t_circBuff(size(stamps,2)+1:end) stamps];
        
        % Channel select
        ch_Pz=(chunk(channel_Pz,:)-mean(chunk(channel_Pz,:)));
        ch_EOG=(chunk(channel_EOG,:)-mean(chunk(channel_EOG,:)));

%         ch=ch+10*cos(2*pi*10*stamps);
        
        circBuff_1 = [circBuff_1(size(ch_Pz,2)+1:end) ch_Pz];
        circBuff_2 = [circBuff_2(size(ch_EOG,2)+1:end) ch_EOG];
        
        % Data bandpass filtering
        if(~isnan(circBuff_1))
            circBuff_1=filtfilt(b, a, circBuff_1);
        end

        % Data normalization
		% ch=normal(ch);
        
        H = fft(circBuff_1, N);
        
        H = abs(H(1:N/2));

        f = (0:N/2-1)*fa/N;

        % Plot Pz signal x time
        figure(1);
        subplot(3,1,1);
        plot(t_circBuff, circBuff_1, 'r', 'Linewidth', 3);
        axis([-inf inf -50 50]);
        xlabel('Time (s)');
        ylabel('Voltage on Pz');
        
        % Plot EOG signal x time
        subplot(3,1,2);
        plot(t_circBuff, circBuff_2, 'b');
        axis([-inf inf -150 150]);
        xlabel('Time (s)');
        ylabel('Voltage on EOG');
        
        % Plot fft x time
        subplot(3,2,5);
        plot(f, H, 'r', 'Linewidth', 3);
        axis([low_cutoff upper_cutoff 0 1000]);
        xlabel('Frequency (Hz)');
        ylabel('Mag');
                
        % Find fourier components at 8 < f < 12 Hz
        bin_f = find(f>low_cutoff & f< upper_cutoff);
        
        % Compute the energy of the signal at these components
        E = nansum(H(bin_f).^2)/length(bin_f);
        
        meanBuff = [meanBuff((end-1):end) E];
        
        % Compute energy mean
        goal = 800000;
        
        % Plot energy using bar
        subplot(3,2,6);
        bar(E, 'r');
        hline = refline([0 goal]); % plot goal line
        hline.Color = 'k';
        hline.LineWidth = 4;
%         axis([-inf inf 0 goal*2+0.01]);
        axis([-inf inf 0 1000000]);
        ylabel('Energy over alpha band');
        
        
        %% Drone control
        block_ctrl=block_ctrl+1; % Blocks drone ctrl for some time to avoid
        % server flooding
        
%         if((E > goal) && (block_ctrl < 50))
        if((E > goal) && (block_ctrl > 30))
            display('entrou');
            if(up == 1)
                sound(voo);
                up = 0;
                fwrite(U, 'l'); % Send cmd to drone to land
                display('Land');
                block_ctrl = 0;
            else
                up = 1;
                sound(voo);
                fwrite(U, 't'); % Send cmd to drone to takeoff
                display('Takeoff');
                block_ctrl = 0;
            end
        end
            
        
        
end

% catch exception
%     display('Error!')
% end
