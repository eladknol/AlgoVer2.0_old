function R_Waves = findRWavesDirect(signals, config) %#codegen
% Fing the R-waves using the direct method

% Alg:
% for every channel:
%     1. Apply power^2 filter to enhance peaks
%     2. Apply anti-median filter
%     3. Find peaks
%     4. Examine peaks to remove repetitions

% once for all of channels:
%     1. perfom voting for every position
%
% for the detection of the mQRS an assumption is done: there is at least
% one channel that the maternal ECG is bigger than the fetal ECG. In general, this
% assumption is true for more than 2 channels. if at least one electrode is close to
% the mother's heart then this assumption is valid.
% mote: put this electrode, (upper-left electrode) in the first row of the
% signals data.

SIZE = size(signals);
[nNumOfSignals, ind] = min(SIZE);

if(ind>1)
    signals = signals';
end

closestElectrode = 1; % the electrode that is most close to the mother's heart.

for iSig = 1:nNumOfSignals
    signal = signals(iSig,:);
    signalPow2 = signal.*signal; % pow2 enhance
    direc = getPeaks(signalPow2, 'direc');                   % Find peaks using 1st and 2nd derivatives
    corr  = getPeaks(signal, 'corr', direc, [], [], config);                 % Get peaks using correlation analysis
    localPeaks{iSig} = examineLocalPeaks({direc, corr}, 0, signal);         % Examine peaks to remove repetitions and false positives
    
%     if(iSig==closestElectrode)
%         localPeaks{iSig} = examineLocalPeaks({direc, corr}, 0, signal);         % Examine peaks to remove repetitions and false positives
%     else
%         classy  = getPeaks(signal, 'class', localPeaks{closestElectrode}.peaks); % Get peaks using knn classification
%         Diff = [length(corr) length(classy)] - length(localPeaks{closestElectrode}.peaks);
%         [a,prefM] = min(abs(Diff));
%         localPeaks{iSig} = examineLocalPeaks({corr, classy}, prefM, signal, length(localPeaks{closestElectrode}.peaks));         % Examine peaks to remove repetitions and false positives
%     end
end

globalPeaks = getGlobalPeaks(localPeaks, signals, closestElectrode);

R_Waves = globalPeaks.peaks.ind;

% figure,
% plot(signals')
% hold on;
% plot(globalPeaks.peaks.ind,30,'ok');
% i=1;
%%
function resPeaks = examineLocalPeaks(peaks, pref, signal, nNumOfPredPeaks)
% examine and align peaks

% peaks: is the peaks cell, the size  of the matrix is as the size of the
%           methodsXnumber of peaks
% pref  (optional): in case of conflict which method to use
% signal(optional): the ECG signal

SIZE = size(peaks);
nNumOfSigs = max(SIZE);

switch (nNumOfSigs)
    case 1,
        % examine the peaks detected by one method
    case 2,
        % examine the peaks detected by 2 methods
        
        MAX_NUM_OF_PEAKS = max(length(peaks{1}), length(peaks{2}));
        MAX_ACC_PEAK_SHIFT = ceil(0.01*nanmean([diff(peaks{1}) diff(peaks{2})])); % accepted peak shift in different methods
        MIN_ACC_CORR_COEF = 0.94;
        if(pref==0)
            % no prefeable channel
            % use the signal to detect which one of the peaks are better:
            %  for conflicting peaks:
            %       calculate 2 templates: one using method 1 and one using
            %       method 2. Then caclulate the cross correlation between the template and the conflicted peak signal (get QRS).
            %       (correlation of the conflicted peak with the two templates
            %       define a score: average correlation.
            %       the method with the higher score is the right one.
            count = 1;
            while(true && count<MAX_NUM_OF_PEAKS)
                len1 = length(peaks{1});
                len2 = length(peaks{2});
                if(len1<len2)
                    peaks{1}(end+1:end+(len2-len1)) = nan;
                elseif(len2<len1)
                    peaks{2}(end+1:end+(len1-len2)) = nan;
                end
                
                diffPeak = find(peaks{1}~=peaks{2}, true, 'first');
                if(isempty(diffPeak))
                    % no more different peaks, finish
                    break;
                end
                Diff = [peaks{1}(diffPeak) peaks{2}(diffPeak)];
                if(abs(diff(Diff))<=MAX_ACC_PEAK_SHIFT)
                    %[QRS, maxInd] = getQRSComplex(signal, peaks{1}(diffPeak));
                    peaks{1}(diffPeak) = floor(min(Diff) + 0.5*abs(diff(Diff)));
                    peaks{2}(diffPeak) = peaks{1}(diffPeak);
                    count = count+1;
                    continue;
                end
                
                if((~isnan(peaks{1}(diffPeak)) && ~isnan(peaks{2}(diffPeak))))
                    clear QRS;
                    for i=1:2
                        template{i} = getTemplate(signal, peaks{i}(~isnan(peaks{i})));
                        QRS{i}      = getQRSComplex(signal, peaks{i}(diffPeak));
                        try
                            corr{i}     = xcorr(template{i}, QRS{i},'coef');
                        catch
                            corr{i}     = conv(template{i}, QRS{i});
                        end
                        maxCorr{i} = max(corr{i});
                        
                        if(corr{i}<MIN_ACC_CORR_COEF)
                            % bad peak detected, remove it!
                            peaks{i}(diffPeak) = [];
                        end
                    end
                    count = count+1;
                else
                    count = count+1;
                end
                if(diffPeak==len1)
                    break;
                end
            end
            for i=1:2
                peaks{i}(isnan(peaks{i}))=[];
            end
            resPeaks.peaks = peaks{1};
            resPeaks.isRel = 1; % relaiable result
        else
            % get the peak positions using one method (prefable method)!
            resPeaks.peaks = peaks{pref};
            
            % check if the results are reliable
            for i=1:length(peaks)
                nNumOfPeaks(i) = length(peaks{i});
            end
            % number of peaks:
            if(nargin>3)
                if(nNumOfPeaks(pref)>1.5*nNumOfPredPeaks || nNumOfPeaks(pref)<0.5*nNumOfPredPeaks)
                    resPeaks.isRel = 0; % not relaiable
                else
                    resPeaks.isRel = 2; % not sure
                end
            end
            % check the std of the RR intervals
            STD = std(diff(resPeaks.peaks));
            RR_STD = getParam(getAlgConstants('normalMaternalRRSTD'));
            % need to correct it to match Fs=1kHz
            if(STD>RR_STD)
                resPeaks.isRel = 0;
            end
        end
    case 3,
        if(pref==0)
            %         to be continued...
        else
            for i=1:length(peaks)
                nNumOfPeaks(i) = length(peaks{i});
            end
            if(nargin>3)
                if(mean(nNumOfPeaks)>0.5*nNumOfPredPeaks || mean(nNumOfPeaks)<0.5*nNumOfPredPeaks)
                    resPeaks.isRel = 0; % not relaiable
                else
                    resPeaks.isRel = 2; % not sure
                end
            end
            resPeaks.peaks = peaks{pref};
        end
end


function globalPeaks = getGlobalPeaks(localPeaks, signals, closestElectrode)

MAX_ACC_PEAK_SHIFT = 40; % mSec
nNumOfSigs = numel(localPeaks);

% Exlude very noisy leads:
for iSig=1:nNumOfSigs
    nNumOfPeaks(iSig) = length(localPeaks{iSig}.peaks);
end

if(localPeaks{closestElectrode}.isRel==0)
    globalPeaks.isRel = 0;
    % If the results of the closest electrode arn't relaiable
    % try to find a more reliable lead?
else
    ind = 1;
    for iPeak = 1:nNumOfPeaks(closestElectrode)
        for iSig=1:nNumOfSigs
            [peakInd(iSig), peakVal(iSig)] = findClosest(localPeaks{iSig}.peaks, localPeaks{closestElectrode}.peaks(iPeak));
        end
        vote = (peakVal-peakVal(closestElectrode)) < MAX_ACC_PEAK_SHIFT;
        
        switch(sum(vote))
            case (length(vote)),
                globalPeaks.peaks.ind(ind) = floor(mean(peakVal));
                globalPeaks.peaks.vote(ind) = sum(vote);
                ind=ind+1;
            otherwise,
                for iSig=1:length(vote)
                    temp(iSig) = localPeaks{iSig}.isRel>0 && vote(iSig);
                end
                if(sum(temp)>=0.5*length(vote))
                    globalPeaks.peaks.ind(ind) = floor(mean(peakVal(temp~=0)));
                    globalPeaks.peaks.vote(ind) = sum(temp);
                    ind=ind+1;
                else
                    globalPeaks.peaks.ind(ind) = peakVal(closestElectrode);
                    globalPeaks.peaks.vote(ind) = 1;
                    ind=ind+1;
                end
        end
    end
end
