clf 
clear all

N = 5; % number of points in the dataset

% H = rand(N, 1); % hours of study
H = [9 15 25 14 10 18 0 16 5 19 16 20];
% H=[2 2 2];

% M = rand(N, 1); % marks
M = [39 56 93 61 50 75 32 85 42 70 66 80];
% M=[2 2 2];

Hmean = mean(H,2); % compute the mean
Mmean = mean(M,2); % compute the mean

plot(H, M, '*')
hold on
axis([0 40 0 100])

covarHM = cov(H,M)

u_int = [10; 100];
u = u_int / norm(u_int);
plotv(u_int)

X = [H;M];

Xproj = u'*X;

% plot(Xproj(1,:), Xproj(2,:), 'r*')

% Xproj_var = var(Xproj);

Xproj_var = u'* covarHM * u

invcovarHM = inv(covarHM);

Xproj_var_cut = u' * invcovarHM * u;

H2 = [0 5];
M2 = [32 42];
covarHM_cut = cov(H2,M2);

X2 = [H2;M2];
Xproj2 = u'*X2;

Xproj2_var = var(Xproj2);

invcovarHM_cut = inv(covarHM_cut);

Xproj_var_cut2 = u' * invcovarHM_cut * u 



