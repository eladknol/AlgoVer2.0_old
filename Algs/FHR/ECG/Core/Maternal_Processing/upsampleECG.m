function signalHR = upsampleECG(signal, factor, Fs)

origTimeBase = linspace(0, length(signal)/Fs, length(signal));
newTimeBase = linspace(0, length(signal)/Fs, length(signal)*factor);

signalHR = interp1(origTimeBase, signal, newTimeBase, 'spline');
