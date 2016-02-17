
clc;clear;close all;

load('/home/rafael/Documents/eeg_data/doutorado_cleison/Data/dadosLotte_Normalizados_A01E.mat');

Chan = 1:22;
% trials  = 1:72; % class A
% trials = 73:144; % Class B
% trials = 145:216; % Class C
trials = 217:288;

faixa = [0 40];
% flag = 'ident';
flag = 'expo';
coef = [15.2 -.5/13.0;
        28.2 -.5/09.5;
        15.2 -.5/13.0;
        28.2 -.5/09.5];

m = size(F,2);
%% Converte faixa de frequencia para indices
[Ho,faixaFreq] = gera_Ho_diag(faixa,coef,m,banda,incremento,flag);

clear m banda labels t fname
%%

Fx = F(Chan,faixaFreq,trials);
m = size(Fx,2);
%%

M = sdpvar(length(Chan));

%% Funcao Objetivo
lambda = 0;
for i=1:length(trials),
lambda = lambda + trace(Fx(Chan,:,i)*Ho*Fx(Chan,:,i)'*M)/trace(Fx(Chan,:,i)*Fx(Chan,:,i)');
end
lambda = lambda/length(trials);
clear i
%% Restricoes

% beta = 0;
% for i= 1:length(trials),
% beta = beta + trace(F(Chan,:,i)*(eye(m) - Ho)*F(Chan,:,i)'*M)/trace(F(Chan,:,i)*F(Chan,:,i)');
% end
% beta = beta/length(trials);

%% LMI restricoes
lmi = [];
for i=1:30,%length(trials),
lmi = lmi + [trace(Fx(Chan,:,i)*(eye(m) - Ho)*Fx(Chan,:,i)'*M)/trace(Fx(Chan,:,i)*Fx(Chan,:,i)') == 1];    
end

%%

solvesdp([lmi,M>=0],lambda,sdpsettings('solver','sedumi'));

%%
 lambda = double(lambda);
%  beta = double(beta);
 M = double(M);
 
 %%
 eta = zeros(1,228);%length(trials));
 for i=1:288,%length(trials),
    eta(i) = trace(F(Chan,faixaFreq,i)*Ho*F(Chan,faixaFreq,i)'*M)/trace(F(Chan,faixaFreq,i)*(eye(m)-Ho)*F(Chan,faixaFreq,i)'*M);
 end
 
 figure
 plot(eta,'--o')
 
 %%
 
[Q,D]=eig(M);
[~,I]=sort(diag(D));
V = Q(:,I(1));

%%

Y = Fx(Chan,:,72)*Xo(faixaFreq,:);
figure
plot(Y' )

Z = V'*Y;

figure
plot(Z')

%%
for j=1:288,
gama(j) = trace(F(Chan,faixaFreq,j)*(eye(m)-Ho)*F(Chan,faixaFreq,j)'*M)/trace(F(Chan,faixaFreq,j)*F(Chan,faixaFreq,j)');
end

figure
plot(gama,'--o')