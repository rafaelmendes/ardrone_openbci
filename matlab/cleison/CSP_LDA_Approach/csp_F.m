%% Function CSP 
function [W,F, cA, cB]=csp_F(F,Ho,faixaFreq,indiceA,indiceB)
%% Projeto CSP binario
% Matrizes de Cov medias e normalizadas

Fa = F(:,:,1:length(indiceA));
Fb = F(:,:,1+length(indiceA):length(indiceA)+length(indiceB));

%% Processamento NaN
% % Para a classe A
% I = isnan(F(:,:,1:72));
% indiceA = find(I(1,1,:)==0);
% Fa = F(:,:,indiceA);
% clear I
% % Para a classe B
% I = isnan(F(:,:,73:144));
% indiceB = find(I(1,1,:)==0);
% Fb = F(:,:,indiceB + 72);
% clear  I
%%
[~,~,ka]=size(Fa);
[n,~,kb]=size(Fb);


if (n>22)
    Chan = 1:n-3;
else
    Chan = 1:n;
end
% Inicializa as matrizes Medias
cA = zeros(length(Chan),length(Chan));
cB = zeros(length(Chan),length(Chan));

for i=1:kb,
%     auxA = .5*F(Chan,faixaFreq,i)*Ho*F(Chan,faixaFreq,i)';
    auxB = .5*Fb(Chan,faixaFreq,i)*Ho*Fb(Chan,faixaFreq,i)';
% cA = cA + auxA/trace(auxA);
cB = cB + auxB/trace(auxB);
end
% cA = cA/trace(cA);
cB = cB/trace(cB);
%
% cA = cA/72;
% cB = cB/72;

for i=1:ka,
    auxA = .5*Fa(Chan,faixaFreq,i)*Ho*Fa(Chan,faixaFreq,i)';
    cA = cA + auxA/trace(auxA);
end
cA = cA/trace(cA);
% cB = cB/trace(cB);

%% Projeto CSP para as classes A e B 

C = cA + cB;

[V,D] = eig(C);
P = D^(-.5)*V'; % Matriz de branqueamento
sA = P*cA*P';
[vA,dA] = eig(sA);
[~,I] = sort(diag(dA));
%ind = find(abs(diag(dA)-.5) >.10);
% Filtro CSP
W = vA(:,I)'*P;
F = cat(3,Fa,Fb);