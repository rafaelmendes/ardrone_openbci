clear all;
close all;

% independent component 1
s1 = rand(1,100);

% independent component 2
s2 = rand(1,100);

% independent component matrix
S_ica = [s1; s2];

% Mixing matrix
A0 = [2 3; 2 1];

% Compute mixtures
X = A0 * S_ica;
x1 = X(1,:);
x2 = X(2,:);

% Single Value Decomposition of A0
[U,S,V] = svd(A0);

figure;
plot(s1,s2, '*')

E1 =  V' * S_ica;
E2 =  S * E1;
E3 =  U * E2;


figure;
hold on;
plot(s1,s2, '*')
plot(E1(1,:),E1(2,:), '*')
plot(E2(1,:),E2(2,:), '*')
plot(E3(1,:),E3(2,:), '*')
legend('Original','E1','E2','E3', 'Location', 'SouthEast')

% figure;
% plot(x1,x2, 'r*')
