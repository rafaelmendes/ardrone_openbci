%% Funcao LDA

%% LDA
function [w,b,y]=lda_proj(fet,indiceA,indiceB)

xA = log(fet(:,1:length(indiceA)));
xB = log(fet(:,length(indiceA)+1:length(indiceA)+length(indiceB)));

xA = [xA;ones(1,length(indiceA))];
xB = [xB;ones(1,length(indiceB))];

mxA = mean(xA,2);
mxB = mean(xB,2);

Sa = xA*xA' - mxA*mxA';
Sb = xB*xB' - mxB*mxB';

w = (Sa+Sb)^(-1)*(mxA - mxB);
b = .5*w'*(mxA+mxB);
y = sign(w'*([xA xB]-b));