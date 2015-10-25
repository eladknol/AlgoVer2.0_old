function closestSensor = analyzeEnergy(signals, inConfig) %#codegen
%#codegen

% #CODER_REMOVE
% This code is under the code rewriting process for the coder. Remove this line when done.


%% DOC
%closestSensor = analyzeEnergy(signals, config)
% This function examines the multi channels signals data and returns signal that has the higher energy content. 
% This signal should be the one witht the closeset channel to the source.
% Inputs:
%   signals: NxL mat. N is the number of channels 
%   config: Configuration structure 
% Outputs:
%   closestSensor: the index of the closest channel

%% CODE
% Energy: RMS 
% Peaks: perform a preliminary analysis on the peaks

%% Coder directives 
coder.varsize('peaks',  [1 10],     [0 1]); % #CODER_VARSIZE
coder.varsize('med',    [1 10],     [0 1]); % #CODER_VARSIZE
coder.varsize('pks',    [1 1000],   [0 1]); % #CODER_VARSIZE

%% Local params
config = inConfig;
config.Order = 5;           % Don't move it to ConfigProvider
config.Fc = 1;    % Don't move it to ConfigProvider
config.isNorm = 1;          % Don't move it to ConfigProvider
config.minDist = 1; % minDist = 150; % Don't move it to ConfigProvider
config.minProm = 0.7; % Don't move it to ConfigProvider
config.Fc = 1/config.Fs;    % Don't move it to ConfigProvider

maxNumOfPredPeaks = (length(signals(1,:))/config.Fs)*(config.maxPredMaternalHR/60);
minNumOfPredPeaks = 0.3*maxNumOfPredPeaks;
nNumOfSigs = size(signals, 1);

config.minDist = floor(length(signals(1,:))/maxNumOfPredPeaks/2); % minDist = 150; % Don't move it to ConfigProvider

[~, signals] = applyFilter('HIGH_BUTTER', signals, config);

RMS = rms(signals');

% Variables initiation
peaks = zeros(1, nNumOfSigs);
med = zeros(1, nNumOfSigs);
pks = zeros(1, 0);


for iSig=1:nNumOfSigs
    sig = signals(iSig,:); 
    sig = sig/nanmax(abs(sig));
    pks = findpeaks(sig, 'MINPEAKDISTANCE', config.minDist, 'MinPeakProminence', config.minProm); % consider using 'Threshold' 'MinPeakHeight', this command SHOULD NOT be used for ECG peak detection, see findPeaks (upper case 'P' for more info)
    pks = sort(abs(pks));
    if(~isempty(pks))
        % Remove noise peaks - spikes 
        for i=1:floor(0.1*length(pks))
            if(std(pks(1:end-10*(i+1)))<0.8*std(pks(1:end-10*i)))
            else
                break;
            end
        end
        pks = pks(1:end-10*(i)); 
        
        if(length(pks)<1.5*maxNumOfPredPeaks && length(pks)>0.5*minNumOfPredPeaks)
            peaks(iSig) = sum(pks)/length(pks);
        else
            peaks(iSig) = nan;
        end
        med(iSig) = median(pks);
    else
        peaks(iSig) = nan;
    end
end

RMS(isnan(peaks) | peaks==0) = nan; % Should use the RMS of the peaks...
[~, maxInd] = nanmax(RMS);
closestSensor = maxInd;
