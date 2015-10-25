function E = getPeaksEnergy(signal, peaks, peaksOnly)

E=0;
if(nargin<3)
    peaksOnly = 0;
end
if(~peaksOnly)
    for i=1:length(peaks)
        qrs = getQRSComplex(signal, peaks(i));
        E = E + getSignalEnergy(qrs);
    end
else
    E = nansum(signal(peaks).*signal(peaks));
end
