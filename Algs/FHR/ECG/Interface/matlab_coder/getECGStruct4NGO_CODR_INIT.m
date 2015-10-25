function resStruct = getECGStruct4NGO_CODR_INIT()

resStruct = struct();

%% patient information
resStruct.unqID = 'thisistheunqfileiddd';
resStruct.analysisType = -1;

resStruct.Fs = -1;
resStruct.patID = 'aaaaaaaa';
resStruct.bmi = -1;
resStruct.gestAge = -1;

%% ECG res data
resData = struct();
resData.ECG_mQRSPos = -ones(10, 1);
resData.ECG_avgMHR = -1;

resData.ECG_fQRSPos = -ones(10, 1);
resData.ECG_avgFHR = 0;

% Scoring
resData.ECG_scoreArray = -ones(10, 1);
resData.ECG_globalScore = -1;
resData.ECG_avgBestFHR = -1;

resStruct.resData = resData;
