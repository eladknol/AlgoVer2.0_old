function [ HR_INST , HR_MED ] = AlgVerificationCalcHR( pos , med_win_size , Fs )
%AlgVerificationCalcHR calculates temp and median HR from vector fetal sounds or ECG peak detection. 
%   Inputs:  f_pos - vector of fetal QRS peak detection (ECG source) or S
%            waves (Audio source) positions. Sampling rate is 1000 Hz.
%            med_win_size - size of median window used for medfilt1
%                           for averaging HR
%            Fs - sampling frequency
%   Outputs: HR_INST - Instantaneous HR (per beat).
%            HR_MED - robust HR calculation using median filter on HR_INST

if isempty(pos)
    HR_INST=[];HR_MED=[];
    return;
end

half_win_size=floor(med_win_size/2);

% Make sure input is row vector
if ~isrow(pos);
    pos=pos';
end;

HR_INST=(60*Fs)./(pos(2:end)-pos(1:end-1));
% mirror beginning of signal and calculate median HR
HR_INST_4_medfilt=horzcat(fliplr(HR_INST(1:half_win_size)),HR_INST,fliplr(HR_INST(end-half_win_size+1:end)));
HR_MED=medfilt1(HR_INST_4_medfilt,med_win_size);
HR_MED=HR_MED(1+half_win_size:end-half_win_size);
end

