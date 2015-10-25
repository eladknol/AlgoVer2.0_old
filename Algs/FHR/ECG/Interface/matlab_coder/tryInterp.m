function resSignal = tryInterp(signal, factor, Fs)

origTimeBase = linspace(0, length(signal)/Fs, length(signal));
newTimeBase = linspace(0, length(signal)/Fs, length(signal)*factor);

resSignal = interp1(origTimeBase, signal, newTimeBase, 'spline');

