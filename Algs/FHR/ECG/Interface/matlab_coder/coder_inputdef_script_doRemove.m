load('doRemoveData.mat');


configProvider.GEN_CFG.usePar = true;
% pool = parpool(4);
tic;
removeStruct.matlab = doRemove(filtECGData, matECGData, mQRS_struct);
toc
% delete(gcp);
% tic
% removeStruct.mex = doRemove_mex(filtECGData, matECGData, mQRS_struct);
% toc
