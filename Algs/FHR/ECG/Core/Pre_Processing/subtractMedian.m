function res = subtractMedian(signal, medLen)

res = signal - fastmedfilt1d(signal, medLen)';
