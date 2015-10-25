function corrVec = matVecCorrFast(mat, vec, bounds)
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

maxlag = length(vec) - 1;
nextPow = 2^nextpow2(2*maxlag + 1);

% global preCalcFFT;
preCalcFFT = conj(fft(vec, nextPow));
sumSqr = sum(vec.*vec);


for i=1:length(inds)
    vec1 = mat(inds(i), :);
    corrVec(i) = xcorr_muha_preload(vec1, preCalcFFT, nextPow, sumSqr);
end

% preCalcFFT = [];
