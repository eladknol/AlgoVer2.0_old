function [R_Waves, RelValidSigs, bestLead, bestLeadPeaks, leadsInclude] = findMatRWaves(signals, config, chnlInclude)
%#codegen

SIZE = size(signals);
nNumOfSigs = SIZE(1);

Fs = config.Fs;
minHR = config.minPredMaternalHR;
maxHR = config.maxPredMaternalHR;
minNumOfPeaks = 0.75*(SIZE(2)/Fs)*(minHR/60);
maxNumOfPeaks = 1.25*(SIZE(2)/Fs)*(maxHR/60);
minDst = floor(length(signals(1,:))/maxNumOfPeaks); % minDist = 200;
peaks  = repmat(struct('value', 0), config.nNumOfChs, 1);

coder.varsize('peaks'           , [6 1]     , [1 0]); % #CODER_VARSIZE % This is related to the maximun allowed size of the data
coder.varsize('peaks(:).value'  , [1000 1]  , [1 0]); % #CODER_VARSIZE % This is related to the maximun allowed size of the data
coder.varsize('pInd(:).value'   , [1000 1]  , [1 0]);
coder.varsize('peaksRelE'       , [6 1]     , [1 0]); % #CODER_VARSIZE % config.nNumOfChs
coder.varsize('peaksE'          , [6 1]     , [1 0]); % #CODER_VARSIZE % config.nNumOfChs
coder.varsize('peaksEnergy'     , [6 1]     , [1 0]); % #CODER_VARSIZE % config.nNumOfChs
coder.varsize('signalE'         , [6 1]     , [1 0]); % #CODER_VARSIZE % config.nNumOfChs
coder.varsize('relPeaksEnergy'  , [6 1]     , [1 0]); % #CODER_VARSIZE % config.nNumOfChs
coder.varsize('leadsInclude'    , [6 1]     , [1 0]); % #CODER_VARSIZE % config.nNumOfChs
coder.varsize('pInd'            , [6 1]     , [1 0]);

peaksRelE       = zeros(0, 1);
peaksEnergy     = zeros(0, 1);
leadsInclude    = zeros(0, 1);
peaksE          = zeros(6, 1);
signalE         = zeros(6, 1);
relPeaksEnergy  = ones(6, 1)*config.relMaternalPeaksEnergy;

for ii=1:config.nNumOfChs
    peaksRelE    = [peaksRelE;      0];
    leadsInclude = [leadsInclude;   0];
end

config_par_minPeakHeight = config.minPeakHeight;
pInd = repmat(struct('value', 1), 6, 1);

if(config.usePar)
    parfor i = 1:config.nNumOfChs
        if(chnlInclude(i))
            %procSig = signals(i,:).*signals(i,:);
            pInd(i).value = findPeaks(signals(i,:).*signals(i,:), signals(i,:), minDst, config_par_minPeakHeight, 0, 0, Fs, 1, 0, config);% for now, don't classify
            
            peaksRelE(i) = -inf(1);
            % remove bad 'source' signals
            if(length(pInd(i).value)<minNumOfPeaks || length(pInd(i).value)>maxNumOfPeaks)
                continue;
            end
            
            peaksE(i) = getPeaksEnergy(signals(i,:), pInd(i).value);
            signalE(i) = getSignalEnergy(signals(i,:));
            if(peaksE(i)>signalE(i))
                % the energy of the peaks is larger thatn the energy of the signal
                % this happens when the QRS's of the peaks overlap
                peaksOnly = 1;
                peaksE(i) = getPeaksEnergy(signals(i,:), pInd(i).value, peaksOnly);
                relPeaksEnergy(i) = relPeaksEnergy(i)/10;
            end
            peaksRelE(i) = peaksE(i)/signalE(i);
            if((peaksRelE(i))<relPeaksEnergy(i))
                continue;
            end
            
            peaks(i).value = getPeaks(signals(i,:), 'corr', pInd(i).value, [],[], config);
            peaksE(i) = getPeaksEnergy(signals(i,:), peaks(i).value);
            peaksRelE(i) = peaksE(i)/signalE(i);
            %peaksEnergy(ind) = peaksRelE(i);
            peaksEnergy = [peaksEnergy, peaksRelE(i)];
            
            leadsInclude(i) = 1;
        else
            pInd(i).value = -1;
            peaksRelE(i) = -inf(1);
            leadsInclude(i) = 0;
        end
    end
else
    for i = 1:config.nNumOfChs
        if(chnlInclude(i))
            %procSig = signals(i,:).*signals(i,:);
            pInd(i).value = findPeaks(signals(i,:).*signals(i,:), signals(i,:), minDst, config_par_minPeakHeight, 0, 0, Fs, 1, 0, config);% for now, don't classify
            
            peaksRelE(i) = -inf(1);
            % remove bad 'source' signals
            if(length(pInd(i).value)<minNumOfPeaks || length(pInd(i).value)>maxNumOfPeaks)
                continue;
            end
            
            peaksE(i) = getPeaksEnergy(signals(i,:), pInd(i).value);
            signalE(i) = getSignalEnergy(signals(i,:));
            if(peaksE(i)>signalE(i))
                % the energy of the peaks is larger thatn the energy of the signal
                % this happens when the QRS's of the peaks overlap
                peaksOnly = 1;
                peaksE(i) = getPeaksEnergy(signals(i,:), pInd(i).value, peaksOnly);
                relPeaksEnergy(i) = relPeaksEnergy(i)/10;
            end
            peaksRelE(i) = peaksE(i)/signalE(i);
            if((peaksRelE(i))<relPeaksEnergy(i))
                continue;
            end
            
            peaks(i).value = getPeaks(signals(i,:), 'corr', pInd(i).value, [],[], config);
            peaksE(i) = getPeaksEnergy(signals(i,:), peaks(i).value);
            peaksRelE(i) = peaksE(i)/signalE(i);
            %peaksEnergy(ind) = peaksRelE(i);
            peaksEnergy = [peaksEnergy, peaksRelE(i)];
            
            leadsInclude(i) = 1;
        else
            pInd(i).value = -1;
            peaksRelE(i) = -inf(1);
            leadsInclude(i) = 0;
        end
    end
end

[y, bestLead] = max(peaksRelE); % get the lead with the maximum energy in the QRS's

[y, bestLeadPeaks] = max(peaksEnergy); % get the lead with the maximum energy in the QRS's
R_Waves = peaks;

if(y<=0)
    for ii=1:numel(R_Waves)
        R_Waves(ii).value = -1;
    end
    RelValidSigs = 0;
    return;
end

RelValidSigs = sum(peaksRelE>config.relMaternalPeaksEnergy)/(nNumOfSigs);
