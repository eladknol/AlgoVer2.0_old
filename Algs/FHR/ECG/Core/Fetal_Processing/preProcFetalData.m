function [fetSignal, fetECGData, bestLead] = preProcFetalData(fetData, procType, config)
%#codegen

%% temp
coder.varsize('fetData'     , [6 120000     ], [1 1]); % #CODER_VARSIZE
coder.varsize('fetSignal'   , [6 120000     ], [1 1]); % #CODER_VARSIZE
coder.varsize('fetECGData'  , [6 120000     ], [1 1]); % #CODER_VARSIZE
coder.varsize('cor'         , [6 120000*2   ], [1 1]); % #CODER_VARSIZE

fetSignal = fetData;

%%
switch lower(procType)
    case 'raw',
        fetSignal = fetData;
    case 'raw_1st'
        fetSignal = fetData(1, :);
    case 'ica',
        if(size(fetData, 1)>1)
            % Apply ICA to the data
            Out1 = fastICA(fetData, 'tanh'); % Needs to be changed
            fetSignal = getFetaSigFromICARes(Out1);
        else
            fetSignal = fetData;
        end
end

% For fetal QRS detection
global configProvider;
filtersConfig.auto_filt.ecg = getECGFilts(configProvider);
filtersConfig.autoApply = 1;
filtersConfig.apply2All = 1;
filtersConfig.dataType = 'ECG';

filtersConfig.auto_filt.ecg.ma.active = true(1);
filtersConfig.auto_filt.ecg.median.active = false(1);
filtersConfig.auto_filt.ecg.ma.len = 201;
filtersConfig.auto_filt.ecg.median.len = 100;

nNumOfChannels = size(fetSignal, 1);

[~, fetSignal] = doFilter(filtersConfig, fetSignal);

filtersConfig.auto_filt.ecg.ma.active = false(1);
filtersConfig.auto_filt.ecg.median.active = true(1);

if(nargout<2)
    return;
end

[~, fetECGData] = doFilter(filtersConfig, fetSignal);

if(nargout<3)
    return;
end

res = winRMS(fetSignal, config.Gen.RMSWinLen);

cor = zeros(6, 2*size(res,2)-1);

for i=1:nNumOfChannels
    cor(i, :) = xcorr(res(i, :));
end

res_1 = cor;

for i=1:nNumOfChannels
    res_1(i,:) = maFilter(cor(i,:), config.Gen); % de-trend the auto-corr
end
en = peak2rms(res_1');
[y, bestLead] = min(en); % i is the best lead...




