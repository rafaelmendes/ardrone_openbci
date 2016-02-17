%% Teste multiplicacao using for:
clc
clear

nepochs = 72;
k = 90; 

tM = ones(22,22);
tF = ones(22,k,nepochs);
tH = ones(k);

constraints = {};

tH = sdpvar(k);

% Non-optimized: constraints 72x1 31078616 lmi 
for i = 1:nepochs,
   constraints = [constraints, (tM * tF(:,:,i) * tH * tF(:,:,i)' * tM' ) >= 0];
   java.lang.Runtime.getRuntime.freeMemory / 1e9 ;% print free heap;
%    pause(1)
end

% Optimized
aux1 = multiprod(tM, tF);
aux2 = multiprod(permute(tF,[2 1 3]),tM');

% aux3 = multiprod(aux1, tH);

% aux4 = multiprod(tH, aux2); % The problem is here!

% aux5 = multiprod(aux3,aux4);

%%
% aux4 = zeros(22,22,72);
constraints2 = {};

for i = 1:nepochs,
   aux3 = aux1(:,:,i) * tH * aux2(:,:,i);
   
   
   
%    constraints2 = [constraints2, aux3 >= 0];
end

aux4 = repmat(aux3,[1 1 nepochs]);

aux5 = permute(aux4,[3 1 2]);
