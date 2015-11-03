function [exitFlag, outData] = analyzeSingleECGRecord__CDR(fileCont, exitFlag)

%#codegen
% #CODER_VERSION $CDRV $CDRV_RMV: this pragma indicates coder only code! this code should not be used in matlab enviroment!

%% ANALYZESINGLEECGRECORD
%%
%  [res, secOut, thrdOut] = analyzeSingleECGRecord(firstInput, startAtStep, stopAtStep, testForResOnly, verbose)
%  This is not a self-contained module, it analyzes a single file given as a full path to the file or as an ECG-input structure
%  The module does not handle exceptions, only exitFlag
%  INPUTS:
%         1. firstInput: :: $CDRV_RMV
%                        (b) A data structure contatining the data to analyze
%                               fileCont.data must have NxL format, N is the number of cahnnels and L is the lenght of thr signal
%         2. startAtStep: :: $CDRV_RMV
%         3. stopAtStep:  :: $CDRV_RMV
%         4. testForResOnly:  :: $CDRV_RMV
%  OUTPUTS:
%         1. exitFlag:    (a) Exit code of the module (default 0). This is used for error handlig for the parent module.
%         2. outData:
%                    (a) .secOut: Second output, for internal useage only (default: [])
%                    (b) .thrdOut: Third output, output structure ready for NGO file generation
%%
%
% <<C:\Users\Admin\Google_Drive\Rnd\Documents\Algorithms\Architecture\ECG\Modules\res\DepAnalysis\ForMatlabPub\analyzeSingleECGRecord.PNG>>
%


%% Input checking and initiating
% Check the inputs and the configuration :: $CDRV_RMV
exitFlag = -1; % exit code, keep it like that for the coder

%% Coder extensions
% :: $CDRV_RMV

%% Test for results only
% Test if the results for a specific file already exist
%%
% :: $CDRV_RMV

%% DO THE ANALYSIS

%% (1) Load data and metadata
%  STEP_ID = 1
% Load the data and the meta data from the firstInput
% If the firstInput is a string, it will be loaded and the data and meta data will be extracted from it
% If the firstInput is a structure, the data and meta data will be extracted from it
% If the data is succ loaded it will be ckecked
% The configProvider is initiated at this step also.
%%
STEP_ID = 1;

exitFlag = STEP_ID;

% Start the configuration provider
global configProvider;

coder.varsize('metaData.channelType', [1 10], [0 1]); % #CODER_VARSIZE

% Meta data
metaData = fileCont.meta;
metaData.Fs = fileCont.meta.Samplerate;
metaData.nNumOfChannels = length(fileCont.meta.ChannelsTypes);
nNumOfChannels = length(fileCont.meta.ChannelsTypes);
metaData.channelType = repmat(struct('value', 'AAA'), 1, nNumOfChannels);

coder.varsize('metaData.channelType(:).value', [1 5], [0 1]); % #CODER_VARSIZE

for i=1:nNumOfChannels
    metaData.channelType(i).value = fileCont.meta.ChannelsTypes(i).value;
end

% update the configProvider

configProvider = ConfigProvider(metaData.Fs); % initiate the configProvider structure
configProvider.GEN_CFG.satLevel         = metaData.satLevel;
configProvider.GEN_CFG.channelType      = metaData.channelType;
configProvider.GEN_CFG.nNumOfChannels   = metaData.nNumOfChannels;

configProvider_temp = configProvider;
ecgCHS = getChannelsByType(configProvider_temp, 'ECG');

configProvider.ECG_CFG.general.ECGChs = ecgCHS;
configProvider.ECG_CFG.general.nNumOfChs = length(ecgCHS);
configProvider.ECG_CFG.general.nNumOfActiveChs = length(ecgCHS);
calcMaxPredMHR = 220 - metaData.Age;
configProvider.ECG_CFG.general.maxPredMHR = calcMaxPredMHR;

configProvider.GEN_CFG.usePar = true(1); % Force parallel computing

ERROR_CODES = configProvider.GEN_CFG.errorCodes;

%% (2) Prepare and Examine the data
%  STEP_ID = 2
%  Prepare and examine the data for the analysis
%  This is only a basic examination to check if the data is valid
%  The result of the examination is binary, if at least one channel is valid, the analysis will start
%  if not, the analysis will be aborted.
%%
%
% <<C:\Users\Admin\Google_Drive\Rnd\Documents\Algorithms\Architecture\ECG\Modules\res\DepAnalysis\ForMatlabPub\doExamine.PNG>>
%

STEP_ID = STEP_ID+1; % 2
exitFlag = STEP_ID;

ECGChs = configProvider.ECG_CFG.general.ECGChs;
tempData = fileCont.data(ECGChs, :);     % Check the data for missing data (nan's)
ecgData = checkData(tempData);

[~, chnlInclude] = doExamine(ecgData, [], 'ECG_AUTO'); % Perform basic examination of the data

if(~any(chnlInclude))
    error('ASF:ID', getErrorString(ERROR_CODES.ECG.EXAMINE_DATA));
    return;
end

%% (3) Filter the data
%  STEP_ID = 3
% Apply the needed digital filters to the data
% The filters config are requested from the configProvider
% The filtering is done using the doFilter module
%%
%
% <<C:\Users\Admin\Google_Drive\Rnd\Documents\Algorithms\Architecture\ECG\Modules\res\DepAnalysis\ForMatlabPub\doFilter.PNG>>
%
STEP_ID = STEP_ID+1;
exitFlag = STEP_ID;

filtersConfig.auto_filt.ecg = configProvider.ECG_CFG.filters;
filtersConfig.autoApply = true(1);
filtersConfig.apply2All = true(1);
filtersConfig.dataType = 'ECG';
filtersConfig.auto_filt.ecg.median.active = false(1);
[sts, filtECGData] = doFilter(filtersConfig, ecgData); % dont save the filtered data to the 'GCF'


%% (4) Examine and Prepare the data for mQRS detection
%  STEP_ID = 4
% Examine and Prepare the data for mQRS detection
% The filters config are requested from the configProvider
% The examination is done using the doExamine module
% The filtering is done using the doFilter module
%%
STEP_ID = STEP_ID+1;
exitFlag = STEP_ID;

[satInds, chnlInclude, closestElectrode, examData] = doExamine(ecgData, filtECGData, 'ECG');
if(~any(chnlInclude))
    error('ASF:ID', getErrorString(ERROR_CODES.ECG.EXAMINE_DATA));
    return;
end

% Apply additional filters for maternal QRS detection
filtersConfig.auto_filt.ecg.low.active = false(1);
filtersConfig.auto_filt.ecg.high.active = false(1);
filtersConfig.auto_filt.ecg.power.active = false(1);
filtersConfig.auto_filt.ecg.ma.active = false(1);
filtersConfig.auto_filt.ecg.median.active = true(1);

[sts, matECGData] = doFilter(filtersConfig, examData);


%% (5) Perform Maternal QRS detection
%  STEP_ID = 5
% Perform Maternal QRS detection
% The detection config are requested from the configProvider
% The detection is done using the doDetect module
% If the secOut is empty, the results are saved to the disk
%%
%
% <<C:\Users\Admin\Google_Drive\Rnd\Documents\Algorithms\Architecture\ECG\Modules\res\DepAnalysis\ForMatlabPub\doDetect_maternal.PNG>>
%

STEP_ID = STEP_ID+1;
exitFlag = STEP_ID;

configProvider.ECG_CFG.general.procType = getProcType('maternal');

% Do detect maternal peaks positions

mQRS_struct = doDetectMaternal(filtECGData, matECGData, chnlInclude);


if(mQRS_struct.err)
    error('ASF:ID', getErrorString(ERROR_CODES.ECG.MQRS_DETECTION));
    return;
end

mQRS.mQRS_struct = mQRS_struct;

%% (6) Perform Maternal ECG elimination
%  STEP_ID = 6
% Perform Maternal ECG elimination
% The elimination config are requested from the configProvider
% The elimination is done using the doRemove module
% If the secOut is empty, the results are saved to the disk
%%
%
% <<C:\Users\Admin\Google_Drive\Rnd\Documents\Algorithms\Architecture\ECG\Modules\res\DepAnalysis\ForMatlabPub\doRemove.PNG>>
%
STEP_ID = STEP_ID+1;
exitFlag = STEP_ID;

removeStruct = doRemove(filtECGData, mQRS_struct);
removeStruct.metaData = metaData;

%% (7) Perform Fetal ECG pre-processing
%  STEP_ID = 7
% Perform Fetal ECG pre-processing
% The pre-processing config are requested from the configProvider
% The pre-processing is done using the preProcFetalData module
%%
%
% <<C:\Users\Admin\Google_Drive\Rnd\Documents\Algorithms\Architecture\ECG\Modules\res\DepAnalysis\ForMatlabPub\preProcFetalData.PNG>>
%
STEP_ID = STEP_ID+1;
exitFlag = STEP_ID;

config = configProvider.ECG_CFG.fECG;
[fetSignal, fetECGData, bestFetLead] = preProcFetalData(removeStruct, 'ica', config);
chnlInclude = true(1, min(size(fetSignal)));


%% (8) Perform Fetal QRS detection
%  STEP_ID = 5
% Perform Fetal QRS detection
% The detection config are requested from the configProvider
% The detection is done using the doDetect module
% If the secOut is empty, the results are saved to the disk
%%
%
% <<C:\Users\Admin\Google_Drive\Rnd\Documents\Algorithms\Architecture\ECG\Modules\res\DepAnalysis\ForMatlabPub\doDetect_fetal.PNG>>
%
STEP_ID = STEP_ID+1;
exitFlag = STEP_ID;

configProvider.ECG_CFG.general.procType = getProcType('fetal');
fQRS_struct = doDetectFetal(fetSignal, chnlInclude, mQRS_struct, bestFetLead, removeStruct);

if(~isempty(configProvider))
    configProvider = struct();
end

%% Output 
outData.secOut.mQRS = mQRS; % $CDRV
outData.secOut.removeStruct = removeStruct; % $CDRV
outData.secOut.fQRS_struct = fQRS_struct; % $CDRV
outData.thrdOut = getECGStruct4NGO_CODR(mQRS_struct, removeStruct, fQRS_struct); % $CDRV

%% Helper functions
% Local functions used during the run time of analyzeSingleECGRecord

function rawData = checkData(rawData)
% Check if there is missing samples and try to solve the problem
% Alg: look for nans and replace using interpolation via convolution with a hamming window

siz = size(rawData,1);
nans = sum(isnan(rawData));
nansPerc = (nans/siz*100)>0.5;%
rawData(:, nansPerc) = nan;
for i=1:length(nansPerc)
    if(~nansPerc(i) && nans(i))
        sig = rawData(:,i);
        inds = isnan(sig);
        df = diff(inds);
        if(inds(1))
            sig(1) = nanmean(sig);
            inds = isnan(sig);
            df = diff(inds);
        end
        if(inds(end))
            sig(end) = nanmean(sig);
            inds = isnan(sig);
            df = diff(inds);
        end
        
        strtInd = find(df==1)+1;
        endInd = find(df==-1);
        nanLen = endInd-strtInd+1;
        for ii=1:length(nanLen)
            if((nanLen(ii)/siz*100)<0.05)
                nanInds = strtInd(ii):endInd(ii);
                sig(nanInds) = linspace(sig(nanInds(1)-1), sig(nanInds(end)+1), length(nanInds));
                sigStrt = nanInds(1)-10; % need to add a check for that
                sigEnd = nanInds(end)+10;% need to add a check for that
                bef = sig(sigStrt-50:sigEnd+50);
                res = conv(bef, hamming(10),'same');
                sig(sigStrt-50:sigEnd+50) = res/(res(60)/bef(60));
            end
        end
        rawData(:,i) = sig;
    end
end
