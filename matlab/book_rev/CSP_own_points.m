clear all
close all

Scale = [1.5 0; 0 0.5];
Rot = [1 1; 1 -1];

X1 = rand(6,100); % Raw signal
aux = mean(X1,2);
X1 = X1 - aux(:,ones(size(X1,2),1));

X2 = Rot * Scale * rand(6,100) ; % Raw signal
aux = mean(X2,2);
X2 = X2 - aux(:,ones(size(X2,2),1));

plot(X1(1,:),X1(2,:), 'r*', X2(1,:),X2(2,:), 'b*')
axis([-1 1 -1 1]);
grid on;


%% Covariance matrices computation
C1 = cov(X1);
C2 = cov(X2);

%% Transformation Matrix computation
[v1, lambda1] = eigs(C1,1);

[v2, lambda2] = eigs(C2);

W = [v1(:,1) v2(:,1)];

%% Applying the filter to data

Y1 = W * X1;
Y2 = W * X2;

figure;
plot(Y1(1,:),Y1(2,:), 'r*', Y2(1,:),Y2(2,:), 'b*')
axis([-1 1 -1 1]);
grid on;




