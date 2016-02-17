clear all

close all



A = 2 - 4*rand(100,1);

B = 5 - 10*rand(100,1);



scale = [2 0; 0 5];

theta = 10 *pi / 4; % 45 grad

rot = [cos(theta) -sin(theta); cos(theta) sin(theta)];

data = [A B]; 

data_scaled = (scale * data')';

data_rot = (rot * data')';

figure
plot(data(:,1), data(:,2), '*')
hold on;
plot(data_scaled(:,1), data_scaled(:,2), '*')
plot(data_rot(:,1), data_rot(:,2), '*')
axis([-10 10 -10 10])