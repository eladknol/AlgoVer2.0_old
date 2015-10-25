load('doDetectFetal_data')

fetSignal = filtData(:,1:60000);
removeStruct = rmfield(removeStruct, 'metaData');
removeStruct.fetData = removeStruct.fetData(:,1:60000);
removeStruct.matData = removeStruct.matData(:,1:60000);
removeStruct.filtData = removeStruct.filtData(:,1:60000);


fQRS_struct = doDetectFetal_mex(fetSignal, chnlInclude, mQRS_struct, bestFetLead, removeStruct);
