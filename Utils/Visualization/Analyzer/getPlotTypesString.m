function typesString = getPlotTypesString(type)


typesString.MndF_FULL_RAW = 'Raw Maternal&Fetal ECG with QRS'; % show fetal and maternal ECG with QRS positions
typesString.MndF_FULL_PreProc = 'PreProc Maternal&Fetal ECG'; % show fetal and maternal ECG 
typesString.MndF_FULL = 'Maternal&Fetal ECG with QRS'; % show fetal and maternal ECG with QRS positions

typesString.MaternalECGWithQRS = 'mECG with mQRS'; % show maternal ECG with QRS positions

typesString.FetalECGWithQRS = 'fECG with fQRS'; % show Fetal ECG with QRS positions


typesString.FullECGICA = 'ICA - Full ECG'; % show results of ICA analysis of full ECG data
typesString.FetalECGICA = 'ICA - Fetal ECG'; % show results of ICA analysis of fECG data

typesString.MndF_FULL_RAW_withAnnfQRS = 'Raw ECG with fQRS and Ann. fQRS';
typesString.MndF_FULL_Proc_withAnnfQRS = 'Proc ECG with fQRS and Ann. fQRS';
typesString.FetalECGICA_withAnnfQRS = 'ICA - Fetal ECG with fQRS and Ann. fQRS';

typesString.MaternalECG_withRawECG = 'Raw ECG with estimated mECG';

