clear;clc

S = [0,0,1,9,0,0,0,0,8;6,0,0,0,8,5,0,3,0;0,0,7,0,6,0,1,0,0;...
     0,3,4,0,9,0,0,0,0;0,0,0,5,0,4,0,0,0;0,0,0,0,1,0,4,2,0;...
     0,0,5,0,7,0,9,0,0;0,1,0,8,4,0,0,0,7;7,0,0,0,0,9,2,0,0];

p = 3;
A = binvar(p^2,p^2,p^2,'full');
F = [sum(A,1) == 1, sum(A,2) == 1, sum(A,3) == 1];

[i,j,k] = find(S);
F = [F, A(sub2ind([p^2 p^2 p^2],i,j,k)) == 1];
    
diagnostics = optimize(F);

Z = value(reshape(A,p^2,p^4)*kron((1:p^2)',eye(p^2)))


%%
for i = 1:p^2 
    for j = 1:p^2 
        if S(i,j)
            F = [F, A(i,j,S(i,j)) == 1];
        end
    end
end