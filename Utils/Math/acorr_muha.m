function res = acorr_muha(sig1)

% Fast Normalized auto correlation

sig1 = real(sig1(:));
maxlag = length(sig1) - 1;

M = maxlag + 1;

% Transform both vectors
nextPow = 2^nextpow2(2*M-1);
X = fft(sig1, nextPow);

% Compute cross-correlation
XX = X.*conj(X);
c = ifft(XX);

% Force real corr
c = real(c);
c = [c(end-maxlag+1:end,:); c(1:maxlag+1,:)];

% Scale

% The output is only the corr coeff (maximum of the cross correlation function)
res = max(c);
