clear all
close all

path='/home/rafael/Documents/eeg_data/doutorado_cleison/A01T.gdf';
EEG = pop_biosig(path, 'blockepoch','off');

% data_val='esquerda_30_imag.set';

% EEG = pop_loadset('filename', data ,'filepath',path);
fL = 6;
fH = 32;

EEG.data = EEG.data(1:22,:,:);

%% Epoch extraction
% Stop:
X1 = pop_epoch( EEG, {  '769'  }, [3.5  5.5], 'newname', 'ref filt epochs', 'epochinfo', 'yes');
X1 = X1.data;

% Move:
X2 = pop_epoch( EEG, {  '770'  }, [3.5  5.5], 'newname', 'ref filt epochs', 'epochinfo', 'yes');
X2 = X2.data;

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
aux =  X0' / (X0 * X0');
for i=1:size(X1,3)
    F1(:,:,i) = X1(:,:,i) * aux;
    F2(:,:,i) = X2(:,:,i) * aux;
end

% Cálculo das matrizes de covariância:
H0 = eye(2*m); % Define matriz de parametrizacao: diagonal
fc = 15;
b = -0.5 / 10;
h = exp(b * (f - fc).^2);

% H0 = diag([h'; h']);

covY1 = zeros(size(X1,1), size(X1,1), size(X1,3)); % dim = channels x freq resolution x trial
covY2 = zeros(size(X1,1), size(X1,1), size(X1,3));
for i=1:size(X1,3)
    covY1(:,:,i) = F1(:,:,i) * H0 * F1(:,:,i)' / trace(F1(:,:,i) * H0 * F1(:,:,i)'); % covariância do sinal projetado parametrizada por H0
    covY2(:,:,i) = F2(:,:,i) * H0 * F2(:,:,i)' / trace(F2(:,:,i) * H0 * F2(:,:,i)'); % covariância do sinal projetado parametrizada por H0
end

covY1_mean = mean(covY1,3);
covY2_mean = mean(covY2,3);

%% LMI Formulation:

setlmis([]);
M=lmivar(1,[3 1]);


M_opt = [];

lmiterm([-1 1 1 0],tr(K*(I-P)*K'*M)1M);         % LMI #1: tr(K*(I-P)*K'*M)1M

teste1=getlmis;

for i=1:size(X1,3)
    M_opt = 
    
end

lmiterm([1 1 1 p],1,a1,'s')     % LMI #1 
lmiterm([2 1 1 p],1,a2,'s')     % LMI #2 
lmiterm([3 1 1 p],1,a3,'s')     % LMI #3 
lmiterm([-4 1 1 p],1,1)         % LMI #4: P 
lmiterm([4 1 1 0],1)            % LMI #4: I 
lmis = getlmis











