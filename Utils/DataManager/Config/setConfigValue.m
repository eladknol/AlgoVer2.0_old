function [configProvider, succ] = setConfigValue(configProvider, unqID, configVal)

succ = 0;
configID = ConfigID();
if(unqID == configID.NONE)
    return;
end

succ = 1;
switch(unqID)
    case configID.SAMPLERATE,
        configProvider.GEN_CFG.sampleRate = configVal;
    case configID.SATURATIONLEVEL,
        configProvider.GEN_CFG.satLevel = configVal;
    case configID.CHANNELSTYPES,
        succ = 0;
        %configProvider.GEN_CFG.channelType = configVal;
        % CODER REMOVE
        %[ConfigProvider, succ] = setConfigVal(ConfigProvider, ConfigProvider.getConfigID('nNumOfChannels'), length(ConfigProvider.GEN_CFG.channelType));
        %[ConfigProvider, succ] = setConfigVal(ConfigProvider, ConfigProvider.getConfigID('ecgchannels'), getChannelsByType(ConfigProvider, 'ECG'));
    case configID.NUMOFCHANNELS
        configProvider.GEN_CFG.nNumOfChannels = configVal;
    case configID.TBX_USEPAR,
        configProvider.GEN_CFG.usePar = logical(configVal);
    case configID.TBX_USESTATS,
        configProvider.GEN_CFG.useStats = logical(configVal);
    case configID.ECG_CHANNELS
        configProvider.ECG_CFG.general.ECGChs = configVal;
        % CODER REMOVE
        %[ConfigProvider, succ] = setConfigVal(ConfigProvider, ConfigProvider.getConfigID('numecgchannels'), length(configVal));
    case configID.ECG_NUM_CHANNELS,
        configProvider.ECG_CFG.general.nNumOfChs = configVal;
    case configID.ECG_NUM_ACTIVE_CHANNELS,
        configProvider.ECG_CFG.general.nNumOfActiveChs = configVal;
        % CODER REMOVE
        %[ConfigProvider, succ] = setConfigVal(ConfigProvider, ConfigProvider.getConfigID('usepar'), runPar(configVal, 2));
    case configID.ECG_MAX_SAT_PERC
        configProvider.ECG_CFG.general.maxSatPerc = configVal;
    case configID.ECG_BIN_SAT_PERC
        configProvider.ECG_CFG.general.binSatPerc = configVal;
    case configID.ECG_MAX_NAN_PERC
        configProvider.ECG_CFG.general.maxNaNPerc = configVal;
    case configID.ECG_MAX_PRED_MHR
        configProvider.ECG_CFG.general.maxPredMHR = configVal;
        configProvider.ECG_CFG.mQRS.maxPredMaternalHR = configVal;
    case configID.ECG_NFFT
        configProvider.ECG_CFG.general.nfft = configVal;
    case configID.ECG_PROC_TYPE
        configProvider.ECG_CFG.general.procType = configVal;
    case configID.ECG_FILTERS_POWER_FC
        configProvider.ECG_CFG.filters.power.freq = configVal;
    case configID.ECG_FILTERS_POWER_WINLEN
        configProvider.ECG_CFG.filters.power.win = configVal;
    case configID.ECG_FILTERS_POWER_HIGHBINLVL
        configProvider.ECG_CFG.filters.power.highBinLvl = configVal;
    %case configID.ECG_MQRS_ALL
        %configProvider.ECG_CFG.mQRS = configVal;
    %case configID.ECG_MTWAVE_ALL
        %configProvider.ECG_CFG.mTwave = configVal;
    case configID.ECG_MQRS_MAX_PRED_MHR
        configProvider.ECG_CFG.mQRS.maxPredMaternalHR = configVal;
        configProvider.ECG_CFG.general.maxPredMHR = configVal;
    case configID.ECG_MQRS_MIN_PRED_MHR
        configProvider.ECG_CFG.mQRS.minPredMaternalHR = configVal;
    case configID.ECG_MQRS_REL_MPEAKS_ENRGY
        configProvider.ECG_CFG.mQRS.relMaternalPeaksEnergy = configVal;
    case configID.ECG_MQRS_MIN_MCORR_COEF
        configProvider.ECG_CFG.mQRS.minMaternalCorrCoef = configVal;
    case configID.ECG_MQRS_MIN_PEAK_H
        configProvider.ECG_CFG.mQRS.minPeakHeight = configVal;
    case configID.ECG_MECG_MIN_MCORR_COEF
        configProvider.ECG_CFG.mECG.minMaternalCorrCoef = configVal;
    case configID.ECG_MECG_RESAMP_FREQ
        configProvider.ECG_CFG.mECG.resampleFreq = configVal;
    %case configID.ECG_MECG_CLT
        %configProvider.ECG_CFG.mECG.CLT = configVal;
    case configID.ECG_MECG_INCLUD_CORR_COEFF
        configProvider.ECG_CFG.mECG.incCorrCoef = configVal;
    case configID.ECG_MECG_INCLUD_NUM_BEATS
        configProvider.ECG_CFG.mECG.incNumBeats = configVal;
    case configID.ECG_MECG_INCLUD_BOUNDS
        configProvider.ECG_CFG.mECG.incBounds = configVal;
    case configID.ECG_MECG_INCLUD_THRESH
        configProvider.ECG_CFG.mECG.incThresh = configVal;
    case configID.ECG_MECG_PST_PRC_FET_SMTH
        configProvider.ECG_CFG.mECG.fetSmoothOrder = configVal;
    %case configID.ECG_MECG_LMA_ALL
        %configProvider.ECG_CFG.mECG.LMA = configVal;
    %case configID.ECG_FECG_PRE_PRC_ICA_ALL
        %configProvider.ECG_CFG.fECG.ICA = configVal;
    %case configID.ECG_FECG_PRE_PRC_ALL
        %configProvider.ECG_CFG.fECG.Gen = configVal;
    %case configID.ECG_FQRS_ALL
        %configProvider.ECG_CFG.fQRS = configVal;
    otherwise,
        succ = 0;
end
