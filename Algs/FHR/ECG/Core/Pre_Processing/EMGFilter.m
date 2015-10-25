function res = EMGFilter(signal, inConfig)

if(nargin<2)
    filterProps = getEMGFilterProps();
    inConfig = filterProps;
end

% build the filter, use butterworth with low order (10-15) 
[b,a] = butter(inConfig.order, inConfig.Fc/(inConfig.Fs/2));

res = filtfilt(b, a, signal);