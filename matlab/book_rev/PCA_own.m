clear all
close all

x = [2.5 0.5 2.2 1.9 3.1 2.3 2 1 1.5 1.1];

y = [2.4 0.7 2.9 2.2 3.0 2.7 1.6 1.1 1.6 0.9];


% mean calculation and removal
xmean = mean(x);

ymean = mean(y);

x = x - xmean;

y = y - ymean;

D = [x;y];

% covariance matrix calculation
S = cov(x,y);

figure;
plot(x, y, 'x', 'Linewidth', 3)
% hold on
grid on
axis([-2 2 -2 2])
xlabel('x1');
ylabel('x2');
set(gcf,'color','w');


% obtain eigenvectors and eigenvalues of cov matrix
[v, lambda] = eig(S);

[lambda1 idx] = max(sum(lambda));
[lambda2] = min(sum(lambda));
v1 = v(:,idx);
v(:, idx) = [];
v2 = v;

% project data onto Principal component:
projD = v1' * D;

% recover data to two dimensions:
projD = v1 * projD;

hold on
plotv(v1*lambda1) 
plotv(v2*lambda2)
legend('original', 'maior v','menor v', 'Location','southeast')

% Plot the recovered data:
figure;
plot(x, y, 'x',projD(1,:), projD(2,:), 'r*', 'Linewidth', 3)
grid on
xlabel('x1''');
ylabel('x2''');
set(gcf,'color','w');
legend('Original', 'Após PCA', 'Location','southeast')



