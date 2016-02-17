
N = 3; % number of channels in x

n = 3; % number of samples in x

x = rand(N, n); %EEG signal

W = (-1/(N))*ones(N, N);

% y = ones(N, n); % Transformed EEG signal

y2 = zeros(N,n);

xmean = mean(x, 1);

% Generating the transformation matrix:
for i=1:N
   
    W(i,i) = 1 - 1 / N;
    
%     W(i,i) = 1;
    
%     aux = x;
%     aux(i, :) = []; 
%     
%     xmean = mean(aux, 1);
    
    y2(i,:) = x(i,:) - xmean; 
    
end


y = W * x % CAR using linear projection

y2 % CAR calculated using mean function

 