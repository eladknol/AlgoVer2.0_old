function res = xcorr_muha(sig1, sig2)

%% DOC
% Fast Normalized XCORR
% sig1 & sig2 must have the same length

%% #pragmas
%#codegen

%% Coder directives
coder.varsize('X', [1 17000], [0 1]); % #CODER_VARSIZE
coder.varsize('X', [1 17000], [0 1]); % #CODER_VARSIZE
coder.extrinsic('disp', 'tic', 'toc', 'num2str');

maxlag = length(sig1) - 1;

% Transform both vectors

nextPow = 2^nextpow2(2*maxlag + 1);
X = fft(sig1, nextPow);
Y = fft(sig2, nextPow);

% Compute cross-correlation
XX = X.*conj(Y);
c = ifft(XX);

% Force real corr

c = real(c);
% c = [c(end-maxlag+1:end), c(1:maxlag+1)];

% Scale
scale = sqrt(sum(sig1.*sig1)*sum(sig2.*sig2));

% The output is only the corr coeff (maximum of the cross correlation function)
res = max(c)/scale;
