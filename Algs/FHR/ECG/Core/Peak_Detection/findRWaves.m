function [R_Waves, RelValidSigs, bestLead, bestLeadPeaks, leadsInclude] = findRWaves(signals, config, inProcSig)
%#codegen

if(nargin==3)
    fetal2nd = 1;
else
    fetal2nd = 0;
end
SIZE = size(signals);
nNumOfSigs = SIZE(1);
peaksEnergy = 0;

isMaternalProc = strcmpi(getProcType(config.procType), 'maternal');
Fs = config.Fs;

if(~isfield(config, 'forceDetect'))
    config.forceDetect = 0;
end

if(isMaternalProc)
    relPeaksEnergy = config.relMaternalPeaksEnergy;
    minHR = config.minPredMaternalHR;
    maxHR = config.maxPredMaternalHR;
    minNumOfPeaks = 0.75*(SIZE(2)/Fs)*(minHR/60);
    maxNumOfPeaks = 1.25*(SIZE(2)/Fs)*(maxHR/60);
    minDst = floor(length(signals(1,:))/maxNumOfPeaks); % minDist = 200;
else
    relPeaksEnergy = config.relFetalPeaksEnergy;
    minDst = config.peakDetection.minPeakDist; % in the case of fetal processing, maybe there will be a residuals from the maternal ECG hence don't limit the distance of the peaks
    minHR = config.minPredFetalHR;
    maxHR = config.maxPredFetalHR;
    minNumOfPeaks = 0.75*(SIZE(2)/Fs)*(minHR/60);
    maxNumOfPeaks = 1.25*(SIZE(2)/Fs)*(maxHR/60);
end
relPeaksEnergySave = relPeaksEnergy;

ind = 1;
leadsInclude = zeros(config.nNumOfChs, 1);
% parfor i = 1:nNumOfSigs %nNumOfSigs-1
if(~isfield(config, 'skipBPS'))
    config.skipBPS = 0;
end
nNumOfSamps = max(size(signals));

% coder remove
% if(config.nNumOfChs>1 && (nNumOfSamps/Fs/60)>3) % More than 1 cahnnel and the length of the signals is more than 3 mins
%     %if(getInsTBXs('par')) % should be avoided!
%     %   config.usePar = 1;
%     %end
% else
%     config.usePar = 0;
% end

peaksRelE = zeros(config.nNumOfChs, 1);
peaks = repmat(struct('value', 0), config.nNumOfChs, 1);
temp = 200;%config.maxPredMaternalHR; % this cannot be maxPredMaternalHR since this function supports fetal peak detection also
coder.varsize('peaks(:).value', [round(temp*SIZE(2)/config.Fs/60) 1], [1 0]);

for i = 1:config.nNumOfChs
    if(isMaternalProc)
        procSig = signals(i,:).*signals(i,:);
        minPeakH = config.minPeakHeight; % 0.15
    else
        if(fetal2nd)
            minPeakH = config.peakDetection.minPeakH;
            procSig = inProcSig(i,:);
        else
            procSig = signals(i,:);
            minPeakH = peakDetection.minPeakH/4;
        end
    end
    % CODER REMOVE
    %     if(strcmpi(minPeakH ,'adpt'))
    %         % TBC
    %         stop = 0;
    %         iti = 0;
    %         minPeakHInit = 0.8;
    %         maxIti = 20;
    %         % use adaptive thresholding
    %         minPeakH = minPeakHInit;
    %         [~, pInd] = findPeaks(procSig, signals(i,:), minDst, minPeakH, 1, 0, Fs);% for now, don't classify
    %
    %         while(true)
    %
    %             df = diff(pInd);
    %             MEDIAN = median(df); % The RR internals should be close to a normal distribution, hence the skewnees
    %             MEAN = mean(df);
    %             % skewness(df');
    %             if(MEDIAN<0.5*MEAN)
    %                 minPeakH = 0.9*minPeakH;
    %                 [~, pInd] = findPeaks(procSig, signals(i,:), minDst, minPeakH, 1, 0, Fs);% for now, don't classify
    %             else
    %                 stop = 1;
    %             end
    %
    %             iti = iti+1;
    %             if(stop || iti>maxIti)
    %                 break;
    %             end
    %         end
    %     else
    %         % use constant thresholding
    %         if(fetal2nd)
    %             [~, pInd] = findPeaks(procSig, signals(i,:), minDst, minPeakH, 0, 0, Fs, 1, 0, config);% for now, don't classify
    %         else
    %             [~, pInd] = findPeaks(procSig, signals(i,:), minDst, minPeakH, 1, 0, Fs, 1, 1, config);% for now, don't classify
    %         end
    %     end
    
    % use constant thresholding
    if(fetal2nd)
        [~, pInd] = findPeaks(procSig, signals(i,:), minDst, minPeakH, 0, 0, Fs, 1, 0, config);% for now, don't classify
    else
        [~, pInd] = findPeaks(procSig, signals(i,:), minDst, minPeakH, 1, 0, Fs, 1, 1, config);% for now, don't classify
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
    if(~isfield(config, 'skipBPS'))
        config.skipBPS = 0;
    end
    if(~isMaternalProc)
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
            corr = getPeaks(procSig, 'corr', pInd, [],[], config);
        end
    else
        corr = getPeaks(signals(i,:), 'corr', pInd, [],[], config);
    end
    %     peaks{ind} = examinePeaks({class, corr}, Out1(i,:));
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

if(config.forceDetect && ~any(leadsInclude) && peaksRelE(bestLead)>2/3*relPeaksEnergy)
    %TBU
    error('TBC');
    % Ok, there is no lead that is relaiable enough, do something about it!
    sig = signals(bestLead, :);
    [~, pInd] = findPeaks(sig.*sig, sig, minDst, minPeakH, 1, 0, Fs);% for now, don't classify
    if(config.useStats)
        Diff = diff(pInd);
        meanRR_prev = 0;
        meanRR_curr = 0;
        for nG=3:10
            [grp, c] = kmedoids(Diff' ,nG);
            for i=1:nG
                num(i) = sum(grp==i);
            end
            [y, i] = max(num);
            meanRR_curr = c(i);
            if(meanRR_curr == meanRR_prev)
                break;
            end
            meanRR_prev = meanRR_curr;
        end
        meanRR = meanRR_curr;
    else
        meanRR = median(diff(pInd)');
    end
    HR = Fs/meanRR * 60;
end

[y, bestLeadPeaks] = max(peaksEnergy); % get the lead with the maximum energy in the QRS's
if(y<=0)
    R_Waves = -1;
    RelValidSigs = 0;
    return;
end

% CODER_REMOVE
% if(~isfield(config,'examine'))
%     config.examine = 0;
% end
% 
% if(config.examine)
%     if(isMaternalProc)
%         [y,i] = sort(peaksRelE, 'descend');
%         R_Waves = examinePeaks(peaks(i(1:3)), signals(bestLead,:));
%         %     config.bestLead = bestLead;
%     else
%         R_Waves = examinePeaks(peaks(bestLeadPeaks), signals(bestLead,:));
%         %     config.bestLead = bestLead;
%     end
% else
%     R_Waves = peaks;
% end

R_Waves = peaks;
RelValidSigs = sum(peaksRelE>relPeaksEnergy)/(nNumOfSigs);

