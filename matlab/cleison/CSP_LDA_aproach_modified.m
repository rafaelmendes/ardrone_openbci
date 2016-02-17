%% CSP + LDA with weigthing Ho
clc;
clear;
close all;
resultsGlobal = zeros(10,1);
rejeitadosT = zeros(9,1);
rejeitadosE = zeros(9,1);
for j=1:9,

filenameT = ['/home/rafael/Documents/eeg_data/doutorado_cleison/Data/dadosLotte_Normalizados_A0' num2str(j) 'T' '.mat'];
% load dado_sem_CAR_A01T.mat
% load('dados_Normalizados_A01T.mat')
load(filenameT)
% Canais utilizados na an�lise
Chan = 1:22;
% Chan = [8 9 10 11 12 14 15 16 17 18 19 20 21];
F_trainning = F(Chan,:,:);
clear F Xo banda fname incremento labels t I filenameT

filenameE = ['/home/rafael/Documents/eeg_data/doutorado_cleison/Data/dadosLotte_Normalizados_A0' num2str(j) 'E' '.mat'];
% load dado_sem_CAR_A01E.mat
load(filenameE)
% load dados_Normalizados_A01E.mat
F_eval = F(Chan,:,:);
clear F fname t I Xo filenameE
%%

cenarios = [001:072 073:144];% Épocas com tarefas de mao esquerda e direita

coef = [15.2 -.5/13.0;
        28.2 -.5/09.5;
        15.2 -.5/13.0;
        28.2 -.5/09.5];
    
faixa = [8 30];

flag = 'ident'; 
% flag = 'expo'; 

avaliacao = zeros(4,1);
% N�mero de pares de filtros CSP 
NumFeat = 3;

% Define as tentativas associadas as Classes
trials = cenarios;

FT = F_trainning(:,:,trials);
[n,m,k]=size(FT);

% Analisa se a tentativa possui NaN
[FT,indiceA,indiceB] = processaNaN(FT);
rejeitadosT(j,1) = 144 - length(indiceA) - length(indiceB);


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
FE = F_eval(:,:,trials);
[FE,indiceA,indiceB] = processaNaN(FE);

%% Feature Extraction

fet = feat_extraction(FE,Hf,faixaFreq,W,NumFeat);

%% LDA evaluation

[~,~,yy]=lda_eval(fet,w,b,indiceA,indiceB);

%% Evaluation Validation Dataset

[table(3),table(4)] = evaluation_F(yy,indiceA,indiceB);
avaliacao(:,1) = table;

rejeitadosE(j,1) = 144 - length(indiceA) - length(indiceB);
clear W w b fet yy FE FT
%%
mediaClasse = mean(avaliacao([3 4],:));

resultsGlobal(j,:) = mediaClasse;

end
%%

mediaClasse = mean(resultsGlobal(:,1));

resultsGlobal(10,1) = mediaClasse;

trueValues = [ 88.89 51.39 96.53 70.14 54.86 71.53 81.25 93.75 93.75 ] * 0.01;

meantrueValues = mean(trueValues);

resultsGlobal(:,2) = [trueValues meantrueValues]';

metric_mean = {'A vs B', 'Lotte'};

subj = {'Subj 1','Subj 2','Subj 3','Subj 4','Subj 5','Subj 6','Subj 7','Subj 8','Subj 9','Med Classe'};
disp('-------------------------------------------------------------------------------------------------------------');
disp('Accuracy (%) - Rows : Classes, Colums : Cenarios');
disp('-------------------------------------------------------------------------------------------------------------');
displaytable(resultsGlobal,metric_mean,10,{'.4f'},subj)
disp('-------------------------------------------------------------------------------------------------------------');



