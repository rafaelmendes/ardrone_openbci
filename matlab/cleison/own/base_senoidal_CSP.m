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
%% Filtering [fL fH] Hz


% EEG = pop_eegfilt( EEG, fL, 0, [], [0]);
% EEG = pop_eegfilt( EEG, 0, fH, [], [0]);


%% Epoch extraction
% Left hand:
X1 = pop_epoch( EEG, {  '769'  }, [1.5  3.5], 'newname', 'ref filt epochs', 'epochinfo', 'yes');
X1 = X1.data;

% Right hand:
X2 = pop_epoch( EEG, {  '770'  }, [1.5  3.5], 'newname', 'ref filt epochs', 'epochinfo', 'yes');
X2 = X2.data;

%% Scatter plot

% figure;
% plot(X1(8,:),X1(12,:), 'r*', X2(8,:),X2(12,:), 'b*')
% axis([-5 5 -5 5]);
% legend('Classe 1', 'Classe 2');
% xlabel('C3')
% ylabel('C4')
% set(gcf,'color','w');
% grid on;


%% Covariance matrices classical computation
C1_epoch = zeros(size(X1,1),size(X1,1),size(X1,3)); % dim = channels x samples x trial
C2_epoch = zeros(size(X1,1),size(X1,1),size(X1,3));

for i=1:size(X1,3)
    
    C1_epoch(:,:,i) = cov(X1(:,:,i)') / trace(cov(X1(:,:,i)'));
    C2_epoch(:,:,i) = cov(X2(:,:,i)') / trace(cov(X2(:,:,i)'));
end

C1 = mean(C1_epoch,3);
C2 = mean(C2_epoch,3);

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

%% Testing the estimated signal
% X_est = F1(1,:,1) * X0; % estimation for one trial and one channel
% 
% figure; % plots the estimated versus the original signal
% plot(X_est);
% hold on
% plot(X1(1,:,1));

% plots covariance matrices (estimated versus calculated from original signal)
% figure;plot(C1(1,:), 'r*'); hold on; plot(covY1_mean(1,:), 'b*');
% figure;plot(C1(:,:), 'r*', 'LineWidth', 2); hold on; plot(covY1_mean(:,:), 'b*');

%% CSP implementation:

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
%% Applying CSP to one trial:

% Y1 = W * X1(:,:,1);
% Y2 = W * X2(:,:,1);
% 
% figure;
% plot(Y1(1,:),Y1(end,:), 'r*', Y2(1,:),Y2(end,:), 'b*')
% legend('Classe 1', 'Classe 2');
% xlabel('C3*')
% ylabel('C4*')
% set(gcf,'color','w');
% % axis([-1 1 -1 1]);
% grid on;

%% Applying CSP to covariances matrices of whole data:

feature1 = zeros(size(X1,3),size(W,1));
feature2 = zeros(size(X1,3),size(W,1));

for i=1:size(X1,3) % for all trials
    feature1(i,:) = log(diag(W * covY1(:,:,i) * W') / trace(W * covY1(:,:,i) * W'))';
    feature2(i,:) = log(diag(W * covY2(:,:,i) * W') / trace(W * covY2(:,:,i) * W'))';
end

% for i=1:size(X1,3) % for all trials
%     feature1(i,:) = log(diag(W * C1_epoch(:,:,i) * W') / trace(W * C1_epoch(:,:,i) * W'))';
%     feature2(i,:) = log(diag(W * C2_epoch(:,:,i) * W') / trace(W * C2_epoch(:,:,i) * W'))';
% end

feature = [feature1; feature2];

feature = [feature(:,1:3) feature(:,end-2:end)];
% feature = [feature(:,1) feature(:,end)];

%% Classifier BLDA:

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

figure;
plot(target, 'LineWidth', 3); hold on; plot(result, 'r*' )







