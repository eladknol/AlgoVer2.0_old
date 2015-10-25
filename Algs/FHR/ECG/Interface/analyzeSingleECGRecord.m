function [exitFlag, outData] = analyzeSingleECGRecord(firstInput, startAtStep, stopAtStep, testForResOnly, verbose)

bDebug = 0;
%#codegen

%% ANALYZESINGLEECGRECORD
%%
%  [res, secOut, thrdOut] = analyzeSingleECGRecord(firstInput, startAtStep, stopAtStep, testForResOnly, verbose)
%  This self-contained module analyze a single file given as a full path to the file or as an ECG-input structure
%  The module handles all of the exceptions and reports acourdingly
%  INPUTS:
%         1. firstInput: (a) A char array containing the file name to analyze
%                        (b) A data structure contatining the data to analyze
%         2. startAtStep: At which step to start the analysis (skip part of the analysis and load the data) (default: 0)
%         3. stopAtStep:  At which step to stop the analysis (default: inf)
%         4. testForResOnly:  Test if a results file already exists
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
% Check the inputs and the configuration
exitFlag = -1; % exit code

%% Coder extensions
if(coder.target('matlab'))
    if(nargin<1)
        % Error: exitFlag = -1; Not enough input arguments
        return;
    end
    
    if(nargin<2)
        startAtStep = [];
    end
    if(nargin<3)
        stopAtStep = [];
    end
    if(nargin<4)
        testForResOnly = [];
    end
    if(nargin<5)
        verbose = [];
    end
    if(isempty(startAtStep))
        startAtStep = 0;
    end
    if(isempty(stopAtStep))
        stopAtStep = 100;
    end
    if(isempty(testForResOnly))
        testForResOnly = 0;
    end
    if(isempty(verbose))
        verbose = 0;
    end
    
    outData.env.target = 'MATLAB';
    
else % C++ path
    if(nargin<5)
        % Error: exitFlag = -1; Not enough input arguments
        outData.secOut = getECGStruct4secout_CODR_INIT();
        outData.thrdOut = getECGStruct4NGO_CODR_INIT();
        return;
    end
    verbose = 0;
    testForResOnly = 0;
    
    %outData.env.target = 'non-MATLAB';
end

%% Test for results only
% Test if the results for a specific file already exist
%%
if(coder.target('matlab') && testForResOnly)
    clear res;
    res = 1;
    steps = [5, 6, 8];
    steps(steps<startAtStep) = [];
    steps(steps>stopAtStep) = [];
    if(isempty(steps))
        res = [];
        return;
    end
    
    for STEP_ID=steps
        resStruct = loadResults(STEP_ID, firstInput);
        if(~isstruct(resStruct) && resStruct==-1)
            res = [-1 STEP_ID];
            return;
        else
            
        end
    end
    return;
end

%% DO THE ANALYSIS
if(coder.target('matlab') && verbose)
    fprintf(1, '%s\n', 'Starting full fECG analysis.');
end

%% (1) Load data and metadata
%  STEP_ID = 1
% Load the data and the meta data from the firstInput
% If the firstInput is a string, it will be loaded and the data and meta data will be extracted from it
% If the firstInput is a structure, the data and meta data will be extracted from it
% If the data is succ loaded it will be ckecked
% The configProvider is initiated at this step also.
%%
STEP_ID = 1;
isLoad = 0;
exitFlag = STEP_ID;

if(coder.target('matlab'))
    gloabalTicker = tic;
end

if(coder.target('matlab') && startAtStep>STEP_ID)
    isLoad = 1;
    resStruct = loadResults(STEP_ID, firstInput);
    if(~isstruct(resStruct) && resStruct==-1)
        isLoad = 0;
    else % Parse outputs of this stage
        % No outputs
    end
end

% Start the configuration provider
global configProvider;

%configProvider = ConfigProvider(); %#ok<MFAMB>

%ERROR_CODES = [];

if(~isLoad)
    if(coder.target('matlab'))
        fileCont = loadECGData(firstInput);
    else
        fileCont = firstInput;
    end
    
    if(~isstruct(fileCont))
        switch(fileCont)
            case -1,
                error('ASF:NOFILE', 'File not found'); % make sure to handle this exception!
            case -2,
                error('ASF:TBC', 'File type is not supported yet!');% make sure to handle this exception!
            case -3,
                error('ASF:FILEFRMT', 'File format is not supported');
            otherwise
                error('ASF:UNKNOWN', 'An Unknown error occured while loading the ECG data'); % make sure to handle this exception!
        end
    end
    
    if(isempty(fileCont) || ~isfield(fileCont, 'data'))
        outData.secOut = getECGStruct4secout_CODR_INIT();
        outData.thrdOut = getECGStruct4NGO_CODR_INIT();
        
        return; % Error: exitFlag = 1; Not enough input arguments
    end
    
    % Raw data
    % fileCont.data must have NxL format, N is the number of cahnnels and L is the lenght of thr signal
    
    
    siz = size(fileCont.data);
    if(siz(1)>siz(2)) % Auto transfer the data if it is NxL to
        error('Data shape is not supported, use NxL data shaping.');
    end
    
    if(coder.target('matlab') && verbose)
        fprintf(1, '%s', 'Data loaded.');
        fprintf(1, '%s', 'Checking data...');
    end
    
    rawData = checkData(fileCont.data);     % Check the data for missing data (nan's)
    
    % CODER REMOVE
    %     fileCont = rmfield(fileCont, 'data');   % Free-up some memory
    
    coder.varsize('metaData.channelType', [1 10], [0 1]); % #CODER_VARSIZE
    
    
    % Meta data
    if(isfield(fileCont, 'meta'))
        metaData = fileCont.meta;
        metaData.Fs = fileCont.meta.Samplerate;
        metaData.nNumOfChannels = length(fileCont.meta.ChannelsTypes);
        nNumOfChannels = length(fileCont.meta.ChannelsTypes);
        metaData.channelType = repmat(struct('value', 'AAA'), 1, nNumOfChannels);
        
        coder.varsize('metaData.channelType(:).value', [1 50], [0 1]); % #CODER_VARSIZE
        
        if(isfield(fileCont.meta, 'ChannelsTypes'))
            
            for i=1:nNumOfChannels
                %metaData.channelType{i} = metaData.ChannelsTypes{i};
                %metaData.channelType(i).value = metaData.ChannelsTypes{i};
                metaData.channelType(i).value = fileCont.meta.ChannelsTypes(i).value;
            end
        end
    else
        %         warning('Cannot find the meta data, using default values.');
        %         metaData = getEssentialMetaValues(); % should be avoided
        error('Cannot find the meta data');
    end
    
    % CODER REMOVE
    %     if(round(max(siz)/metaData.Fs)>10*60) % exclude long files, for now
    %         error('ASF:DATA2LONG', 'Data is too long.');
    %     end
    
    % update the configProvider
    if(coder.target('matlab') && verbose)
        fprintf(1, '%s', 'Updating the Configuration Provider...');
    end
    configProvider = ConfigProvider('initiate', metaData.Fs, '');
    configProvider.GEN_CFG.satLevel = metaData.satLevel;
    %coder.varsize('configProvider.GEN_CFG.channelType', [1 10], [1 0]); % #CODER_VARSIZE
    configProvider.GEN_CFG.channelType = metaData.channelType;
    configProvider.GEN_CFG.nNumOfChannels  = metaData.nNumOfChannels;
    
    configProvider_temp = configProvider;
    ecgCHS = getChannelsByType(configProvider_temp, 'ECG');
    
    %coder.varsize('configProvider.ECG_CFG.general.ECGChs', [1 6], [1 0]); % #CODER_VARSIZE
    configProvider.ECG_CFG.general.ECGChs = ecgCHS;
    configProvider.ECG_CFG.general.nNumOfChs = length(ecgCHS);
    configProvider.ECG_CFG.general.nNumOfActiveChs = length(ecgCHS);
    calcMaxPredMHR = 220 - metaData.Age;
    configProvider.ECG_CFG.general.maxPredMHR = calcMaxPredMHR;
    
    
    if(coder.target('matlab'))
        configProvider.GEN_CFG.usePar = runPar(configProvider.ECG_CFG.general.nNumOfActiveChs, 2);
    else
        configProvider.GEN_CFG.usePar = true(1);
    end
    
    ERROR_CODES = configProvider.GEN_CFG.errorCodes;
    
    if(coder.target('matlab'))
        clear fileCont;
    end
    
    if(coder.target('matlab') && verbose)
        if(toc(gloabalTicker)<1)
            fprintf(1, '%s %0.1f sec )\n', 'Done (', toc(gloabalTicker));
        else
            if(toc(gloabalTicker)<1)
                fprintf(1, '%s %0.1f sec )\n', 'Done (', toc(gloabalTicker));
            else
                fprintf(1, '%s', 'Done ('); fprintf(2, ' %0.1f sec ', toc(gloabalTicker)); fprintf(1, ')\n');
            end
        end
    end
    
else
    outData.secOut = getECGStruct4secout_CODR_INIT();
    outData.thrdOut = getECGStruct4NGO_CODR_INIT();
    
end
if(stopAtStep==STEP_ID)
    outData.secOut = getECGStruct4secout_CODR_INIT();
    outData.thrdOut = getECGStruct4NGO_CODR_INIT();
    
    return;
end

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
isLoad = 0;
exitFlag = STEP_ID;
if(coder.target('matlab'))
    gloabalTicker = tic;
end

if(coder.target('matlab') && startAtStep>STEP_ID)
    isLoad = 1;
    resStruct = loadResults(STEP_ID, firstInput);
    if(~isstruct(resStruct) && resStruct==-1)
        isLoad = 0;
    else % Parse outputs of this stage
        
    end
end

if(~isLoad)
    if(coder.target('matlab') && verbose)
        fprintf(1, '%s', 'Performing ECG data examining...');
    end
    
    ECGChs = configProvider.ECG_CFG.general.ECGChs;
    ecgData = rawData(ECGChs, :);
    
    if(coder.target('matlab'))
        clear rawData ECGChs; % Free up some memory
    end
    
    [~, chnlInclude] = doExamine(ecgData, [], 'ECG_AUTO'); % Perform basic examination of the data
    
    if(~any(chnlInclude))
        if(coder.target('matlab'))
            error(['ASF:ID' num2str(ERROR_CODES.ECG.EXAMINE_DATA)], getErrorString(ERROR_CODES.ECG.EXAMINE_DATA));
        else
            error('ASF:ID', getErrorString(ERROR_CODES.ECG.EXAMINE_DATA));
        end
    end
    
    if(coder.target('matlab') && verbose)
        if(toc(gloabalTicker)<1)
            fprintf(1, '%s %0.1f sec )\n', 'Done (', toc(gloabalTicker));
        else
            fprintf(1, '%s', 'Done ('); fprintf(2, ' %0.1f sec ', toc(gloabalTicker)); fprintf(1, ')\n');
        end
    end
    
else
    outData.secOut = getECGStruct4secout_CODR_INIT();
    outData.thrdOut = getECGStruct4NGO_CODR_INIT();
    
end
if(stopAtStep==STEP_ID)
    outData.secOut = getECGStruct4secout_CODR_INIT();
    outData.thrdOut = getECGStruct4NGO_CODR_INIT();
    
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
isLoad = 0;
exitFlag = STEP_ID;

if(coder.target('matlab'))
    gloabalTicker = tic;
end

if(coder.target('matlab') && startAtStep>STEP_ID)
    isLoad = 1;
    resStruct = loadResults(STEP_ID, firstInput);
    if(~isstruct(resStruct) && resStruct==-1)
        isLoad = 0;
    else % Parse outputs of this stage
        
    end
end

if(~isLoad)
    if(coder.target('matlab') && verbose)
        fprintf(1, '%s', 'Performing ECG data filtering...');
    end
    
    filtersConfig.auto_filt.ecg = configProvider.ECG_CFG.filters;
    filtersConfig.autoApply = true(1);
    filtersConfig.apply2All = true(1);
    filtersConfig.dataType = 'ECG';
    filtersConfig.auto_filt.ecg.median.active = false(1);
    [sts, filtECGData] = doFilter(filtersConfig, ecgData); % dont save the filtered data to the 'GCF'
    
    if(coder.target('matlab') && verbose)
        if(toc(gloabalTicker)<1)
            fprintf(1, '%s %0.1f sec )\n', 'Done (', toc(gloabalTicker));
        else
            fprintf(1, '%s', 'Done ('); fprintf(2, ' %0.1f sec ', toc(gloabalTicker)); fprintf(1, ')\n');
        end
    end
    
    % ERROR_CODES.ECG.FILTERING
    
else
    outData.secOut = getECGStruct4secout_CODR_INIT();
    outData.thrdOut = getECGStruct4NGO_CODR_INIT();
    
end
if(stopAtStep==STEP_ID)
    outData.secOut = getECGStruct4secout_CODR_INIT();
    outData.thrdOut = getECGStruct4NGO_CODR_INIT();
    
    return;
end

%% (4) Examine and Prepare the data for mQRS detection
%  STEP_ID = 4
% Examine and Prepare the data for mQRS detection
% The filters config are requested from the configProvider
% The examination is done using the doExamine module
% The filtering is done using the doFilter module
%%
STEP_ID = STEP_ID+1;
isLoad = 0;
exitFlag = STEP_ID;

if(coder.target('matlab'))
    gloabalTicker = tic;
end

if(coder.target('matlab') && startAtStep>STEP_ID)
    isLoad = 1;
    resStruct = loadResults(STEP_ID, firstInput);
    if(~isstruct(resStruct) && resStruct==-1)
        isLoad = 0;
    else % Parse outputs of this stage
        
    end
end

if(~isLoad)
    if(coder.target('matlab') && verbose)
        fprintf(1, '%s', 'Performing ECG data examining for mQRS detection...');
    end
    
    [satInds, chnlInclude, closestElectrode, filtData] = doExamine(ecgData, filtECGData, 'ECG');
    if(coder.target('matlab'))
        clear ecgData;
    end
    if(~any(chnlInclude))
        if(coder.target('matlab'))
            error(['ASF:ID' num2str(ERROR_CODES.ECG.EXAMINE_DATA)], getErrorString(ERROR_CODES.ECG.EXAMINE_DATA));
        else
            error('ASF:ID', getErrorString(ERROR_CODES.ECG.EXAMINE_DATA));
        end
    end
    
    % Apply additional filters for maternal QRS detection
    filtersConfig.auto_filt.ecg.low.active = false(1);
    filtersConfig.auto_filt.ecg.high.active = false(1);
    filtersConfig.auto_filt.ecg.power.active = false(1);
    filtersConfig.auto_filt.ecg.ma.active = false(1);
    filtersConfig.auto_filt.ecg.median.active = true(1);
    
    [sts, matECGData] = doFilter(filtersConfig, filtData);
    
    if(coder.target('matlab'))
        clear filtData;
    end
    if(coder.target('matlab') && verbose)
        if(toc(gloabalTicker)<1)
            fprintf(1, '%s %0.1f sec )\n', 'Done (', toc(gloabalTicker));
        else
            fprintf(1, '%s', 'Done ('); fprintf(2, ' %0.1f sec ', toc(gloabalTicker)); fprintf(1, ')\n');
        end
    end
    
else
    outData.secOut = getECGStruct4secout_CODR_INIT();
    outData.thrdOut = getECGStruct4NGO_CODR_INIT();
    
end
if(stopAtStep==STEP_ID)
    outData.secOut = getECGStruct4secout_CODR_INIT();
    outData.thrdOut = getECGStruct4NGO_CODR_INIT();
    
    return;
end

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
isLoad = 0;
exitFlag = STEP_ID;

if(coder.target('matlab'))
    gloabalTicker = tic;
end

if(coder.target('matlab') && startAtStep>STEP_ID)
    isLoad = 1;
    resStruct = loadResults(STEP_ID, firstInput);
    if(~isstruct(resStruct) && resStruct==-1)
        isLoad = 0;
        if(testForResOnly)
            res = [resStruct STEP_ID];
            return;
        end
    else % Parse outputs of this stage
        if(testForResOnly)
            res = [1 STEP_ID];
        end
        mQRS_struct = resStruct.mQRS.mQRS_struct;
    end
end

if(~isLoad)
    if(coder.target('matlab') && verbose)
        fprintf(1, '%s', 'Performing mQRS detection...');
    end
    
    configProvider.ECG_CFG.general.procType = getProcType('maternal');
    
    % Do detect maternal peaks positions
    
    if(coder.target('matlab'))
        ticker = tic;
    end
    
    %     mQRS_struct = doDetect('filtData', filtECGData, 'matData', matECGData, 'chnlInclude', chnlInclude);
    mQRS_struct = doDetectMaternal(filtECGData, matECGData, chnlInclude);
    
    if(coder.target('matlab'))
        dTime = toc(ticker);
    end
    
    if(isfield(mQRS_struct, 'err'))
        if(coder.target('matlab'))
            error(['ASF:ID' num2str(ERROR_CODES.ECG.MQRS_DETECTION)], getErrorString(ERROR_CODES.ECG.MQRS_DETECTION));
        else
            error('ASF:ID', getErrorString(ERROR_CODES.ECG.MQRS_DETECTION));
        end
    end
    
    if(coder.target('matlab'))
        matDetectionSum = sprintf('%s \n ->%s \n ->%s \n ->%s \n ->%s \n ->%s \n', 'Maternal QRS detection summary:',...
            ['Chs available for the detection: ' num2str(find(chnlInclude))],...
            ['Chs used for the detection: ' num2str(find(mQRS_struct.leadsInclude'))],...
            ['Best lead for detection: ' num2str(mQRS_struct.bestLead)],...
            ['Detection reliability: ' num2str(mQRS_struct.rel) '%'],...
            ['Detection duration: ' num2str(round(dTime, 2)) ' Sec']...
            );
        mQRS.matDetectionSum = matDetectionSum;
        %else
        %mQRS.matDetectionSum = 'Maternal detection summary is not available in non-MATLAB implementation';
    end
    
    mQRS.mQRS_struct = mQRS_struct;
    outData.secOut.mQRS = mQRS;
    % CODER REMOVE
    %     if(nargout>1)
    %         secOut.mQRS = mQRS;
    %     else
    %         % Save the results
    %         res.fullSavePath = saveResults(firstInput, STEP_ID, mQRS);
    %     end
    
    if(coder.target('matlab') && verbose)
        if(toc(gloabalTicker)<1)
            fprintf(1, '%s %0.1f sec )\n', 'Done (', toc(gloabalTicker));
        else
            fprintf(1, '%s', 'Done ('); fprintf(2, ' %0.1f sec ', toc(gloabalTicker)); fprintf(1, ')\n');
        end
    end
    
else
    outData.secOut = getECGStruct4secout_CODR_INIT();
    outData.thrdOut = getECGStruct4NGO_CODR_INIT();
end
if(stopAtStep==STEP_ID)
    return;
end

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
isLoad = 0;
exitFlag = STEP_ID;

if(coder.target('matlab'))
    gloabalTicker = tic;
end

if(coder.target('matlab') && startAtStep>STEP_ID)
    isLoad = 1;
    resStruct = loadResults(STEP_ID, firstInput);
    if(~isstruct(resStruct) && resStruct==-1)
        isLoad = 0;
        if(testForResOnly)
            res = [resStruct STEP_ID];
            return;
        end
    else % Parse outputs of this stage
        if(testForResOnly)
            res = [1 STEP_ID];
        end
        removeStruct = resStruct.removeStruct;
    end
end

if(~isLoad)
    if(coder.target('matlab') && verbose)
        fprintf(1, '%s', 'Performing mECG elimination...');
    end
    
    bDebug = 1&0;
    if(bDebug)
        configProvider.GEN_CFG.usePar = 0&1;
    end
    
    removeStruct = doRemove(filtECGData,  matECGData, mQRS_struct);
    
    removeStruct.metaData = metaData;
    
    outData.secOut.removeStruct = removeStruct;
    
    % CODER REMOVE
    %     if(nargout>1)
    %         secOut.removeStruct = removeStruct;
    %     else
    %         % Save the results
    %         res.fullSavePath = saveResults(firstInput, STEP_ID, removeStruct);
    %     end
    
    if(coder.target('matlab') && verbose)
        if(toc(gloabalTicker)<1)
            fprintf(1, '%s %0.1f sec )\n', 'Done (', toc(gloabalTicker));
        else
            fprintf(1, '%s', 'Done ('); fprintf(2, ' %0.1f sec ', toc(gloabalTicker)); fprintf(1, ')\n');
        end
    end
    
else
    outData.secOut = getECGStruct4secout_CODR_INIT();
    outData.thrdOut = getECGStruct4NGO_CODR_INIT();
    
end
if(stopAtStep==STEP_ID)
    outData.thrdOut = getECGStruct4NGO_CODR_INIT();
    return;
end

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
isLoad = 0;
exitFlag = STEP_ID;

if(coder.target('matlab'))
    gloabalTicker = tic;
end

if(coder.target('matlab') && startAtStep>STEP_ID)
    isLoad = 1;
    resStruct = loadResults(STEP_ID, firstInput);
    if(~isstruct(resStruct) && resStruct==-1)
        isLoad = 0;
    else % Parse outputs of this stage
        
    end
end

if(~isLoad)
    if(coder.target('matlab') && verbose)
        fprintf(1, '%s', 'Performing fECG extraction...');
    end
    
    config = configProvider.ECG_CFG.fECG;
    
    if(coder.target('matlab') && verbose)
        if(toc(gloabalTicker)<1)
            fprintf(1, '%s %0.1f sec )\n', 'Done (', toc(gloabalTicker));
        else
            fprintf(1, '%s', 'Done ('); fprintf(2, ' %0.1f sec ', toc(gloabalTicker)); fprintf(1, ')\n');
        end
    end
    
    if(coder.target('matlab') && verbose)
        fprintf(1, '%s', 'Performing fECG pre-processing...');
    end
    
    [fetSignal, fetECGData, bestFetLead] = preProcFetalData(removeStruct, 'ica', config);
    
    chnlInclude = true(1, min(size(fetSignal)));
    
    if(coder.target('matlab') && verbose)
        if(toc(gloabalTicker)<1)
            fprintf(1, '%s %0.1f sec )\n', 'Done (', toc(gloabalTicker));
        else
            fprintf(1, '%s', 'Done ('); fprintf(2, ' %0.1f sec ', toc(gloabalTicker)); fprintf(1, ')\n');
        end
    end
    
else
    outData.secOut = getECGStruct4secout_CODR_INIT();
    outData.thrdOut = getECGStruct4NGO_CODR_INIT();
    
end
if(stopAtStep==STEP_ID)
    outData.thrdOut = getECGStruct4NGO_CODR_INIT();
    return;
end

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
isLoad = 0;
exitFlag = STEP_ID;

if(coder.target('matlab'))
    gloabalTicker = tic;
end

if(coder.target('matlab') && startAtStep>STEP_ID)
    isLoad = 1;
    resStruct = loadResults(STEP_ID, firstInput);
    if(~isstruct(resStruct) && resStruct==-1)
        isLoad = 0;
        if(testForResOnly)
            res = [resStruct STEP_ID];
            return;
        end
    else % Parse outputs of this stage
        if(testForResOnly)
            res = [1 STEP_ID];
        end
        fQRS_struct = resStruct.fQRS_struct;
    end
end

if(~isLoad)
    if(coder.target('matlab') && verbose)
        fprintf(1, '%s', 'Performing fQRS detection...');
    end
    
    configProvider.ECG_CFG.general.procType = getProcType('fetal');
    
    %     fQRS_struct = doDetect('filtData', fetSignal, 'fetData', fetECGData, 'type', 'fetal', 'chnlInclude', chnlInclude, 'mQRS_struct', mQRS_struct, 'bestFetLead', bestFetLead, 'removeStruct', removeStruct);
    fQRS_struct = doDetectFetal(fetSignal, chnlInclude, mQRS_struct, bestFetLead, removeStruct);
    
    outData.secOut.fQRS_struct = fQRS_struct;
    if(coder.target('matlab'))
        outData.thrdOut = getECGStruct4NGO(mQRS_struct, removeStruct, fQRS_struct);
    else
        outData.thrdOut = getECGStruct4NGO_CODR(mQRS_struct, removeStruct, fQRS_struct);
    end
    % CODER REMOVE
    %     if(nargout>1)
    %         secOut.fQRS_struct = fQRS_struct;
    %         thrdOut = getECGStruct4NGO(mQRS_struct, removeStruct, fQRS_struct);
    %     else
    %         % Save the results
    %
    %         if(ischar(firstInput))
    %             res.fullSavePath = saveResults(firstInput, STEP_ID, fQRS_struct);
    %             ngoFileName = strrep(strrep(firstInput, getNGFBaseDir(), getNGOBaseDir()), '.ngf', '.ngo');
    %         else
    %             tmpName = ['AlgoV1_0_def_OutputFile_' getTimeForSave()];
    %             tmpName(tmpName == ' ') = '_';
    %             tmpName(tmpName == ':') = '_';
    %             res.fullSavePath = saveResults([tmpName '.ngf'], STEP_ID, fQRS_struct);
    %             ngoFileName = [pwd '\' tmpName '.ngo'];
    %         end
    %
    %         [~, path] = getFileName(ngoFileName);
    %
    %         if(~isempty(path) && ~isdir(path))
    %             mkdir(path);
    %         end
    %
    %         resHere = generateNGO(mQRS_struct, removeStruct, fQRS_struct, ngoFileName);
    %         if(~resHere)
    %             error('ASF:SAVERES', 'Cannot save NGO file.');
    %         end
    %     end
    
    if(coder.target('matlab') && verbose)
        if(toc(gloabalTicker)<1)
            fprintf(1, '%s %0.1f sec )\n', 'Done (', toc(gloabalTicker));
        else
            fprintf(1, '%s', 'Done ('); fprintf(2, ' %0.1f sec ', toc(gloabalTicker)); fprintf(1, ')\n');
        end
    end
    
else
    outData.secOut = getECGStruct4secout_CODR_INIT();
    outData.thrdOut = getECGStruct4NGO_CODR_INIT();
    
end
if(~isempty(configProvider))
    configProvider = struct();
end

if(stopAtStep==STEP_ID)
    return;
end

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

function fullSavePath = saveResults(fullFileName, stepID, varargin)
% For internal usage only, if you need to save the results use generateNGO(...)
ext = '.mat';
[a, b] = getFileName(fullFileName);
fullFileName = [b '\' a];
shortFileName = fullFileName(strfind(fullFileName, 'Database') + length('Database'):end);
if(isempty(shortFileName))
    shortFileName = ['\' getFileName(fullFileName)];
end

fullSavePath = [getOutputPath(stepID) shortFileName];
count = 1;
while(exist([fullSavePath ext], 'file') && count<0)
    fullSavePath = [fullSavePath '_1'];
    count = count+1;
end

fullSavePath = [fullSavePath ext];
[f, p, e] = getFileName(fullSavePath);

if(~isdir(p))
    mkdir(p);
end
switch(stepID)
    case 5,
        dataToSaveName = 'mQRS';
        mQRS = varargin{1};
    case 6,
        dataToSaveName = 'removeStruct';
        removeStruct = varargin{1};
    case 8,
        dataToSaveName = 'fQRS_struct';
        fQRS_struct = varargin{1};
    otherwise,
        return;
end
save(fullSavePath, dataToSaveName, 'shortFileName');

function savePath = getOutputPath(step)

base = getNGFBaseDir('full', 'local'); % Full local path
switch(step)
    case 5,
        PATH = 'mQRSDetection';
    case 6,
        PATH = 'mECGElimination';
    case 8,
        PATH = 'fQRSDetection';
    otherwise,
        PATH = '';
end
savePath = [base '\Output\' PATH];

if(~isdir(savePath))
    mkdir(savePath);
end

function resStruct = loadResults(stepID, fileName)
try
    currBase = getBaseByStepId(convStepID(stepID));
    currFile = fileName;
    resExt = '.mat';
    currFileRes = strrep(currFile, getNGFBaseDir(), currBase);
    currFileRes = strrep(currFileRes, '...\Database', currBase);
    [file, path, ~] = getFileName(currFileRes);
    currFileRes = [path '\' file resExt];
    resStruct = load(currFileRes);
catch
    % Nothing to catch
    resStruct = -1;
end

function baseDir = getBaseByStepId(stepID)
baseDir = [getNGFBaseDir() '\Output'];

switch(stepID)
    case {'load'},
    case {'prep_exam'},
        baseDir = [baseDir '\prepareAndExamine'];
    case {'filter'},
        baseDir = [baseDir '\filter'];
    case {'prep_mqrsd'},
        baseDir = [baseDir '\prepare4mQRSDetection'];
    case {'mqrsd'},
        baseDir = [baseDir '\mQRSDetection'];
    case {'mecge'},
        baseDir = [baseDir '\mECGElimination'];
    case {'fecgpreproc'},
        baseDir = [baseDir '\fECGPreProc'];
    case {'fqrsd'},
        baseDir = [baseDir '\fQRSDetection'];
end

function stepID_out = convStepID(stepID_in)
if(ischar(stepID_in))
    stepID_out = [];
    switch(stepID_in)
        case {'load'},
            stepID_out = 1;
        case {'prep_exam'},
            stepID_out = 2;
        case {'filter'},
            stepID_out = 3;
        case {'prep_mqrsd'},
            stepID_out = 4;
        case {'mqrsd'},
            stepID_out = 5;
        case {'mecge'},
            stepID_out = 6;
        case {'fecgpreproc'},
            stepID_out = 7;
        case {'fqrsd'},
            stepID_out = 8;
    end
else
    stepID_out = '';
    switch(stepID_in)
        case 1,
            stepID_out = 'load';
        case 2,
            stepID_out = 'prep_exam';
        case 3,
            stepID_out = 'filter';
        case 4,
            stepID_out = 'prep_mqrsd';
        case 5,
            stepID_out = 'mqrsd';
        case 6,
            stepID_out = 'mecge';
        case 7,
            stepID_out = 'fecgpreproc';
        case 8,
            stepID_out = 'fqrsd';
    end
end

function metaData = getEssentialMetaValues()
% The meta data must be specefied, yet if it is not use these default values
metaData.Fs = 1000;
metaData.satLevel = 10;
metaData.channelType = 'ECG';
metaData.Age = 30;


%% Excluded functions
% These functions shouldn't be used, they are kept here for reference only

function filtersConfig = getFiltersConfig()
% This should be moved from here...
% The filters config should be loaded and requested from the FilterManager

filtersConfig.doFilt = 1;
filtersConfig.autoApply = 1;
filtersConfig.auto_filt.ecg.low.active = true(1);
filtersConfig.auto_filt.ecg.low.fc = 70;
filtersConfig.auto_filt.ecg.low.order = 12;

filtersConfig.auto_filt.ecg.high.active = false(1);
filtersConfig.auto_filt.ecg.high.fc = 2;
filtersConfig.auto_filt.ecg.high.order = 5;

filtersConfig.auto_filt.ecg.ma.active = true(1);
filtersConfig.auto_filt.ecg.ma.len = 501;

filtersConfig.auto_filt.ecg.median.active = false(1);
filtersConfig.auto_filt.ecg.median.len = 100;

filtersConfig.auto_filt.ecg.power.active = true(1);
filtersConfig.auto_filt.ecg.power.win = 0.5;
filtersConfig.auto_filt.ecg.power.order = 10;
