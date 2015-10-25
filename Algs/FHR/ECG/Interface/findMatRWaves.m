function [R_Waves, RelValidSigs, bestLead, bestLeadPeaks, leadsInclude] = findMatRWaves(signals, config)
%#codegen

SIZE = size(signals);
nNumOfSigs = SIZE(1);
peaksEnergy = 0;

Fs = config.Fs;
relPeaksEnergy = config.relMaternalPeaksEnergy;
minHR = config.minPredMaternalHR;
maxHR = config.maxPredMaternalHR;
minNumOfPeaks = 0.75*(SIZE(2)/Fs)*(minHR/60);
maxNumOfPeaks = 1.25*(SIZE(2)/Fs)*(maxHR/60);
minDst = floor(length(signals(1,:))/maxNumOfPeaks); % minDist = 200;

relPeaksEnergySave = relPeaksEnergy;

ind = 1;

peaks = repmat(struct('value', 0), config.nNumOfChs, 1);

coder.varsize('peaks', [6 1], [1 0]); % #CODER_VARSIZE % This is related to the maximun allowed size of the data
coder.varsize('peaks(:).value', [1000 1], [1 0]); % #CODER_VARSIZE % This is related to the maximun allowed size of the data
coder.varsize('peaksRelE', [6 1], [1 0]); % #CODER_VARSIZE % config.nNumOfChs
coder.varsize('leadsInclude', [6 1], [1 0]); % #CODER_VARSIZE % config.nNumOfChs

peaksRelE = zeros(0, 1);
leadsInclude = zeros(0, 1);
for i=1:config.nNumOfChs
    peaksRelE = [peaksRelE; 0];
    leadsInclude = [leadsInclude; 0];
end


for i = 1:config.nNumOfChs
    procSig = signals(i,:).*signals(i,:);
    pInd = findPeaks(procSig, signals(i,:), minDst, config.minPeakHeight, 0, 0, Fs, 1, 0, config);% for now, don't classify
    
    peaksRelE(i) = -inf(1);
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
    
    
    corr = getPeaks(signals(i,:), 'corr', pInd, [],[], config);
    
    peaks(i).value = corr; % no need to examine the peaks detected by the corr method only (they are already examined)
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

if(config.forceDetect && ~any(leadsInclude) && peaksRelE(bestLead)>2/3*relPeaksEnergy)
    %TBU
    error('TBC');
    % Ok, there is no lead that is relaiable enough, do something about it!
%     sig = signals(bestLead, :);
%     pInd = findPeaks(sig.*sig, sig, minDst, config.minPeakHeight, 1, 0, Fs);% for now, don't classify
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
end

[y, bestLeadPeaks] = max(peaksEnergy); % get the lead with the maximum energy in the QRS's
R_Waves = peaks;

if(y<=0)
    for i=1:numel(R_Waves)
        R_Waves(i).value = -1;
    end
    
    RelValidSigs = 0;
    return;
end

RelValidSigs = sum(peaksRelE>relPeaksEnergy)/(nNumOfSigs);
