function ID = getConfigID(inputString)
%#codegen

configID = ConfigID();

switch(lower(inputString)) %#ok<MFAMB>
    case 'error',
        ID = configID.ERROR_CODES;
    case 'errorcodes',
        ID = configID.ERROR_CODES;
    case 'samplerate',
        ID = configID.SAMPLERATE;
    case 'fs',
        ID = configID.SAMPLERATE;
    case 'samplingrate',
        ID = configID.SAMPLERATE;
    case 'saturationlevel', 
        ID = configID.SATURATIONLEVEL;
    case 'satlevel',
        ID = configID.SATURATIONLEVEL;
    case 'channeltype',
        ID = configID.CHANNELSTYPES;
    case 'channelstype',
        ID = configID.CHANNELSTYPES;
    case 'channelstypes',
        ID = configID.CHANNELSTYPES;
    case 'channeltypes',
        ID = configID.CHANNELSTYPES;
    case 'numofchs',
    case 'numberofchannels',
        ID = configID.NUMOFCHANNELS;
    case 'nnumofchannels',
        ID = configID.NUMOFCHANNELS;
    case 'nnumofchs',
        ID = configID.NUMOFCHANNELS;
    case 'usepar', 
        ID = configID.TBX_USEPAR;
    case 'useparallel', 
        ID = configID.TBX_USEPAR;
    case 'parallel',
        ID = configID.TBX_USEPAR;
    case 'usestat', 
        ID = configID.TBX_USESTATS;
    case 'usestatistics', 
        ID = configID.TBX_USESTATS;
        case 'stats',
        ID = configID.TBX_USESTATS;
    case 'ecgchannels',
        ID = configID.ECG_CHANNELS;
    case 'numecgchannels',
        ID = configID.ECG_NUM_CHANNELS;
    case 'numactiveecgchannels',
        ID = configID.ECG_NUM_ACTIVE_CHANNELS;
    case 'maxsatperc', 
        ID = configID.ECG_MAX_SAT_PERC;
    case 'maxsat', 
        ID = configID.ECG_MAX_SAT_PERC;
    case 'maximumsaturationlevel',
        ID = configID.ECG_MAX_SAT_PERC;
    case 'binsatperc',
        ID = configID.ECG_BIN_SAT_PERC;
    case 'maxnanperc', 
        ID = configID.ECG_MAX_NAN_PERC;
    case 'maxnan', 
        ID = configID.ECG_MAX_NAN_PERC;
    case 'maximumnanpercent',
        ID = configID.ECG_MAX_NAN_PERC;
    case 'maxmhr', 
        ID = configID.ECG_MAX_PRED_MHR;
    case 'maxpredmhr', 
        ID = configID.ECG_MAX_PRED_MHR;
    case 'maximummaternalheartrate', 
        ID = configID.ECG_MAX_PRED_MHR;
    case 'maxpredmathr',
        ID = configID.ECG_MAX_PRED_MHR;
    case 'nfft',
        ID = configID.ECG_NFFT;
    case 'proctype',
        ID = configID.ECG_PROC_TYPE;
    case 'ecgfiltsall',
        ID = configID.ECG_FILTERS_ALL;
    case 'powerlinefc',
        ID = configID.ECG_FILTERS_POWER_FC;
    case 'powerlinefreq',
        ID = configID.ECG_FILTERS_POWER_FC;
    case 'powerlinewinlen', 
        ID = configID.ECG_FILTERS_POWER_WINLEN;
    case 'powerlinewin',
        ID = configID.ECG_FILTERS_POWER_WINLEN;
    case 'powerlinebinlevel', 
        ID = configID.ECG_FILTERS_POWER_HIGHBINLVL;
    case 'powerlinehighbin', 
        ID = configID.ECG_FILTERS_POWER_HIGHBINLVL;
    case 'powerlinehighbinlevel',
        ID = configID.ECG_FILTERS_POWER_HIGHBINLVL;
    case 'mqrsdetectionall',
        ID = configID.ECG_MQRS_ALL;
    case 'mtwavedetectionall',
        ID = configID.ECG_MTWAVE_ALL;
    case 'maxpredmaternalhr',
        ID = configID.ECG_MQRS_MAX_PRED_MHR;
    case 'minpredmaternalhr',
        ID = configID.ECG_MQRS_MIN_PRED_MHR;
    case 'relmaternalpeaksenergy',
        ID = configID.ECG_MQRS_REL_MPEAKS_ENRGY;
    case 'minmaternalcorrcoef',
        ID = configID.ECG_MQRS_MIN_MCORR_COEF;
    case 'minPeakHeight',
        ID = configID.ECG_MQRS_MIN_PEAK_H;
    case 'mecgeliminationall',
        ID = configID.ECG_MECG_ALL;
    case 'maxpredmaternalhrforelim',
        ID = configID.ECG_MECG_MIN_MCORR_COEF;
    case 'resamplefreq', 
        ID = configID.ECG_MECG_RESAMP_FREQ;
    case 'resmapfreq',
        ID = configID.ECG_MECG_RESAMP_FREQ;
    case 'curvelength', 
        ID = configID.ECG_MECG_CLT;
    case 'qrsonsetoffset',
        ID = configID.ECG_MECG_CLT;
    case 'corrcoeffinclude'
        ID = configID.ECG_MECG_INCLUD_CORR_COEFF;
    case 'numbeatsinclude'
        ID = configID.ECG_MECG_INCLUD_NUM_BEATS;
    case 'includebounds'
        ID = configID.ECG_MECG_INCLUD_BOUNDS;
    case 'includethresh'
        ID = configID.ECG_MECG_INCLUD_THRESH;
    case 'fetsmoothorder'
        ID = configID.ECG_MECG_PST_PRC_FET_SMTH;
    case 'lma',
        ID = configID.ECG_MECG_LMA_ALL;
    case 'fecgicaall', 
            ID = configID.ECG_FECG_PRE_PRC_ICA_ALL;
    case 'fecgpreprocicaall',
        ID = configID.ECG_FECG_PRE_PRC_ICA_ALL;
    case 'fecgall', 
        ID = configID.ECG_FECG_PRE_PRC_ALL;
    case 'fecgpreprocall',
        ID = configID.ECG_FECG_PRE_PRC_ALL;
    case 'fqrsdetectionall',
        ID = configID.ECG_FQRS_ALL;
        
    otherwise,
        ID = configID.NONE;
end
