%% Function CSP 
function [W]=CSPproj(dataA, dataB)
%% Projeto CSP binario
% Extrai 

cA = dataA * dataA';
cA = cA / trace(cA);

cB = dataB * dataB';
cB = cB / trace(cB);

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