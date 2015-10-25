function [beatOnset, beatOffset] = getBeatPos(peakPos, beatInterval, signalLen, brdPeak)

beatOnset    = peakPos - beatInterval.onset;
beatOffset   = peakPos + beatInterval.offset;

coder.varsize('beatOnset', [1 1], [1 0]); % #CODER_VARSIZE
coder.varsize('beatOffset', [1 1], [1 0]); % #CODER_VARSIZE

if(brdPeak)
    beatOnset(beatOnset<0) = 1;
    beatOffset(beatOffset>signalLen) = signalLen;
else
    beatOffset(beatOnset<0) = [];
    beatOnset(beatOnset<0) = [];
    
    beatOnset(beatOffset>signalLen) = [];
    beatOffset(beatOffset>signalLen) = [];
end
