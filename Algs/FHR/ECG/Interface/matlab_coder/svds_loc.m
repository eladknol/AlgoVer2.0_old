function [U,S,V,flag] = svds_loc(A, k, sigma, options)

U = ones(min(size(A)), k);
S = zeros(k);
V = ones(max(size(A)), k);
