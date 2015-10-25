load('doDetectData.mat');

filtECGData = filtECGData(:,1:60000);
matECGData = matECGData(:,1:60000);
mQRS_struct = doDetect('filtData', filtECGData, 'matData', matECGData, 'chnlInclude', chnlInclude);
