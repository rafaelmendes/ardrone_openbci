clc; clear; close all;


q = 5;

X = sdpvar(q); % Variable to be found

c = {}; % Constraints
c2 = {};

%% Non-optimized version:

for i=1:q
    for j=1:q
        c = [c, X(i,j)>= 1];
    end
end

%% Optimized version (vectorized):
clear index;
k=0;
for i=1:q
    for j=1:q
        k = k+1;
        index(k,:) = [i,j];
    end
end
% index = 1:q;
% index = perms(1:q,2);
% use = [index, index];
ij = sub2ind([q q], index(:,1), index(:,2));


c2 = [X(ij) >= 1];

%% Optimized2 version (vectorized):
clear index;

K = ones(5,5,10);

U = multiprod(K, X);

c2 = [U >= 1];

c3 = {};
for i = 1:size(K,3)
    c3 = [c3, K(:,:,i)*X >= 1];
end






