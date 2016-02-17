clear all
close all

lambdaA = [0.8 0.7 0.4 0.3 0.1 0.01 0.01 0.01];

lambdaB = [0.9 0.6 0.3 0.1 0.05 0.03 0.02 0.01];

h1 = 0:0.001:1.5;

d_up = 0;
d_down = 0;

for i=1:length(lambdaA)
    d_up = d_up + sqrt(log10(lambdaA(i) ./ h1).^2);
    
    d_down = d_down + sqrt(log10(lambdaB(i) ./ h1).^2);
end

plot(h1, sqrt(d_up./d_down));