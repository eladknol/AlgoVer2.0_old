function resSig = filtfilt1D(b, a, signal)

resSig = zeros(1, length(signal));
coder.varsize('resSig', [1 120000], [0 1]);
resSig = filtfilt(b, a, signal);
