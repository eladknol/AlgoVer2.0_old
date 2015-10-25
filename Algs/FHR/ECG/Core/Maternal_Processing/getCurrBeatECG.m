function [beatECG, peakInd] = getCurrBeatECG(signal, peakPos, beatInterval, brdPeak)

%% #pragmas
%#codegen

%% Coder directives
coder.varsize('beatOnset',  [1 1], [1 0]); % #CODER_VARSIZE
coder.varsize('beatOffset', [1 1], [1 0]); % #CODER_VARSIZE
coder.varsize('beatECG',    [1 5000], [0 1]); % #CODER_VARSIZE

%% Code
if(nargin<4)
    brdPeak = false(1);
end

[beatOnset, beatOffset] = getBeatPos(peakPos, beatInterval, length(signal), brdPeak);
peakInd = peakPos;

if(isempty(beatOnset) || isempty(beatOffset))
    beatECG = 0;
    return;
end

beatECG = signal(beatOnset(1):beatOffset(1));

if(nargout>1)
    [val, peakInd] = max(abs(beatECG));
    peakInd = peakInd + beatOnset(1);
end
