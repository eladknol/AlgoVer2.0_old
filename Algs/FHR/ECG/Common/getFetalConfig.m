function Config = getFetalConfig()

Config.fetalAge = 20; % in weeks
Config.maxPredFetalHR = 220;
Config.minPredFetalHR = 50;
Config.relFetalPeaksEnergy = 0.8; % minimum relative energy of the peaks. (the signals should be clean!)

Config.minFetalCorrCoef = 0.8; % to be used when removng the maternal ECG