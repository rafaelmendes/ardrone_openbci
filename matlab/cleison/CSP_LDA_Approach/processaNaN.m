%% Analise de NaN
function [F,indiceA,indiceB]=processaNaN(F)
%% Processamento NaN
% Para a classe A
I = isnan(F(:,:,1:72));
indiceA = find(I(1,1,:)==0);
Fa = F(:,:,indiceA);
clear I
% Para a classe B
I = isnan(F(:,:,73:144));
indiceB = find(I(1,1,:)==0);
Fb = F(:,:,indiceB + 72);
clear  I
F = cat(3,Fa,Fb);