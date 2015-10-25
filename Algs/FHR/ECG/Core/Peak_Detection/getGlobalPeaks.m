function [globalPeaks, rel] = getGlobalPeaks(inLocalPeaks, signals, bestLead, bestLeadPeaks, leadsInclude)
%#codegen
rel = 0;
%TO-DO
% check the STD of the number of peaks...

localPeaks = repmat(struct('value', 0), 1, 1);
coder.varsize('localPeaks'          , [1 6   ], [0 1]);  % #CODER_VARSIZE
coder.varsize('localPeaks(:).value' , [5000 1], [1 0]);  % #CODER_VARSIZE
ind = 1;
for i=1:length(inLocalPeaks)
    if(length(inLocalPeaks(i).value)>1)
        localPeaks(ind).value = inLocalPeaks(i).value;
        ind = ind + 1;
    else
        if(bestLead>i)
            bestLead = bestLead - 1;
        end
        if(bestLeadPeaks>i)
            bestLeadPeaks = bestLeadPeaks - 1;
        end
    end
end

MAX_ACC_PEAK_SHIFT = 40; % 40mSec, take from config provider
nNumOfSigs = numel(localPeaks);

indsG = find(leadsInclude);

for iSig=1:length(indsG)
    Sign = mode(sign(signals(indsG(iSig), localPeaks(iSig).value)));
    len = length(localPeaks(iSig).value);
    for jPeak = 1:len
        currSign = sign(signals(indsG(iSig), localPeaks(iSig).value(jPeak)));
        if(Sign ~= currSign)
            [~, localPeaks(iSig).value(jPeak)] = getQRSComplex(Sign*signals(indsG(iSig),:), localPeaks(iSig).value(jPeak), any(jPeak==[1 len]), 2, 1);
        end
    end
end

nNumOfPeaks = zeros(nNumOfSigs, 1);
for iSig=1:nNumOfSigs
    nNumOfPeaks(iSig) = length(localPeaks(iSig).value);
end
pad = max(nNumOfPeaks)-nNumOfPeaks;

coder.varsize('peaks', [6 5000], [1 1]); % #CODER_VARSIZE
coder.varsize('globalPeaks', [1, 5000], [0 1]); % #CODER_VARSIZE
coder.varsize('globalPeaksInd', [1, 5000], [0 1]);% #CODER_VARSIZE
coder.varsize('VOTERS', [5000, 1], [1 0]);% #CODER_VARSIZE

peaks = zeros(nNumOfSigs, max(nNumOfPeaks));
globalPeaksInd =  zeros(1, 0);
globalPeaks  = zeros(1, 0);
VOTERS = zeros(0, 1);

for iSig=1:nNumOfSigs
    peaks(iSig, :) = [localPeaks(iSig).value; nan(pad(iSig), 1)]';
end

MAX_COUNT = max(nNumOfPeaks)*3;
MIN_ACC_CORR_COEF = 0.9;
MIN_ACC_BEST_LEAD_CORR_COEF = 0.92;
count = 1;
noChange = 0;
pInd = 1;
ind = 1;
bestLeadVotes = 0;

% Examine multi lead peaks - cross lead validation
if(nNumOfSigs>1)
    while(true)
        [peak, ~] = nanmin(peaks(:,pInd)); % Might not be the best advancing methodology
        %clear peakIndVal peakInd corrVal; % not supported by the coder
        peakInd = zeros(nNumOfSigs, 1);
        peakIndVal = zeros(nNumOfSigs, 1);
        for iSig=1:nNumOfSigs
            [peakInd(iSig), peakIndVal(iSig)] = findClosest(peaks(iSig,:), peak);
        end
        
        vote = abs(peakIndVal - peak)<MAX_ACC_PEAK_SHIFT;
        %         VOTERS(pInd) = sum(vote);
        VOTERS = [VOTERS; sum(vote)];
        bestLeadVotes = bestLeadVotes + vote(bestLeadPeaks);
        switch(sum(vote))
            case (length(vote)), % The peak is detected on all of the signals
                %globalPeaksInd(ind) = peakIndVal(bestLeadPeaks);
                globalPeaksInd = [globalPeaksInd, peakIndVal(bestLeadPeaks)];
                ind = ind + 1;
            otherwise,
                if(vote(bestLeadPeaks))
                    peakPos = peakIndVal(bestLeadPeaks);
                    brdPeak = peakPos==1 || peakPos==length(peaks);
                    template = getTemplate(signals(bestLead,:), peaks(bestLeadPeaks,~isnan(peaks(bestLeadPeaks,:))), getQRSTemplateSize(2));
                    QRS = getQRSComplex(signals(bestLead,:), peakPos, brdPeak, 2, 0, 1);
                    if(length(template) == length(QRS))
                        corrVal = max(xcorr(template, QRS, 'coeff'));
                    else
                        corrVal = max(xcorr(template, QRS, 'none'))/max(xcorr(template));
                    end
                    if(corrVal>MIN_ACC_BEST_LEAD_CORR_COEF)
                        %globalPeaksInd(ind) = peakPos;
                        globalPeaksInd = [globalPeaksInd, peakPos];
                        ind = ind + 1;
                    end
                else
                    peakPos = floor(mean(peakIndVal(vote)));
                    brdPeak = peakPos==1 || peakPos==length(peaks);
                    corrVal_vec = zeros(nNumOfSigs, 1);
                    for iSig=1:nNumOfSigs
                        template = getTemplate(signals(iSig,:), peaks(iSig,~isnan(peaks(iSig,:))), getQRSTemplateSize(2));
                        QRS = getQRSComplex(signals(iSig,:), peakPos, brdPeak, 2, 0, 1);
                        if(length(template) == length(QRS))
                            corrVal_vec(iSig) = max(xcorr(template, QRS, 'coeff'));
                        else
                            corrVal_vec(iSig) = max(xcorr(template, QRS, 'none'))/max(xcorr(template));
                        end
                    end
                    voteStep2 = sum(corrVal_vec>MIN_ACC_CORR_COEF); % make sure that MIN_ACC_CORR_COEF is high so no false positives will be added
                    
                    if(voteStep2 + vote(bestLeadPeaks) >= nNumOfSigs) % Cool, a peak :)
                        % Refine the position using the bestLead
                        [QRS, pos] = getQRSComplex(signals(bestLead,:), peakPos, brdPeak, 2, 1, 1);
                        if(abs(peakPos - pos) < MAX_ACC_PEAK_SHIFT)
                            peakPos = pos;
                        end
                        %globalPeaksInd(ind) = peakPos;
                        globalPeaksInd = [globalPeaksInd, peakPos];
                        
                        ind = ind + 1;
                    end
                end
        end
        pInd = pInd + 1;
        if(pInd>length(peaks))
            noChange = 1;
        end
        if(noChange || count>MAX_COUNT)
            break;
        end
        count = count+1;
    end
else
    globalPeaksInd = localPeaks(1).value';
    VOTERS = ones(size(peaks));
    bestLeadVotes = sum(VOTERS);
end

if(isempty(globalPeaksInd))
    globalPeaks = zeros(1, 0);
    rel = 0;
    return;
end
% Do peak pos refinement
len = length(globalPeaksInd);
temp_globalPeaksInd = zeros(1, len);

for i=1:len
    [~, temp_globalPeaksInd(i)] = getQRSComplex(signals(bestLead,:), globalPeaksInd(i), i==1||i==len);
end
globalPeaksInd = temp_globalPeaksInd;

globalPeaks = globalPeaksInd;

% Physiological analysis of the peaks

maxITI = length(globalPeaksInd);
iti=1;
terminate = false(1);
skipCurrPeak = 0;
meanRR = 0;

while(iti<maxITI && ~terminate)
    % The peaks model is updated each time a change is done!
    % The max number of iti's is as the number of peaks
    breakFlag = 0;
    Diff = diff(globalPeaksInd);
    nG = 3;
    
    [grp, c] = kMedoids(Diff' ,nG, 1, false(1)); % The C version is way faster, you can use multible replicates yet I kept it like that since I don't want to add algo changes
    
    % #CODER_REMOVE
    %     if(config.useStats) % use matlab's functions if toolbox is avavaiable
    %         [grp, c] = kmedoids(Diff' ,nG); % Using multible replicates increase the run time but does not increase the accuracy that much
    %     else
    %         [grp, c] = kmedoids_ext(Diff ,nG);
    %         c = c(:);
    %         grp = grp(:);
    %     end
    
    num = zeros(nG, 1);
    for i=1:nG
        num(i) = sum(grp==i);
    end
    
    [~, i] = max(num);
    meanRR = c(i);
    terminate = isempty(find(Diff>1.5*meanRR, 1)) && isempty(find(Diff<2/3*meanRR, 1));
    if(terminate)
        break;
    end
    strInd = 1;
    
    if(skipCurrPeak)
        strInd = skipCurrPeak+1;
    end
    for ind = strInd:length(Diff)
        if(Diff(ind)>1.5*meanRR)
            predNumOfMissPeaks = round(Diff(ind)/meanRR) - 1; % The predicted number of missing peaks
            if(predNumOfMissPeaks>7)
                % Alright, go home...
                return;
            end
            susPeakPoss = globalPeaksInd(ind) + floor( (1:predNumOfMissPeaks)/(predNumOfMissPeaks+1)*Diff(ind) );
            susPeakPoss(susPeakPoss>globalPeaksInd(end))=[];
            brdPeak = 0;
            template = getTemplate(signals(bestLead,:), globalPeaksInd, getQRSTemplateSize(2));
            for ii_captain=1:predNumOfMissPeaks
                [susQRS, pos] = getQRSComplex(signals(bestLead,:), susPeakPoss(ii_captain), brdPeak, 2, 0, 1);
                if(length(template) == length(susQRS))
                    corrVal = max(xcorr(template, susQRS, 'coeff'));
                else
                    corrVal = max(xcorr(template, susQRS, 'none'))/max(xcorr(template));
                end
                if(corrVal >= MIN_ACC_BEST_LEAD_CORR_COEF) % high corr! it is a peak...
                    globalPeaksInd = [globalPeaksInd(1:ind) pos globalPeaksInd(ind+1:end)];
                    breakFlag = 1;
                    skipCurrPeak = 0;
                else % not very high corr
                    if(ind<length(globalPeaksInd)-1)
                        prevQRS = getQRSComplex(signals(bestLead,:), globalPeaksInd(ind), brdPeak, 2, 1, 1);
                        nextQRS = getQRSComplex(signals(bestLead,:), globalPeaksInd(ind+1), brdPeak, 2, 1, 1);
                        if(length(template) == length(nextQRS))
                            corrValPrev = max(xcorr(template, prevQRS, 'coeff'));
                            corrValNext = max(xcorr(template, nextQRS, 'coeff'));
                        else
                            corrValPrev = max(xcorr(template, prevQRS, 'none'))/max(xcorr(template));
                            corrValNext = max(xcorr(template, nextQRS, 'none'))/max(xcorr(template));
                        end
                        if(Diff(ind+1)<2/3*meanRR) % Too close to the next peak
                            if(corrValPrev>MIN_ACC_BEST_LEAD_CORR_COEF && corrValNext>MIN_ACC_BEST_LEAD_CORR_COEF) % the surrounding peaks have high correlation
                                % Remove this peak and try to add a peak in the middle
                                susPeakPos = floor(mean(globalPeaksInd([ind, ind+2])));
                                if(susPeakPos>globalPeaksInd(end))
                                    breakFlag = 1;
                                    skipCurrPeak = 0;
                                end
                                [susQRS, pos] = getQRSComplex(signals(bestLead,:), susPeakPos, brdPeak, 2, 1, 1);
                                if(length(template) == length(susQRS))
                                    corrVal = max(xcorr(template, susQRS, 'coeff'));
                                else
                                    corrVal = max(xcorr(template, susQRS, 'none'))/max(xcorr(template));
                                end
                                if(corrVal >= MIN_ACC_BEST_LEAD_CORR_COEF) % high corr! it is a peak...
                                    globalPeaksInd(ind) = pos;
                                    breakFlag = 1;
                                    skipCurrPeak = 0;
                                else
                                    globalPeaksInd(ind) = [];
                                    skipCurrPeak = 0;
                                end
                            end
                        else
                            if(sum(abs(Diff([ind-1, ind+1]) - meanRR)<0.1*meanRR)==2)
                                if(corrValPrev>MIN_ACC_BEST_LEAD_CORR_COEF && corrValNext>MIN_ACC_BEST_LEAD_CORR_COEF) % the surrounding peaks have high correlation
                                    % This is a miss, the current peak is different than the template yet it is an actual peak!
                                    susPeakPos = susPeakPoss(ii_captain);%floor(mean(globalPeaksInd([ind, ind+1])));
                                    globalPeaksInd = sort([globalPeaksInd susPeakPos]);
                                    breakFlag = 1;
                                    skipCurrPeak = 0;
                                elseif(predNumOfMissPeaks==1 && (corrValPrev + corrValNext + corrVal)>0.95*2 + 0.6)
                                    susPeakPos = floor(mean(globalPeaksInd([ind, ind+1])));
                                    globalPeaksInd = sort([globalPeaksInd susPeakPos]);
                                    breakFlag = 1;
                                    skipCurrPeak = 0;
                                end
                            else
                                if(predNumOfMissPeaks==1 && (corrValPrev + corrValNext + corrVal)>0.95*2 + 0.6)
                                    susPeakPos = floor(mean(globalPeaksInd([ind, ind+1])));
                                    globalPeaksInd = sort([globalPeaksInd susPeakPos]);
                                    breakFlag = 1;
                                    skipCurrPeak = 0;
                                else
                                    breakFlag = 1;
                                    skipCurrPeak = ind;
                                end
                            end
                        end
                    end
                end
            end
            if(breakFlag)
                break;
            end
        elseif(Diff(ind)<2/3*meanRR)
            if(ind>1 && ind<length(Diff))
                
                before = ~(Diff(ind-1)<2/3*meanRR || Diff(ind-1)>1.5*meanRR);
                after = ~(Diff(ind+1)<2/3*meanRR || Diff(ind+1)>1.5*meanRR);
                
                if(~before && ~after)
                    % bad pos, remove it
                    globalPeaksInd(ind) = [];
                    breakFlag = 1;
                    skipCurrPeak = 0;
                end
                if(breakFlag)
                    break;
                end
            end
        end
    end
    globalPeaksInd = sort(globalPeaksInd);
    globalPeaksInd(diff(globalPeaksInd)==0) = [];
    iti = iti+1;
end

% TO-DO: Now test for the first and last peaks...
if((globalPeaksInd(1)-1)>meanRR)
    %TBU
end

HRV = 0; % For future versions that support HRV analysis
if(~HRV)
    globalPeaks = globalPeaksInd;
    meas = zeros(4,1);
    % Check the relaiability of the peaks: Internal algorithm scoring
    meas(1) = sum(VOTERS==size(signals, 1))/length(VOTERS);
    meas(2) = mean(VOTERS)/size(signals, 1);
    meas(3) = bestLeadVotes/length(VOTERS);
    meas(4) = 1 - (iti-1)/length(globalPeaks);
    rel = max(min(round(mean(meas)*100), 100), 0);
else
    %globalPeaks
    % Check the difference between globalPeaks and globalPeaksInd and notify
end

len = length(globalPeaks);
tempSig = signals(bestLead, :);
Sign = mode(sign(tempSig(globalPeaks)));
for jPeak = 1:len
    currSign = sign(tempSig(globalPeaks(jPeak)));
    if(Sign ~= currSign)
        [~, globalPeaks(jPeak)] = getQRSComplex(Sign*tempSig, globalPeaks(jPeak), any(jPeak==[1 len]), 2, 1);
    end
end
