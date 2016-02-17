%% Funcao Extracao de Caracteristicas

function [fet]=feat_extraction(F,Ho,faixaFreq,W,NumFeat)
% Feature Extraction
[n,~,k]=size(F);


if (n>22)
    Chan = 1:n-3;
else
    Chan = 1:n;
end

vet = [1:NumFeat length(Chan)-NumFeat+1:length(Chan)];

feat = zeros(length(Chan),k);
for i=1:k,
    aux = .5*(W*F(Chan,faixaFreq,i)*Ho*F(Chan,faixaFreq,i)'*W');
    feat(:,i) = diag(aux)/trace(aux);
end
fet = feat(vet,:);
