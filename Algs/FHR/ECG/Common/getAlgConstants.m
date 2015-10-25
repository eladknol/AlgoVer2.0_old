function const = getAlgConstants(name)
% get algorithm constants

const.SAMPLERATE = 1;
const.NORMAL_MATERNAL_SHORT_TERM_RR_STD = 2;
const.MAX_PRED_MATERNAL_HR = 3;

if(nargin)
    switch(name)
        case {'samplerate','sampleRate','FS','Fs','fs'}
            const = const.SAMPLERATE;
        case {'normalMaternalRRSTD'}
            const = const.NORMAL_MATERNAL_SHORT_TERM_RR_STD;
        case {'maxMaternalHR'}
            const = const.MAX_PRED_MATERNAL_HR;
    end
end