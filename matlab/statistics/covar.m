clf 
clear all

N = 5; % number of points in the dataset

% H = rand(N, 1); % hours of study
% H = [9 15 25 14 10 18 0 16 5 19 16 20];
H=[2 2 2];

% M = rand(N, 1); % marks
% M = [39 56 93 61 50 75 32 85 42 70 66 80];
M=[2 2 2];

Hmean = mean(H,2); % compute the mean
Mmean = mean(M,2); % compute the mean

subplot(1,2,1)
plot(H, M, '*')

covarHM = cov(H,M)

covHM2 = ((H-mean(H))*(M-mean(M))') / (length(H)-1)

subplot(1,2,2)
plot(covarHM, '*')

