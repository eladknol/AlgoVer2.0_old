function [matConfig, fetConfig] = setDetectionConfig()
% Internal function, assumes inputs are valid!
% Detection configuration is divided into two main parts:
%       1. Maternal config
%       2. Fetal config

global configProvider;
% procType = getProcType(configProvider.ECG_CFG.general.procType);

matConfig = configProvider.ECG_CFG.mQRS;
fetConfig = configProvider.ECG_CFG.fQRS;


%% global config
matConfig.Fs = configProvider.GEN_CFG.sampleRate;
matConfig.procType = configProvider.ECG_CFG.general.procType;
matConfig.nNumOfChs = configProvider.ECG_CFG.general.nNumOfActiveChs;
matConfig.useStats = configProvider.GEN_CFG.useStats;
matConfig.usePar = configProvider.GEN_CFG.usePar;

fetConfig.Fs = configProvider.GEN_CFG.sampleRate;
fetConfig.procType = configProvider.ECG_CFG.general.procType;
fetConfig.nNumOfChs = configProvider.ECG_CFG.general.nNumOfActiveChs;
fetConfig.useStats = configProvider.GEN_CFG.useStats;
fetConfig.usePar = configProvider.GEN_CFG.usePar;
