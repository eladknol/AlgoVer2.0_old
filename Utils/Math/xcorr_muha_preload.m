function res = xcorr_muha_preload(sig1, preCalcFFT, nextPow, sumSqr)

%% DOC
% Fastest Normalized XCORR with a pre loaded FFT of sig2

%% #pragmas
%#codegen
% global preCalcFFT;
%% Coder directives
coder.varsize('X', [1 17000], [0 1]); % #CODER_VARSIZE
coder.varsize('X', [1 17000], [0 1]); % #CODER_VARSIZE
coder.extrinsic('disp', 'tic', 'toc', 'num2str');

%% Code
% Transform both vectors
X = fft(sig1, nextPow);

% Compute cross-correlation
XX = X.*preCalcFFT;
c = ifft(XX);

% Force real corr
c = real(c);

% Scale
scale = sqrt(sum(sig1.*sig1)*sumSqr);

% The output is only the corr coeff (maximum of the cross correlation function)
res = max(c)/scale;
