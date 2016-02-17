clc
clear all
close all

% path='/home/rafael/Documents/eeg_data/doutorado_cleison';
% data='A01E.set';

path='/home/rafael/Documents/eeg_data/doutorado_cleison/A05T.gdf';
EEG = pop_biosig(path, 'blockepoch','off');

% data_val='esquerda_30_imag.set';

% EEG = pop_loadset('filename', data ,'filepath',path);

EEG.data = EEG.data(1:22,:,:);
%% Filtering [fL fH] Hz

fL = 0;
fH = 40;


%% Epoch extraction
% Left hand:
X1 = pop_epoch( EEG, {  '769'  }, [1.5  3.5], 'newname', 'ref filt epochs', 'epochinfo', 'yes');
% X1 = X1.data / sqrt(size(X1.data,2));
X1 = X1.data;

% Right hand:
X2 = pop_epoch( EEG, {  '770'  }, [1.5  3.5], 'newname', 'ref filt epochs', 'epochinfo', 'yes');
% X2 = X2.data / sqrt(size(X2.data,2));
X2 = X2.data;

%% Mean extraction

q = size(X1,2); % sample count per epoch
n = size(X1,1); % channel count
trials = size(X1,3);

W = eye(n,n) - (1/n)*ones(n,n);

for i=1:trials
    X1(:,:,i) = W * X1(:,:,i);
    X2(:,:,i) = W * X2(:,:,i);
end

%% Estimating YY' (cleison)

fs = 250; % Freq de amostragem
delf = fs/q;

m = 1 + round((fH - fL) / delf); % Quantidade de componentes de frequência

% Bins de frequência
f = zeros(1,m);
for i=1:m
    f(i) = fL + (i - 1) * delf;
end

% Sinal Tempo:
t = linspace(0, q/fs, q);

% Base de senos e cossenos.
X0_seno = zeros(n,q);
X0_cos = zeros(n,q);
for i=1:m
    X0_seno(i,:) = sin(2 * pi .* t .* f(i));
    X0_cos(i,:) = cos(2 * pi .* t .* f(i));
end

X0 = [X0_seno; X0_cos];

%%
% Cálculo dos coeficientes:

F1 = zeros(size(X1,1), 2*m, size(X1,3)); % dim = channels x freq resolution x trial
F2 = zeros(size(X1,1), 2*m, size(X1,3));

aux = X0' * pinv(X0 * X0');

for i=1:size(X1,3)
    F1(:,:,i) = X1(:,:,i) * aux;
    F2(:,:,i) = X2(:,:,i) * aux;
end

close all

% F1_mean = mean(F1,3);
% F2_mean = mean(F2,3);
%%

% Fc1 = F1_mean(:,1:m).^2 + F1_mean(:,m+1:end).^2;
% Fc2 = F2_mean(:,1:m).^2 + F2_mean(:,m+1:end).^2;
P1 = zeros(size(F1,1), size(F1,2)/2, size(F1,3));
P2 = zeros(size(F1,1), size(F1,2)/2, size(F1,3));

for i=1:size(F1,3)
    P1(:,:,i) = 0.5 * (F1(:, 1:m, i).^2 + F1(:, m+1:end, i).^2);
    P2(:,:,i) = 0.5 * (F2(:, 1:m, i).^2 + F2(:, m+1:end, i).^2);
end

P1_mean = mean(P1,3);
P2_mean = mean(P2,3);

figure;
plot(f, P1_mean(14,:), '-Ob', f, P1_mean(18,:), '-Or', 'LineWidth', 1);
title('Left Hand mov')
grid on;
legend('C3', 'C4');

figure;
plot(f, P2_mean(14,:), '-Ob', f, P2_mean(18,:), '-Or', 'LineWidth', 1);
title('Right Hand mov')
grid on;
legend('C3', 'C4');






