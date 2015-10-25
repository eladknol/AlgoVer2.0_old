function filtSig = apply50HzNotchFiltering(signal, inConfig)

if(coder.target('matlab'))
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
        notchBsFilt = designfilt('bandstopiir','FilterOrder',inConfig.Order, ...
            'HalfPowerFrequency1',inConfig.Fc(1),'HalfPowerFrequency2',inConfig.Fc(2), ...
            'SampleRate',inConfig.Fs);
        save('notchBsFilt.mat', 'notchBsFilt');
    end
    notchBsFilt_global = notchBsFilt;
    filtSig = filtfilt(notchBsFilt, signal);
else
    % Fs = 1000
    % Order = 10
    % Fc = 50 +-0.5 Hz
    
    if(mean(inConfig.Fc) == 50)
        b_50 = [
            0.9990   -1.9003    0.9990
            0.9990   -1.9003    0.9990
            0.9975   -1.8973    0.9975
            0.9975   -1.8973    0.9975
            0.9969   -1.8962    0.9969];
        
        a_50 = [
            1.0000   -1.8984    0.9980
            1.0000   -1.9021    0.9981
            1.0000   -1.8961    0.9949
            1.0000   -1.8985    0.9950
            1.0000   -1.8962    0.9937];
        
        filtSig = signal;
        
        tempSig = filtfilt(b_50(1,:), a_50(1,:), filtSig);
        filtSig = tempSig(:);
        tempSig = filtfilt(b_50(2,:), a_50(2,:), filtSig);
        filtSig = tempSig(:);
        tempSig = filtfilt(b_50(3,:), a_50(3,:), filtSig);
        filtSig = tempSig(:);
        tempSig = filtfilt(b_50(4,:), a_50(4,:), filtSig);
        filtSig = tempSig(:);
        tempSig = filtfilt(b_50(5,:), a_50(5,:), filtSig);
        filtSig = tempSig(:);
        
    elseif(mean(inConfig.Fc) == 60)
        % Fs = 1000
        % Order = 10
        % Fc = 60 +-0.5 Hz
        b_60 = [
            0.9990   -1.8578    0.9990
            0.9990   -1.8578    0.9990
            0.9975   -1.8548    0.9975
            0.9975   -1.8548    0.9975
            0.9969   -1.8537    0.9969];
        a_60 = [
            1.0000   -1.8555    0.9980
            1.0000   -1.8600    0.9981
            1.0000   -1.8535    0.9949
            1.0000   -1.8562    0.9950
            1.0000   -1.8537    0.9937];
        filtSig = signal;
        
        tempSig = filtfilt(b_60(1,:), a_60(1,:), filtSig);
        filtSig = tempSig(:);
        tempSig = filtfilt(b_60(2,:), a_60(2,:), filtSig);
        filtSig = tempSig(:);
        tempSig = filtfilt(b_60(3,:), a_60(3,:), filtSig);
        filtSig = tempSig(:);
        tempSig = filtfilt(b_60(4,:), a_60(4,:), filtSig);
        filtSig = tempSig(:);
        tempSig = filtfilt(b_60(5,:), a_60(5,:), filtSig);
        filtSig = tempSig(:);
    else
        error('power line filter configuration is not valid.');
    end
    
end
