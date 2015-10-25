function peaksVals = getPeaksVals(signal, peaks)

peaksVals.vec = signal(peaks);
peaksVals.avg = mean(peaksVals.vec);