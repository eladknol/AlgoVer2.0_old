function [sts, filtData, b, a] = applyFilter(type, inData, config)
%#codegen

% #CODER_REMOVE
% This code is under the code rewriting process for the coder. Remove this line when done.

% Apply a specific fitler

%% Output initiation
sts = false(1);
coder.varsize('filtData', [6 120000], [1 1]); % #CODER_VARSIZE
filtData = nan(size(inData));

%% local params

nNumOfSigs = size(inData, 1);

if(isempty(inData))
    % Don't filter the data, get b,a only
    dofilt = false(1);
else
    dofilt = true(1);
end

%% Core code

switch(type)
    case 'PWR', % Power line filter
        if(config.Fc(1)~=0 && config.Fc(2)~=0) % For powerline filter, fc = [2,1]
            for chnl = 1:nNumOfSigs
                filtData(chnl,:) = powerLineFilter(inData(chnl,:), config);
            end
            sts = true(1); % All done
        else
            filtData = inData;
        end
        
    case 'ma', % Moving average filter
        if(config.maLength~=0)
            for chnl = 1:nNumOfSigs
                filtData(chnl,:) = maFilter(inData(chnl,:), config);
            end
            sts = true(1); % All done
        else
            filtData = inData;
        end
        
    case 'BSLN', % Baseline median filter
        if(config.medianLength>0)
            for chnl = 1:nNumOfSigs
                filtData(chnl,:) = baselineWanderFilter(inData(chnl,:), config.medianLength);
            end
            sts = true(1); % All done
        else
            filtData = inData;
        end
            
    case 'HIGH_BUTTER', % High pass filter
        if(coder.target('matlab'))
            if(config.Order == 5 && length(config.Fc) == 1 && config.Fc(1) == 0.0020) % For low pass filter, fc = [1,1]
                b_high = [0.989885075391028,-4.94942537695514,9.89885075391028,-9.89885075391028,4.94942537695514,-0.989885075391028];
                a_high = [1,-4.97966719499007,9.91887533813755,-9.87862154877963,4.91928586812375,-0.979872462481901];
            elseif(config.Order == 5 && length(config.Fc) == 1 && config.Fc(1) == 0.0010) % For low pass filter, fc = [1,1]
                b_high = [0.994929691353823,-4.97464845676912,9.94929691353823,-9.94929691353823,4.97464845676912,-0.994929691353823];
                a_high = [1,-4.98983359383530,9.95938603408543,-9.93915637708831,4.95948902757589,-0.989885090737414];
            elseif(config.Order == 7 && length(config.Fc) == 1 && config.Fc(1) == 0.03) % For low pass filter, fc = [1,1]
                b_high = [0.809066862358600,-5.66346803651020,16.9904041095306,-28.3173401825510,28.3173401825510,-16.9904041095306,5.66346803651020,-0.809066862358600];
                a_high = [1,-6.57647643600197,18.5478739344260,-29.0802902788848,27.3730470232592,-15.4689232614369,4.85935826012510,-0.654589187766789];
            else
                [b, a] = butter(config.Order, config.Fc, 'high');
                b_high = b;
                a_high = a;
                warning('Filter config is not supported for the code. If you are trying to use new configurations you should pre-create the filters coeffs.');
            end
            if(dofilt)
                for chnl = 1:nNumOfSigs
                    sigTemp = filtfilt(b_high, a_high, inData(chnl,:));
                    filtData(chnl,:) = sigTemp(:);
                end
                sts = true(1); % All done
            end
        else
            % Use pre-designed filters
            % Standard ECG high pass filter: (order:5; Fc=1Hz, 0.0020 )
            if(config.Order == 5 && length(config.Fc) == 1 && config.Fc(1) == 0.0020) % For low pass filter, fc = [1,1]
                temper = 1;
                b_high_1 = [0.989885075391028,-4.94942537695514,9.89885075391028,-9.89885075391028,4.94942537695514,-0.989885075391028];
                a_high_1 = [1,-4.97966719499007,9.91887533813755,-9.87862154877963,4.91928586812375,-0.979872462481901];
                if(dofilt)
                    for chnl = 1:nNumOfSigs
                        sigTemp = filtfilt(b_high_1, a_high_1, inData(chnl,:));
                        filtData(chnl,:) = sigTemp(:);
                    end
                    sts = true(1); % All done
                end
            elseif(config.Order == 5 && length(config.Fc) == 1 && config.Fc(1) == 0.0010) % For low pass filter, fc = [1,1]
                temper = 2;
                b_high_2 = [0.994929691353823,-4.97464845676912,9.94929691353823,-9.94929691353823,4.97464845676912,-0.994929691353823];
                a_high_2 = [1,-4.98983359383530,9.95938603408543,-9.93915637708831,4.95948902757589,-0.989885090737414];
                if(dofilt)
                    for chnl = 1:nNumOfSigs
                        sigTemp = filtfilt(b_high_2, a_high_2, inData(chnl,:));
                        filtData(chnl,:) = sigTemp(:);
                    end
                    sts = true(1); % All done
                end
            else
                error('Filter config is not supported. If you are trying to use new configurations you need to pre-create the filters coeffs.');
            end
        end
        
    case 'LOW_BUTTER', % Low pass filter
        if(coder.target('matlab'))
            if(config.Order == 12 && length(config.Fc) == 1 && config.Fc(1) == 0.14) % For high pass filter, fc = [1,1]
                b_low = [2.83376993560993e-09,3.40052392273191e-08,1.87028815750255e-07,6.23429385834184e-07,1.40271611812691e-06,2.24434578900306e-06,2.61840342050357e-06,2.24434578900306e-06,1.40271611812691e-06,6.23429385834184e-07,1.87028815750255e-07,3.40052392273191e-08,2.83376993560993e-09];
                a_low = [1,-8.63159665788591,34.5108312981228,-84.4350851217093,140.683909248538,-168.061136511723,147.514271902245,-95.8095489650896,45.6795636046311,-15.5852999981524,3.61079940976397,-0.509873329073074,0.0331767274532591];
            else
                [b, a] = butter(config.Order, config.Fc, 'low');
                b_low = b;
                a_low = a;
            end
        else
            % Use pre-designed filters
            % Standard ECG low pass filter: (order:12; Fc=70Hz, 0.14 )
            if(config.Order == 12 && length(config.Fc) == 1 && config.Fc(1) == 0.14) % For high pass filter, fc = [1,1]
                b_low = [2.83376993560993e-09,3.40052392273191e-08,1.87028815750255e-07,6.23429385834184e-07,1.40271611812691e-06,2.24434578900306e-06,2.61840342050357e-06,2.24434578900306e-06,1.40271611812691e-06,6.23429385834184e-07,1.87028815750255e-07,3.40052392273191e-08,2.83376993560993e-09];
                a_low = [1,-8.63159665788591,34.5108312981228,-84.4350851217093,140.683909248538,-168.061136511723,147.514271902245,-95.8095489650896,45.6795636046311,-15.5852999981524,3.61079940976397,-0.509873329073074,0.0331767274532591];
            else
                error('Filter config is not supported. If you are trying to use new configurations you need to pre-create the filters coeffs.');
            end
        end
        
        if(dofilt)
            for chnl = 1:nNumOfSigs
                temp = filtfilt(b_low, a_low, inData(chnl,:));
                filtData(chnl,:) = temp(:);
            end
            sts = true(1); % All done
        end
        
    case 'DC', % Mean removal filter
        for chnl = 1:nNumOfSigs
            filtData(chnl,:) = inData(chnl,:) - nanmean(inData(chnl,:));
        end
        sts = true(1); % All done
        
    otherwise
       error('ERR-HERE');
end
