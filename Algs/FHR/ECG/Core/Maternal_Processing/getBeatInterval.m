function interval = getBeatInterval(peaks, peakInd, sigLen)

if(nargin<3)
    sigLen = peaks(end);
end
if(peakInd==1)
    interval.onset = peaks(1) - 1;
else
    interval.onset  = floor((peaks(peakInd)+peaks(peakInd-1))/2) - peaks(peakInd-1)-1;
    % If the signal is upsampled to match an even Fs this difference should be 0!: floor((peaks(peakInd)+peaks(peakInd-1))/2) - (peaks(peakInd)+peaks(peakInd-1))/2
    % If it is not 0, make it so! 
end

len = length(peaks);
if(peakInd==len)
   interval.offset = sigLen - peaks(len);
else
    interval.offset = floor((peaks(peakInd)+peaks(peakInd+1))/2) - peaks(peakInd);
end
