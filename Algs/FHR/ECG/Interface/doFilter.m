function [sts, filtData] = doFilter(filterConfig, rawData)
%#codegen

% #CODER_REMOVE
% This code is under the code rewriting process for the coder. Remove this line when done.


% Main filtering module
% rawData must be be NxL
% This can be used for ECG only

% Inputs:
%     filterConfig: the configuration of the filters
%     rawData: The raw data to filter
% Outputs:
%     sts: return status
%     filtData: the filtered data

%% Output initiation
sts = false(1);
filtData = rawData;

% #CODER_DIRECTIVE

coder.varsize('config.filtType', [1 20], [0 1]);    %#CODER_VARSIZE
coder.varsize('config.Fc', [1 2], [0 1]);           %#CODER_VARSIZE

%% local params

Fs = filterConfig.auto_filt.ecg.Fs;
% You need to specify all of the structure fileds before using the structure!
% (Cannot add fields after first operation on the struct)
config.Fc = filterConfig.auto_filt.ecg.low.fc/(Fs/2);
config.Order = filterConfig.auto_filt.ecg.low.order;
config.maLength = filterConfig.auto_filt.ecg.ma.len;
config.medianLength = filterConfig.auto_filt.ecg.median.len;
config.Fs = Fs;
config.method = 'notch_auto';

%% Core code

% Low pass filter
config.filtType = 'LOW_BUTTER';
if(filterConfig.auto_filt.ecg.low.active)
    [sts, filtData] = applyFilter(config.filtType, filtData, config);
end

% Baseline filter using sliding median filter
config.filtType = 'BSLN';
if(filterConfig.auto_filt.ecg.median.active)
    [sts, filtData] = applyFilter(config.filtType, filtData, config);
end

% Moving average filter
config.filtType = 'ma';
if(filterConfig.auto_filt.ecg.ma.active)
    [sts, filtData] = applyFilter(config.filtType, filtData, config);
end

% Powerline
win0 = filterConfig.auto_filt.ecg.power.win;
config.Fc = filterConfig.auto_filt.ecg.power.freq + [-win0 +win0]; % use varsize
config.Order = filterConfig.auto_filt.ecg.power.order;
config.filtType = 'PWR';
if(filterConfig.auto_filt.ecg.power.active)
    [sts, filtData] = applyFilter(config.filtType, filtData, config);
end

sts = true(1);
