clear all
close all
clc

%% Load data and labels
data = load('/arquivos/Documents/eeg_data/hieron/usuario1/samples.txt');
index = load('/arquivos/Documents/eeg_data/hieron/usuario1/marcas.txt');

index(1,1) = 1; % Set first label in position 1 to avoid pointer issues
index(:,2) = [];

% Extract useful parameters:
nEpochs = size(index, 1);
nChannels = size(data, 2);
nSamples = size(data,1);

%% Band pass FIR filtering:

% Parameters
freq_band = [8 30];
order = 10;
fs = 250;

% Design
[b, a] = FIRproj( freq_band, order, fs);

% Filtering
data=filtfilt(b, a, data);

%% Get data from class A and class B
clc
clear dataA dataB samplesA;

nSamplesEpoch = fs*9; % Each epoch is 9 sec long with fs = 250 and 8 channels

indexA = square(2*pi*(0.5/(nSamplesEpoch))*(1:nSamples));
indexA( indexA == -1 ) = 0;
indexB = logical(1 - indexA);
indexA = logical(indexA);

dataA = data(indexA,:);
dataB = data(indexB,:);


%% Train CSP filter

W = CSPproj(dataA, dataB);