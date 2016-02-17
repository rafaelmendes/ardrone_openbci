clear all
close all

b = [1; 2];

a = [2; 2];

data = [b a];

plot(a(1,:), a(2,:), '*'); 

hold on; 

plot(b(1,:), b(2,:), '*')

axis([0 4 0 4])
grid on

cov(data)