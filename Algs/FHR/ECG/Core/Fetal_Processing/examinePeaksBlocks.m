function fQRS = examinePeaksBlocks(fetSignal, pks, mQRS, config)
%#codegen

sig = fetSignal(1,:);
% remove repeating peaks!!
df = diff(pks);
pks(df==0) = [];

mult = 1;
len = length(pks);
for i=1:len
    [~, pks(i)] = getQRSComplex(sig, pks(i), i==1||i==len, mult);
end
df = diff(pks);
pks(df==0) = [];

maxFetalRRInterSTD = config.peakExamination.maxFetalRRInterSTD;
Fs = config.Fs;
maxPredHR = config.maxPredFetalHR;
minPredHR = config.minPredFetalHR;
predFetHR = (config.maxPredFetalHR + config.minPredFetalHR)/2;

% Find a charasteristic RR interval
winSize = config.peakExamination.goodSegPeaks; % 5 peaks are needed to flag a good segment
peakDst = median(diff(pks));
STD = zeros(1, length(pks) - winSize);

for iPeak=1:length(pks) - winSize
    currPeaks = pks(iPeak:iPeak+winSize);
    df = diff(currPeaks);
    STD(iPeak) = std(df);
end
bin = diff(STD<maxFetalRRInterSTD);
raiseInd = find(bin==1);
fallInd = find(bin==-1);
if(length(raiseInd) ~= length(fallInd))
        
    if(isempty(fallInd))
        fallInd = length(bin);
    end
    if(isempty(raiseInd))
       raiseInd = 1; 
    end

    if(raiseInd(1) > fallInd(1))
        raiseInd = [1 raiseInd];
    else
        if(fallInd(end) <length(bin)-1)
            fallInd = [fallInd length(bin)];
        end        
    end
end

[y, i] = max(fallInd - raiseInd);
inds = (raiseInd(i)+1):fallInd(i);
bestPeaks = pks(inds);
nNumOfBestPeaks = length(bestPeaks);
meanRR = mean(diff(bestPeaks));

if(60*Fs/meanRR>maxPredHR)
    % not acc results
    meanRR = Fs/(predFetHR/60);
end

%
FHRSTDV = config.peakExamination.FHRSTDV;
% peaks = [];
%peaks.pos = -1;
%peaks.type = -1;
pks_save = pks;
%peaks = registerPeak(peaks, pks(1), 'act'); % actual peak
iti = 0;
terminate = false(1);
maxITI = length(pks);
skipper = 0;
ind = 0;
startInd = 1;
Diff=diff(pks);

while(iti<maxITI && ~terminate)
    % pks should be updated every iteration
    %     startInd = 1;
    if(skipper)
        sameDiff = any(Diff-diff(pks));
        if(all(~sameDiff))
            startInd = ind+1;
        end
    end
    Diff = diff(pks);
    
    terminate = isempty(find(Diff > (1+FHRSTDV)*meanRR, 1)) && isempty(find(Diff < (1-FHRSTDV)*meanRR, 1));
    if(terminate)
        break;
    end
    
    skipper = 0;
    for ind = startInd:length(Diff)
        if(Diff(ind) < (1-FHRSTDV)*meanRR) % false positive
            res = examineAddPeak(pks, ind, mQRS, sig, meanRR, config);
            switch(res)
                case 0,
                    % Don't know what to do with this peak, keep it but flag it
                    %peaks = registerPeak(peaks, pks(ind+1), 'sus_false_pos');
                    pks(ind+1) = [];
                    %log('Bingo :: false positive removed');
                    break;
                case 1,
                    % Keep the 1st peak and remove the 2nd peak:
                    pks(ind+1) = [];
                    %log('Bingo :: false positive removed');
                    break;
                case 2,
                    pks(ind) = [];
                    %log('Bingo :: false positive removed');
                    break;
                otherwise,
                    % Don't know what to do with this peak, keep it but flag it
                    %peaks = registerPeak(peaks, pks(iPeak+1), 'sus_false_pos');
            end
        elseif(Diff(ind) > (1+FHRSTDV)*meanRR)
            % the alg have missed a peak
            res = searchForMissingPeaks(pks, ind, mQRS, sig, meanRR, config);
            if(sum(res)==0)
                skipper = 1;
                % Don't know what to do with this peak, keep it but flag it
                % peaks = registerPeak(peaks, pks(ind+1), 'sus_false_neg');
                break;
            end
            for i=1:length(res)
                if(res(i))
                    %log('Bingo :: false negative added');
                    %peaks = registerPeak(peaks, res(i), 'add_pk');
                    pks = [pks; res(i)];
                end
                pks = sort(pks);
            end
            break;
        end
    end
    
    iti = iti+1;
end
fQRS = pks;

function peaks = registerPeak(peaks, newPeakPos, newPeakType)

switch(newPeakType)
    case 'act_pk',
        type = 1;
    case 'add_pk',
        type = 2;
    case 'sus_false_neg'
        type = -1;
    case 'sus_false_pos'
        type = -2;
    otherwise,
        type = 0;
end

if(peaks.pos(1) == -1)
    peaks.pos = newPeakPos;
    peaks.type = type;
    return;
end

if(~any(peaks.pos==newPeakPos))
    peaks.pos = [peaks.pos, newPeakPos];
    peaks.type = [peaks.type type];
end

function res = examineAddPeak(pks, iPeak, mQRS, sigm, meanRR, config)
% res = 1, remove the next peak
% res = 2, remove the current peak, the next peak is the real peak
% res = 0, do nothing I have no idea what to do...

res = 0;
MAX_ACC_SHIFT = config.peakExamination.minAccShift;

[ind, val, df] = findClosest(mQRS, pks(iPeak+1));
susMatPeak = 0;
if(df<MAX_ACC_SHIFT)
    susMatPeak = 1; % this peak looks like a residual from a maternal peak since there is a maternal peak very close to it...
end

if(susMatPeak)
    res = 1; % ok, remove this peak
    return;
end

% Test which peak is the fetal peak by bioulding a time series for each of the two peaks
back_ind = [];
% go back in time, if possible
peak1_series = [];
peak2_series = [];
peak1_series = pks(iPeak):-meanRR:1;
if(~isempty(peak1_series))
    peak1_series(1) = [];
    if(~isempty(peak1_series))
        peak1_series(end) = [];
    end
end
peak2_series = pks(iPeak+1):-meanRR:1;
if(~isempty(peak2_series))
    peak2_series(1) = [];
    if(~isempty(peak2_series))
        peak2_series(end) = [];
    end
end

for i=length(peak1_series):-1:1
    if(i<=length(peak2_series) && iPeak-i>0)
        tmp = [peak1_series(i) peak2_series(i)] - pks(iPeak-i);
        [y, back_ind(i)] = min(tmp);
    else
        
    end
end

% go forward in time, if possible
peak1_series = [];
peak2_series = [];
peak1_series = pks(iPeak):meanRR:pks(end);
if(~isempty(peak1_series))
    peak1_series(1) = [];
    if(~isempty(peak1_series))
        peak1_series(end) = [];
    end
end
peak2_series = pks(iPeak+1):meanRR:pks(end);

if(~isempty(peak2_series))
    peak2_series(1) = [];
    if(~isempty(peak2_series))
        peak2_series(end) = [];
    end
end

fwd_ind = zeros(0,1);
coder.varsize('fwd_ind', [5000 1], [1 0]); % #CODER_VARSIZE

for i=1:length(peak1_series)
    if(i<=length(peak2_series) && iPeak+i < length(pks))
        tmp = [peak1_series(i) peak2_series(i)] - pks(iPeak+i);
        [~, curr_temp] = min(tmp);
        fwd_ind = [fwd_ind, curr_temp];
    else
        
    end
end

if(isempty(back_ind) && isempty(fwd_ind))
    res = 0;
else
    res = mode([back_ind fwd_ind]);
end

function res = searchForMissingPeaks(pks, iPeak, mQRS, sig, meanRR, config)

coder.varsize('res', [1 100], [0 1]);
res = 0;
MAX_ACC_SHIFT = meanRR/10;
MIN_ACC_CORR_COEF = config.peakExamination.minAccCorrCoeff;
Diff = diff(pks(iPeak:iPeak+1));
predNumOfMissPeaks = round(Diff/meanRR) - 1;
susPeakPoss = pks(iPeak) + floor((1:predNumOfMissPeaks)/(predNumOfMissPeaks+1)*Diff);
susPeakPoss(susPeakPoss>pks(end)) = [];
mult = config.peakExamination.beatMult;
matTemplate = getTemplate(sig, mQRS, getQRSTemplateSize(mult));

for i=1:length(susPeakPoss)
    currSusPos = susPeakPoss(i);
    [mat_ind, v, df] = findClosest(mQRS, currSusPos);
    susMatPeak = 0;
    if(df<MAX_ACC_SHIFT)
        susMatPeak = 1; % this peak looks like a residual from a maternal peak since there is a maternal peak very close to it...
    end
    if(susMatPeak)
        signal = getQRSComplex(sig, mQRS(mat_ind), 0, mult, 0, 1) - matTemplate;
        [pks_vals, locs] = findpeaks(signal.*signal, 'minpeakdistance', length(signal)-2);
        peakLoc = (mQRS(mat_ind)-locs) + (length(signal)-1)/2;
        temp_1 = abs(peakLoc - currSusPos)<(MAX_ACC_SHIFT/2);
        if(any(temp_1(:)))
            if(any(res==0))
                res = currSusPos;%res = peakLoc;
            else
                res = [res currSusPos];%res = [res peakLoc];
            end
        end
    else
        fetTemplate = getTemplate(sig, pks, getQRSTemplateSize(mult));
        signal = getQRSComplex(sig, currSusPos, 0, mult, 0, 1);
        crr = corrCoef(fetTemplate, signal);
        [pks_vals, locs] = findpeaks(signal.*signal, 'minpeakdistance', length(signal)-2);
        sz = getQRSTemplateSize(mult);
        startShift = currSusPos + sz.onset;
        peakLoc = startShift + locs - 1;
        
        if(crr>MIN_ACC_CORR_COEF)
            temp_2 = abs(peakLoc - currSusPos)<(MAX_ACC_SHIFT/2);
            if(any(temp_2(:)))
                if(any(res==0))
                    res = currSusPos;%res = peakLoc;
                else
                    res = [res currSusPos];%res = [res peakLoc];
                end
            end
        end
    end
end

