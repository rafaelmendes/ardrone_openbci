%% CSP + LDA with weigthing Ho
clc;
clear;
close all;
resultsGlobal = zeros(9,7);
rejeitadosT = zeros(9,6);
rejeitadosE = zeros(9,6);

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

%%

for j=1:9,

filenameT = ['/home/rafael/Documents/eeg_data/doutorado_cleison/Data/dadosLotte_Normalizados_A0' num2str(j) 'T' '.mat'];

path='/home/rafael/Documents/eeg_data/doutorado_cleison/A01T.gdf';
EEG = pop_biosig(path, 'blockepoch','off');

% Canais utilizados na an�lise
Chan = 1:22;

EEG.data = EEG.data(chan,:,:);

%% Epoch extraction
% none:
X1 = pop_epoch( EEG, {  '768'  }, [0  2], 'newname', 'ref filt epochs', 'epochinfo', 'yes');
X1 = X1.data;

% Right hand:
X2 = pop_epoch( EEG, {  '770'  }, [1.5  3.5], 'newname', 'ref filt epochs', 'epochinfo', 'yes');
X2 = X2.data;

%%

% Cálculo dos coeficientes:
F1 = zeros(size(X1,1), 2*m, size(X1,3)); % dim = channels x freq resolution x trial
F2 = zeros(size(X1,1), 2*m, size(X1,3));
for i=1:size(X1,3)
    F1(:,:,i) = X1(:,:,i) * X0' / (X0 * X0');
    F2(:,:,i) = X2(:,:,i) * X0' / (X0 * X0');
end

F_trainning = F(Chan,:,:);

filenameE = ['/home/rafael/Documents/eeg_data/doutorado_cleison/Data/dadosLotte_Normalizados_A0' num2str(j) 'E' '.mat'];
% load dado_sem_CAR_A01E.mat
load(filenameE)
% load dados_Normalizados_A01E.mat
F_eval = F(Chan,:,:);
clear F fname t I Xo filenameE
%%

cenarios = [001:072 073:144; % AB
            001:072 145:216; % AC
            001:072 217:288; % AD
            073:144 145:216; % BC
            073:144 217:288; % BD
            145:216 217:288];% CD 

coef = [15.2 -.5/13.0;
        28.2 -.5/09.5;
        15.2 -.5/13.0;
        28.2 -.5/09.5];
    
faixa = [0 40];

% flag = 'ident'; 
flag = 'expo'; 

avaliacao = zeros(4,6);
% Número de pares de filtros CSP 
NumFeat = 3;

for i=1:1,
% Define as tentativas associadas as Classes
trials = cenarios(i,:);

FT = F_trainning(:,:,trials);
[n,m,k]=size(FT);

% Analisa se a tentativa possui NaN
[FT,indiceA,indiceB] = processaNaN(FT);
rejeitadosT(j,i) = 144 - length(indiceA) - length(indiceB);


[Hf,faixaFreq] = gera_Ho_diag(faixa,coef,m,banda,incremento,flag);
% Hf_train = eye(90,90);
%% Projeto CSP
[W,FT, cA, cB] = csp_F(FT,Hf,faixaFreq,indiceA,indiceB);

%% Feature Extraction

fet = feat_extraction(FT,Hf,faixaFreq,W,NumFeat);

%% LDA project
[w,b,yy] = lda_proj(fet,indiceA,indiceB);

%% Evaluation Trainning Dataset
table = zeros(4,1);
[table(1),table(2)] = evaluation_F(yy,indiceA,indiceB);


%% Validation 
% clear F feat 

% load dado_sem_CAR_A01E.mat
% load dados_Normalizados_A01E.mat

FE = F_eval(:,:,trials);
[FE,indiceA,indiceB] = processaNaN(FE);

%% Feature Extraction

fet = feat_extraction(FE,Hf,faixaFreq,W,NumFeat);

%% LDA evaluation

[~,~,yy]=lda_eval(fet,w,b,indiceA,indiceB);

%% Evaluation Validation Dataset

[table(3),table(4)] = evaluation_F(yy,indiceA,indiceB);

%%
% ref = [0.8750;0.9444;0.5278;0.9437]; %A01E ==> A01T
% ref = [0.8472;0.8889;0.9583;0.8028]; %A01T ==> A01E


% mediaTable  = mean(table);
avaliacao(:,i) = table;

rejeitadosE(j,i) = 144 - length(indiceA) - length(indiceB);
clear W w b fet yy FE FT
end
%%

mediaClasse = mean(avaliacao([3 4],:));
mediaSujeito = mean([avaliacao;mediaClasse],2);
results = [[avaliacao;mediaClasse] mediaSujeito];



resultsGlobal(j,:) = results(5,:);

end
%%
metric_mean = {'A vs B','A vs C','A vs D','B vs C','B vs D','C vs D','Med Sub'};
% metric_dist = {'Classe A (T)','Classe B (T)','Classe A (E)','Classe B (E)','Valor m�dio (E)'};
% 
% disp('-------------------------------------------------------------------------------------------------------------');
% disp('Accuracy (%) - Rows : Classes, Colums : Cen�rios');
% disp('-------------------------------------------------------------------------------------------------------------');
% displaytable(results,metric_mean,10,{'.4f'},metric_dist)
% disp('-------------------------------------------------------------------------------------------------------------');
subj = {'Subj 1','Subj 2','Subj 3','Subj 4','Subj 5','Subj 6','Subj 7','Subj 8','Subj 9'};
disp('-------------------------------------------------------------------------------------------------------------');
disp('Accuracy (%) - Rows : Classes, Colums : Cen�rios');
disp('-------------------------------------------------------------------------------------------------------------');
displaytable(resultsGlobal,metric_mean,10,{'.4f'},subj)
disp('-------------------------------------------------------------------------------------------------------------');

trueValues = [ 88.89 51.39 96.53 70.14 54.86 71.53 81.25 93.75 93.75 ];

