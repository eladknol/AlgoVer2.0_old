function resStruct = getECGStruct4NGO_CODR(mQRS_struct, mECG, fQRS_struct)

resStruct = struct();

%% patient information
resStruct.unqID = 'thisistheunqfileiddd';
resStruct.analysisType = 1;

metaData = mECG.metaData;
resStruct.Fs = metaData.Fs;
resStruct.patID = metaData.SubjectID;
resStruct.bmi = metaData.BMIbeforepregnancy;
resStruct.gestAge = metaData.Weekofpregnancy;

%% ECG res data
resData = struct();
resData.ECG_mQRSPos = mQRS_struct.pos;
resData.ECG_avgMHR = 60*mECG.metaData.Fs /(nanmean(diff(mQRS_struct.pos)));

resData.ECG_fQRSPos = fQRS_struct.fQRS;
resData.ECG_avgFHR = 60*mECG.metaData.Fs /(nanmean(diff(fQRS_struct.fQRS)));

% Scoring
resData.ECG_scoreArray = fQRS_struct.scoring.scrVec;
resData.ECG_globalScore = fQRS_struct.scoring.globalScore;
resData.ECG_avgBestFHR = nanmean(fQRS_struct.scoring.bestWindow.HR);

resStruct.resData = resData;

if(resStruct.Fs == -1)
    resStruct.Fs = fQRS_struct.metaData.Fs;
end
