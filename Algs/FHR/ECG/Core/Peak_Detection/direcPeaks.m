function peaks = direcPeaks(signal)
minDist = 100; % minimum distance between two peaks (depends on the heart rate and the sampling freq.)
[peaksVals, peaksInd] = findpeaks(signal, 'MINPEAKDISTANCE', minDist); % very high sensitivy with a lot of false positives
% peaks = findpeaks(signal); % another version (faster - with more flase positives)

% classify the peaks into two main groups: actual peaks and false positives
% [group, C] = kmeans(peaksVals, 2); % matlab kmeans
[group, C] = kmeans(peaksVals', 2);
if(C(1)>C(2)) % assumption: peaks have higher values
    peaksG = 1;
else
    peaksG = 2;
end

% return only actual peaks
peaks = peaksInd(group==peaksG);