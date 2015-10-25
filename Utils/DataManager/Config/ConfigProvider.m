function configProvider  = ConfigProvider(sampleRate)
%#codegen

configProvider.GEN_CFG = getGENconfig(sampleRate);
configProvider.ECG_CFG = getECGconfig(sampleRate);
