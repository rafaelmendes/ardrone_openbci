%% Funcao de Avaliacao

function [ScoreA,ScoreB]=evaluation_F(y,indiceA,indiceB)

% [~,k]=size(y);

ScoreA = (sum(y(1:length(indiceA))>0))/(length(indiceA));

ScoreB = (sum(y(length(indiceA)+1:length(indiceA)+length(indiceB))<0))/(length(indiceB));