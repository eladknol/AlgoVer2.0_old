function [satInds, chnlInclude, closestElectrode, filtData] = doExamine(rawData, filtData, dataType)
%#codegen

% #CODER_REMOVE
% This code is under the code rewriting process for the coder. Remove this line when done.


%%
%[varargout] = doExamine(data, metaData, dataType)
% Examine the input data
% Inputs:
%   rawData: the raw data , NxL mat. N is the number of channels
%   filtData: the filtered data , NxL mat. N is the number of channels
%   metaData: the meta data
%   dataType: the type of the data: ECG, MIC
% Outputs:
%   chnlInclude: Which channles to include
%   satInds: indices where the saturation level is reached
%   filtData: the data after examination (maybe can be excluded)
%   closestElectrode: the closeset electrode to the mother's heart

%% Output initiation
satInds = struct('inds', 0);
chnlInclude = false(1, 0);
closestElectrode = -1;

%% Local Params
exclude.sat = false(1, 0);
exclude.pwr = false(1, 0);

%% #CODER_DIRECTIVE
coder.varsize('satInds',        [10, 1], [1 0]);    % #CODER_VARSIZE
coder.varsize('chnlInclude',    [1, 10], [0 1]);    % #CODER_VARSIZE
coder.varsize('exclude.sat',    [1, 10], [0 1]);    % #CODER_VARSIZE
coder.varsize('exclude.pwr',    [1, 10], [0 1]);    % #CODER_VARSIZE
coder.varsize('satInds(:).inds',[1 120000], [0 1]); % #CODER_VARSIZE

%% Configurations
global configProvider; % Only getters are allowed here
localConfig.saturationLevel         = configProvider.GEN_CFG.satLevel;
localConfig.maxSatPerc              = configProvider.ECG_CFG.general.maxSatPerc;
localConfig.binSatPerc              = configProvider.ECG_CFG.general.binSatPerc;
localConfig.maxNaNPerc              = configProvider.ECG_CFG.general.maxNaNPerc;
localConfig.Fs                      = configProvider.GEN_CFG.sampleRate;
localConfig.maxPredMaternalHR       = configProvider.ECG_CFG.general.maxPredMHR;
localConfig.nfft                    = configProvider.ECG_CFG.general.nfft;
localConfig.powerLineFc             = configProvider.ECG_CFG.filters.power.freq;
localConfig.powerLineWinlen         = configProvider.ECG_CFG.filters.power.win;
localConfig.powerLineHighBinLevel   = configProvider.ECG_CFG.filters.power.highBinLvl;

%% Core code
switch(dataType)
    case 'ECG',
        satPerc = checkSaturation(rawData, localConfig.saturationLevel); % Make sure not to use the filtered data, because saturation is translated into '0' mainly after high-pass filtering
        satExclude = satPerc>localConfig.maxSatPerc;
        filtData(satExclude, :) = nan;
        nanPerc = checkNaN(filtData); % make sure to use the filtered data, so the nans will be excluded from the data-to-be processed
        nanExclude = nanPerc>localConfig.maxNaNPerc;
        %filtData(nanExclude, :) = []; % remove NaN channels
        filtData(nanExclude, :) = nan; % remove NaN channels
        chnlInclude = ~nanExclude;
        if(any(chnlInclude))
            closestElectrode = analyzeEnergy(filtData, localConfig);
        else
            closestElectrode = -1;
        end
        
    case 'MIC',
        error('Not implemented.');
        
    case 'ECG_AUTO', % ECG files that have been run automatically
        nNumOfChannels = size(rawData, 1);
        L = size(rawData, 2);
        
        for i=1:nNumOfChannels-1
            satInds = [satInds; struct('inds', zeros(1, 100))];
        end
        
        for i=1:nNumOfChannels
            satInds(i).inds = find(abs(rawData(i, :)) >= localConfig.binSatPerc*localConfig.saturationLevel);
            exclude.sat = [exclude.sat length(satInds(i).inds) > 0.5*L];
        end
        
        DFT = fft(rawData', localConfig.nfft);
        freqs = (localConfig.Fs/2)*linspace(0, 1, localConfig.nfft/2+1);
        DFT = 2*abs(DFT(1:localConfig.nfft/2+1, :));
        tremp = DFT(freqs<(localConfig.powerLineFc + localConfig.powerLineWinlen) & freqs>(localConfig.powerLineFc - localConfig.powerLineWinlen), :);
        if(isempty(tremp))
            tremp = DFT(freqs<(localConfig.powerLineFc + 2*localConfig.powerLineWinlen) & freqs>(localConfig.powerLineFc - 2*localConfig.powerLineWinlen), :);
        end
        
        if(min(size(tremp))>1)
            tremp = mean(tremp);
        end
        
        powerLine = tremp./(sum(DFT(freqs<100 & freqs>5, :)));
        
        % It is more important to check if the 50Hz is wide and not only the amplitude of the peak, needs to be implemented
        exclude.pwr = powerLine>localConfig.powerLineHighBinLevel; % These channles have a lot of 50Hz, the attachement of this sensors is bad!!
        
        chnlInclude = ~(exclude.pwr | exclude.sat);
        
end

