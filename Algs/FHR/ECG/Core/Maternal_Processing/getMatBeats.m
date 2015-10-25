function [ECG, beatLen, nullDataInds] = getMatBeats(peaks, signalHR)

%% #pragmas
%#codegen

%% Coder directives
% coder.extrinsic('disp');
coder.varsize('beatLen',            [1 5000], [0 1]);  % #CODER_VARSIZE
coder.varsize('nullDataInds.first', [1 5000], [0 1]);  % #CODER_VARSIZE
coder.varsize('nullDataInds.last',  [1 5000], [0 1]);  % #CODER_VARSIZE

%% Code
nNumOfMatPeaks = length(peaks);
beatLen = zeros(1, 0);

for iPeak = 1:nNumOfMatPeaks
    beatInterval = getCurrBeatInterval(peaks, iPeak, length(signalHR));
    currECG = getCurrBeatECG(signalHR, peaks(iPeak), beatInterval, iPeak == 1 || iPeak == nNumOfMatPeaks);
    beatLen = [beatLen, length(currECG)];
end

maxSiz = max(beatLen);
ECG = zeros(nNumOfMatPeaks, maxSiz); % #CODER_DYNAMIC

nullDataInds.first = zeros(1, 0);
nullDataInds.last = zeros(1, 0);

for iPeak = 1:nNumOfMatPeaks
    [beatInterval, nullInds] = getCurrBeatInterval(peaks, iPeak, length(signalHR));
    if(iPeak == 1)
        nullDataInds.first = nullInds;
    elseif(iPeak == nNumOfMatPeaks)
        nullDataInds.last = nullInds;
    end
    currECG = getCurrBeatECG(signalHR, peaks(iPeak), beatInterval, iPeak == 1 || iPeak == nNumOfMatPeaks);
    ECG(iPeak, 1:length(currECG)) = currECG;
    ECG(iPeak, length(currECG)+1:end) = currECG(end);
end
