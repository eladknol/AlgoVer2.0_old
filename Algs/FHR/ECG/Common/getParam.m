function val = getParam(ind)

params = getAllParams();
const = getAlgConstants();

switch(ind)
    case const.SAMPLERATE,
        val = params.Fs;
        return;
    case const.NORMAL_MATERNAL_SHORT_TERM_RR_STD,
        val = params.normMatRRSTD;
        return;
    case const.MAX_PRED_MATERNAL_HR,
        val = params.maxMaternalHR;
        return;
end