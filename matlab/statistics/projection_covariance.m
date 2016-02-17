clear all
close all

v = [1; 2];

x = [2 - 4*rand(1,100); 5 - 10*rand(1,100)];

cov_x = cov(x'); % close to zero covariance

v = v / norm(v);

y =  v * (v' * x);

figure(1)
plotv(v, '-*')
hold on
% plotv(x)
grid on
plotv(y)
axis([0 10 0 10])

legend('v', 'x', 'y');

% covariance calculation:
S2 = cov(y'); 

S2_proj = (v' * cov_x) * v;
