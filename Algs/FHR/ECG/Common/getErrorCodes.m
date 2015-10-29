function codesStruct = getErrorCodes(type)

if(~nargin)
    type = 'all';
end


%% General errors
codesStruct.General.GUI_GENERAL = 10;  % general error while creating/updating the GUI

codesStruct.FREE                = 0;       % no errors
codesStruct.LOADING             = 1;    % error loading data file
codesStruct.FILTERING           = 2;  % error filtering the data
codesStruct.DATA_NOT_SUPPORTED  = 9;  % Data format is not supported
codesStruct.USER_ABORT          = 18;
% codesStruct.EXAMINE_DATA        = 10;  % Data format is not supported


%% ECG errors
codesStruct.ECG.FREE                = 10;       % no errors
codesStruct.ECG.LOADING             = 11;    % error loading data file
codesStruct.ECG.FILTERING           = 12;  % error filtering the data
codesStruct.ECG.ARRANGING           = 13;  % error re-arranging the data
codesStruct.ECG.MQRS_DETECTION      = 14;  % error detecting maternal qrs positions
codesStruct.ECG.MECG_ELIMINATION   = 15;  % error substracting maternal ECG
codesStruct.ECG.FQRS_DETECTION      = 16;  % error detecting fetal qrs positions
codesStruct.ECG.FULL_ECG_ICA        = 17;  % error performing ICA
codesStruct.ECG.FETAL_ECG_ICA       = 18;  % error performing fetal ICA
codesStruct.DATA_NOT_SUPPORTED      = 19;  % Data format is not supported
codesStruct.ECG.EXAMINE_DATA        = 20;  % Data examination failed
codesStruct.ECG.EXAMINE_FDATA        = 21;  % fData examination failed
codesStruct.ECG.INVALID_DATA        = 22;  % Invalid data - failed the examination - too many nans

%% Acoustics errors

