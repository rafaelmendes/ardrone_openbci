%% Funcao LDA

%% LDA
function [w,b,y]=lda_eval(fet,w,b,indiceA,indiceB)

% [~,k]=size(fet);

% ind = .5*k;

xA = log(fet(:,1:length(indiceA)));
xB = log(fet(:,length(indiceA)+1:length(indiceA)+length(indiceB)));

xA = [xA;ones(1,length(indiceA))];
xB = [xB;ones(1,length(indiceB))];

% mxA = mean(xA,2);
% mxB = mean(xB,2);

% b = .5*w'*(mxA+mxB);

y = sign(w'*([xA xB]-b));