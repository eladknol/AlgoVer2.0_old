function [beatInterval, nullDataInds] = getCurrBeatInterval(peaks, peakInd, sigLen)

nullDataInds = -1;
nNumOfMatPeaks = length(peaks);
if(peakInd == 1)
    beatInterval2ndPeak = getBeatInterval(peaks, 2, sigLen);
    beatInterval = getBeatInterval(peaks, peakInd, sigLen);
    fstPeakOnset = beatInterval.onset;
    beatInterval.onset = min(beatInterval2ndPeak.onset, beatInterval.onset);
    nullDataInds = 1:(fstPeakOnset - beatInterval.onset);
elseif(peakInd == nNumOfMatPeaks)
    beatInterval2ndPeak = getBeatInterval(peaks, peakInd-1, sigLen);
    beatInterval = getBeatInterval(peaks, peakInd, sigLen);
    lastPeakOffset = beatInterval.offset;
    beatInterval.offset = min(beatInterval2ndPeak.offset, beatInterval.offset);
    len = sigLen;
    nullDataInds = len-(lastPeakOffset - beatInterval.offset):len;
else
    beatInterval = getBeatInterval(peaks, peakInd, sigLen); % the indices of the current beat
end