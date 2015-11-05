function fQRS_struct = doDetectFetal(mQRS_struct, removeStruct)

%% #pragmas
% #codegen

%% Coder directives
coder.varsize('detectorStruct.filtData'     , [6 120000], [1 1]); % #CODER_VARSIZE
coder.varsize('detectorStruct.signals'      , [6 120000], [1 1]); % #CODER_VARSIZE
coder.varsize('detectorStruct.chnlInclude'  , [6 1     ], [1 0]); % #CODER_VARSIZE

%% Code
% Setup the fetal detector structure
% detectorStruct.filtData     = fetSignals;           % Pre-processed Fetal data
% detectorStruct.chnlInclude  = chnlInclude;          % Channels to include in the analysis
detectorStruct.mQRS_struct  = mQRS_struct;          % Maternal QRS detection output structure
% detectorStruct.bestFetLead  = bestFetLead;          % Best fetal channel obtained in the preprocessing stage
detectorStruct.removeStruct = removeStruct;         % mECG removal output structure
detectorStruct.signals      = removeStruct.fetData; % Raw fetal data (after the maternal elimination)
[~, detectorStruct.config]  = setDetectionConfig(); % Update the config

% Do the detection
fQRS_struct = getFetalQRSPos(detectorStruct); % Find the fetal Rwaves
