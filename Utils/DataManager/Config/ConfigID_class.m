classdef ConfigID_class    
    enumeration
        %% General
        NONE,
        ERROR_CODES,
        SAMPLERATE,
        SATURATIONLEVEL,
        CHANNELSTYPES,
        NUMOFCHANNELS,
        
        %% Environment
        TBX_USEPAR,
        TBX_USESTATS,
        
        %% ECG
        % General
        ECG_CHANNELS,
        ECG_NUM_CHANNELS,
        ECG_NUM_ACTIVE_CHANNELS,
        ECG_MAX_SAT_PERC,
        ECG_BIN_SAT_PERC,
        ECG_MAX_NAN_PERC,
        ECG_MAX_PRED_MHR,
        ECG_NFFT,
        ECG_PROC_TYPE,
        
        % Filters
        ECG_FILTERS_ALL,
        ECG_FILTERS_POWER_FC,
        ECG_FILTERS_POWER_WINLEN,
        ECG_FILTERS_POWER_HIGHBINLVL,
        
        % mQRS detection
        ECG_MQRS_ALL,
        ECG_MQRS_MAX_PRED_MHR,
        ECG_MQRS_MIN_PRED_MHR,
        ECG_MQRS_REL_MPEAKS_ENRGY,
        ECG_MQRS_MIN_MCORR_COEF,
        ECG_MQRS_MIN_PEAK_H,
        
        % mTwave detection
        ECG_MTWAVE_ALL,
        
        % mECG elimination
        ECG_MECG_ALL,
        ECG_MECG_MIN_MCORR_COEF,
        ECG_MECG_RESAMP_FREQ,
        ECG_MECG_CLT,
        ECG_MECG_INCLUD_CORR_COEFF,
        ECG_MECG_INCLUD_NUM_BEATS,
        ECG_MECG_INCLUD_BOUNDS,
        ECG_MECG_INCLUD_THRESH,
        ECG_MECG_LMA_ALL,
        ECG_MECG_PST_PRC_FET_SMTH,
        
        % fQRS detection
        ECG_FQRS_ALL,
        ECG_FECG_PRE_PRC_ICA_ALL,
        ECG_FECG_PRE_PRC_ALL,
        
        
        %% MIC
        
        ME,
    end
end