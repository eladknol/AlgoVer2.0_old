function varargout = doDetect(varargin)
%#codegen

% DODETECT Performs Rwave detection on ECG signals
%   The inputs of the function must be in pairs: 'NAME', 'VALUE'
%   Inputs:
%           {'type'     : Type of the detection , 'maternal' or 'fetal'}
%           {'filtData' : Filtered ECG data     , NxL matrix}
%           {'matData'  : Maternal ECG data     , NxL matrix; Needed for maternal QRS detection only}
%           {'fetData'  : Fetal ECG data        , NxL matrix; Needed for fetal QRS detection only}
%           {'metaData' : Meta data             , Structure}


if(nargin<2 || mod(nargin,2)) 
    error('Not enough input arguments. Inputs must be in pairs');
end


%% Parse inputs
global configProvider;

for i=1:2:nargin-1
    if(ischar(varargin{i}))
        switch(varargin{i})
            case 'filtData',
                detectorStruct.filtData = varargin{i+1};
            case 'matData',
                detectorStruct.matData = varargin{i+1};
            case 'chnlInclude',
                detectorStruct.chnlInclude = varargin{i+1};
            case 'type',
                detectorStruct.type = varargin{i+1};
            case 'mQRS_struct',
                detectorStruct.mQRS_struct = varargin{i+1};
            case 'bestFetLead',
                detectorStruct.bestFetLead = varargin{i+1};
            case 'removeStruct',
                detectorStruct.removeStruct = varargin{i+1};
        end
    else
        error('Inputs must be in Name-Value pairs');
    end
end


%% Do Detect
detectorStruct.config  = setDetectionConfig(); % Update the config
isMaternal      = strcmpi(getProcType(detectorStruct.config.procType), 'maternal');

if(isMaternal)
    detectorStruct.signals      = detectorStruct.matData; % Maternal signals, with filters spec for the mother
    detectorStruct.filtSignals  = detectorStruct.filtData; 
    
    % CODER REMOVE
    %     detectorStruct  = rmfield(detectorStruct, {'matData', 'filtData'});
    
    mQRS_struct     = getMaternalQRSPos(detectorStruct); % Find the maternal Rwaves
    
    detectorStruct.config.mTwave = configProvider.ECG_CFG.mTwave;
    detectorStruct.config.mTwave.CLT = configProvider.ECG_CFG.mECG.CLT;
    
%     mTwave_struct     = getMaternalTPos(detectorStruct, mQRS_struct); % Find the maternal Twaves
    
    varargout{1}    = mQRS_struct;
%     varargout{2}    = mTwave_struct;
    
else % Fetal
    detectorStruct.signals = detectorStruct.removeStruct.fetData;
    fQRS_struct = getFetalQRSPos(detectorStruct); % Find the fetal Rwaves
    varargout{1}    = fQRS_struct;
end
