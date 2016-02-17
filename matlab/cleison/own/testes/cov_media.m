clc; clear all; close all;

A = rand(10,50,100); % simulated coeficients matrix

ntrials = size(A,3);

nsamples = size(A,2);

% A1_mean = mean(A,3);
% A2_mean = mean(A,3);
% 
% A_mean = A1_mean * A2_mean;

H0 = eye(nsamples, nsamples);

for i=1:ntrials
    aux(:,:,i) = A(:,:,i) * A(:,:,i)';
end

A_mean = mean(aux,3);
clear aux;
 
for i=1:ntrials
    aux(:,:,i) = A(:,:,i) * H0 * A(:,:,i)';
end

A_mean2 = mean(aux,3);


% A_1 = A;
% A_2 = permute(A,[2 1 3]);
% 
% A_mean2 = mean(A_1,3) * mean(A_2,3);


