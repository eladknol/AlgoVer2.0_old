function filtSig = applyPwrNotchFiltering_matlab(signal, inConfig)

% This version of the powerline filtering should be used only in the MATLAB environment. (targeting)

if(mean(inConfig.Fc) == 50 && inConfig.Fs == 1000 && inConfig.Order == 10)
    filtSig = applyPwrNotchFiltering(signal, inConfig); % Use the coder version to get the same results as the coder
    return;
end


global notchBsFilt_global;
% Auto design 50 notch filter and apply it to the in signal
isLoadFilt = 0;

if(~isempty(notchBsFilt_global))
    if(notchBsFilt_global.SampleRate == inConfig.Fs && all([notchBsFilt_global.HalfPowerFrequency1 notchBsFilt_global.HalfPowerFrequency2] == inConfig.Fc) && notchBsFilt_global.FilterOrder == inConfig.Order)
        % The filter config is the same as the previuos run, use it instead of re-designing the filter
        isLoadFilt = 1;
    end
else
    if(exist('notchBsFilt.mat', 'file'))
        isLoadFilt = 2;
    else
        isLoadFilt = 0;
    end
end

if(isLoadFilt==1)
    notchBsFilt = notchBsFilt_global;
elseif(isLoadFilt==2)
    load('notchBsFilt.mat');
else
    notchBsFilt = designfilt('bandstopiir', 'FilterOrder', inConfig.Order, ...
        'HalfPowerFrequency1', inConfig.Fc(1), 'HalfPowerFrequency2', inConfig.Fc(2), ...
        'SampleRate', inConfig.Fs);
    
    save('notchBsFilt.mat', 'notchBsFilt');
end
notchBsFilt_global = notchBsFilt;
filtSig = filtfilt(notchBsFilt, signal);
