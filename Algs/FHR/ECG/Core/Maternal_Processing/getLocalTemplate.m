function [localTemplate, flag] = getLocalTemplate(signalHR, peaks, beatInterval, ECG_mat_orig, iPeak, beatLen, config)

%% #pragmas
%#codegen

%% Coder directives
coder.extrinsic('disp', 'tic', 'toc', 'num2str');
coder.varsize('ECG_mat_orig_temp', [], [1 1]);
%% Code
flag = 0;
corrCoef = config.incCorrCoef;
nNumOfBeatsForTempConst = config.incNumBeats;
currECG = getCurrBeatECG(signalHR, peaks(iPeak), beatInterval, 0);
len = beatLen;
boundsBkwd = config.incBounds; 
boundsFwd = config.incBounds;
incThresh = config.incThresh;

bounds = (iPeak-boundsBkwd:iPeak+boundsFwd);
bounds = bounds(bounds>0);
bounds = bounds(bounds<size(ECG_mat_orig, 1));

% tic
ECG_mat_orig_temp = ECG_mat_orig(:, 1:len);

% corrVec = matVecCorr(ECG_mat_orig_temp, currECG, bounds([1 end]));
corrVec = matVecCorrFast(ECG_mat_orig_temp, currECG, bounds([1 end])); 

% disp(['matVecCorr: ' num2str(len) ' : ' num2str(bounds([1 end])) ' : ' num2str(toc)]);% #CODER_CHECKPOINT

incPeak = corrVec>corrCoef;
if(sum(incPeak)>=nNumOfBeatsForTempConst)
    localTemplate = getECGTemplate(signalHR, peaks(incPeak), beatInterval); 
    return;
else
    incPeak = corrVec>median(corrVec);
    if(median(corrVec(incPeak))>incThresh)
        localTemplate = getECGTemplate(signalHR, peaks(incPeak), beatInterval); 
    else
        localTemplate = getECGTemplate(signalHR, peaks, beatInterval);
        flag = 1;
    end
    return;
end

