function removeStruct = doRemove(filtECGData, mQRS_struct)
%% #pragmas
%#codegen

%% Coder directives
coder.varsize('fetData'         , [6, 120000], [1 1]);  % #CODER_VARSIZE
coder.varsize('relRemEng'       , [6, 1     ], [1 0]);  % #CODER_VARSIZE
coder.varsize('noisyBeatFlag'   , [6, 5000  ], [1 1]);  % #CODER_VARSIZE

%% Code
config = setEliminationConfig();
nNumOfSigs = size(filtECGData, 1);
fetData = zeros(size(filtECGData));

relRemEng = zeros(nNumOfSigs, 1);
noisyBeatFlag = zeros(nNumOfSigs, length(mQRS_struct.pos));

if(config.usePar)
    tempFiltData = filtECGData(:, :);
    matQRSPos = mQRS_struct.pos;
    parfor iLead = 1:nNumOfSigs
        [fetData(iLead,:), relRemEng(iLead), noisyBeatFlag(iLead,:)] = remMECG(tempFiltData(iLead,:), matQRSPos, config);
    end
else
    for iLead = 1:nNumOfSigs
        [fetData(iLead,:), relRemEng(iLead), noisyBeatFlag(iLead,:)] = remMECG(filtECGData(iLead,:), mQRS_struct.pos, config);
    end
end

removeStruct.filtData = filtECGData;
removeStruct.mQRS_struct = mQRS_struct;
removeStruct.fetData = fetData;
removeStruct.relRemEng = relRemEng;
removeStruct.noisyBeatFlag = noisyBeatFlag;
