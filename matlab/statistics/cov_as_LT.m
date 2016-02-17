clf 
clear all

N = 5; % number of points in the dataset

D = rand(2, 100);

uD = mean(D,2);

D(1,:) = D(1,:) - uD(1);
D(2,:) = D(2,:) - uD(2);

plot(D(1,:), D(2,:),'*')
axis([-2 2 -2 2])
grid on
hold on

S = [4 0;0 1];

DT = S'*D;

plot(DT(1,:), DT(2,:),'r*')

S = cov(D(1,:), D(1,:))
S2 = cov(DT(1,:), DT(1,:))