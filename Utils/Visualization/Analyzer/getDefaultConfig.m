function dConfig = getDefaultConfig()

dConfig.hdr.Fs = 'Sampling Freq.';
dConfig.val.Fs = 1000;

flds = {'flt_PWR', 'flt_BSLN', 'flt_EMG'};
tempNames = {'Powerline freq', 'Baseline median size', 'EMG freq'};
tempVals = {50, 100, 49};
for i=1:length(tempVals)
    dConfig.hdr.(flds{i}) = tempNames{i};
    dConfig.val.(flds{i}) = tempVals{i};
end


Config = getConfig('maternal');
tempNames = {'Mother age', 'Max pred mHR', 'Min pred mHR', 'Relative mPeak energy', 'min mCorrelation coef'};
flds = fields(Config);
for i=1:length(flds)-1
    dConfig.hdr.(flds{i}) = tempNames{i};
    dConfig.val.(flds{i}) = Config.(flds{i});
end

Config = getConfig('fetal');
tempNames = {'Fetal age', 'Max pred fHR', 'Min pred fHR', 'Relative fPeak energy', 'min fCorrelation coef'};
flds = fields(Config);
for i=1:length(flds)-1
    dConfig.hdr.(flds{i}) = tempNames{i};
    dConfig.val.(flds{i}) = Config.(flds{i});
end