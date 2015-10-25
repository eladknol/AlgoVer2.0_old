function [R_Waves, RelValidSigs, bestLead, bestLeadPeaks, leadsInclude] = findFetRWaves(signals, inConfig, inProcSig)
%#codegen

if(nargin==3)
    fetal2nd = 1;
else
    fetal2nd = 0;
end

SIZE = size(signals);
nNumOfSigs = SIZE(1);
peaksEnergy = 0;

Fs = inConfig.Fs;

relPeaksEnergy = inConfig.relFetalPeaksEnergy;
minDst = inConfig.peakDetection.minPeakDist; % in the case of fetal processing, maybe there will be a residuals from the maternal ECG hence don't limit the distance of the peaks
minHR = inConfig.minPredFetalHR;
maxHR = inConfig.maxPredFetalHR;
minNumOfPeaks = 0.75*(SIZE(2)/Fs)*(minHR/60);
maxNumOfPeaks = 1.25*(SIZE(2)/Fs)*(maxHR/60);
relPeaksEnergySave = relPeaksEnergy;

ind = 1;
leadsInclude = zeros(inConfig.nNumOfChs, 1);
config = inConfig;
if(~isfield(inConfig, 'skipBPS'))
    config.skipBPS = 0;
end

peaksRelE = zeros(config.nNumOfChs, 1);

peaks = repmat(struct('value', 0), config.nNumOfChs, 1);

coder.varsize('peaks', [6 1], [1 0]); % #CODER_VARSIZE % This is related to the maximun allowed size of the data
coder.varsize('peaks(:).value', [1000 1], [1 0]); % #CODER_VARSIZE % This is related to the maximun allowed size of the data
coder.varsize('peaksRelE', [6 1], [1 0]); % #CODER_VARSIZE % config.nNumOfChs
coder.varsize('leadsInclude', [6 1], [1 0]); % #CODER_VARSIZE % config.nNumOfChs

for i = 1:config.nNumOfChs
    
    if(fetal2nd)
        minPeakH = config.peakDetection.minPeakH;
        procSig = inProcSig(i,:);
    else
        minPeakH = peakDetection.minPeakH/4;
        procSig = signals(i,:);
    end
    
    % use constant thresholding
    if(fetal2nd)
        pInd = findPeaks(procSig, signals(i,:), minDst, minPeakH, 0, 0, Fs, 1, 0, config);% for now, don't classify
    else
        pInd = findPeaks(procSig, signals(i,:), minDst, minPeakH, 1, 0, Fs, 1, 1, config);% for now, don't classify
    end
    
    peaksRelE(i) = -inf;
    % remove bad 'source' signals
    if(length(pInd)<minNumOfPeaks || length(pInd)>maxNumOfPeaks)
        continue;
    end
    
    peaksE = getPeaksEnergy(signals(i,:), pInd);
    signalE = getSignalEnergy(signals(i,:));
    if(peaksE>signalE)
        % the energy of the peaks is larger thatn the energy of the signal
        % this happens when the QRS's of the peaks overlap
        peaksOnly = 1;
        peaksE = getPeaksEnergy(signals(i,:), pInd, peaksOnly);
        relPeaksEnergy = relPeaksEnergy/10;
    end
    peaksRelE(i) = peaksE/signalE;
    if((peaksRelE(i))<relPeaksEnergy)
        continue;
    end
    
    %     if(~isMaternalProc)
    if(~config.skipBPS)
        % only for fetal detection,
        inds = 1:length(signals(i,:));
        theoNumOfPeaks = floor(Fs/median(diff(pInd))*60);
        % ok, the lead seems as a good lead
        pInd(diff(pInd)==0) = [];
        bps = 1/((median(diff(pInd)))/config.Fs);
        if(bps>6 || bps<0.3) % like, really?!
            continue;
        end
        
        if(fetal2nd)
            bps = 1/((mode(diff(pInd)))/config.Fs);
        else
            %             sig = procSig.*procSig;
            %             refind = getPeaks(sig, 'refind', pInd); % refind can be -1!
            %             bps = 1/((mode(diff(refind)))/1000);
            bps = 1/((mode(diff(pInd)))/config.Fs);
        end
        
        if(bps>4 || bps<0.5) % like, really?!
            continue;
        end
        
        if(fetal2nd)
            peaksInd = pInd;
            len = length(peaksInd);
            for iPeak =1:len
                [~, maxInd] = getQRSComplex(signals(i,:), peaksInd(iPeak), iPeak==1 || iPeak==len, 2, 0, 1); % use a mult of 2 since the peak pos isn't acc yet...
                peaksInd(iPeak) = maxInd;
            end
            corr = peaksInd;
        else
            corr = pInd;
        end
    else
        corr = getPeaks(procSig, 'corr', pInd, [],[], config)';
    end
    
    peaks(ind).value = corr'; % no need to examine the peaks detected by the corr method only (they are already examined)
    peaksE = getPeaksEnergy(signals(i,:), corr);
    peaksRelE(i) = peaksE/signalE;
    %peaksEnergy(ind) = peaksRelE(i);
    peaksEnergy = [peaksEnergy, peaksRelE(i)];
    
    ind = ind+1;
    relPeaksEnergy = relPeaksEnergySave; % revert value
    leadsInclude(i) = 1;
end

%peaksRelE(peaksRelE<relPeaksEnergy) = -Inf;
% leadsInclude(peaksRelE<relPeaksEnergy) = 0;
[y, bestLead] = max(peaksRelE); % get the lead with the maximum energy in the QRS's
% leadsInclude = peaksRelE>relPeaksEnergy;
%peaksEnergy = peaksEnergy(peaksEnergy<relPeaksEnergy);

% if(config.forceDetect && ~any(leadsInclude) && peaksRelE(bestLead)>2/3*relPeaksEnergy)
%     %TBU
%     error('TBC');
%     % Ok, there is no lead that is relaiable enough, do something about it!
%     sig = signals(bestLead, :);
%     [~, pInd] = findPeaks(sig.*sig, sig, minDst, minPeakH, 1, 0, Fs);% for now, don't classify
%     if(config.useStats)
%         Diff = diff(pInd);
%         meanRR_prev = 0;
%         meanRR_curr = 0;
%         for nG=3:10
%             [grp, c] = kmedoids(Diff' ,nG);
%             for i=1:nG
%                 num(i) = sum(grp==i);
%             end
%             [y, i] = max(num);
%             meanRR_curr = c(i);
%             if(meanRR_curr == meanRR_prev)
%                 break;
%             end
%             meanRR_prev = meanRR_curr;
%         end
%         meanRR = meanRR_curr;
%     else
%         meanRR = median(diff(pInd)');
%     end
%     HR = Fs/meanRR * 60;
% end

[y, bestLeadPeaks] = max(peaksEnergy); % get the lead with the maximum energy in the QRS's
R_Waves = peaks;

if(y<=0)
    RelValidSigs = 0;
    return;
end

RelValidSigs = sum(peaksRelE>relPeaksEnergy)/(nNumOfSigs);
