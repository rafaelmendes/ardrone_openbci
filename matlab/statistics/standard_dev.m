N = 3; % number of points in the dataset

X = rand(N, 1); % dataset

Xmean = mean(X,1); % compute the mean

sum = 0; % aux variable

for i=1:N
    
    sum = sum + (X(i)-Xmean)^2;
    
end

% compute standard deviation
S = sqrt((sum) / (N-1))

Sml = std(X)

