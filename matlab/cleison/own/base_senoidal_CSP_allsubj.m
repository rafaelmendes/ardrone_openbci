clc
clear all
close all

% path='/home/rafael/Documents/eeg_data/doutorado_cleison';
% data='A01E.set';

path='/home/rafael/Documents/eeg_data/doutorado_cleison/A09T.gdf';
EEG = pop_biosig(path, 'blockepoch','off');

% data_val='esquerda_30_imag.set';

% EEG = pop_loadset('filename', data ,'filepath',path);
fL = 8;
fH = 30;

EEG.data = EEG.data(1:22,:,:);
%% Filtering [fL fH] Hz

% 
% EEG = pop_eegfilt( EEG, fL, 0, [], [0]);
% EEG = pop_eegfilt( EEG, 0, fH, [], [0]);


%% Epoch extraction
% Left hand:
X1 = pop_epoch( EEG, {  '769'  }, [1.5  3.5], 'newname', 'ref filt epochs', 'epochinfo', 'yes');
X1 = X1.data;

% Right hand:
X2 = pop_epoch( EEG, {  '770'  }, [1.5  3.5], 'newname', 'ref filt epochs', 'epochinfo', 'yes');
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
F2 = zeros(size(X2,1), 2*m, size(X2,3));

aux = X0' * pinv(X0 * X0');
for i=1:size(X1,3)
    F1(:,:,i) = X1(:,:,i) * aux;
    F2(:,:,i) = X2(:,:,i) * aux; 
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
% H0 = eye(2*m); % Define matriz de parametrizacao: diagonal
% fc = 15;
% b = -0.5 / 10;
% h = exp(b * (f - fc).^2);
% 
% H0 = diag([h'; h']);

H0 = diag([P1_mean(14,:)';P1_mean(14,:)']);

H0 = H0 / max(diag(H0));

% H0 = eye(2*m); % Define matriz de parametrizac% figure;
% plot(target, 'LineWidth', 3); hold on; plot(result, 'r*' )

covY1 = zeros(size(X1,1), size(X1,1), size(X1,3)); % dim = channels x freq resolution x trial
covY2 = zeros(size(X1,1), size(X1,1), size(X1,3));
for i=1:size(X1,3)
    covY1(:,:,i) = F1(:,:,i) * H0 * F1(:,:,i)' / trace(F1(:,:,i) * H0 * F1(:,:,i)'); % covariância do sinal projetado parametrizada por H0
    covY2(:,:,i) = F2(:,:,i) * H0 * F2(:,:,i)' / trace(F2(:,:,i) * H0 * F2(:,:,i)'); % covariância do sinal projetado parametrizada por H0
end

covY1_mean = mean(covY1,3);
covY2_mean = mean(covY2,3);

%%% CSP implementation:

[v, lambda] = eig(covY1_mean + covY2_mean);

[v1, lambda1] = eig(covY1_mean);
[v2, lambda2] = eig(covY2_mean);

% [v, lambda] = eig(C1 + C2);

% whiten matrix
Q = lambda^(-1/2) * v';

[V D] = eig(Q * covY1_mean * Q');

[D, ind] = sort(diag(D), 'descend');
V = V(:,ind);

W = V' * Q;

%%% Applying CSP to covariances matrices of whole data:

feature1 = zeros(size(X1,3),size(W,1));
feature2 = zeros(size(X1,3),size(W,1));

for i=1:size(X1,3) % for all trials
    feature1(i,:) = log(diag(W * covY1(:,:,i) * W') / trace(W * covY1(:,:,i) * W'))';
    feature2(i,:) = log(diag(W * covY2(:,:,i) * W') / trace(W * covY2(:,:,i) * W'))';
end

feature = [feature1; feature2];

feature = [feature(:,1:3) feature(:,end-2:end)];
% feature = [feature(:,1) feature(:,end)];

%%% Classifier BLDA:

% Targets:
target = [ones(size(feature1,1),1) ; zeros(size(feature2,1),1)];

w = LDA(feature,target);

L = [ones(size(feature,1), 1) feature] * w';

P = exp(L) ./ repmat(sum(exp(L),2),[1 2]);

result = zeros(size(feature,1),1);

ind = find(P(:,1) < P(:,2));
result(ind) = 1;

right = sum(result == target);

accuracy = right / length(result)

% figure;
% plot(target, 'LineWidth', 3); hold on; plot(result, 'r*' )







