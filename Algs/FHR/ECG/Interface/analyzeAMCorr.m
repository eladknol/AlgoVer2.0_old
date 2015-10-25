function STD = analyzeAMCorr(signals)

% analyze the auto correlation and the mutual correlation functions
fstDim = size(signals, 1);

for i=1:fstDim
    for j=1:floor(fstDim/2)
        temp = xcorr(signals(i, :), signals(j, :), 'coeff');
        temp = temp(floor(end/2):end);
        [~, pInds] = findpeaks(temp, 'MinPeakProminence',0.2);
        STD(i,j) = std(diff(pInds));
    end
end
