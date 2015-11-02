function fQRS_struct_res = getFetalQRSPos(fetDetectorStruct)

%% #pragmas
%#codegen

% This is a dummy comment to test git-whatever 
% This is a dummy comment to test git-whatever - line 2
%% Coder directives
coder.extrinsic('warning')

%% Code

% Take only the 1st signal and try to perform detection using only it
% fetSignal = preProcFetalData('ecg', fetDetectorStruct, 'raw_1st');
% procSig = getFetalSignal2ndTry(fetSignal, fetDetectorStruct.config);
% config.nNumOfChs = min(size(fetSignal));
% [R_Waves_FNL, RelValidSigs.FNL, bestLead, bestLeadPeaks, leadsInclude]= getRWaves(fetSignal, '2nd', config, procSig);
% Use all of the channels for fQRS detection

coder.varsize('fetSignal'           , [6 120000 ], [1 1]);  % #CODER_VARSIZE
R_Waves_FNL = repmat(struct('value', 0), 6, 1);

coder.varsize('R_Waves_FNL'         , [6 1      ], [1 0]); % #CODER_VARSIZE % This is related to the maximun allowed size of the data
coder.varsize('R_Waves_FNL(:).value', [1000 1   ], [1 0]); % #CODER_VARSIZE % This is related to the maximun allowed size of the data

config = fetDetectorStruct.config;
config.skipBPS = 0;
fetSignal = preProcFetalData(fetDetectorStruct.removeStruct, 'raw', config);
[procSig, newSignals, bestPreProcLead, dataTypeProc] = getFetalSignal2ndTry(fetSignal, fetDetectorStruct.config, 1);
warning('use the xcorr of procSig ');
%STD = analyzeAMCorr(procSig)
if(strcmpi(dataTypeProc, 'bestOnly'))
    procSig = procSig(bestPreProcLead, :);
    fetSignal = newSignals(bestPreProcLead, :);
end

config.nNumOfChs = min(size(fetSignal)); % to take into account the reduction in the dimentions of the data

% [R_Waves_FNL, RelValidSigs.FNL, bestLead, bestLeadPeaks, leadsInclude]= getRWaves(fetSignal, '2nd', config, procSig);
[R_Waves_FNL, RelValidSigs.FNL, bestLead, bestLeadPeaks, leadsInclude]= findFetRWaves(fetSignal, config, procSig);

maxi = 0;
for ii = 1:config.nNumOfChs
    maxi = max(maxi, max(size([R_Waves_FNL(ii).value])));
end

if(maxi == 1 || RelValidSigs.FNL<=0)
    [fetSignal, fetECGData] = preProcFetalData(fetDetectorStruct.removeStruct, 'raw', config);
    [procSig, newSignals] = getFetalSignal2ndTry(fetSignal, fetDetectorStruct.config, 1);
    config.skipBPS = 1;
    %[R_Waves_FNL, RelValidSigs.FNL, bestLead, bestLeadPeaks, leadsInclude]= getRWaves(newSignals, '2nd', config, procSig);
    [R_Waves_FNL, RelValidSigs.FNL, bestLead, bestLeadPeaks, leadsInclude]= findFetRWaves(newSignals, config, procSig);
    fetSignal = newSignals;
    maxi = 0;
    for ii = 1:config.nNumOfChs
        maxi = max(maxi, max(size([R_Waves_FNL(ii).value])));
    end
    if(~(maxi == 1))
        inds = find(leadsInclude);
        kurt = zeros(length(inds), 1);
        err = zeros(length(inds), 1);
        for iLead=1:length(inds)
            
            pks = R_Waves_FNL(iLead).value;
            kurt(iLead) = kurtosis(hist(diff(pks),50)');
            
            x = 1:length(pks);
            p = polyfit(x, pks', 1);
            y = polyval(p, x);
            err(iLead) = sum((y-pks').^2);
        end
        if(any(abs(diff(kurt))/max(kurt)>0.2))
            [y, bestPeaks] = max(kurt);
        else
            if(any(abs(diff(err))/max(err)>0.2))
                [y, bestPeaks] = min(err);
            else
                banana = 1;
                bestPeaks = banana;
            end
        end
        
        pks = R_Waves_FNL(bestPeaks).value;
        bestPeaks = inds(bestPeaks);
        sig = fetSignal(bestPeaks,:);
        res = reDetectPeaks(pks, sig, config);
        
        R_Waves_FNL(bestPeaks).value = res';
        %res1 = scanAndDetect(newSignals(1,:), res);
    end
end
if(maxi == 1 || RelValidSigs.FNL<=0)
    % TBU
    % Activate scanner!
    %         res = scanAndDetect(procSig, newSignals);
    
    % For now, try to perform detection using only the data of the 1st channel
    fetSignal = preProcFetalData(fetDetectorStruct.removeStruct, 'raw_1st', config);
    procSig = getFetalSignal2ndTry(fetSignal, fetDetectorStruct.config);
    config.nNumOfChs = min(size(fetSignal));
    %     [R_Waves_FNL, RelValidSigs.FNL, bestLead, bestLeadPeaks, leadsInclude]= getRWaves(fetSignal, '2nd', config, procSig);
    [R_Waves_FNL, RelValidSigs.FNL, bestLead, bestLeadPeaks, leadsInclude]= findFetRWaves(fetSignal, config, procSig);
    for ii = 1:config.nNumOfChs
        maxi = max(maxi, max(size([R_Waves_FNL(ii).value])));
    end
end

if(~(maxi == 1))
    
    % Find the best fECG lead 
    [glbScr.bestLead, glbScr.bestLeadPeaks, glbScr.scoring, fPeaks, glbScr.leadsInclude] = getChannelPeaksScore(R_Waves_FNL, fetDetectorStruct.mQRS_struct, fetDetectorStruct.config);
    % Use the local scoring to extract the best global peaks 
    
    temp = find(leadsInclude);
    if(~isempty(temp) && glbScr.bestLeadPeaks>0)
        bestLeadPeaks = temp(glbScr.bestLeadPeaks);
    else
        bestLeadPeaks = [];
    end
    fQRS_struct.bestLeadPeaks = bestLeadPeaks;
    fQRS_struct.bestLead = glbScr.bestLead;
    fQRS_struct.bestPreProcLead = bestPreProcLead;
    
    if(min(size(fetSignal))>1)
        fQRS_struct.fetSignal = fetSignal(bestLeadPeaks, :);
    else
        fQRS_struct.fetSignal = fetSignal(:);
    end
    
    
    fQRS_struct.leadsInclude = glbScr.leadsInclude;
    fQRS_struct.metaData.Fs = fetDetectorStruct.config.Fs;
    fQRS_struct.calcConfig = fetDetectorStruct.config; % save it for future references
    
    pks = fPeaks;
    mQRS = fetDetectorStruct.mQRS_struct.pos;
    fQRS_struct.info = '';
    
    fQRS_struct.fQRSPos = pks;
    
    fQRS_struct.fQRSPos = examinePeaksBlocks(fetSignal(bestLeadPeaks,:), pks, mQRS, config);
    
    fQRS_struct.fQRS = zeros(0, 1);
    coder.varsize('fQRS_struct.fQRS', [5000 1], [1 0]); % #CODER_VARSIZE
    coder.varsize('fQRS_struct.info', [1 500], [0 1]); % #CODER_VARSIZE
    
    fQRS_struct.fQRS = lastCheck(fQRS_struct.fQRSPos);
    
    tempRes_new_stg2 = buildFetalTimeSeries(fetSignal(fQRS_struct.bestLeadPeaks,:), fQRS_struct.fQRSPos, config, 2);
    tempRes_new_stg1 = buildFetalTimeSeries(fetSignal(fQRS_struct.bestLeadPeaks,:), tempRes_new_stg2, config, 1);
    fQRS_struct.fQRS = tempRes_new_stg1;
    
    %fQRS_struct.scoring = -1;
    
    fQRS_struct_res = calcFetalPeaksScore(fQRS_struct, fetDetectorStruct.mQRS_struct);
    
%     if(fQRS_struct_res.scoring.globalScore == 909) % MECG elimination is not perfect, mECG remains interfer with the fECG detection
%         resHere = calcFetalPeaksScorePerChannel(R_Waves_FNL, fetDetectorStruct.mQRS_struct, fQRS_struct.calcConfig);
%     end
    
    if(fQRS_struct_res.scoring.globalScore(1) == 100)
        fQRS_struct_res.info = 'Cannot detect fetal peaks';
        fQRS_struct_res.fQRSPos = [];
        fQRS_struct_res.fQRS = [];
    end
    
else
    fQRS_struct_res.bestLeadPeaks = 0;
    fQRS_struct_res.bestLead = 0;
    fQRS_struct_res.bestPreProcLead = 0;
    
    if(min(size(fetSignal))>1)
        fQRS_struct_res.fetSignal = 0*fetSignal(1, :);
    else
        fQRS_struct_res.fetSignal = 0*fetSignal(:);
    end
    
    fQRS_struct_res.leadsInclude = false(1);
    fQRS_struct_res.metaData.Fs = 0;
    
    fQRS_struct_res.calcConfig = fetDetectorStruct.config;
    fQRS_struct_res.info = 'Cannot detect fetal peaks';
    fQRS_struct_res.fQRSPos = [];
    fQRS_struct_res.fQRS = [];
    
    fQRS_struct_res.scoring.scrVec = 0*(1:10);
    fQRS_struct_res.scoring.globalScore = 0;
    fQRS_struct_res.scoring.bestWindow.inds = 0;
    fQRS_struct_res.scoring.bestWindow.HR = 0;
    fQRS_struct_res.scoring.bestWindow.score = 0;
    fQRS_struct_res.scoring.bestWindow.valid = 0;
    
end

function fQRS = lastCheck(fQRSPos)
fQRS = fQRSPos;
fQRS(diff(fQRSPos)==0) = [];

function fQRS_struct = calcFetalPeaksScore(fQRS_struct_in, mQRS_struct)

fQRS_struct = fQRS_struct_in;
config = fQRS_struct_in.calcConfig;

susFlag = false(1);
if(fQRS_struct.fQRS(1) == -1)
    fQRS = fQRS_struct.fQRSPos';
    susFlag = true(1);
else
    fQRS = fQRS_struct.fQRS;
end

mHRC = 60*config.Fs./(diff(mQRS_struct.pos));
fHRC = 60*config.Fs./(diff(fQRS));

fHR = nanmean(fHRC);
mHR = nanmean(mHRC);

fHRC_diff = diff(fHRC);
winLen = config.peakExamination.scoring.goodSegPeaks;
scrVec = winRMS(fHRC_diff, winLen, 1);
fQRS_struct.scoring.scrVec = scrVec;
fQRS_struct.scoring.globalScore = mean(scrVec);

% Check if the fetal HR is very close to the mHR
% The main assumption is that the mHR detection is more robust and relaiable than the fHR detection
if(abs(fHR - mHR)/(mHR)*100 < config.peakExamination.scoring.closePerc)
    if(fHR<0.9*config.minPredFetalHR)
        % The fHR is very low
        fQRS_struct.scoring.globalScore = 100; % Bad score
    else
        if(mHR>config.minPredFetalHR)
            % The mHR is high
            % Check the cross corr
            corrCoef = max(xcorr(fHRC, mHRC, 'none'))/max(xcorr(fHRC));
            if(corrCoef>config.peakExamination.scoring.minAccCorrCoeff)
                % There is high correlation between the HR curves, looks that the fHR is mHR
                fQRS_struct.scoring.globalScore = 909; % Bad score
            end
        else
            corrCoef = max(xcorr(fHRC, mHRC, 'none'))/max(xcorr(fHRC));
            if(corrCoef>config.peakExamination.scoring.minAccCorrCoeff)
                % There is high correlation between the HR curves, looks that the fHR is mHR
                fQRS_struct.scoring.globalScore = 909; % Bad score
            end
        end
    end
end

% Now find the best region in the fHRC

sig = -scrVec + max(scrVec);
sig = sig./max(sig);
minPeakHeight = config.peakExamination.scoring.minPeakHeight;
[pks, inds] = findpeaks(sig, 'MinPeakHeight', minPeakHeight);
threshVal = median(scrVec(inds));

maxITI = config.peakExamination.scoring.maxIti;
countExt = 1;
minLen = config.peakExamination.scoring.goodSegPeaks; % minimum number of consecutive good peaks

while(countExt<maxITI)
    bin = diff(scrVec<threshVal);
    raiseInd = find(bin==1);
    fallInd = find(bin==-1);
    
    if(length(raiseInd) ~= length(fallInd))
        firstRaise = raiseInd(1);
        if(raiseInd(1) > fallInd(1))
            raiseInd = [1; raiseInd];
        else
            fallInd = [fallInd; length(bin)];
        end
    end
    
    countExt = countExt + 1;
    
    if(isempty(raiseInd) || isempty(fallInd))
        continue;
    end
    
    if(fallInd(1)<raiseInd(1))
        raiseInd = [1; raiseInd];
        raiseInd(end) = [];
    end
    [y, i] = max(fallInd - raiseInd);
    inds = (raiseInd(i)+1):fallInd(i);
    
    if(length(inds)>=minLen)
        break;
    end
    
    % Update the threshold
    minPeakHeight = minPeakHeight*config.peakExamination.scoring.minPeakHeightUpdate;
    [pks, inds] = findpeaks(sig, 'MinPeakHeight', minPeakHeight);
    threshVal = median(scrVec(inds));
    
end

fQRS_struct.scoring.bestWindow.inds = inds;
fQRS_struct.scoring.bestWindow.HR = fHRC(inds+2);
fQRS_struct.scoring.bestWindow.score = mean(scrVec(inds));

if(length(inds)>=minLen)
    fQRS_struct.scoring.bestWindow.valid = 1;
else
    fQRS_struct.scoring.bestWindow.valid = 0;
end

if(susFlag && mean(scrVec)>10)
    fQRS_struct.scoring.globalScore = 100;
    fQRS_struct.scoring.bestWindow.valid = 0;
    fQRS_struct.scoring.bestWindow.score = 100;
end

%% Give score for the detected peaks for each channel and sort the channels accourdingly
function [bestLead, bestLeadPeaks, scoring, fPeaks, leadInc] = getChannelPeaksScore(R_Waves, mQRS_struct, config)
%%
winLen = config.peakExamination.scoring.goodSegPeaks;
mHRC = 60*config.Fs./(diff(mQRS_struct.pos));
mHR = nanmean(mHRC);
nNum = numel(R_Waves);

fHR = zeros(nNum, 1);
globalScore = nan(nNum, 1);

for i=1:nNum
    if(length(R_Waves(i).value) == 1 && any(R_Waves(i).value==0))
        continue;
    end
    fQRS = R_Waves(i).value;
    fQRS(diff(fQRS)==0) = [];
    R_Waves(i).value = fQRS;
    fHRC = 60*config.Fs./(diff(fQRS));
    fHR(i) = nanmedian(fHRC);
    fHRC_diff = diff(fHRC);
    scrVec = winRMS(fHRC_diff', winLen, 1);
    globalScore(i) = mean(scrVec);
    if(abs(fHR(i) - mHR)/(mHR)*100 < config.peakExamination.scoring.closePerc)
        if(fHR(i)<0.9*config.minPredFetalHR)
            globalScore(i) = inf;
        else
            if(mHR>config.minPredFetalHR)
                corrCoef = max(xcorr(fHRC, mHRC, 'none'))/max(xcorr(fHRC));
                if(corrCoef>config.peakExamination.scoring.minAccCorrCoeff)
                    globalScore(i) = inf;
                end
            else
                corrCoef = max(xcorr(fHRC, mHRC, 'none'))/max(xcorr(fHRC));
                if(corrCoef>config.peakExamination.scoring.minAccCorrCoeff)
                    globalScore(i) = inf;
                end
            end
        end
    end
end

leadInc = ~isnan(globalScore);

if(all(~leadInc))
    fPeaks = [];
    bestLead = -1;
    bestLeadPeaks = -1;
    scoring = 100; % inf
    return;
end

[bestScore, bestLeadPeaks] = nanmin(globalScore);

fPeaks = R_Waves(bestLeadPeaks).value;
scoring = globalScore(bestLeadPeaks);
bestLead = bestLeadPeaks;
