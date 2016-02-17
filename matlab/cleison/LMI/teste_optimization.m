% Original

clc;clear;close all;

N = 20;

X = sdpvar(N);

c = {};


%% Non-optimized
tic
for i=1:N-2
    for j=i+1:N-1
        for k=j+1:N
            
            c = [c, X(i,j) + X(i,k) + X(j,k) >=-1, X(i,j) - X(i,k) - X(j,k) >= -1,-X(i,j) + X(i,k) - X(j,k) >= -1, -X(i,j) - X(i,k) + X(j,k) >= -1 ];
            
        end
        
    end
end
toc

%% Optimized

index = nchoosek(1:N,3);
use = index(:,1) <= N-2 & index(:,2) >= index(:,1)+1 & index(:,2) <= N-1 & index(:,3) >= index(:,2)+1;
index = index(find(use),:);
ij = sub2ind([N N],index(:,1),index(:,2));
ik = sub2ind([N N],index(:,1),index(:,3));
jk = sub2ind([N N],index(:,2),index(:,3));
tic
c2 = [X(ij) + X(ik) + X(jk) >=-1, X(ij) - X(ik) - X(jk) >= -1,-X(ij) + X(ik) - X(jk) >= -1, -X(ij) - X(ik) + X(jk) >= -1 ];
toc        
