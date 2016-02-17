function [ b, a ] = FIRproj( freq_band, order, fs )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    low_cutoff = freq_band(1); % band pass filter lower cutoff frequency (Hz)
    upper_cutoff = freq_band(2); % band pass filter upper cutoff frequency (Hz)
                  
    filter_cutoff = [2*low_cutoff/fs 2*upper_cutoff/fs]; % 1 to 12 Hz  

    [b, a] = butter(order,filter_cutoff);

end

