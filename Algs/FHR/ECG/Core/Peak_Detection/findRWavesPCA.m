function [R_Waves, RelValidSigs, bestLead, bestLeadPeaks] = findRWavesPCA(signals, config)

SIZE = size(signals);
nNumOfSigs = SIZE(1);

% [signals, Out2, Out3] = fastica(signals,'g','tanh','verbose','off'); % no
% need to re-do it! (it might give different resutls and hence different bestLead...)

% assume that the last 'source' signal is noise

% minDst = 200;
maternalProc = strcmp(config.procType,'maternal');
Fs = config.Fs;

global globalConfig;
globalConfig.procType = config.procType;

if(maternalProc)
    relPeaksEnergy = config.relMaternalPeaksEnergy;
    minHR = config.minPredMaternalHR;
    maxHR = config.maxPredMaternalHR;
    minNumOfPeaks = 0.75*(SIZE(2)/Fs)*(minHR/60);
    maxNumOfPeaks = 1.25*(SIZE(2)/Fs)*(maxHR/60);
    minDst = floor(length(signals(1,:))/maxNumOfPeaks); % minDist = 200;
else
    relPeaksEnergy = config.relFetalPeaksEnergy;
    minDst = 1; % in the case of fetal processing, maybe there will be a residuals from the maternal ECG hence don't limit the distance of the peaks
    minHR = config.minPredFetalHR;
    maxHR = config.maxPredFetalHR;
    minNumOfPeaks = 0.75*(SIZE(2)/Fs)*(minHR/60);
    maxNumOfPeaks = 1.25*(SIZE(2)/Fs)*(maxHR/60);
end
relPeaksEnergySave = relPeaksEnergy;

ind = 1;
for i = 1:nNumOfSigs-1
    if(maternalProc)
        procSig = abs(signals(i,:));
        minPeakH = 0.15;
    else
        procSig = signals(i,:).*signals(i,:);
        minPeakH = 0.15;
    end
    
    [pks, pInd] = findPeaks(procSig, signals(i,:), minDst, minPeakH, 1, 1);
    peaksRelE(i) = -inf;
    % remove bad 'source' signals
    if(length(pks)<minNumOfPeaks || length(pks)>maxNumOfPeaks)
        continue;
    end
    
    peaksE = getPeaksEnergy(procSig, pInd);
    signalE = getSignalEnergy(procSig);
    if(peaksE>signalE)
        % the energy of the peaks is larger thatn the energy of the signal
        % this happens when the QRS's of the peaks overlap
        peaksOnly = 1;
        peaksE = getPeaksEnergy(procSig, pInd, peaksOnly);
        relPeaksEnergy = relPeaksEnergy/10;
    end
    peaksRelE(i) = peaksE/signalE;
    if((peaksRelE(i))<relPeaksEnergy)
        continue;
    end
    %     class = classifyPeaks(Out1(i,:), pInd);
    corr = getPeaks(signals(i,:), 'corr', pInd);
    %     peaks{ind} = examinePeaks({class, corr}, Out1(i,:));
    peaks{ind} = corr; % no need to examine the peaks detected by the corr method only (they are already examined)
    peaksEnergy(ind) = peaksRelE(i);
    ind = ind+1;
    relPeaksEnergy = relPeaksEnergySave; % revert value
    
end
[y, bestLead] = max(peaksRelE); % get the lead with the maximum energy in the QRS's
[y, bestLeadPeaks] = max(peaksEnergy); % get the lead with the maximum energy in the QRS's
if(maternalProc)
    R_Waves = examinePeaks(peaks, signals(bestLead,:));
%     config.bestLead = bestLead;
else
    R_Waves = examinePeaks(peaks(bestLeadPeaks), signals(bestLead,:));
%     config.bestLead = bestLead;
end

RelValidSigs = sum(peaksRelE>relPeaksEnergy)/(nNumOfSigs-1);
%%
function E = getPeaksEnergy(signal, peaks, peaksOnly)

E=0;
if(nargin<3)
    peaksOnly = 0;
end
if(~peaksOnly)
    for i=1:length(peaks)
        qrs = getQRSComplex(signal, peaks(i));
        E = E + getSignalEnergy(qrs);
    end
else
    E = nansum(signal(peaks).*signal(peaks));
end

function E = getSignalEnergy(signal)
E = nansum(signal.*signal);

%%
function peaks = classifyPeaks(signal, pInd)
peaks = getPeaks(signal, 'class', pInd);

%%
function peaks = examinePeaks(pks, signal)

MAX_ACC_PEAK_SHIFT = ceil(0.1*nanmean(diff(pks{1})));
ind = 1;
if(numel(pks)==1)
    len = length(pks{1});
    for i=1:len
        [QRS, maxInd] = getQRSComplex(signal, pks{1}(i), i==1 || i==len);
        pks{1}(i) = maxInd;
    end
    peaks = pks{1};
    
elseif(numel(pks)==2)
    for i=1:length(pks{1})
        temp = abs(pks{2}-pks{1}(i))<MAX_ACC_PEAK_SHIFT;
        fInd = find(temp,1);
        if(~isempty(fInd))
            if(abs(signal(pks{1}(i)))>abs(signal(pks{2}(fInd))))
                peaks(ind) = pks{1}(i);
            else
                peaks(ind) = pks{2}(fInd);
            end
            ind = ind+1;
        end
    end
elseif(numel(pks)==3)
    for i=1:length(pks{1})
        temp2 = abs(pks{2}-pks{1}(i))<MAX_ACC_PEAK_SHIFT;
        temp3 = abs(pks{3}-pks{1}(i))<MAX_ACC_PEAK_SHIFT;
        fInd2 = find(temp2,1);
        fInd3 = find(temp3,1);
        if(~isempty(fInd2)) % >=2
            if(abs(signal(pks{1}(i)))>abs(signal(pks{2}(fInd2))))
                peaks(ind) = pks{1}(i);
            else
                peaks(ind) = pks{2}(fInd2);
            end
            if(~isempty(fInd3))
                if(abs(signal(peaks(ind)))>abs(signal(pks{3}(fInd3))))
                    peaks(ind) = pks{1}(i);
                else
                    peaks(ind) = pks{3}(fInd3);
                end
            end
            ind = ind+1;
        end
    end
    
end

peaks(peaks<0)=[];
peaks(peaks>length(signal))=[];

