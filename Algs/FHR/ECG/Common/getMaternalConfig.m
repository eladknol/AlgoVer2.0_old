function Config = getMaternalConfig()

Config.motherAge = 30;
Config.maxPredMaternalHR = 220 - Config.motherAge;
Config.minPredMaternalHR = 40;
Config.relMaternalPeaksEnergy = 0.8; % minimum relative energy of the peaks. (the signals should be clean!)

Config.minMaternalCorrCoef = 0.8; % to be used when removng the maternal ECG
