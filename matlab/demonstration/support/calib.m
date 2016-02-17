function [ go_stop_mean, left_right_mean ] = calib_relax( inlet, b, a , low_cutoff, upper_cutoff)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

display('Calibrating...');

C3_i = 7; % index of channel C3
C4_i = 8; % index of channel C4

N = 512; % points for FFT

fa = 250;

% aux variables:
k=1;
kmax=200;

[chunk,stamps] = inlet.pull_chunk();
pause(0.1)
%% Trials:
ch=0;
buffSize = 1000; % size of the circular buffer
circBuff = nan(2, buffSize); % create circular buffer for data
t_circBuff = nan(1, buffSize); % create circular buffer with time stamps

go_stop=zeros(1, kmax);
left_right=zeros(1, kmax);

[chunk,stamps] = inlet.pull_chunk();


while(k<kmax) % calibration time = imax * t_pause = 60s
    
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
        bin_f = find(f>8 & f< 12);
        
        % Compute the energy of the signal at these components
        E = sum(H(:, bin_f).^2, 2)/length(bin_f);
        
        go_stop(k) = E(2) + E(1);
        left_right(k) = E(2) - E(1);
        
        % Plot energy using bar
        subplot(3,2,6);
        bar([go_stop(k) left_right(k)]);
        axis([-inf inf -5000 5000]);
        ylabel('Energy over alpha band');
        xlabel('[Go/Stop          Left/Right]');
                
        k=k+1;
end

    go_stop_mean=nanmean(go_stop,2);
    left_right_mean=nanmean(left_right,2);
    
    close all;
    display('End of Calibration');

end

