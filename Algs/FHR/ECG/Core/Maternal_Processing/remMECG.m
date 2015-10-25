function [fECG, remRelEng, noisyBeatFlag] = remMECG(signal, mRWaves, config)
% function [fECG, mECG, remRelEng, noisyBeatFlag] = remMECG(signal, mRWaves, config)
%% #pragmas
%#codegen

%% Coder directives
coder.varsize('predECG',        [1 480000], [0 1]);     % #CODER_VARSIZE
coder.varsize('predECG_temp',   [1 480000], [0 1]);     % #CODER_VARSIZE
coder.varsize('mECG',           [1 120000], [0 1]);     % #CODER_VARSIZE
coder.varsize('fECG',           [1 120000], [0 1]);     % #CODER_VARSIZE

%% Code
newConfig       = config;
Fs              = config.Fs;
newConfig.reqFs = config.resampleFreq/1000 * config.Fs;
matchFreq = ceil(newConfig.reqFs/Fs);
signalHR = upsampleECG(signal, matchFreq, Fs);

peaks = mRWaves*matchFreq;

[ECG_mat_orig, beatLen, nullDataInds] = getMatBeats(peaks, signalHR);

% This line sucks in terms of performance, kill it some how...
[predMatECG, noisyBeatFlag] = getTempBeats(peaks, signalHR, ECG_mat_orig, beatLen, newConfig);

predECG = zeros(1, 0); % For type detection in the coder

if(isempty(predMatECG))
    %mECG = 0.*signal;
    fECG = signal;
    remRelEng = 1;
    return;
end

if(~isempty(nullDataInds.first) && nullDataInds.first(1) == 1)
    predECG = signalHR(nullDataInds.first);
end

predECG = [predECG predMatECG];

if(nullDataInds.last(end) == length(signalHR))
    predECG = [predECG signalHR(nullDataInds.last(1:end-1))];
end

%mECG = downsample(predECG, matchFreq);

predECG = signalHR - predECG;
predECG_temp = smooth(predECG, 'ma', config.fetSmoothOrder);
fECG = downsample(predECG_temp, matchFreq);

%% Optional code
% Not essintial for the removal
% It used for measuring the quality of the removal
templateSize.onset = -200;
templateSize.offset = +200;
origTemp = getTemplate(signal, mRWaves, templateSize);
remTemp = getTemplate(fECG, mRWaves(2:end-1), templateSize);

remRelEng = rms(remTemp)/rms(origTemp);

