%% Funcao LDA

%% LDA
function [w,b,y]=lda_proj(fet)

xA = log(fet(:,1:72));
xB = log(fet(:,73:144));

xA = [xA;ones(1,72)];
xB = [xB;ones(1,72)];

mxA = mean(xA,2);
mxB = mean(xB,2);

Sa = xA*xA' - mxA*mxA';
Sb = xB*xB' - mxB*mxB';

w = (Sa+Sb)^(-1)*(mxA - mxB);
b = .5*w'*(mxA+mxB);
y = sign(w'*([xA xB]-b));