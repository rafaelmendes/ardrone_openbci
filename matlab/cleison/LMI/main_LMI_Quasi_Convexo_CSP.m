%% Resolve LMI

clc;clear;close all;

load /home/rafael/Documents/eeg_data/doutorado_cleison/Data/dadosLotte_Normalizados_A01T.mat

clear Xo incremento fname labels


%%

Channels = 1:22;
F = F(Channels,:,:);
Fab = F(:,:,001:144);
Fcd = F(:,:,145:288);
[AB,indA,indB] = processaNaN(Fab);
[CD,indC,indD] = processaNaN(Fcd);
clear F
F = cat(3,AB,CD);

clear AB CD Fab Fcd Xo


%%

[n,m,trials] = size(F);

faixa = [8 30];

SubBandL = (.5*m-1)/(banda(2))*faixa(1) + 1;
SubBandH = (.5*m-1)/(banda(2))*faixa(2) + 1;

faixaFreq = [SubBandL:SubBandH SubBandL+.5*m:SubBandH+.5*m];
q = length(faixaFreq);


%%
C = zeros(n,n,trials);
for i=1:trials,
  C(:,:,i) = F(:,faixaFreq,i)*F(:,faixaFreq,i)';  
end

cA = mean(C(:,:,001:072),3);
cB = mean(C(:,:,073:144),3);

%%

[V,D] = eig(cA,cA+cB);
[~,I] = sort(diag(D));
% M = V(:,I([1 22]))';
M = V';

%%

% H = diag(sdpvar(q,1));

H = sdpvar(q);
% lambda = sdpvar(1);
% lambda = .1;

%%
lmi = [];
meanProj = M*cA*M';
% for i = 1:length(indA),
constraints = {};

% constraints = zeros(2,1);

% Optimized:
index = Channels;
index2 = faixaFreq;
index3 = 1:length(indA);

% use = sub2ind(size(F), index, index2, index3);
% h = 0;
% for i = 1:index
%     for j = 1:index2
%         for k = 1:length(indA)
%             h = h + 1;
%             use_ind(h,:) = [i,j,k]; 
%         end
%     end
% end

% for i = 1:length(indA),
%    aux(:,:,i) = M*F(:,faixaFreq,i);
%    aux2(:,:,i) = F(:,faixaFreq,i)'*M';
% end

aux = multiprod(M, F(:,faixaFreq,1:length(indA)));
aux2 = multiprod(permute(F(:,faixaFreq,1:length(indA)),[2 1 3]),M');

aux3 = multiprod(aux, H);
aux4 = multiprod(aux3, aux2);

% aux5 = multiprod(1,aux4);

% aux4 = multiprod(aux3, aux2);

% constraints = [aux3 >= 0];

for i = 1:length(indA),
   constraints = [constraints, (M*F(:,faixaFreq,i)*H*F(:,faixaFreq,i)'*M')>=0];
end

% Non-optimized
% for i = 1:length(indA),
%    constraints = [constraints, (M*F(:,faixaFreq,i)*H*F(:,faixaFreq,i)'*M' - meanProj)>=0];
%    java.lang.Runtime.getRuntime.freeMemory / 1e9 % print free heap
%    pause(1)
% end

%% Non-optimized
constraints2 = {};
for i = 1:length(indA),
   constraints2 = [constraints2, (M*F(:,faixaFreq,i) * H * F(:,faixaFreq,i)' * M' )>=0];
   java.lang.Runtime.getRuntime.freeMemory / 1e9 % print free heap
%    pause(1)
end

%%
meanProj = M*cA*M';

aux = multiprod(M,F(:,faixaFreq,:));

F_ =  permute(F, [2 1 3]);
aux2 = multiprod(F_(faixaFreq,:,:),M');

aux3 = multiprod(aux,H);
aux4 = multiprod(aux3, aux2);

constraints = [(aux4 - meanProj)>=0];
java.lang.Runtime.getRuntime.freeMemory / 1e9; % print free heap
% pause(1)

clear i
%%
lambda = 1.01;
lmi1 = [];
for i = 1:length(indA),
   lmi1 = lmi1 + [[(M*F(:,faixaFreq,i)*H*F(:,faixaFreq,i)'*M' -  M*cA*M')*lambda - (M*F(:,faixaFreq,i)*H*F(:,faixaFreq,i)'*M' -  M*cB*M')]>=0]; 
end
%%
clear F
solvesdp([H>=0,lmi,lmi1],1,sdpsettings('solver','sedumi'))

%%

H = double(H);

figure
subplot(211);plot(diag(H),'--o')
subplot(212);plot(eig(H),'--o')

h = diag(H);
f = linspace(faixa(1),faixa(2),.5*q);

figure
plot(f,h(.5*q+1:q),'--ro');hold on
plot(f,h(1:.5*q),'--o')
legend('COS','SEN')