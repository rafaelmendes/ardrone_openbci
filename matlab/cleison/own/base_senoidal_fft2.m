clc
clear all
close all

% path='/home/rafael/Documents/eeg_data/doutorado_cleison';
% data='A01E.set';

path='/home/rafael/Documents/eeg_data/doutorado_cleison/A01T.gdf';
EEG = pop_biosig(path, 'blockepoch','off');

% data_val='esquerda_30_imag.set';

% EEG = pop_loadset('filename', data ,'filepath',path);
fL = 8;
fH = 32;

EEG.data = EEG.data(1:22,:,:);

%% Epoch extraction
% Left hand:
X1 = pop_epoch( EEG, {  '769'  }, [1.5  3.5], 'newname', 'ref filt epochs', 'epochinfo', 'yes');
X1 = mean(X1.data,3);

% Right hand:
X2 = pop_epoch( EEG, {  '770'  }, [1.5  3.5], 'newname', 'ref filt epochs', 'epochinfo', 'yes');
X2 = mean(X2.data,3);

%% Estimating YY' (cleison)

q = size(X1,2); % sample count per epoch
n = size(X1,1); % channel count

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

% Cálculo dos coeficientes:
F1 = zeros(size(X1,1), 2*m, size(X1,3)); % dim = channels x freq resolution x trial
F2 = zeros(size(X1,1), 2*m, size(X1,3));
for i=1:size(X1,3)
    F1(:,:,i) = X1(:,:,i) * X0' / (X0 * X0');
    F2(:,:,i) = X2(:,:,i) * X0' / (X0 * X0');
end

P1 = zeros(size(F1,1), size(F1,2)/2, size(F1,3));
P2 = zeros(size(F1,1), size(F1,2)/2, size(F1,3));

for i=1:size(F1,3)
    P1(:,:,i) = 0.5 * (F1(:, 1:m, i).^2 + F1(:, m+1:end, i).^2);
    P2(:,:,i) = 0.5 * (F2(:, 1:m, i).^2 + F2(:, m+1:end, i).^2);
end

P1_mean = mean(P1,3);
P2_mean = mean(P2,3);

% Cálculo das matrizes de covariância:
H0 = eye(2*m); % Define matriz de parametrizacao: diagonal
% H0 = 1;
% fc = 15;
% b = -0.5 / 10;
% h = exp(b * (f - fc).^2);
% 
% H0 = diag([h'; h']);

% H0 = diag([P2_mean(8,:)';P2_mean(8,:)']);

covY1 = zeros(size(X1,1), size(X1,1), size(X1,3)); % dim = channels x freq resolution x trial
covY2 = zeros(size(X1,1), size(X1,1), size(X1,3));
for i=1:size(X1,3)
    covY1(:,:,i) = F1(:,:,i) * H0 * F1(:,:,i)' / trace(F1(:,:,i) * H0 * F1(:,:,i)'); % covariância do sinal projetado parametrizada por H0
    covY2(:,:,i) = F2(:,:,i) * H0 * F2(:,:,i)' / trace(F2(:,:,i) * H0 * F2(:,:,i)'); % covariância do sinal projetado parametrizada por H0
end

covY1_mean = mean(covY1,3);
covY2_mean = mean(covY2,3);

%% testes

F1_cov = zeros(size(covY1_mean));
for i=1:2*m
    F1_cov = F1_cov + F1(:,i) * F1(:,i)';
end

F1_cov = F1_cov / trace(F1_cov);










