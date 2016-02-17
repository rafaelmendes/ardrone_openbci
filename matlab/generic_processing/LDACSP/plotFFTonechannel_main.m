clear all
close all
clc

% Config parameters:
channel = 3; % FC3, FC4, C3, CZ, C4, CP3, CPZ, CP4

%% Load data and labels
data = load('/arquivos/Documents/eeg_data/hieron/user3/samples.txt');
index = load('/arquivos/Documents/eeg_data/hieron/user3/marcas.txt');

index(1,1) = 1; % Set first label in position 1 to avoid pointer issues
% index(:,2) = [];

% Extract useful parameters:
nEpochs = size(index, 1);
nChannels = size(data, 2);
nSamples = size(data,1);

%% Channel Selection:

data = data(:, channel);

%% Band pass FIR filtering:

% Design
% [b, a] = FIRproj( freq_band, order, fs);
% Filter parameters
order = 5;
fs = 250;
filter_cutoff = [3 30]*2/fs;
% filter_cutoff = [2*low_cutoff/fs 2*upper_cutoff/fs]; % 1 to 12 Hz  

[b, a] = butter(order, filter_cutoff);

% Filtering
data = filtfilt(b, a, data);

%% Get data from class A and class B
% clc
% clear dataA dataB samplesA;

nSamplesEpoch = fs*9; % Each epoch is 9 sec long with fs = 250 and 8 channels

% indexA = square(2*pi*(0.5/(nSamplesEpoch))*(1:nSamples));
% indexA( indexA == -1 ) = 0;
% indexB = logical(1 - indexA);
% indexA = logical(indexA);

% indexA = (-1).^[0:nEpochs-1];
% indexA( indexA == -1 ) = 0;
% indexB = logical(1 - indexA);
% indexA = logical(indexA);

indexA = logical(index(:,2));
indexB = logical(1 - index(:,2));

indexTask = [3*fs:6*fs]; % Tarefa realizada entre 3 e 6 segundos

for i=1:nEpochs % exclude last epoch
    
    dataTask(:,i) = data((i-1)*nSamplesEpoch + indexTask,:);
%     dataB = data(indexB,:);
end

dataTaskA = dataTask(:,indexA);
dataTaskB = dataTask(:,indexB(1:end-1));

%% Compute FFT
N = 512;

Ha = fft(dataTaskA, N);   
Ha = abs(Ha(1:N/2,:));

Hb = fft(dataTaskB, N); 
Hb = abs(Hb(1:N/2,:));

f = (0:N/2-1)*fs/N;

fmax = find(f > 30, 1);
fmin = find(f > 2, 1);

HaMean = mean(Ha,2);
HbMean = mean(Hb,2);

% HaMean = abs(HaMean(1:N/2,:));
% HbMean = abs(HbMean(1:N/2,:));

% Plot ffts

% clf; close all
% figure;
% hold on
% plot(f(fmin:fmax), HaMean(fmin:fmax), f(fmin:fmax), HbMean(fmin:fmax), 'LineWidth', 3)
% plot(f(fmin:fmax), HaMean(fmin:fmax), 'LineWidth', 3)
grid on
xlabel('freq')
ylabel('mag')
legend('C3', 'C4');
hold on

%% plot spectogram of data of selected channel:
clc
clf
% s = spectrogram(data);
spectrogram(data(50000:70000),100, 50, [2:30], fs , 'yaxis')





