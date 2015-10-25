function mQRS_struct = doDetectMaternal(filtECGData, matECGData, chnlInclude)
%#codegen

% DODETECT Performs Rwave detection on ECG signals
%   The inputs of the function must be in pairs: 'NAME', 'VALUE'
%   Inputs:
%           {'type'     : Type of the detection , 'maternal' or 'fetal'}
%           {'filtData' : Filtered ECG data     , NxL matrix}
%           {'matData'  : Maternal ECG data     , NxL matrix; Needed for maternal QRS detection only}
%           {'fetData'  : Fetal ECG data        , NxL matrix; Needed for fetal QRS detection only}
%           {'metaData' : Meta data             , Structure}

%% inputs

coder.varsize('detectorStruct.filtSignals'  , [6 120000], [1 1]); % #CODER_VARSIZE
coder.varsize('detectorStruct.signals'      , [6 120000], [1 1]); % #CODER_VARSIZE
coder.varsize('detectorStruct.chnlInclude'  , [1 6     ], [0 1]); % #CODER_VARSIZE

detectorStruct.filtSignals  = filtECGData;
detectorStruct.signals = matECGData; % Maternal signals, with filters spec for the mother
detectorStruct.chnlInclude = chnlInclude;

%% Do Detect
detectorStruct.config  = setDetectionConfig(); % Update the config
% isMaternal      = strcmpi(getProcType(detectorStruct.config.procType), 'maternal');

mQRS_struct     = getMaternalQRSPos(detectorStruct); % Find the maternal Rwaves

%     detectorStruct.config.mTwave = configProvider.ECG_CFG.mTwave;
%     detectorStruct.config.mTwave.CLT = configProvider.ECG_CFG.mECG.CLT;
%     mTwave_struct     = getMaternalTPos(detectorStruct, mQRS_struct); % Find the maternal Twaves
