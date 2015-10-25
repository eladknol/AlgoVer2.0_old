function [corrVal, lag] = xcorr_muha_lag__preload(sig1, preCalcFFT, nextPow, sumSqr)

% Fastest Normalized XCORR
maxlag = length(sig1) - 1;

% Transform both vectors
X = fft(sig1, nextPow);

% Compute cross-correlation
XX = X.*preCalcFFT;
c = ifft(XX);

% Force real corr
c = real(c);
% Shift the xcorr func
c = [c(end-maxlag+1:end), c(1:maxlag+1)];

% Scale
scale = sqrt(sum(sig1.*sig1)*sumSqr);

% The output is only the corr coeff (maximum of the cross correlation function)
[y, i] = max(c);
corrVal = y/scale;

lag = -maxlag + i -1;

