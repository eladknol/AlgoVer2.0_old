function config = setMatDetectionConfig()
% Internal function, assumes inputs are valid!
% Detection configuration is divided into two main parts:
%       1. Maternal config
%       2. Fetal config

global configProvider;
% procType = getProcType(configProvider.ECG_CFG.general.procType);

config = configProvider.ECG_CFG.mQRS;
%% global config
config.Fs = configProvider.GEN_CFG.sampleRate;
config.procType = configProvider.ECG_CFG.general.procType;
config.nNumOfChs = configProvider.ECG_CFG.general.nNumOfActiveChs;
config.useStats = configProvider.GEN_CFG.useStats;
config.usePar = configProvider.GEN_CFG.usePar;

