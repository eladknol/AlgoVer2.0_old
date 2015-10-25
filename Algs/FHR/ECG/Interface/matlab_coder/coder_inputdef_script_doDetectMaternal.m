load('doDetectData.mat');

filtECGData = filtECGData(:,1:60000);
matECGData = matECGData(:,1:60000);
mQRS_struct.matlab = doDetectMaternal(filtECGData, matECGData, chnlInclude);
mQRS_struct.mex = doDetectMaternal_mex(filtECGData, matECGData, chnlInclude);
