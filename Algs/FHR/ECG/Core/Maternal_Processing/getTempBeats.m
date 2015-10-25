function [predMatECG, noisyBeatFlag] = getTempBeats(peaks, signalHR, ECG_mat_orig, beatLen, config)

%% #pragmas
%#codegen

%% Coder directives
%coder.extrinsic('disp', 'tic', 'toc', 'num2str');
coder.varsize('sigRes', [1 480000], [0 1]); % #CODER_VARSIZE

%% Code
tic;
nNumOfMatPeaks = length(peaks);

meanOnset = 0;
meanOffset = 0;
for i=1:nNumOfMatPeaks
    beatInterval = getCurrBeatInterval(peaks, 6, length(signalHR));
    meanOnset = meanOnset + beatInterval.onset;
    meanOffset = meanOffset + beatInterval.offset;
end
beatInterval.onset = meanOnset/nNumOfMatPeaks;
beatInterval.offset = meanOffset/nNumOfMatPeaks;

templateECG = getECGTemplate(signalHR, peaks, beatInterval);

CL = clt(templateECG, config);

inds = diff(CL(config.CLT.filter.order+2:end)>2*mean(CL(config.CLT.filter.order+2:end)));
starts = find(inds==1);
ends = find(inds==-1);
if(length(starts) ~= length(ends))
    predMatECG = [];
    noisyBeatFlag = ones(nNumOfMatPeaks, 1);
    return;
end
ind = (ends - starts)>config.reqFs/1000*70;

if(isempty(ind))
    QRS.onset = -config.reqFs/1000*50;
    QRS.offset = +config.reqFs/1000*50;
else
    pos = [starts(ind), ends(ind)+config.CLT.filter.winsize];
    [y, i] = max(abs(templateECG));
    if(abs(mean(pos)-i)<100)
        pos = pos - i;
        QRS.onset = pos(1);
        QRS.offset = pos(2);
    else
        QRS.onset = -config.reqFs/1000*50;
        QRS.offset = +config.reqFs/1000*50;
    end
end

sigRes = zeros(1, 0);

noisyBeatFlag = zeros(nNumOfMatPeaks, 1);

for iPeak = 1:nNumOfMatPeaks
    beatInterval = getCurrBeatInterval(peaks, iPeak, length(signalHR));
    [localTemplate, noisyBeatFlag(iPeak)] = getLocalTemplate(signalHR, peaks, beatInterval, ECG_mat_orig, iPeak, beatLen(iPeak), config);
    currECG = getCurrBeatECG(signalHR, peaks(iPeak), beatInterval, 0);    
    ecg_adapted = adaptECGBeat(localTemplate, currECG, beatInterval.onset+1, QRS, config.LMA);
    sigRes = [sigRes ecg_adapted];
end

predMatECG = sigRes;
