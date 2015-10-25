function config = setEliminationConfig()

global configProvider;

config = configProvider.ECG_CFG.mECG;
config.Fs = configProvider.GEN_CFG.sampleRate;
config.usePar = configProvider.GEN_CFG.usePar;
