classdef ConfigProvider_class
    %% CONFIGPROVIDER Configurations provider for AlgoV1.0
    %%
    %  This class takes care of the configurations and parameters needed during the execution of the AlgoV1.0
    %  Usage example:
    %%
    %
    %   configProvider = ConfigProvider(); % Construct the class
    %   oldFs = 1000;
    %   configProvider = configProvider.initiate('', oldFs); % Can be used also as: initiate(configProvider, '', oldFs);
    %   configProvider = configProvider.setConfigVal(configProvider.getConfigID('fs'), 1800); % Change the sample rate
    %   newFs = configProvider.getConfigVal(configProvider.getConfigID('fs')); % get the new sample rate
    %   disp(['The old sample rate is: ' num2str(oldFs)]);
    %   disp(['The new sample rate is: ' num2str(newFs)]);
    
    
    properties (SetAccess = private, GetAccess = private)
        GEN_CFG;
        ECG_CFG;
        MIC_CFG;
    end
    
    methods (Access = public)
        %% Initiate the configProvider class
        %%
        %  ConfigProvider = initiate(configFileName, sampleRate)
        %       Initiates the configurationProvider class. This method must be called before the class can be used.
        %           Inputs:
        %               configFileName: file name of a saved version of the configurations. Leave empty if not relevant
        %               sampleRate: the sample rate of the data. If not specefied, a default value of 1kSPS is used (1000Hz)
        %           Outputs:
        %               ConfigProvider: initiated configProvider class.
        %           Note: You must request the class as an output to get the initiated class (unlike C++, Java classes)
        %
        function ConfigProvider = initiate(ConfigProvider, configFileName, sampleRate)
            
            if(nargin<2)
                configFileName = '';
                sampleRate = 1000;
            end
            
            if(nargin<3)
                sampleRate = 1000;
            end
            
            useDefault = 0;
            
            if(~isempty(configFileName))
                % load config file
            else
                % saved config is not available, use default values for the initiation
                useDefault = 1;
            end
            
            if(useDefault)
                ConfigProvider.GEN_CFG = getGENconfig(ConfigProvider, sampleRate);
                ConfigProvider.ECG_CFG = getECGconfig(ConfigProvider, sampleRate);
                %ConfigProvider.MIC_CFG = getMICconfig(ConfigProvider, sampleRate); % Uncomment when MIC config is ready
            end
            
        end
        
        %% Get a configuration ID
        %%
        %  ID = getConfigID(inputString)
        %       Get a specific configuraion ID
        %           Inputs:
        %               inputString: an input strin which relates to a specific configuration
        %           Outputs:
        %               ID: An auto enumerated ID, see the ConfigID class for more info.
        %
        function ID = getConfigID(ConfigProvider, inputString)
            
            switch(lower(inputString)) %#ok<MFAMB>
                case {'error', 'errorcodes'},
                    ID = ConfigID.ERROR_CODES;
                case {'samplerate', 'fs', 'samplingrate'},
                    ID = ConfigID.SAMPLERATE;
                case {'saturation', 'saturationlevel', 'satlevel', 'satlvl'},
                    ID = ConfigID.SATURATIONLEVEL;
                case {'channeltype', 'channelstype', 'channelstypes', 'channeltypes'},
                    ID = ConfigID.CHANNELSTYPES;
                case {'numofchs', 'numberofchannels', 'nnumofchannels', 'nnumofchs'},
                    ID = ConfigID.NUMOFCHANNELS;
                case {'usepar', 'useparallel', 'parallel'},
                    ID = ConfigID.TBX_USEPAR;
                case {'usestat', 'usestatistics', 'stats'},
                    ID = ConfigID.TBX_USESTATS;
                case {'ecgchannels'},
                    ID = ConfigID.ECG_CHANNELS;
                case {'numecgchannels'},
                    ID = ConfigID.ECG_NUM_CHANNELS;
                case {'numactiveecgchannels'},
                    ID = ConfigID.ECG_NUM_ACTIVE_CHANNELS;
                case {'maxsatperc', 'maxsat', 'maximumsaturationlevel'},
                    ID = ConfigID.ECG_MAX_SAT_PERC;
                case {'binsatperc'},
                    ID = ConfigID.ECG_BIN_SAT_PERC;
                case {'maxnanperc', 'maxnan', 'maximumnanpercent'},
                    ID = ConfigID.ECG_MAX_NAN_PERC;
                case {'maxmhr', 'maxpredmhr', 'maximummaternalheartrate', 'maxpredmathr'},
                    ID = ConfigID.ECG_MAX_PRED_MHR;
                case {'nfft'},
                    ID = ConfigID.ECG_NFFT;
                case {'proctype', 'processingtype'},
                    ID = ConfigID.ECG_PROC_TYPE;
                case {'ecgfiltsall'},
                    ID = ConfigID.ECG_FILTERS_ALL;
                case {'powerlinefc', 'powerlinefreq', '50hz'},
                    ID = ConfigID.ECG_FILTERS_POWER_FC;
                case {'powerlinewinlen', 'powerlinewin'},
                    ID = ConfigID.ECG_FILTERS_POWER_WINLEN;
                case {'powerlinebinlevel', 'powerlinehighbin', 'powerlinehighbinlevel'},
                    ID = ConfigID.ECG_FILTERS_POWER_HIGHBINLVL;
                case {'mqrsdetectionall'},
                    ID = ConfigID.ECG_MQRS_ALL;
                case {'mtwavedetectionall'},
                    ID = ConfigID.ECG_MTWAVE_ALL;
                case {'maxpredmaternalhr'},
                    ID = ConfigID.ECG_MQRS_MAX_PRED_MHR;
                case {'minpredmaternalhr'},
                    ID = ConfigID.ECG_MQRS_MIN_PRED_MHR;
                case {'relmaternalpeaksenergy'},
                    ID = ConfigID.ECG_MQRS_REL_MPEAKS_ENRGY;
                case {'minmaternalcorrcoef'},
                    ID = ConfigID.ECG_MQRS_MIN_MCORR_COEF;
                case {'minPeakHeight'},
                    ID = ConfigID.ECG_MQRS_MIN_PEAK_H;
                case {'mecgeliminationall'},
                    ID = ConfigID.ECG_MECG_ALL;
                case {'maxpredmaternalhrforelim'},
                    ID = ConfigID.ECG_MECG_MIN_MCORR_COEF;
                case {'resamplefreq', 'resmapfreq'},
                    ID = ConfigID.ECG_MECG_RESAMP_FREQ;
                case {'curvelength', 'qrsonsetoffset'},
                    ID = ConfigID.ECG_MECG_CLT;
                case {'corrcoeffinclude'}
                    ID = ConfigID.ECG_MECG_INCLUD_CORR_COEFF;
                case {'numbeatsinclude'}
                    ID = ConfigID.ECG_MECG_INCLUD_NUM_BEATS;
                case {'includebounds'}
                    ID = ConfigID.ECG_MECG_INCLUD_BOUNDS;
                case {'includethresh'}
                    ID = ConfigID.ECG_MECG_INCLUD_THRESH;
                case {'fetsmoothorder'}
                    ID = ConfigID.ECG_MECG_PST_PRC_FET_SMTH;
                case {'lma'},
                    ID = ConfigID.ECG_MECG_LMA_ALL;
                case {'fecgicaall', 'fecgpreprocicaall'},
                    ID = ConfigID.ECG_FECG_PRE_PRC_ICA_ALL;
                case {'fecgall', 'fecgpreprocall'},
                    ID = ConfigID.ECG_FECG_PRE_PRC_ALL;
                case {'fqrsdetectionall'},
                    ID = ConfigID.ECG_FQRS_ALL;
                    
                otherwise,
                    ID = ConfigID.NONE;
            end
        end
        
        %% Get a configuration value
        %%
        %  configVal = getConfigVal(unqID)
        %       Get a specific configuraion value
        %           Inputs:
        %               unqID: An auto enumerated ID obtained by calling getConfigID(...)
        %           Outputs:
        %               configVal: the requested configuration value
        %
        function configVal = getConfigVal(ConfigProvider, unqID)
            if(unqID == ConfigID.NONE)
                configVal = [];
                return;
            end
            
            switch(unqID)
                case ConfigID.ERROR_CODES,
                    configVal = ConfigProvider.GEN_CFG.errorCodes;
                case ConfigID.SAMPLERATE,
                    configVal = ConfigProvider.GEN_CFG.sampleRate;
                case ConfigID.SATURATIONLEVEL,
                    configVal = ConfigProvider.GEN_CFG.satLevel;
                case ConfigID.CHANNELSTYPES,
                    configVal = ConfigProvider.GEN_CFG.channelType;
                case ConfigID.NUMOFCHANNELS,
                    configVal = ConfigProvider.GEN_CFG.nNumOfChannels;
                case ConfigID.TBX_USEPAR,
                    configVal = ConfigProvider.GEN_CFG.usePar;
                case ConfigID.TBX_USESTATS,
                    configVal = ConfigProvider.GEN_CFG.useStats;
                case ConfigID.ECG_CHANNELS,
                    configVal = ConfigProvider.ECG_CFG.general.ECGChs;
                case ConfigID.ECG_NUM_CHANNELS,
                    configVal = ConfigProvider.ECG_CFG.general.nNumOfChs;
                case ConfigID.ECG_NUM_ACTIVE_CHANNELS,
                    configVal = ConfigProvider.ECG_CFG.general.nNumOfActiveChs;
                case ConfigID.ECG_MAX_SAT_PERC
                    configVal = ConfigProvider.ECG_CFG.general.maxSatPerc;
                case ConfigID.ECG_BIN_SAT_PERC
                    configVal = ConfigProvider.ECG_CFG.general.binSatPerc;
                case ConfigID.ECG_MAX_NAN_PERC
                    configVal = ConfigProvider.ECG_CFG.general.maxNaNPerc;
                case ConfigID.ECG_MAX_PRED_MHR
                    configVal = ConfigProvider.ECG_CFG.general.maxPredMHR;
                case ConfigID.ECG_NFFT
                    configVal = ConfigProvider.ECG_CFG.general.nfft;
                case ConfigID.ECG_PROC_TYPE
                    configVal = ConfigProvider.ECG_CFG.general.procType;
                case ConfigID.ECG_FILTERS_ALL
                    configVal = ConfigProvider.getECGFilts();
                case ConfigID.ECG_FILTERS_POWER_FC
                    configVal = ConfigProvider.ECG_CFG.filters.power.freq;
                case ConfigID.ECG_FILTERS_POWER_WINLEN
                    configVal = ConfigProvider.ECG_CFG.filters.power.win;
                case ConfigID.ECG_FILTERS_POWER_HIGHBINLVL
                    configVal = ConfigProvider.ECG_CFG.filters.power.highBinLvl;
                case ConfigID.ECG_MQRS_ALL
                    configVal = ConfigProvider.ECG_CFG.mQRS;
                case ConfigID.ECG_MTWAVE_ALL
                    configVal = ConfigProvider.ECG_CFG.mTwave;
                case ConfigID.ECG_MQRS_MAX_PRED_MHR
                    configVal = ConfigProvider.ECG_CFG.mQRS.maxPredMaternalHR;
                case ConfigID.ECG_MQRS_MIN_PRED_MHR
                    configVal = ConfigProvider.ECG_CFG.mQRS.minPredMaternalHR;
                case ConfigID.ECG_MQRS_REL_MPEAKS_ENRGY
                    configVal = ConfigProvider.ECG_CFG.mQRS.relMaternalPeaksEnergy;
                case ConfigID.ECG_MQRS_MIN_MCORR_COEF
                    configVal = ConfigProvider.ECG_CFG.mQRS.minMaternalCorrCoef;
                case ConfigID.ECG_MQRS_MIN_PEAK_H
                    configVal = ConfigProvider.ECG_CFG.mQRS.minPeakHeight;
                case ConfigID.ECG_MECG_ALL
                    configVal = ConfigProvider.ECG_CFG.mECG;
                case ConfigID.ECG_MECG_MIN_MCORR_COEF
                    configVal = ConfigProvider.ECG_CFG.mECG.minMaternalCorrCoef;
                case ConfigID.ECG_MECG_RESAMP_FREQ
                    configVal = ConfigProvider.ECG_CFG.mECG.resampleFreq;
                case ConfigID.ECG_MECG_CLT
                    configVal = ConfigProvider.ECG_CFG.mECG.CLT;
                case ConfigID.ECG_MECG_INCLUD_CORR_COEFF
                    configVal = ConfigProvider.ECG_CFG.mECG.incCorrCoef;
                case ConfigID.ECG_MECG_INCLUD_NUM_BEATS
                    configVal = ConfigProvider.ECG_CFG.mECG.incNumBeats;
                case ConfigID.ECG_MECG_INCLUD_BOUNDS
                    configVal = ConfigProvider.ECG_CFG.mECG.incBounds;
                case ConfigID.ECG_MECG_INCLUD_THRESH
                    configVal = ConfigProvider.ECG_CFG.mECG.incThresh;
                case ConfigID.ECG_MECG_PST_PRC_FET_SMTH
                    configVal = ConfigProvider.ECG_CFG.mECG.fetSmoothOrder;
                case ConfigID.ECG_MECG_LMA_ALL
                    configVal = ConfigProvider.ECG_CFG.mECG.LMA;
                case ConfigID.ECG_FECG_PRE_PRC_ICA_ALL
                    configVal = ConfigProvider.ECG_CFG.fECG.ICA;
                case ConfigID.ECG_FECG_PRE_PRC_ALL
                    configVal = ConfigProvider.ECG_CFG.fECG.Gen;
                case ConfigID.ECG_FQRS_ALL
                    configVal = ConfigProvider.ECG_CFG.fQRS;
                otherwise,
                    configVal = [];
            end
            
        end
        
        %% Set a configuration value
        %%
        %  [ConfigProvider, succ] = setConfigVal(unqID, configVal)
        %       Set a specific configuraion value
        %           Inputs:
        %               unqID: An auto enumerated ID obtained by calling getConfigID(...)
        %               configVal: configuration value to save
        %           Outputs:
        %               ConfigProvider: updated configProvider class.
        %               succ: a boolean that is true if the class was updated. It is false if the specified unqID is not supported
        %           Note 1: You must request the class as an output to get the initiated class (unlike C++, Java classes)
        %           Note 2: the setter in this class does not perform input checking, you must do that before invoking the setter
        %
        function [ConfigProvider, succ] = setConfigVal(ConfigProvider, unqID, configVal)
            succ = 0;
            if(unqID == ConfigID.NONE)
                return;
            end
            succ = 1;
            switch(unqID)
                case ConfigID.SAMPLERATE,
                    ConfigProvider.GEN_CFG.sampleRate = configVal;
                case ConfigID.SATURATIONLEVEL,
                    ConfigProvider.GEN_CFG.satLevel = configVal;
                case ConfigID.CHANNELSTYPES,
                    ConfigProvider.GEN_CFG.channelType = configVal;
                    % CODER REMOVE
                    %[ConfigProvider, succ] = setConfigVal(ConfigProvider, ConfigProvider.getConfigID('nNumOfChannels'), length(ConfigProvider.GEN_CFG.channelType));
                    %[ConfigProvider, succ] = setConfigVal(ConfigProvider, ConfigProvider.getConfigID('ecgchannels'), getChannelsByType(ConfigProvider, 'ECG'));
                case ConfigID.NUMOFCHANNELS
                    ConfigProvider.GEN_CFG.nNumOfChannels = configVal;
                case ConfigID.TBX_USEPAR,
                    ConfigProvider.GEN_CFG.usePar = configVal;
                case ConfigID.TBX_USESTATS,
                    ConfigProvider.GEN_CFG.useStats = configVal;
                case ConfigID.ECG_CHANNELS
                    ConfigProvider.ECG_CFG.general.ECGChs = configVal;
                    % CODER REMOVE
                    %[ConfigProvider, succ] = setConfigVal(ConfigProvider, ConfigProvider.getConfigID('numecgchannels'), length(configVal));
                case ConfigID.ECG_NUM_CHANNELS,
                    ConfigProvider.ECG_CFG.general.nNumOfChs = configVal;
                case ConfigID.ECG_NUM_ACTIVE_CHANNELS,
                    ConfigProvider.ECG_CFG.general.nNumOfActiveChs = configVal;
                    % CODER REMOVE
                    %[ConfigProvider, succ] = setConfigVal(ConfigProvider, ConfigProvider.getConfigID('usepar'), runPar(configVal, 2));
                case ConfigID.ECG_MAX_SAT_PERC
                    ConfigProvider.ECG_CFG.general.maxSatPerc = configVal;
                case ConfigID.ECG_BIN_SAT_PERC
                    ConfigProvider.ECG_CFG.general.binSatPerc = configVal;
                case ConfigID.ECG_MAX_NAN_PERC
                    ConfigProvider.ECG_CFG.general.maxNaNPerc = configVal;
                case ConfigID.ECG_MAX_PRED_MHR
                    ConfigProvider.ECG_CFG.general.maxPredMHR = configVal;
                    ConfigProvider.ECG_CFG.mQRS.maxPredMaternalHR = configVal;
                case ConfigID.ECG_NFFT
                    ConfigProvider.ECG_CFG.general.nfft = configVal;
                case ConfigID.ECG_PROC_TYPE
                    ConfigProvider.ECG_CFG.general.procType = configVal;
                case ConfigID.ECG_FILTERS_POWER_FC
                    ConfigProvider.ECG_CFG.filters.power.fc = configVal;
                case ConfigID.ECG_FILTERS_POWER_WINLEN
                    ConfigProvider.ECG_CFG.filters.power.win = configVal;
                case ConfigID.ECG_FILTERS_POWER_HIGHBINLVL
                    ConfigProvider.ECG_CFG.filters.power.highBinLvl = configVal;
                case ConfigID.ECG_MQRS_ALL
                    ConfigProvider.ECG_CFG.mQRS = configVal;
                case ConfigID.ECG_MTWAVE_ALL
                    ConfigProvider.ECG_CFG.mTwave = configVal;
                case ConfigID.ECG_MQRS_MAX_PRED_MHR
                    ConfigProvider.ECG_CFG.mQRS.maxPredMaternalHR = configVal;
                    ConfigProvider.ECG_CFG.general.maxPredMHR = configVal;
                case ConfigID.ECG_MQRS_MIN_PRED_MHR
                    ConfigProvider.ECG_CFG.mQRS.minPredMaternalHR = configVal;
                case ConfigID.ECG_MQRS_REL_MPEAKS_ENRGY
                    ConfigProvider.ECG_CFG.mQRS.relMaternalPeaksEnergy = configVal;
                case ConfigID.ECG_MQRS_MIN_MCORR_COEF
                    ConfigProvider.ECG_CFG.mQRS.minMaternalCorrCoef = configVal;
                case ConfigID.ECG_MQRS_MIN_PEAK_H
                    ConfigProvider.ECG_CFG.mQRS.minPeakHeight = configVal;
                case ConfigID.ECG_MECG_MIN_MCORR_COEF
                    ConfigProvider.ECG_CFG.mECG.minMaternalCorrCoef = configVal;
                case ConfigID.ECG_MECG_RESAMP_FREQ
                    ConfigProvider.ECG_CFG.mECG.resampleFreq = configVal;
                case ConfigID.ECG_MECG_CLT
                    ConfigProvider.ECG_CFG.mECG.CLT = configVal;
                case ConfigID.ECG_MECG_INCLUD_CORR_COEFF
                    ConfigProvider.ECG_CFG.mECG.incCorrCoef = configVal;
                case ConfigID.ECG_MECG_INCLUD_NUM_BEATS
                    ConfigProvider.ECG_CFG.mECG.incNumBeats = configVal;
                case ConfigID.ECG_MECG_INCLUD_BOUNDS
                    ConfigProvider.ECG_CFG.mECG.incBounds = configVal;
                case ConfigID.ECG_MECG_INCLUD_THRESH
                    ConfigProvider.ECG_CFG.mECG.incThresh = configVal;
                case ConfigID.ECG_MECG_PST_PRC_FET_SMTH
                    ConfigProvider.ECG_CFG.mECG.fetSmoothOrder = configVal;
                case ConfigID.ECG_MECG_LMA_ALL
                    ConfigProvider.ECG_CFG.mECG.LMA = configVal;
                case ConfigID.ECG_FECG_PRE_PRC_ICA_ALL
                    ConfigProvider.ECG_CFG.fECG.ICA = configVal;
                case ConfigID.ECG_FECG_PRE_PRC_ALL
                    ConfigProvider.ECG_CFG.fECG.Gen = configVal;
                case ConfigID.ECG_FQRS_ALL
                    ConfigProvider.ECG_CFG.fQRS = configVal;
                otherwise,
                    succ = 0;
            end
            
        end
        
        %% Get Channels By Type
        %%
        %  chInds = getChannelsByType(inChType)
        %       Get the indices of all the channels with a specific type
        %           Inputs:
        %               inChType: input string of the needed type ('ECG', 'MIC', ...)
        %           Outputs:
        %               chInds: Linear indices of the channels with the requested cahnnel type. Empty of there is no channels with the
        %               requested type
        %
        function chInds = getChannelsByType(ConfigProvider, inChType)
            chInds = [];
            for iCh=1:ConfigProvider.GEN_CFG.nNumOfChannels
                %if(strcmpi(ConfigProvider.GEN_CFG.channelType{iCh}, inChType))
                if(strcmpi(ConfigProvider.GEN_CFG.channelType(iCh).value, inChType))
                    chInds = [chInds iCh];
                end
            end
        end
    end
    
    methods (Access = private)
        
        % General configuration - default values
        function gen_cfg = getGENconfig(ConfigProvider, sampleRate)
            % Signal params
            gen_cfg.sampleRate = sampleRate;
            gen_cfg.satLevel = 10;
            
            temp = ['ECG'; 'ECG'; 'ECG'; 'ECG'; 'ECG'; 'ECG'; 'MIC'; 'MIC'; 'MIC'; 'MIC'];
            gen_cfg.nNumOfChannels = 10;
            for i=1:gen_cfg.nNumOfChannels
                gen_cfg.channelType(i).value = temp(i,:);
            end
            % env params
            gen_cfg.usePar = 1;
            gen_cfg.useStats = 1;
            
            % Error handling
            gen_cfg.errorCodes = getErrorCodes();
        end
        
        % fECG configuration
        function ecg_cfg = getECGconfig(ConfigProvider, sampleRate)
            
            % --- General ---
            ecg_cfg.general.ECGChs = 1:6;
            ecg_cfg.general.nNumOfChs = length(ecg_cfg.general.ECGChs);
            ecg_cfg.general.nNumOfActiveChs = length(ecg_cfg.general.ECGChs);
            
            ecg_cfg.general.maxSatPerc = 10; % %
            ecg_cfg.general.binSatPerc = 0.98;
            ecg_cfg.general.maxNaNPerc = 10; % %
            ecg_cfg.general.maxPredMHR = 220-30;
            ecg_cfg.general.nfft = 1024;
            ecg_cfg.general.procType = 'maternal';
            
            % --- Filters ---
            ecg_cfg.filters.Fs = sampleRate;
            % Low pass filter
            ecg_cfg.filters.low.active = 1;
            ecg_cfg.filters.low.fc = 70;
            ecg_cfg.filters.low.order = 12;
            % High pass filter
            ecg_cfg.filters.high.active = 0;
            ecg_cfg.filters.high.fc = 2;
            ecg_cfg.filters.high.order = 5;
            % MA filter
            ecg_cfg.filters.ma.active = 1;
            ecg_cfg.filters.ma.len = round(501/1000 * sampleRate);
            % Median filter
            ecg_cfg.filters.median.active = 0;
            ecg_cfg.filters.median.len = round(100/1000 * sampleRate);
            % Power line filter
            ecg_cfg.filters.power.active = 1;
            ecg_cfg.filters.power.win = 0.5;
            ecg_cfg.filters.power.order = 10;
            ecg_cfg.filters.power.freq = 50;
            ecg_cfg.filters.power.highBinLvl = 0.2;
            
            % --- mQRS detection ---
            ecg_cfg.mQRS.maxPredMaternalHR = ecg_cfg.general.maxPredMHR;
            ecg_cfg.mQRS.minPredMaternalHR = 40;
            ecg_cfg.mQRS.relMaternalPeaksEnergy = 0.8;
            ecg_cfg.mQRS.minMaternalCorrCoef = 0.8;
            ecg_cfg.mQRS.minPeakHeight = 0.15;
            ecg_cfg.mQRS.analWinLen = 10; % seconds
            
            % --- mTwave detection ---
            ecg_cfg.mTwave.filters.low.Fc = 20; % Hz
            ecg_cfg.mTwave.filters.low.Order = 12; % seconds
            
            % --- mECG elimination ---
            ecg_cfg.mECG.minMaternalCorrCoef = 0.8;
            ecg_cfg.mECG.resampleFreq = 4e3;
            ecg_cfg.mECG.CLT.filter.type = 'bandpass';
            ecg_cfg.mECG.CLT.filter.order = 100;
            ecg_cfg.mECG.CLT.filter.fc = [5, 20];
            ecg_cfg.mECG.CLT.filter.winsize = 100;
            ecg_cfg.mECG.incCorrCoef = 0.98;
            ecg_cfg.mECG.incNumBeats = 10;
            ecg_cfg.mECG.incBounds = 50;
            ecg_cfg.mECG.incThresh = 0.5;
            ecg_cfg.mECG.fetSmoothOrder = 5;
            
            ecg_cfg.mECG.LMA.QRSMultCorct = 1.05;
            ecg_cfg.mECG.LMA.initE = 1e7;
            ecg_cfg.mECG.LMA.dR = 1;
            ecg_cfg.mECG.LMA.lambda = 0.001;
            ecg_cfg.mECG.LMA.maxIti = 15;
            ecg_cfg.mECG.LMA.corctP1 = 10;
            ecg_cfg.mECG.LMA.corctP2 = 10;
            ecg_cfg.mECG.LMA.jacbDelta = 0.05;
            ecg_cfg.mECG.LMA.multsSmoother = 15;
            
            ecg_cfg.fECG.ICA.nonLin = 'tanh';
            ecg_cfg.fECG.Gen.RMSWinLen = 100;
            ecg_cfg.fECG.Gen.maLength = 50;
            
            
            ecg_cfg.fQRS.relFetalPeaksEnergy = 0.4;
            ecg_cfg.fQRS.minPredFetalHR = 80;
            ecg_cfg.fQRS.maxPredFetalHR = 200;
            ecg_cfg.fQRS.analWinLen = 10; % seconds
            ecg_cfg.fQRS.peak2Mean.winLen = 100;
            ecg_cfg.fQRS.peak2Mean.smoothWinLen = 15;
            ecg_cfg.fQRS.peak2Mean.peakDetection.minPeakHeight = 0.2;
            ecg_cfg.fQRS.peak2Mean.peakDetection.kmed_nG = 3;
            ecg_cfg.fQRS.peak2Mean.peakDetection.susRRThresh = 30;
            ecg_cfg.fQRS.peak2Mean.peakDetection.xcorr_rms_winLen = 100;
            ecg_cfg.fQRS.peak2Mean.peakDetection.xcorr_MA_winLen = 50;
            ecg_cfg.fQRS.peak2Mean.peakDetection.peakRMSThresh = 10;
            ecg_cfg.fQRS.peak2Mean.peakDetection.RMSRel = [2.5, 0.25];
            ecg_cfg.fQRS.extnddAnalss.filters.low.fc = 70;
            ecg_cfg.fQRS.extnddAnalss.filters.low.order = 8;
            ecg_cfg.fQRS.extnddAnalss.filters.high.fc = 15;
            ecg_cfg.fQRS.extnddAnalss.filters.high.order = 7;
            ecg_cfg.fQRS.extnddAnalss.filters.ma.winLen = 500;
            ecg_cfg.fQRS.extnddAnalss.wavelet.rms_winLen = 50;
            ecg_cfg.fQRS.extnddAnalss.wavelet.filters.low.fc = 35;
            ecg_cfg.fQRS.extnddAnalss.wavelet.filters.low.order = 8;
            ecg_cfg.fQRS.extnddAnalss.wavelet.initHR = 171;
            ecg_cfg.fQRS.extnddAnalss.wavelet.AGCSmoothWinLen = 15;
            ecg_cfg.fQRS.peakDetection.minPeakDist = round(20/1000*sampleRate);
            ecg_cfg.fQRS.peakDetection.minPeakH = 0.4;
            ecg_cfg.fQRS.peakExamination.maxFetalRRInterSTD = 20;
            ecg_cfg.fQRS.peakExamination.goodSegPeaks = 5;
            ecg_cfg.fQRS.peakExamination.FHRSTDV = 0.5;
            ecg_cfg.fQRS.peakExamination.minAccShift = round(40/1000*sampleRate);
            ecg_cfg.fQRS.peakExamination.minAccCorrCoeff = 0.6;
            ecg_cfg.fQRS.peakExamination.beatMult = 2;
            ecg_cfg.fQRS.peakExamination.timeSeries.maLength = 13;
            ecg_cfg.fQRS.peakExamination.scoring.goodSegPeaks = 5;
            ecg_cfg.fQRS.peakExamination.scoring.minPeakHeight = 0.8;
            ecg_cfg.fQRS.peakExamination.scoring.minPeakHeightUpdate = 0.9;
            ecg_cfg.fQRS.peakExamination.scoring.maxIti = 5;
            ecg_cfg.fQRS.peakExamination.scoring.closePerc = 10;
            ecg_cfg.fQRS.peakExamination.scoring.minAccCorrCoeff = 0.8;
            ecg_cfg.fQRS.nonLin = ecg_cfg.fECG.ICA.nonLin;
            
        end
        
        function ecg_filts = getECGFilts(ConfigProvider)
            ecg_filts = ConfigProvider.ECG_CFG.filters;
        end
        
    end
    
end

