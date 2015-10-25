function resStruct = getECGStruct4NGO(mQRS_struct, mECG, fQRS_struct)

resStruct = struct();

%% patient information
resStruct.unqID = 'thisistheunqfileiddd';
resStruct.analysisType = 1;


if(isempty(mECG))
    resStruct.Fs = -1;
    resStruct.patID = 'aaaaaa';
    resStruct.bmi = -1;
    resStruct.gestAge = -1;
else
    metaData = mECG.metaData;
    resStruct.Fs = metaData.Fs;
    resStruct.patID = metaData.SubjectID;
    resStruct.bmi = metaData.BMIbeforepregnancy;
    resStruct.gestAge = metaData.Weekofpregnancy;
end

%% ECG res data
resData = [];
if(isempty(mQRS_struct))
    resData.ECG_mQRSPos = -1;
    resData.ECG_avgMHR = -1;
else
    resData.ECG_mQRSPos = mQRS_struct.pos;
    resData.ECG_avgMHR = 60*mECG.metaData.Fs /(nanmean(diff(mQRS_struct.pos)));
end

if(isempty(fQRS_struct))
    resData.ECG_fQRSPos = -1;
    resData.ECG_avgFHR = -1;
    resData.ECG_avgBestFHR = -1;
else
    resData.ECG_fQRSPos = fQRS_struct.fQRS;
    resData.ECG_avgFHR = 60*mECG.metaData.Fs /(nanmean(diff(fQRS_struct.fQRS)));
    
    if(resStruct.Fs == -1)
        resStruct.Fs = fQRS_struct.metaData.Fs;
    end
    
    if(isfield(fQRS_struct, 'scoring'))
        if(isstruct(fQRS_struct.scoring))
            resData.ECG_scoreArray = fQRS_struct.scoring.scrVec;
            resData.ECG_globalScore = fQRS_struct.scoring.globalScore;
            resData.ECG_avgBestFHR = nanmean(fQRS_struct.scoring.bestWindow.HR);
        else
            resData.ECG_scoreArray = -1;
            resData.ECG_globalScore = -1;
            resData.ECG_avgBestFHR = -1;
        end
    else
        resData.ECG_scoreArray = -1;
        resData.ECG_globalScore = -1;
        resData.ECG_avgBestFHR = -1;
    end
end

if(isempty(resData))
   resData.info = 'results are not available';
end

resStruct.resData = resData;
