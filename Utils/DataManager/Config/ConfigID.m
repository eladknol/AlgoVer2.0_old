function configID = ConfigID()

% Configuration ID enumertation
i = int32(-1);
%% General

i=i+1; configID.NONE = i;
i=i+1; configID.ERROR_CODES = i;
i=i+1; configID.SAMPLERATE = i;
i=i+1; configID.SATURATIONLEVEL = i;
i=i+1; configID.CHANNELSTYPES = i;
i=i+1; configID.NUMOFCHANNELS = i;

%% Environment
i=i+1; configID.TBX_USEPAR = i;
i=i+1; configID.TBX_USESTATS = i;

%% ECG
% General
i=i+1; configID.ECG_CHANNELS = i;
i=i+1; configID.ECG_NUM_CHANNELS = i;
i=i+1; configID.ECG_NUM_ACTIVE_CHANNELS = i;
i=i+1; configID.ECG_MAX_SAT_PERC = i;
i=i+1; configID.ECG_BIN_SAT_PERC = i;
i=i+1; configID.ECG_MAX_NAN_PERC = i;
i=i+1; configID.ECG_MAX_PRED_MHR = i;
i=i+1; configID.ECG_NFFT = i;
i=i+1; configID.ECG_PROC_TYPE = i;

% Filters
i=i+1; configID.ECG_FILTERS_ALL = i;
i=i+1; configID.ECG_FILTERS_POWER_FC = i;
i=i+1; configID.ECG_FILTERS_POWER_WINLEN = i;
i=i+1; configID.ECG_FILTERS_POWER_HIGHBINLVL = i;

% mQRS detection
i=i+1; configID.ECG_MQRS_ALL = i;
i=i+1; configID.ECG_MQRS_MAX_PRED_MHR = i;
i=i+1; configID.ECG_MQRS_MIN_PRED_MHR = i;
i=i+1; configID.ECG_MQRS_REL_MPEAKS_ENRGY = i;
i=i+1; configID.ECG_MQRS_MIN_MCORR_COEF = i;
i=i+1; configID.ECG_MQRS_MIN_PEAK_H = i;

% mTwave detection
i=i+1; configID.ECG_MTWAVE_ALL = i;

% mECG elimination
i=i+1; configID.ECG_MECG_ALL = i;
i=i+1; configID.ECG_MECG_MIN_MCORR_COEF = i;
i=i+1; configID.ECG_MECG_RESAMP_FREQ = i;
i=i+1; configID.ECG_MECG_CLT = i;
i=i+1; configID.ECG_MECG_INCLUD_CORR_COEFF = i;
i=i+1; configID.ECG_MECG_INCLUD_NUM_BEATS = i;
i=i+1; configID.ECG_MECG_INCLUD_BOUNDS = i;
i=i+1; configID.ECG_MECG_INCLUD_THRESH = i;
i=i+1; configID.ECG_MECG_LMA_ALL = i;
i=i+1; configID.ECG_MECG_PST_PRC_FET_SMTH = i;

% fQRS detection
i=i+1; configID.ECG_FQRS_ALL = i;
i=i+1; configID.ECG_FECG_PRE_PRC_ICA_ALL = i;
i=i+1; configID.ECG_FECG_PRE_PRC_ALL = i;


%% MIC

i=i+1; ME = i;