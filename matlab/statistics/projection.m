clear all
close all

v = [1; 2];

x = [4; 5];

v = v / norm(v);

y = (v' * x) * v;

figure(1)
plotv(v, '-*')
hold on
plotv(x)
grid on
plotv(y)
axis([0 10 0 10])

legend('v', 'x', 'y');

S2 = var(y); 