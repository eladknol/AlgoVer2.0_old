function string = getErrorString(code)

% Get the describtion of a specific error

string = ' ';
codesStruct = getErrorCodes('ecg');

switch(code)
    case codesStruct.FREE,
        string = 'No errors';
    case codesStruct.LOADING,
        string = 'Cannot load data from file';
    case codesStruct.FILTERING,
        string = 'Cannot filter the data';
    case codesStruct.ECG.ARRANGING,
        string = 'Cannot re-arrange the data';
    case codesStruct.ECG.MQRS_DETECTION,
        string = 'Failed to perform maternal QRS detection';
    case codesStruct.ECG.MECG_ELIMINATION,
        string = 'Failed to substract maternal ECG';
    case codesStruct.ECG.FQRS_DETECTION,
        string = 'Failed to perform fetal QRS detection';
    case codesStruct.ECG.FULL_ECG_ICA,
        string = 'Failed to perform ICA on the full ECG data';
    case codesStruct.ECG.FETAL_ECG_ICA,
        string = 'Failed to perform ICA on the fetal ECG data';
    case codesStruct.DATA_NOT_SUPPORTED,
        string = 'Data format is not supported';
    case codesStruct.ECG.EXAMINE_DATA,
        string = 'Failed to perform data examination';
    case codesStruct.ECG.INVALID_DATA,
        string = 'Data is invalid';
    
    
    case codesStruct.General.GUI_GENERAL,
        string = 'Cannot initiate figure for file.';
    
    case codesStruct.USER_ABORT,
        string = 'Calulations aborted';
        
    otherwise,
        string = 'Unknown error';
end