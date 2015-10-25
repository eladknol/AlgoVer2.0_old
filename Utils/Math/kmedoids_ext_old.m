function [label, energy, index] = kmedoids_ext_old(X,k)
% X: d x n data matrix
% k: number of cluster
v = dot(X,X,1);
D = bsxfun(@plus,v,v')-2*(X'*X);
n = size(X,2);
try
    inds = randsample(n,k);
catch
    inds = randperm(n, k)';
end
[~, label] = min(D(inds,:),[],1);
last = 0;
while any(label ~= last)
    [~, index] = min(D*sparse(1:n,label,1,n,k,n),[],1);
    last = label;
    [val, label] = min(D(index,:),[],1);
end
energy = sum(val);
