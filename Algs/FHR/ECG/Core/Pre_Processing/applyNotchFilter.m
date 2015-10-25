function res = applyNotchFilter(filterProps, signal)

% Apply notch filter to a data sequence in signal
wo = filterProps.Fc/(filterProps.Fs/2);
bw = wo/filterProps.QF;

[b, a] = iirnotch(wo, bw);

res = filtfilt(b, a, signal);
