load('preProcFetalData_data')

config = configProvider.ECG_CFG.fECG;
removeStruct.filtData = removeStruct.filtData(:, 1:60000);
removeStruct.matData = removeStruct.matData(:, 1:60000);
removeStruct.fetData = removeStruct.fetData(:, 1:60000);

removeStruct = rmfield(removeStruct, 'metaData');
tic
[fetSignal.matlab, fetECGData.matlab, bestFetLead.matlab] = preProcFetalData(removeStruct, 'ica', config);
toc

tic
[fetSignal.mex, fetECGData.mex, bestFetLead.mex] = preProcFetalData_mex(removeStruct, 'ica', config);
toc
