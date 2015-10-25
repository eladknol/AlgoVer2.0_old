function corrVec = matVecCorr(mat, vec, bounds)
%% DOC
% Calculate correlation between a matrix and a vector

%% #pragmas
%#codegen

%% Coder directives
coder.extrinsic('tic', 'toc', 'disp');
coder.varsize('corrVec', [5000 1], [1 0]); % #CODER_VARSIZE
coder.varsize('vec1', [1 5000], [0 1]); % #CODER_VARSIZE

%% Code
siz = bounds(2) - bounds(1) + 1;
corrVec = zeros(siz, 1);

inds = bounds(1):bounds(2);

for i=1:length(inds)
    vec1 = mat(inds(i), :);
    corrVec(i) = xcorr_muha(vec1, vec);
end
