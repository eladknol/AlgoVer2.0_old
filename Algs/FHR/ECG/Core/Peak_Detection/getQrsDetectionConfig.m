function resConfig = getQrsDetectionConfig(type)

switch(type)
    case 'maternal',
        resConfig.fld = 1;
        resConfig = getMaternalConfig();
        
    case 'fetal',
        resConfig.fld = 1;
        resConfig.relFetalPeaksEnergy = 0.4;% TBU
        resConfig.minPredFetalHR = 80;% TBU
        resConfig.maxPredFetalHR = 200;% TBU
        
        
    otherwise,
        resConfig = -1;
end