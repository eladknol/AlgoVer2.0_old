function [corrVal, lag] = xcorr_muha_lag(sig1, sig2)

% Fast Normalized XCORR
% sig1 & sig2 must have the same length

sig1 = real(sig1(:));
sig2 = real(sig2(:));
maxlag = length(sig1) - 1;

M = maxlag + 1;

% Transform both vectors
nextPow = 2^nextpow2(2*M-1);
X = fft(sig1, nextPow);
Y = fft(sig2, nextPow);

% Compute cross-correlation
XX = X.*conj(Y);
c = ifft(XX);

% Force real corr
c = real(c);
c = [c(end-maxlag+1:end), c(1:maxlag+1)];

% Scale
scale = sqrt(sum(sig1.^2)*sum(sig2.^2));

% The output is only the corr coeff (maximum of the cross correlation function)
[y, i] = max(c);
corrVal = y/scale;

% lags = -maxlag:maxlag;
% lag = lags(i);

lag = -maxlag + i -1;

