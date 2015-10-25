function varargout = Analyzer(varargin)
% ANALYZER MATLAB code for Analyzer.fig
%      ANALYZER, by itself, creates a new ANALYZER or raises the existing
%      singleton*.
%
%      H = ANALYZER returns the handle to a new ANALYZER or the handle to
%      the existing singleton*.
%
%      ANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYZER.M with the given input arguments.
%
%      ANALYZER('Property','Value',...) creates a new ANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Analyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Analyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Analyzer

% Last Modified by GUIDE v2.5 11-Oct-2015 13:18:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Analyzer_OpeningFcn, ...
    'gui_OutputFcn',  @Analyzer_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
global autoFileName
if nargin>1 && ischar(varargin{2})
    if(strcmpi(varargin{2}, 'filename'))
        autoFileName = varargin{3};
    end
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Analyzer is made visible.
function Analyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Analyzer (see VARARGIN)

% Choose default command line output for Analyzer
handles.output = hObject;
global GCF autoFileName;
GCF = handles.figure1;

set(handles.popupmenu_plot_type, 'String', getPlotTypes());
set(handles.popupmenu_time_res, 'String', getTimeBaseResString());
set(handles.popupmenu_time_res, 'value', find(getTimeBaseResValue()==60));
updateErrCodes();
% Update handles structure
guidata(hObject, handles);

if(~isempty(autoFileName) && length(autoFileName)>4)
    % Check if the file name is relative, if so add the full path prefix
    if(strcmp(autoFileName(1:4), '...\'))
        base = [getNGFBaseDir('rel') '\'];
        autoFileName = strrep(autoFileName, '...\', base);
        save('nanana.mat', 'autoFileName');
    end
    
    eventdata.auto_load_file = 1;
    pushbutton_load_file_Callback(hObject, eventdata, handles);
end
% UIWAIT makes Analyzer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Analyzer_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

%% Callback functions

function pushbutton_load_file_Callback(hObject, eventdata, handles)

skipGui = 0;
if(isfield(eventdata, 'auto_load_file') && eventdata.auto_load_file)
    skipGui = 1;
    global autoFileName;
    fileName = autoFileName;
end

try
    waitbarHandle = createWaitBar('Loading file');
    global GCF;
    if(isempty(GCF))
        GCF = handles.figure1;
    end
    clearAppData();
    
    handles.lastOpenPath = loadConfig('lastOpenPath');
    handles.fileType = loadConfig('fileType');
    
    if(isfield(handles, 'lastOpenPath') && ~isempty(handles.lastOpenPath) && sum(handles.lastOpenPath~=0)>0)
        startDir = handles.lastOpenPath;
    else
        startDir = getNGFBaseDir('full', 'local');
        
    end
    if(~skipGui)
        [fileName, openPath] = getfile(startDir, handles.fileType);
    else
        [f, openPath] = getFileName(fileName);
    end
    
    if(fileName==0)
        updateTextbox(handles.text1, 'Cannot load file.', 'replace');
        updateTextbox(handles.text1, 'File format is not supported', 'append');
        destroyWaitBar(waitbarHandle);
        return;
    end
    if(~exist(fileName, 'file'))
        updateTextbox(handles.text1, 'Cannot load file.', 'replace');
        updateTextbox(handles.text1, 'File does not exist', 'append');
        destroyWaitBar(waitbarHandle);
        return;
    end
    
    handles.lastOpenPath = openPath;
    
    saveConfig('lastOpenPath', handles.lastOpenPath);
    saveConfig('fileType', handles.fileType);
    
    
    [file, path, ext] = getFileName(fileName);
    setappdata(GCF, 'fileName', fileName);
    switch(ext)
        case {'.mat', 'mat'},
            fileCont = load(fileName);
        case {'.edf', 'edf'},
            [edf.meta, edf.data] = edfread(fileName);
            if(strfind(edf.meta.patientID, 'X F X'))
                % same preg woman database
                fileCont = edf;
            end
        case {'.ngf', 'ngf'},
            [ngf.meta, ngf.data] = ReadNGF(fileName);
            fileCont = ngf;
        case {'.ecg', 'ecg'},
            resStruct = readECGFile(fileName);
            fileCont = resStruct;
        case {'.dat', 'dat'}
            resStruct = readEHGFile(fileName);
            fileCont = resStruct;
        case {'.txt', 'txt'}
            [succ, resData] = parsePhilipsAvalonFile(fileName);
            fileCont = resData;
            fileCont.fileFlag = 12;
        otherwise
            updateTextbox(handles.text1, 'Cannot load file.', 'replace');
            updateTextbox(handles.text1, 'File format is not supported', 'append');
            destroyWaitBar(waitbarHandle);
            return;
    end
    
    saveConfig('fileType', ext);
    
    fileType = 0;
    if(isfield(fileCont, 'fileFlag')) % a flag to determine the type of the file
        fileType = fileCont.fileFlag;
    else % Backward compatibility for old files
        if(isfield(fileCont, 'dataStruct'))
            if(isfield(fileCont.dataStruct, 'data'))
                if(isfield(fileCont.dataStruct, 'meta'))
                    fileType = getFileFlag('combined'); % Both meta data and data are in the file
                else
                    fileType = getFileFlag('dataOnly'); % only data is in the file
                end
            else
                if(isfield(fileCont.dataStruct, 'meta'))
                    fileType = getFileFlag('metaOnly'); % Only meta data is in the file
                end
            end
        elseif(isfield(fileCont, 'data')) % batch for biopac files
            fileType = getFileFlag('combined'); % only data is in the file
        end
    end
    
    switch(fileType)
        case 0,
            updateTextbox(handles.text1, 'Cannot load file.', 'replace');
            updateTextbox(handles.text1, 'Format is not supported.', 'append')
            destroyWaitBar(waitbarHandle);
            return;
        case 1,
            loadFile(fileCont, handles, 'dataOnly');
        case 2,
            loadFile(fileCont, handles, 'metaOnly');
        case 3,
            loadFile(fileCont, handles, 'combined');
        case 12,
            plotNow(handles, fileCont);
    end
    
    handles.isLoaded = true;
    [aa, bb, cc] = fileparts(fileName);
    handles.file = fileName;
    guidata(hObject, handles);
    if(fileType~=12)
        examineInputData(handles);
    end
    notify(handles, 'fileLoaded', ['[' bb cc ']']);
    
    destroyWaitBar(waitbarHandle);
catch
    try
        destroyWaitBar(waitbarHandle);
    end
    updateTextbox(handles.text1, 'Cannot load file.', 'replace');
    waitfor(warndlg('Cannot load file.'));
end

guidata(hObject, handles);

%% Helping functions
function fileFlag = getFileFlag(typeStr)

switch(typeStr)
    case {'dataOnly'}
        fileFlag = 1;
    case {'metaOnly'}
        fileFlag = 2;
    case {'combined'}
        fileFlag = 3;
    otherwise
        fileFlag = 0;
end

function loadFile(fileCont, handles, typeStr)

switch(typeStr)
    case {'dataOnly'}
        loadData(fileCont);
    case {'metaOnly'}
        loadMeta(fileCont);
    case {'combined'}
        loadFile(fileCont, handles, 'dataOnly');
        loadFile(fileCont, handles, 'metaOnly');
    otherwise
        fileFlag = 0;
end

function loadData(fileCont)

global GCF; % don't use 'gcf' (lower case functio) so in case that another figure come in the front
if(isfield(fileCont, 'dataStruct')) % Our system
    rawData = prepareData(fileCont.dataStruct.data);
elseif(isfield(fileCont, 'data'))
    if(isstruct(fileCont.data))
        if(isfield(fileCont.data, 'RawData')) % CinC2013 challenge data
            rawData = prepareData(fileCont.data.RawData, 'cinc13');
        end
    else % biopac data and NIFECG (same preg woman) database
        if(isfield(fileCont, 'isi'))
            daq = 'biopac';
        elseif(isfield(fileCont, 'meta'))
            tmp = fileCont.meta;
            if(isfield(tmp, 'EOF'))
                % ST ECG EVAL
                daq = 'STECGEVM';
            else
                if(isfield(tmp, 'DeviceID'))
                    daq = lower(fileCont.meta.DeviceID);
                else
                    daq = 'nifecg';
                end
            end
        else
            daq = 'nifecg';
        end
        rawData = prepareData(fileCont.data, daq);
    end
else
    rawData = [];
end
rawData = checkData(rawData);
setappdata(GCF, 'rawData', rawData); % update the figure
setappdata(GCF, 'nNumOfChannels', min(size(rawData))); % update the figure

function loadMeta(fileCont)
global GCF;

if(isfield(fileCont, 'meta'))
    tmp = fileCont.meta;
    if(isfield(tmp, 'Filename') && strfind(tmp.Filename, 'ngf'))% NGFs
        metaData = fileCont.meta;
        metaData.Fs = metaData.Samplerate;
        metaData.nNumOfChannels = length(metaData.ChannelsTypes);
        metaData.daq = 'MP150';
        metaData.satLevel = 10; % Biopac
        if(isfield(metaData, 'db'))
            % do nothing
        elseif(isfield(metaData, 'Testplace'))
            metaData.db = metaData.Testplace;
        else
            metaData.db = 'Nuvo_DB1';
        end
        if(isfield(metaData, 'channelType'))
            % do nothing
        elseif(isfield(metaData, 'ChannelsTypes'))
            for i=1:metaData.nNumOfChannels
                metaData.channelType{i} = metaData.ChannelsTypes(i).value;
            end
        else
            % do nothing auto, it will be selected man
        end
        if(isfield(metaData, 'Weekofpregnancy'))
            metaData.Gestation.week = metaData.Weekofpregnancy;
            metaData.Gestation.day = 0;
        end
        if(isfield(metaData, 'SubjectID'))
            metaData.ID = metaData.SubjectID;
        end
        if(isfield(metaData, 'Filename'))
            metaData.fileName = metaData.Filename;
        end
        
    elseif(isfield(tmp, 'EOF')) % STECGEVM .ECG files
        metaData = fileCont.meta;
        metaData.db = 'NUVO_TEMP';
        metaData.daq = 'STECGEVM';
        for i=1:metaData.nNumOfChannels
            metaData.channelType{i} = 'ECG';
        end
        
        metaData.fileName = getappdata(GCF, 'fileName');
    elseif(isfield(tmp, 'fileName') && strfind(tmp.fileName, 'tpehg')) % EHG files
        metaData = fileCont.meta;
        metaData.db = 'TPEHGDB';
        metaData.daq = 'NA';
        for i=1:metaData.nNumOfChannels
            metaData.channelType{i} = 'EHG';
        end
        
    else% NIFECG
        metaData = fileCont.meta;
        metaData.Fs = 1000; % NIFECG, no info in the file...
        metaData.nNumOfChannels = fileCont.meta.ns - 1; % remove the anns
        ind_s = strfind(metaData.patientID,'Gestation') + length('Gestation') + 1;
        ind_e = strfind(metaData.patientID,'+');
        if(ind_s+ind_e>1)
            metaData.Gestation.week = str2double(metaData.patientID(ind_s:ind_e-1));
            metaData.Gestation.day  = str2double(metaData.patientID(ind_e+1));
        end
        metaData.db = 'NIFECG';
        metaData.daq = 'g.BSamp';
        metaData.satLevel = inf;
        for i=1:metaData.nNumOfChannels
            metaData.channelType{i} = 'ECG';
        end
        
        metaData.fileName = getappdata(GCF, 'fileName');
    end
elseif(isfield(fileCont, 'dataStruct')) % Our system
    metaData = fileCont.dataStruct.meta;
    metaData.Fs = fileCont.dataStruct.meta.DAQ_params.samplingRate;
    metaData.nNumOfChannels = metaData.DAQ_params.nNumOfChannels;
    metaData.db = 'Nuvo_DB0';
    metaData.daq = 'NUVO_DAQ';
    metaData.satLevel = 1;
    
elseif(isfield(fileCont, 'data') && isfield(fileCont, 'isi')) % biopac
    switch(fileCont.isi_units)
        case {'s'},
            r = 1/1;
        case {'ms'},
            r = 1/1000;
        case {'ns'},
            r = 1/1000000;
        otherwise
            r = 1;
    end
    Fs = fileCont.isi/r;
    metaData.Fs = Fs;
    metaData.nNumOfChannels = min(size(fileCont.data));
    metaData.db = 'Nuvo_DB0';
    metaData.daq = 'biopac';
    metaData.daq = 'MP150';
    metaData.satLevel = 10; % Biopac
    metaData.fileName = 'fileName.mat';
else
    temp = getappdata(GCF, 'Temp');
    if(~isempty(temp) && length(temp)==2)
        metaData.Fs = temp(1);
        metaData.nNumOfChannels = temp(2);
        metaData.db = 'CinC2013';
        metaData.daq = 'NA';
        for i=1:metaData.nNumOfChannels
            metaData.channelType{i} = 'ECG';
        end
        
        metaData.fileName = getappdata(GCF, 'fileName');
    else
        metaData = [];
    end
end

% tmp = getappdata(GCF, 'UsedByGUIData_m');
% name = getFileName(tmp.file);
% metaData.fileName = name;

% batch for cinc annotated data

if(strcmpi(metaData.db, 'CinC2013'))
    [aa, bb, cc] = fileparts(metaData.fileName);
    basePath = aa(1:strfind(aa,'cincchlng2013')+length('cincchlng2013'));
    annotFileName = [bb '.fqrs' '.txt'];
    res = findSpecFile(annotFileName, 'txt', basePath);
    if(~isempty(res))
        if(iscell(res))
            res = res{1};
        end
        temp = load(res);
        if(isnumeric(temp))
            metaData.annotfQRSPos = temp;
        end
    end
end

setappdata(GCF, 'metaData', metaData); % update the figure
if(~isempty(metaData))
    updateMeta();
end


function updateTextbox(handle, newStr, option)
str = '';
if(strcmpi(newStr,'clear'))
    str = '';
else
    if(nargin<3)
        option = 'replace';
    end
    if(strcmpi(option,'replace'))
        updateTextbox(handle, 'clear');
    end
    
    oldStr = get(handle,'string');
    for i=1:size(oldStr,1)
        str = [str sprintf('%s\n', oldStr(i,:))];
    end
    str = [str sprintf('%s', newStr)];
end
set(handle,'string', str);

function notify(handles, event, varargin)

if(~isstruct(handles))
    handles = getappdata(handles,'UsedByGUIData_m');
end
switch(lower(event))
    case {'fileloaded'},
        fileName = varargin{1};
        updateTextbox(handles.text1, 'File loaded.', 'replace');
        updateTextbox(handles.text1, fileName, 'append');
        updatePlot(handles, 'newFileLoaded');
    case {'eventname'},
        
    case {'error'},
        errCode = varargin{1};
        errStr = getErrorString(errCode);
        if(length(varargin)>1)
            errStr = varargin{2};
        end
        updateTextbox(handles.text1, errStr, 'replace');
        
    otherwise,
end

function updatePlot(handles, action)
global GCF;
metaData = getappdata(GCF, 'metaData');
if(isempty(metaData))
    updateTextbox(handles.text1, 'Load file first!', 'Replace');
    return;
end

[plotConfig, isChanged] = getPlotConfig(handles);
if(~isChanged)
    return;
end

switch(lower(action))
    case {'newfileloaded'},
        doPlot(handles, plotConfig);
    case {'configchanged'},
        doPlot(handles, plotConfig)
        
end
%setappdata

function doPlot(handles, plotConfig)

if(sum(plotConfig.chnlSelect)==0)
    x = 1:1000;
    plot(x, zeros(size(x)));
    return;
end

global GCF;
metaData = getappdata(GCF, 'metaData');

switch(lower(plotConfig.plotType))
    case {'raw'},
        plotData = getappdata(GCF, 'rawData');
        plotMat = plotData(plotConfig.chnlSelect>0, :);
        
    case {'filtered'},
        filterConfig = getFilterConfig(handles);
        filterConfig.auto_filt.ecg.Fs = metaData.Fs;
        
        if(filterConfig.doFilt)
            waitbarHandle = createWaitBar('Filtering data...');
            temp = getappdata(GCF, 'rawData');
            [~, filtData] = doFilter(filterConfig, temp(plotConfig.chnlSelect>0, :));
            destroyWaitBar(waitbarHandle);
            %plotData = getappdata(GCF, 'filtData');
            plotData = filtData;
            if(~isempty(plotData))
                plotMat = plotData;
                %                 plotMat = plotData(plotConfig.chnlSelect>0, :);
            else
                plotConfig.plotType = 'raw';
                set(handles.popupmenu_plot_type, 'value', 1);
                
                doPlot(handles, plotConfig);
                return;
            end
        else
            plotConfig.plotType = 'raw';
            set(handles.popupmenu_plot_type, 'value', 1);
            
            doPlot(handles, plotConfig);
            return;
        end
    case {'ica'},
        waitbarHandle = createWaitBar('Performing ICA on the selected data...');
        run_ica(handles);
        plotData = getappdata(GCF, 'icaData');
        destroyWaitBar(waitbarHandle);
        if(~isempty(plotData))
            %plotMat = plotData(:, plotConfig.chnlSelect>0);
            plotMat = plotData;
        else
            plotConfig.plotType = 'raw';
            set(handles.popupmenu_plot_type, 'value', 1);
            
            doPlot(handles, plotConfig);
            return;
        end
    case {'spectrogram'},
        waitbarHandle = createWaitBar('Calculating the spectrograms of the data...');
        run_spec(handles);
        
        plotData = getappdata(GCF, 'specData');
        if(~isempty(plotData))
            %plotMat = plotData(:, plotConfig.chnlSelect>0);
            plotMat = plotData;
            if(min(size(plotMat))==1)
                % Only one channel, plot the data on the main axes
                
            else
                % More than one channel, split the plots
                
            end
        else
            filtData = getappdata(GCF, 'filtData');
            cfg = getPlotConfig(handles);
            chs = cfg.chnlSelect;
            if(~isempty(filtData))
                for i=1:length(chs)
                    if(chs(i))
                        stft(filtData(:,i), 64,0.1,[],[], 100, 20*1000, 'log10');
                    end
                end
            else
                rawData = getappdata(GCF, 'rawData');
                if(~isempty(rawData))
                    for i=1:length(chs)
                        if(chs(i))
                            stft(rawData(:,i), 64,0.1,[],[], 100, 20*1000, 'log2');
                        end
                    end
                else
                    
                    plotConfig.plotType = 'raw';
                    set(handles.popupmenu_plot_type, 'value', 1);
                    
                    doPlot(handles, plotConfig);
                    destroyWaitBar(waitbarHandle);
                    return;
                end
            end
        end
        
end

axes(handles.axes_main);
if(plotConfig.auto_hold_plot)
    hold on;
else
    hold off;
end

if(strcmpi(plotConfig.domain, 'time'))
    timebase = (1:size(plotMat,2))/metaData.Fs;
    if(plotConfig.normalizeData)
        for i=1:size(plotMat,1)
            plotMat(i, :) = plotMat(i, :)/(max(abs(plotMat(i, :))));
        end
    end
    plot(timebase, plotMat');
    grid minor;
    
    xlabel('Time [Sec]');
    ylabel('Amplitude [V]');
    
    if~(plotConfig.autoScale)
        ylim(plotConfig.manYLim);
    end
    
elseif(strcmpi(plotConfig.domain, 'freq'))
    for i=1:size(plotMat,1)
        [pxx(i, :), f] = pwelch(plotMat(i, :), [], [], 2048, metaData.Fs);
    end
    plot(f, 10*log10(pxx));
    grid on;
    xlabel('Frequency [Hz]');
    ylabel('PSD [db/Hz]');
    title('Welch Power Spectral Density Estimate');
    
else
    % reserved for future versions
end


function plots = getPlotTypes(num)
plots = {'Raw', 'Filtered', 'ICA', 'Spectrogram'};

if(nargin)
    plots = plots{num};
end

function popupmenu_plot_type_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);


function popupmenu_plot_type_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox_chnl_view_slct1_Callback(hObject, eventdata, handles)
updateChannelSelect(hObject, handles);


function checkbox_chnl_view_slct2_Callback(hObject, eventdata, handles)
updateChannelSelect(hObject, handles);

function checkbox_chnl_view_slct3_Callback(hObject, eventdata, handles)
updateChannelSelect(hObject, handles);

function checkbox_chnl_view_slct4_Callback(hObject, eventdata, handles)
updateChannelSelect(hObject, handles);

function checkbox_chnl_view_slct5_Callback(hObject, eventdata, handles)
updateChannelSelect(hObject, handles);

function checkbox_chnl_view_slct6_Callback(hObject, eventdata, handles)
updateChannelSelect(hObject, handles);

function checkbox_chnl_view_slct7_Callback(hObject, eventdata, handles)
updateChannelSelect(hObject, handles);

function checkbox_chnl_view_slct8_Callback(hObject, eventdata, handles)
updateChannelSelect(hObject, handles);

function checkbox_chnl_view_slct_all_Callback(hObject, eventdata, handles)

set(handles.checkbox_chnl_view_slct_none, 'value', 0);
set(handles.checkbox_chnl_view_slct_all_ecg, 'value', 0);

for i=1:10
    pause(0.05);
    set(handles.(['checkbox_chnl_view_slct' num2str(i)]), 'value', 1);
end
plotWithNewConfig(handles);

function checkbox_chnl_view_slct_none_Callback(hObject, eventdata, handles)

set(handles.checkbox_chnl_view_slct_all, 'value', 0);
set(handles.checkbox_chnl_view_slct_all_ecg, 'value', 0);
for i=1:10
    pause(0.05);
    set(handles.(['checkbox_chnl_view_slct' num2str(i)]), 'value', 0);
end
plotWithNewConfig(handles);

function updateChannelSelect(hObject, handles)
if(get(hObject,'value'))
    set(handles.checkbox_chnl_view_slct_none, 'value', 0);
else
    set(handles.checkbox_chnl_view_slct_all, 'value', 0);
end
guidata(hObject, handles);
plotWithNewConfig(handles);

function plotWithNewConfig(handles, forcePlot)
if(nargin<2)
    forcePlot = 0;
end
global GCF;
plotConfig = getappdata(GCF, 'plotConfig');
plotConfig.auto_update_plot = get(handles.checkbox_auto_update_plot, 'value');
if(~isempty(plotConfig) && (plotConfig.auto_update_plot || forcePlot))
    updatePlot(handles, 'configChanged');
end


function checkbox_auto_scale_Callback(hObject, eventdata, handles)
axes(handles.axes_main);
axis tight;


function edit_auto_scale_min_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_scale_min_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_auto_scale_max_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_scale_max_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox_plot_normalize_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function resStr = getTimeBaseResString()
resStr = {'1', '5', '10', '30', '60', '120', '0'};

function resVal = getTimeBaseResValue(num)
resStr = getTimeBaseResString();
for i=1:length(resStr)
    resVal(i) = str2double(resStr{i});
end
if(nargin)
    resVal = resVal(num);
end

function popupmenu_time_res_Callback(hObject, eventdata, handles)
global GCF;

[plotConfig, isChanged] = getPlotConfig(handles); % Includes updating the time slider
if(~isChanged || isempty(plotConfig) || ~plotConfig.auto_update_plot)
    return;
end

plotConfig = getPlotInterval(plotConfig, handles);
plotConfig = updateTimeBase(plotConfig, handles);

setappdata(GCF, 'plotConfig', plotConfig);
guidata(hObject, handles);

function plotConfig = updateTimeBase(plotConfig, handles)
axes(handles.axes_main);
xlim(plotConfig.timeBase.dispInd/plotConfig.timeBase.Fs);

function popupmenu_time_res_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function plotConfig = getPlotInterval(plotConfig, handles)
step = floor(get(handles.slider_time_base, 'Value')/plotConfig.timeBase.step_size);
% step=max causes an error, should be corrected
if(step==plotConfig.timeBase.dataLenSecs/plotConfig.timeBase.step_size)
    step = step-1;
end
strtInd = max(1+(step)*plotConfig.timeBase.dispBlockSize, 1);
endInd = floor(min((step+1)*plotConfig.timeBase.dispBlockSize, length(plotConfig.timeBase.timeInd)));
plotConfig.timeBase.dispInd = [strtInd, endInd];


function slider_time_base_Callback(hObject, eventdata, handles)
global GCF;
[plotConfig, isChanged] = getPlotConfig(handles); % Includes updating the time slider
if(~isChanged || isempty(plotConfig) || ~plotConfig.auto_update_plot)
    return;
end

plotConfig = getPlotInterval(plotConfig, handles);
plotConfig = updateTimeBase(plotConfig, handles);

setappdata(GCF, 'plotConfig', plotConfig);
guidata(hObject, handles);

function slider_time_base_CreateFcn(hObject, eventdata, handles)

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function checkbox_auto_update_plot_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function pushbutton_update_plot_Callback(hObject, eventdata, handles)
updatePlot(handles, 'configChanged');

function rawData = prepareData(data, databaseTag)
% Transform the data to a constant structure
% If you want to add support for additional data files transform the data here before,
% The raw data must be saved in an LxN 2D array 'rawData'. N is the number of channels and L is the length of the data in samples
global GCF;
ERROR_CODES = getappdata(GCF, 'ERROR_CODES');
rawData = [];
if(nargin>1)
    switch lower(databaseTag)
        case {'cinc13'},
            Fs = 1/mean(diff(data.Elapsed_time));
            
            data = anounced2Mat(data);
            setappdata(GCF, 'Temp', [Fs, min(size(data))]);
        case {'nifecg'},
            data(end, :) = []; % remove the anns
            data(3:end, :) = data(3:end, :)/1000; % this data is in uV, convert it to mV
        case {'biopac'},
            mx = max(data(:));
            mn = min(data(:));
            if(mx>10*10 || mn<10*(-10))
                data = data./(2^15)*10;
            end
            % do nothing...
        case {'stecgevm'},
            data = data/(2^15)*10;
        case {'ehgdb'},
            data = data/(2^15)*10;
        otherwise,
            notify(GCF, 'Error', ERROR_CODES.DATA_NOT_SUPPORTED);
            return;
    end
end

if(isstruct(data) || iscell(data))
    notify(GCF, 'Error', 'Data format is not supported');
    return;
end

siz = size(data);

if(siz(1)>siz(2)) % Auto transfer the data if it is NxL to LxN
    data = data';
end
rawData = data;


function [plotConfig, isChanged] = getPlotConfig(handles)
%<-- To-Do -->
%  1. update the 'isChanged' conditions

%<-- To-Do -->
global GCF;
isChanged = true; % does the configurations changed from the last update
plotConfig = [];
if(~isfield(getappdata(handles.figure1), 'lastPlotConfig'))
    isChanged = true;
end

metaData = getappdata(GCF, 'metaData');
if(isempty(metaData))
    updateTextbox(handles.text1, 'Load file first!', 'Replace');
    return;
end
if(isfield(metaData, 'nNumOfChannels'))
    nNumOfChannels = metaData.nNumOfChannels;
else
    nNumOfChannels = getappdata(GCF, 'nNumOfChannels');
end

if(isfield(metaData, 'calculatedDuration'))
    plotConfig.timeBase.dataLenSamps = max(size(getappdata(GCF, 'rawData')));
    plotConfig.timeBase.dataLenSecs = metaData.calculatedDuration;
else
    plotConfig.timeBase.dataLenSamps = max(size(getappdata(GCF, 'rawData')));
    plotConfig.timeBase.dataLenSecs = plotConfig.timeBase.dataLenSamps/metaData.Fs;
end
plotConfig.timeBase.Fs = metaData.Fs;
plotConfig.timeBase.timeInd = linspace(0, plotConfig.timeBase.dataLenSecs, plotConfig.timeBase.dataLenSamps);

plotConfig.plotType = getPlotTypes(get(handles.popupmenu_plot_type, 'value'));
chnlBaseName = 'checkbox_chnl';
for i=1:10
    if(i>nNumOfChannels)
        set(handles.([chnlBaseName '_view_slct' num2str(i)]), 'Value', 0);
    end
    plotConfig.chnlSelect(i) = get(handles.([chnlBaseName '_view_slct' num2str(i)]), 'Value') && strcmpi(get(handles.([chnlBaseName '_view_slct' num2str(i)]),'Enable'),'on');
end

plotConfig.autoScale = get(handles.checkbox_auto_scale ,'value');
plotConfig.normalizeData = get(handles.checkbox_plot_normalize ,'value');
plotConfig.manYLim = [str2double(get(handles.edit_auto_scale_min, 'string')), str2double(get(handles.edit_auto_scale_max, 'string'))];
plotConfig.auto_update_plot = get(handles.checkbox_auto_update_plot, 'value');
plotConfig.auto_hold_plot = get(handles.checkbox_auto_hold_plot, 'value');

if(get(handles.radiobutton_domain_time, 'value'))
    plotConfig.domain = 'time';
else
    plotConfig.domain = 'freq';
end

plotConfig.timeBase.scale = getTimeBaseResValue(get(handles.popupmenu_time_res,'Value'));
if(plotConfig.timeBase.dataLenSecs<plotConfig.timeBase.scale)
    [~, y] = findClosest(getTimeBaseResValue(), plotConfig.timeBase.dataLenSecs);
    plotConfig.timeBase.scale = y;
    set(handles.popupmenu_time_res, 'value', find(getTimeBaseResValue()==y));
end

plotConfig = initTimeSlider(plotConfig, handles);

axes(handles.axes_main);
if(get(handles.radiobutton_plot_tools_none,'value'))
    zoom off;
    datacursormode off;
    pan off;
elseif(get(handles.radiobutton_plot_tools_zoom,'value'))
    zoom on;
elseif(get(handles.radiobutton_plot_tools_pan,'value'))
    pan on;
elseif(get(handles.radiobutton_plot_tools_cursor,'value'))
    datacursormode on;
end

setappdata(GCF, 'plotConfig', plotConfig);

function plotConfig = initTimeSlider(plotConfig, handles)
nNumOfSlidingSteps = max(floor(plotConfig.timeBase.dataLenSecs/plotConfig.timeBase.scale), 1);
strtPoint = 0;
endPoint = plotConfig.timeBase.dataLenSecs;

plotConfig.timeBase.step_size = plotConfig.timeBase.dataLenSecs/nNumOfSlidingSteps;
plotConfig.timeBase.dispBlockSize = plotConfig.timeBase.step_size*plotConfig.timeBase.Fs;
slider_step(1) = 1*plotConfig.timeBase.step_size/(endPoint-strtPoint);
slider_step(2) = 1*plotConfig.timeBase.step_size/(endPoint-strtPoint);
set(handles.slider_time_base, 'Min', strtPoint, 'Max', endPoint, 'Sliderstep', slider_step);


function examineInputData(handles)
metaData = getappdata(handles.figure1, 'metaData');

if(isempty(metaData) || ~isfield(metaData, 'channelType'))
    choice = questdlg('Cannot determine the types of the channels. Select the type manually?', ...
        'Warning', ...
        'Ok','No. Use default values','Ok');
    % Handle response
    switch choice
        case 'Ok'
            metaData.channelType = getUserChannelTypes(metaData.nNumOfChannels);
            if(~iscell(metaData.channelType) && metaData.channelType==-1)
                % 4 ECG and 4 MIC
                for i=1:metaData.nNumOfChannels
                    if(i<=6)
                        metaData.channelType{i} = 'ECG';
                    else
                        metaData.channelType{i} = 'MIC';
                    end
                end
            end
        case 'No. Use default values'
            % 4 ECG and 4 MIC
            for i=1:metaData.nNumOfChannels
                metaData.channelType{i} = 'GEN';
            end
    end
    
else
    str = metaData.channelType{1};
    
    for i=2:metaData.nNumOfChannels
        str = [str ',' metaData.channelType{i}];
    end
    h = warndlg(sprintf('%s \n %s', 'Channels types were auto detected.', str));
    pause(0.2);
    try
        delete(h);
    end
    
end

if(isfield(metaData, 'channelType'))
    MICChs = getChannelsByType(metaData, 'MIC');
    if(~isempty(MICChs))
        set(handles.uipanel_audio, 'visible', 'on');
        for i=1:length(MICChs)
            str1{i} = num2str(MICChs(i));
        end
        set(handles.popupmenu_audio_ch_slct, 'String', str1);
        set(handles.popupmenu_audio_ch_slct, 'value', 1);
    else
        set(handles.uipanel_audio, 'visible', 'off');
    end
end


setappdata(handles.figure1, 'metaData', metaData);

function checkbox_auto_hold_plot_Callback(hObject, eventdata, handles)


function radiobutton_domain_time_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);


function radiobutton_domain_freq_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);


function radiobutton_plot_tools_none_Callback(hObject, eventdata, handles)
zoom off;
datacursormode off;
pan off;


function radiobutton_plot_tools_zoom_Callback(hObject, eventdata, handles)
zoom on;
datacursormode off;
pan off;


function radiobutton_plot_tools_cursor_Callback(hObject, eventdata, handles)
zoom off;
datacursormode on;
pan off;


function radiobutton_plot_tools_pan_Callback(hObject, eventdata, handles)
zoom off;
datacursormode off;
pan on;


function pushbutton_split_plots_Callback(hObject, eventdata, handles)
x = get(get(handles.axes_main,'children'), 'xData');
y = get(get(handles.axes_main,'children'), 'yData');
if(~iscell(x))
    return;
end
fig = figure;

siz = size(x,1);
for i=1:siz
    ax(i) = subplot(siz, 1,i);
    plot(x{siz-i+1}, y{siz-i+1});
    axis tight;
    grid on;
end
linkaxes(ax, 'x');


function pushbutton_print_Callback(hObject, eventdata, handles)
x = get(get(handles.axes_main,'children'), 'xData');
y = get(get(handles.axes_main,'children'), 'yData');
fig = figure;
if(iscell(x))
    for i=size(x,1):-1:1
        plot(x{i}, y{i});
        hold on;
    end
else
    plot(x, y);
    grid on;
end

[aa, bb, cc] = fileparts(handles.file);

print(fig,'-dpng','-r0',bb);
%close(fig);
save([bb '_print_data_x_y'], 'x','y');


function checkbox_filter_auto_apply_Callback(hObject, eventdata, handles)
if(get(hObject,'value'))
    
    set(handles.pushbutton_man_filter_apply, 'visible', 'off');
    set(handles.checkbox_auto_filt_mic_power, 'string', 'Power');
    set(handles.uipanel_auto_filt_mic, 'visible', 'off');
    pause(0.1);
    set(handles.uipanel_auto_filt_ecg, 'visible', 'on');
    set(handles.uipanel_auto_filt_mic, 'title', 'MIC');
    set(handles.uipanel_auto_filt_mic, 'visible', 'on');
else
    set(handles.uipanel_auto_filt_ecg, 'visible', 'off');
    pause(0.1);
    set(handles.uipanel_auto_filt_mic, 'visible', 'off');
    set(handles.checkbox_auto_filt_mic_power, 'string', 'Notch');
    pause(0.1);
    set(handles.uipanel_auto_filt_mic, 'title', 'Options');
    set(handles.uipanel_auto_filt_mic, 'visible', 'on');
    set(handles.pushbutton_man_filter_apply, 'visible', 'on');
end
plotWithNewConfig(handles);

function edit_auto_filt_ecg_low_fc_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_filt_ecg_low_fc_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_auto_filt_ecg_low_order_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_filt_ecg_low_order_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_auto_filt_ecg_median_len_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_filt_ecg_median_len_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_auto_filt_ecg_power_win_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_filt_ecg_power_win_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_auto_filt_ecg_power_order_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_filt_ecg_power_order_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_auto_filt_mic_power_order_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_filt_mic_power_order_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox16_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function checkbox17_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function checkbox18_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit8_Callback(hObject, eventdata, handles)


function edit8_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit9_Callback(hObject, eventdata, handles)


function edit9_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit10_Callback(hObject, eventdata, handles)


function edit10_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit11_Callback(hObject, eventdata, handles)


function edit11_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit12_Callback(hObject, eventdata, handles)


function edit12_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit17_Callback(hObject, eventdata, handles)


function edit17_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_auto_filt_mic_power_win_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_filt_mic_power_win_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_auto_filt_mic_high_fc_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_filt_mic_high_fc_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_auto_filt_mic_low_order_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_filt_mic_low_order_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_auto_filt_mic_low_fc_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_filt_mic_low_fc_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox_auto_filt_mic_power_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function checkbox20_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function checkbox_auto_filt_mic_low_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function checkbox_auto_filt_mic_high_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_filt_mic_high_order_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_filt_mic_high_order_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function checkbox_auto_filt_ecg_low_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function checkbox_auto_filt_ecg_power_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);


function filterConfig = getFilterConfig(handles)
filterConfig.doFilt = 0;

filterConfig.autoApply = get(handles.checkbox_filter_auto_apply,'value');

filterConfig.auto_filt.ecg.low.active = get(handles.checkbox_auto_filt_ecg_low,'value');
filterConfig.auto_filt.ecg.low.fc = str2double(get(handles.edit_auto_filt_ecg_low_fc,'string'));
filterConfig.auto_filt.ecg.low.order = str2double(get(handles.edit_auto_filt_ecg_low_order,'string'));

filterConfig.auto_filt.ecg.high.active = get(handles.checkbox_auto_filt_ecg_high,'value');
filterConfig.auto_filt.ecg.high.fc = str2double(get(handles.edit_auto_filt_ecg_high_fc,'string'));
filterConfig.auto_filt.ecg.high.order = str2double(get(handles.edit_auto_filt_ecg_high_order,'string'));

filterConfig.auto_filt.ecg.ma.active = get(handles.checkbox_auto_filt_ecg_ma,'value');
filterConfig.auto_filt.ecg.ma.len = str2double(get(handles.edit_auto_filt_ecg_ma_len,'string'));

filterConfig.auto_filt.ecg.median.active = get(handles.checkbox_auto_filt_ecg_median,'value');
filterConfig.auto_filt.ecg.median.len = str2double(get(handles.edit_auto_filt_ecg_median_len,'string'));

filterConfig.auto_filt.ecg.power.active = get(handles.checkbox_auto_filt_ecg_power,'value');
filterConfig.auto_filt.ecg.power.win = str2double(get(handles.edit_auto_filt_ecg_power_win,'string'));
filterConfig.auto_filt.ecg.power.order = str2double(get(handles.edit_auto_filt_ecg_power_order,'string'));
filterConfig.auto_filt.ecg.power.freq = str2double(get(handles.edit_auto_filt_ecg_power_freq,'string'));

filterConfig.auto_filt.mic.low.active = get(handles.checkbox_auto_filt_mic_low,'value');
filterConfig.auto_filt.mic.low.fc = str2double(get(handles.edit_auto_filt_mic_low_fc,'string'));
filterConfig.auto_filt.mic.low.order = str2double(get(handles.edit_auto_filt_mic_low_order,'string'));

filterConfig.auto_filt.mic.high.active = get(handles.checkbox_auto_filt_mic_high,'value');
filterConfig.auto_filt.mic.high.fc = str2double(get(handles.edit_auto_filt_mic_high_fc,'string'));
filterConfig.auto_filt.mic.high.order = str2double(get(handles.edit_auto_filt_mic_high_order,'string'));

filterConfig.auto_filt.mic.power.active = get(handles.checkbox_auto_filt_mic_power,'value');
filterConfig.auto_filt.mic.power.win = str2double(get(handles.edit_auto_filt_mic_power_win,'string'));
filterConfig.auto_filt.mic.power.order = str2double(get(handles.edit_auto_filt_mic_power_order,'string'));

% Man apply filters
filterConfig.man_filt.low.active = get(handles.checkbox_auto_filt_mic_low,'value');
filterConfig.man_filt.high.active = get(handles.checkbox_auto_filt_mic_high,'value');
filterConfig.man_filt.power.active = get(handles.checkbox_auto_filt_mic_power,'value');

filterConfig.man_filt.low.fc = str2double(get(handles.edit_auto_filt_mic_low_fc,'string'));
filterConfig.man_filt.low.order = str2double(get(handles.edit_auto_filt_mic_low_order,'string'));
filterConfig.man_filt.high.fc = str2double(get(handles.edit_auto_filt_mic_high_fc,'string'));
filterConfig.man_filt.high.order = str2double(get(handles.edit_auto_filt_mic_high_order,'string'));
filterConfig.man_filt.power.win = str2double(get(handles.edit_auto_filt_mic_power_win,'string'));
filterConfig.man_filt.power.order = str2double(get(handles.edit_auto_filt_mic_power_order,'string'));


if(filterConfig.autoApply)
    if(filterConfig.auto_filt.ecg.low.active || filterConfig.auto_filt.ecg.high.active || filterConfig.auto_filt.ecg.median.active || filterConfig.auto_filt.ecg.ma.active || filterConfig.auto_filt.ecg.power.active || filterConfig.auto_filt.mic.low.active || filterConfig.auto_filt.mic.high.active || filterConfig.auto_filt.mic.power.active)
        filterConfig.doFilt = 1;
    end
else
    if(filterConfig.man_filt.low.active || filterConfig.man_filt.high.active || filterConfig.man_filt.power.active)
        filterConfig.doFilt = 1;
    end
end

function checkbox_auto_filt_ecg_median_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function pushbutton_man_filter_apply_Callback(hObject, eventdata, handles)
pushbutton_update_plot_Callback(hObject, eventdata, handles);


function pushbutton_ecg_generate_report_Callback(hObject, eventdata, handles)
global GCF;
ngoFileName = getappdata(GCF, 'ngoOut');
if(isempty(ngoFileName))
    updateTextbox(handles.text1, 'NGO file is not available. Run the analysis first.', 'Replace');
    return;
end
generateResultsReportForSingleFile(ngoFileName);


function pushbutton_run_ecg_analysis_Callback(hObject, eventdata, handles)

global GCF;
analysisSteps = str2double(get(handles.edit_ecg_steps, 'string'));
ERROR_CODES = getappdata(GCF, 'ERROR_CODES');
waitbarHandle = createWaitBar('Performing ECG analysis on the data...');
ecgVisConfig = getECGVisConfig(handles);

dontDisturb = get(handles.checkbox_dont_disturb, 'value');

setappdata(GCF, 'ngoOut', '');
try % To get the data
    rawData = getappdata(GCF, 'rawData');
    metaData = getappdata(GCF, 'metaData');
    if(isempty(rawData) || isempty(metaData))
        updateTextbox(handles.text1, 'Data is not avaiable', 'Replace');
        destroyWaitBar(waitbarHandle);
        return;
    end
    
    ECGChs = includeActiveECGChs(handles, getChannelsByType(metaData, 'ECG'));
    
    for i=1:min(numel(ECGChs), 4)
        pos = getECGSensorPos(metaData, ECGChs(i));
        set(handles.(['text_ecg_config_ch' num2str(i)]), 'string', pos);
        set(handles.(['text_ecg_config_ch' num2str(i)]), 'visible', 'on');
    end
    ecgData = rawData(ECGChs, :);
    isCont = 1;
catch excp
    dlg = warndlg('An error has occured during run time, refer to the log file or the command window for more info');     disp(excp.getReport());     pause(2);     try, close(dlg); end
    isCont = 0;
    notify(handles, 'error', ERROR_CODES.LOADING);
    destroyWaitBar(waitbarHandle);
end

if(analysisSteps==0)
    destroyWaitBar(waitbarHandle);
    return;
end

% Start the configuration provider
global configProvider;
if(~isempty(configProvider))
    configProvider = []; %#ok<NASGU>
end
configProvider = ConfigProvider(); %#ok<MFAMB>

if(isfield(metaData, 'Samplerate'))
    Fs = metaData.Samplerate;
elseif(isfield(metaData, 'Fs'))
    metaData.Samplerate = metaData.Fs;
else
    metaData.Samplerate = 1000;
end

if(~isfield(metaData, 'Age'))
    metaData.Age = 31;
end

metaData = rmfield(metaData, 'channelType');
for i=1:metaData.nNumOfChannels
    %metaData.channelType{i} = metaData.ChannelsTypes{i};
    metaData.channelType(i).value = metaData.ChannelsTypes(i).value;
end

% update the configProvider
configProvider = configProvider.initiate('', metaData.Samplerate);
configProvider = configProvider.setConfigVal(configProvider.getConfigID('saturation'), metaData.satLevel); % Saturation level
configProvider = configProvider.setConfigVal(configProvider.getConfigID('channelstypes'), metaData.channelType); % Channels types
calcMaxPredMHR = 220 - metaData.Age;
configProvider = configProvider.setConfigVal(configProvider.getConfigID('maxPredMHR'), calcMaxPredMHR);
configProvider = configProvider.setConfigVal(configProvider.getConfigID('ecgchannels'), ECGChs);
configProvider = configProvider.setConfigVal(configProvider.getConfigID('numECGChannels'), length(ECGChs));
configProvider = configProvider.setConfigVal(configProvider.getConfigID('numActiveECGChannels'), length(ECGChs));

try % To filter the data
    
    filterConfig = getFilterConfig(handles);
    if(~filterConfig.autoApply)
        filterConfig.autoApply = 1;
    end
    filterConfig.apply2All = 1;
    filterConfig.dataType = 'ECG';
    filterConfig.auto_filt.ecg.median.active = 0;
    filterConfig.auto_filt.ecg.Fs = metaData.Fs;
    
    % Update the config provider
    configProvider = configProvider.setConfigVal(configProvider.getConfigID('ECGFiltsAll'), filterConfig.auto_filt.ecg);
    
    % Low pass, powerline, MA
    [~, filtECGData] = doFilter(filterConfig, ecgData); % dont save the filtered data to the 'GCF'
    isCont = 1;
catch excp
    dlg = warndlg('An error has occured during run time, refer to the log file or the command window for more info');     disp(excp.getReport());     pause(2);     try, close(dlg); end
    notify(handles, 'error', ERROR_CODES.FILTERING);
    destroyWaitBar(waitbarHandle);
    isCont = 0;
    return;
end

try % To prepare the data for maternal QRS detection
    [filtData, chnlInclude, closestElectrode] = doExamine(ecgData', filtECGData, 'ECG'); % dont save the filtered data to the 'GCF'
    
    % For maternal QRS detection
    filterConfig.auto_filt.ecg.low.active = 0;
    filterConfig.auto_filt.ecg.high.active = 0;
    filterConfig.auto_filt.ecg.power.active = 0;
    filterConfig.auto_filt.ecg.ma.active = 0;
    filterConfig.auto_filt.ecg.median.active = 1;
    if(~any(chnlInclude))
        notify(handles, 'error', ERROR_CODES.ECG.INVALID_DATA);
        destroyWaitBar(waitbarHandle);
        return;
    end
    [~, matECGData] = doFilter(filterConfig, filtData); % dont save the filtered data to the 'GCF'
    
    %     disp(chnlInclude);
    isCont = 1;
catch excp
    dlg = warndlg('An error has occured during run time, refer to the log file or the command window for more info');     disp(excp.getReport());     pause(2);     try, close(dlg); end
    notify(handles, 'error', ERROR_CODES.ECG.EXAMINE_DATA);
    destroyWaitBar(waitbarHandle);
    isCont = 0;
    return;
end


try % To perform maternal QRS detection
    doLoad = 0;
    try % To load saved data
        res = which('analyzer');
        [aa, bb, cc] = fileparts(res);
        if(~isempty(aa))
            savePath = [aa '\Output\mQRSDetection'];
            [aa, bb, cc] = fileparts(metaData.fileName);
            fullFileName = [savePath '\' bb];
            
            if(~dontDisturb && exist([fullFileName '.mat'], 'file'))
                choice = questdlg('mQRS positions are avilable in a saved file, load the results? ', ...
                    'Warning', ...
                    'Yes','No. Run again', 'Cancel', 'Cancel');
                % Handle response
                switch choice
                    case 'Yes',
                        doLoad = 1;
                    case 'No. Run again',
                        doLoad = 0;
                    case 'Cancel'
                        doLoad = 2;
                    otherwise,
                        doLoad = 0;
                end
                
                if(doLoad==2)
                    error('Calculations canceled by the user');
                end
                if(doLoad)
                    tempLoad = load(fullFileName);
                    if(isfield(tempLoad, 'mQRS'))
                        mQRS = tempLoad.mQRS;
                        clear tempLoad;
                    else
                        doLoad = 0;
                    end
                end
            end
        end
    catch
        if(doLoad~=2)
            disp('Cannot load results file. Aborting load and running full analysis.');
            doLoad = 0;
        end
        
    end
    
    if(doLoad==2)
        error('ERR:USER_ABORT', 'Calculations canceled by the user');
    end
    if(sum(chnlInclude)>=1 && ~doLoad)
        tic;
        [mQRS_struct, mTwave_struct] = doDetect('filtData',filtECGData, 'matData', matECGData, 'chnlInclude', chnlInclude);
        dTime = toc;
        if(isfield(mQRS_struct, 'err'))
            notify(handles, 'error', ERROR_CODES.ECG.MQRS_DETECTION);
            if(mQRS_struct.err == -1)
                updateTextbox(handles.text1, ['@doDetect :: ' mQRS_struct.resStr], 'add');
            end
            return;
        end
        
        matDetectionSum = sprintf('%s \n ->%s \n ->%s \n ->%s \n ->%s \n ->%s \n', 'Maternal QRS detection summary:',...
            ['Chs available for the detection: ' num2str(find(chnlInclude))],...
            ['Chs used for the detection: ' num2str(find(mQRS_struct.leadsInclude))],...
            ['Best lead for detection: ' num2str(mQRS_struct.bestLead)],...
            ['Detection reliability: ' num2str(mQRS_struct.rel) '%'],...
            ['Detection duration: ' num2str(round(dTime, 2)) ' Sec']...
            );
        disp(round(dTime, 2))
        updateTextbox(handles.text1, matDetectionSum, 'replace');
        set(handles.text1, 'HorizontalAlignment', 'left');
        
        mQRS.mQRS_struct = mQRS_struct;
        mQRS.mTwave_struct = mTwave_struct;
        
        mQRS.matDetectionSum = matDetectionSum;
        setappdata(GCF, 'mQRS', mQRS);
        
        isCont = 1;
    else
        if(~doLoad)
            notify(handles, 'error', ERROR_CODES.ECG.INVALID_DATA);
            destroyWaitBar(waitbarHandle);
            isCont = 0;
            return;
        end
    end
catch excp
    if(strcmpi(excp.identifier, 'ERR:USER_ABORT'))
        notify(handles, 'error', ERROR_CODES.USER_ABORT);
    else
        dlg = warndlg('An error has occured during run time, refer to the log file or the command window for more info');     disp(excp.getReport());     pause(2);     try, close(dlg); end
        notify(handles, 'error', ERROR_CODES.ECG.MQRS_DETECTION);
    end
    destroyWaitBar(waitbarHandle);
    isCont = 0;
    return;
end

try % To calculate maternal HR curve
    mQRS.RR = diff(mQRS.mQRS_struct.pos)/metaData.Fs;
    mQRS.HRC.samps = 1./mQRS.RR*60;
    reps = round(mQRS.RR/0.1);
    res = [];
    for i=1:length(mQRS.HRC.samps)
        res = [res repmat(mQRS.HRC.samps(i), 1, reps(i))];
    end
    opts.size = floor(median(reps));
    sig = smooth(res, 'MA', opts);
    sig = sig(1:1/0.1:end);
    sig = smooth(sig);
    sig = sig(2:end-1);
    %     sig = resample([sig sig sig], 2,1); % upsame the signal
    %     sig = sig(length(sig)/3:2*length(sig)/3);
    mQRS.HRC.time = sig;
    setappdata(GCF, 'mQRS', mQRS);
catch excp
    dlg = warndlg('An error has occured during run time, refer to the log file or the command window for more info');
    disp(excp.getReport());
    pause(2);
    try
        close(dlg);
    end
    return;
end

try % To visualize the results
    if(ecgVisConfig.autoVis)
        mQRS.chnlInclude = chnlInclude;
        
        %visChnl = chnlInclude;
        %visChnl(visChnl) = mQRS.mQRS_struct.leadsInclude(mQRS.mQRS_struct.leadsInclude>0);
        
        keepPlot = 0; % TBU
        if(keepPlot)
            axes(handles.axes_main);
            cla;
            plotWithNewConfig(handles, 1); drawnow;
            hold on;
            spec = {'*r', 'ok', 'sm', 'vr', '>r', '<r'};
            x = get(get(handles.axes_main,'children'), 'xData');
            y = get(get(handles.axes_main,'children'), 'yData');
            if(iscell(x))
                for i=1:length(x)
                    val(i) = max(abs(y{i}));
                end
                [vv, ind]= max(val(i));
            else
                ind = 1;
            end
            Y = y{ind};
            if(abs(min(Y))>abs(max(Y)))
                spec = '^';
            else
                spec = 'v';
            end
            spec = [spec 'b'];
            plot(mQRS.mQRS_struct.pos/metaData.Fs, Y(mQRS.mQRS_struct.pos), spec);
            
            % Maternal T wave
            plot(mQRS.mTwave_struct.pos/metaData.Fs, Y(mQRS.mTwave_struct.pos), spec);
            
            
            hold off;
        else
            setappdata(GCF, 'mQRS', mQRS);
            visECGRes('online', handles);
        end
    end
catch excp
    dlg = warndlg('An error has occured during run time, refer to the log file or the command window for more info');     disp(excp.getReport());     pause(2);     try, close(dlg); end
end

try % To save the results
    if(~doLoad)
        % Save the mQRS positions
        res = which('analyzer');
        [aa, bb, cc] = fileparts(res);
        if(~isempty(aa))
            savePath = [aa '\Output\mQRSDetection'];
            if(~isdir(savePath))
                mkdir(savePath);
            end
            [aa, bb, cc] = fileparts(metaData.fileName);
            mQRS.info = 'The R wave positions are in mQRS.mQRS_struct.pos';
            fullFileName = [savePath '\' bb];
            doSave = 1;
            
            if(~dontDisturb && exist([fullFileName '.mat'], 'file'))
                doSave = 0;
                choice = questdlg('File already exists, override results?', ...
                    'Warning', ...
                    'Yes','No. Save new file', 'Cancel', 'Cancel');
                % Handle response
                switch choice
                    case 'Yes',
                        doSave = 1;
                    case 'No. Save new file',
                        saveTime = datestr(datetime());
                        saveTime(saveTime==':') = '-';
                        fullFileName = [fullFileName '_' saveTime];
                        doSave = 1;
                    case 'Cancel',
                        doSave = 0;
                end
            end
            
            if(doSave)
                save(fullFileName, 'mQRS');
                disp('Results saved.');
            else
                disp('Results not saved.');
            end
        end
    end
catch excp
    dlg = warndlg('An error has occured during run time, refer to the log file or the command window for more info');     disp(excp.getReport());     pause(2);     try, close(dlg); end
end

if(analysisSteps==1)
    destroyWaitBar(waitbarHandle);
    return;
end

try % To remove mECG
    doLoad = 0;
    try % To load saved data
        res = which('analyzer');
        [aa, bb, cc] = fileparts(res);
        if(~isempty(aa))
            savePath = [aa '\Output\mECGElimination'];
            [aa, bb, cc] = fileparts(metaData.fileName);
            fullFileName = [savePath '\' bb];
            
            if(~dontDisturb && exist([fullFileName '.mat'], 'file'))
                choice = questdlg('mECG data is available in a saved file, load the results? ', ...
                    'Warning', ...
                    'Yes','No. Run again', 'Cancel', 'Cancel');
                % Handle response
                switch choice
                    case 'Yes',
                        doLoad = 1;
                    case 'No. Run again',
                        doLoad = 0;
                    case 'Cancel'
                        doLoad = 2;
                    otherwise,
                        doLoad = 0;
                end
                
                if(doLoad==2)
                    error('Calculations canceled by the user');
                end
                
                if(doLoad)
                    tempLoad = load(fullFileName);
                    if(isfield(tempLoad, 'removeStruct'))
                        removeStruct = tempLoad.removeStruct;
                        clear tempLoad;
                    else
                        doLoad = 0;
                    end
                end
            end
        end
    catch
        
        if(doLoad~=2)
            disp('Cannot load results file. Aborting load and running full analysis.');
            doLoad = 0;
        end
        
    end
    if(doLoad==2)
        error('ERR:USER_ABORT', 'Calculations canceled by the user');
    end
    
    if(~doLoad)
        removeStruct = doRemove('filtData',filtECGData, 'matData', matECGData, 'mQRS_struct', mQRS.mQRS_struct);
    end
    
catch excp
    if(strcmpi(excp.identifier, 'ERR:USER_ABORT'))
        notify(handles, 'error', ERROR_CODES.USER_ABORT);
    else
        dlg = warndlg('An error has occured during run time, refer to the log file or the command window for more info');     disp(excp.getReport());     pause(2);     try, close(dlg); end
        notify(handles, 'error', ERROR_CODES.ECG.MECG_ELIMINATION);
    end
    
    pause(2);
    try
        close(dlg);
    catch % nothing
    end
    
    return;
end

try % To visualize the result
    if(ecgVisConfig.autoVis && analysisSteps~=3)
        % Show the results
        tit = {'Filtered data', 'Maternal data', 'Fetal data'};
        for i=1:size(removeStruct.filtData, 1)
            visData = [removeStruct.filtData(i,:);...
                removeStruct.matData(i,:);...
                removeStruct.fetData(i,:);];
            [fig(i), ax] = subPlot(visData);
            for j=1:numel(tit)
                axes(ax(j)); title(tit{j});
            end
            set(fig(i), 'name', ['Channel #' num2str(i)])
        end
        for i=size(removeStruct.filtData, 1):-1:1
            figure(fig(i));
        end
    end
catch
    dlg = warndlg('An error has occured during run time, refer to the log file or the command window for more info');     disp(excp.getReport());     pause(2);     try, close(dlg); end
end

try % To save the result
    if(~doLoad)
        % Save the results
        res = which('analyzer');
        [aa, bb, cc] = fileparts(res);
        if(~isempty(aa))
            savePath = [aa '\Output\mECGElimination'];
            if(~isdir(savePath))
                mkdir(savePath);
            end
            [aa, bb, cc] = fileparts(metaData.fileName);
            mQRS.info = 'The R wave positions are in mQRS.mQRS_struct.pos';
            fullFileName = [savePath '\' bb];
            doSave = 1;
            
            if(~dontDisturb && exist([fullFileName '.mat'], 'file'))
                doSave = 0;
                choice = questdlg('File already exists, override results?', ...
                    'Warning', ...
                    'Yes','No. Save new file', 'Cancel', 'Cancel');
                % Handle response
                switch choice
                    case 'Yes',
                        doSave = 1;
                    case 'No. Save new file',
                        saveTime = datestr(datetime());
                        saveTime(saveTime==':') = '-';
                        fullFileName = [fullFileName '_' saveTime];
                        doSave = 1;
                    case 'Cancel',
                        doSave = 0;
                end
            end
            
            if(doSave)
                save(fullFileName, 'removeStruct');
                disp('Results saved.');
            else
                disp('Results not saved.');
            end
        end
    end
catch
    dlg = warndlg('An error has occured during run time, refer to the log file or the command window for more info');     disp(excp.getReport());     pause(2);     try, close(dlg); end
end

if(analysisSteps==2)
    destroyWaitBar(waitbarHandle);
    return;
end

try % To pre-proc the fetal ECG
    config = configProvider.getConfigVal(configProvider.getConfigID('fECGPreProcICAAll'));
    cfg1 = configProvider.getConfigVal(configProvider.getConfigID('fECGPreProcAll'));
    config = structCopy(config, cfg1);
    [fetSignal, fetECGData, bestFetLead] = preProcFetalData('ecg', removeStruct, 'ica', config);
    chnlInclude = ones(min(size(fetSignal)), 1);
catch excp
    dlg = warndlg('An error has occured during run time, refer to the log file or the command window for more info');     disp(excp.getReport());     pause(2);     try, close(dlg); end
    destroyWaitBar(waitbarHandle);
    return;
end

try % To perform fetal QRS detection
    doLoad = 0;
    try % To load saved data
        res = which('analyzer');
        [aa, bb, cc] = fileparts(res);
        if(~isempty(aa))
            savePath = [aa '\Output\fQRSDetection'];
            [aa, bb, cc] = fileparts(metaData.fileName);
            fullFileName = [savePath '\' bb];
            
            if(~dontDisturb && exist([fullFileName '.mat'], 'file'))
                choice = questdlg('fQRS positions are avilable in a saved file, load the results? ', ...
                    'Warning', ...
                    'Yes','No. Run again', 'Cancel', 'Cancel');
                % Handle response
                switch choice
                    case 'Yes',
                        doLoad = 1;
                    case 'No. Run again',
                        doLoad = 0;
                    case 'Cancel',
                        doLoad = 2;
                    otherwise,
                        doLoad = 0;
                end
                
                if(doLoad==2)
                    error('Calculations canceled by the user');
                end
                
                if(doLoad)
                    tempLoad = load(fullFileName);
                    if(isfield(tempLoad, 'fQRS'))
                        fQRS = tempLoad.fQRS;
                        clear tempLoad;
                    else
                        doLoad = 0;
                    end
                end
            end
        end
    catch
        if(doLoad~=2)
            disp('Cannot load results file. Aborting load and running full analysis.');
            doLoad = 0;
        end
    end
    
    if(doLoad==2)
        error('ERR:USER_ABORT', 'Calculations canceled by the user');
    end
    
    if(~doLoad)
        configProvider = configProvider.setConfigVal(configProvider.getConfigID('proctype'), 'fetal');
        tic;
        fQRS_struct = doDetect('filtData',fetSignal, 'fetData', fetECGData, 'type', 'fetal', 'chnlInclude', chnlInclude, 'mQRS_struct', mQRS.mQRS_struct, 'bestFetLead', bestFetLead, 'removeStruct', removeStruct);
        dTime = toc;
        fQRS.fQRS_struct = fQRS_struct;
        
        ngoFileName = strrep(strrep(handles.file, getNGFBaseDir(), getNGOBaseDir()), '.ngf', '.ngo');
        removeStruct.metaData = metaData;
        res = generateNGO(mQRS.mQRS_struct, removeStruct, fQRS_struct, ngoFileName);
        if(res)
            setappdata(GCF, 'ngoOut', ngoFileName);
        end
        
    end
catch excp
    dlg = warndlg('An error has occured during run time, refer to the log file or the command window for more info');     disp(excp.getReport());     pause(2);     try, close(dlg); end
    destroyWaitBar(waitbarHandle);
    return;
end

autoSave = 0;
try % To visualize the results
    if(ecgVisConfig.autoOpenResearchApp)
        
        if(exist('fullFileName', 'var') && ~isempty(fullFileName))
            if(isempty(strfind(fullFileName, '.mat')))
                fullFileName = [fullFileName, '.mat'];
            end
            fetalAnalyzer([], 'filename', fullFileName);
            autoSave = 1;
        end
    else
        if(ecgVisConfig.autoVis)
            fQRS.chnlInclude = chnlInclude;
            
            %         visChnl = chnlInclude;
            %         visChnl(visChnl) = fQRS.fQRS_struct.leadsInclude;
            
            setappdata(GCF, 'fQRS', fQRS);
            %         visECGRes('online', handles);
            if(ecgVisConfig.autoVis)
                % Show the results
                tit = {'Filtered data', 'Fetal data'};
                timeBase = (1:length(removeStruct.filtData(1,:)))/(metaData.Fs);
                matSpec = '^r';
                fetSpec = {'ok', '*g'};
                
                annotfQRSPos = [];
                
                if(~dontDisturb && isfield(metaData, 'annotfQRSPos'))
                    choice = questdlg('Annotated results are available, load it?', ...
                        'Warning', ...
                        'Yes', 'No', 'No');
                    % Handle response
                    switch choice
                        case 'Yes'
                            annotfQRSPos = metaData.annotfQRSPos;
                        case 'No'
                            %lateze
                    end
                end
                
                for i=1:size(removeStruct.filtData, 1)
                    visData = [removeStruct.filtData(i,:);...
                        removeStruct.fetData(i,:);];
                    fig(i) = figure;
                    ax(1) = subplot(2, 1, 1);
                    plotWithPeaks(removeStruct.filtData(i,:), mQRS.mQRS_struct.pos, 0, timeBase, matSpec);
                    ax(2) = subplot(2, 1, 2);
                    plotWithPeaks(removeStruct.fetData(i,:), {fQRS.fQRS_struct.fQRS annotfQRSPos}, 0, timeBase, fetSpec);
                    if(~isempty(annotfQRSPos))
                        legend(' ', 'Calulated', 'Annotated');
                    end
                    
                    linkaxes(ax, 'x');
                    for j=1:numel(tit)
                        axes(ax(j)); title(tit{j});
                    end
                    set(fig(i), 'name', ['Channel #' num2str(i)])
                end
                for i=size(removeStruct.filtData, 1):-1:1
                    figure(fig(i));
                end
                
                plotf(medfilt1(60./(diff(fQRS.fQRS_struct.fQRS)/metaData.Fs),3))
                if(~isempty(annotfQRSPos))
                    plotf(60./(diff(annotfQRSPos)/metaData.Fs), 1);
                    legend('Calulated', 'Annotated');
                end
                
                title('Noisy beat-2-beat fHR');
                xlabel('Beat')
                ylabel('Heart rate [BPM]');
                leadsNames = getECGLeadsNames(metaData);
                fetDetectionSum = sprintf('%s \n ->%s \n ->%s \n ->%s \n ->%s \n ->%s \n ->%s \n', 'Fetal QRS detection summary:',...
                    ['Chs available for the detection: ' num2str(find(chnlInclude'))],...
                    ['ECG Leads: ' leadsNames{find(fQRS_struct.leadsInclude)}],...
                    ['Chs used for the detection: ' num2str(find(fQRS_struct.leadsInclude))],...
                    ['Best lead data: ' num2str(fQRS_struct.bestLead)],...
                    ['Best lead for detection: ' num2str(fQRS_struct.bestLeadPeaks)],...
                    ['Detection duration: ' num2str(round(dTime, 2)) ' Sec']...
                    );
                updateTextbox(handles.text1, fetDetectionSum, 'replace');
                
            end
        end
    end
catch excp
    dlg = warndlg('An error has occured during run time, refer to the log file or the command window for more info');     disp(excp.getReport());     pause(2);     try, close(dlg); end
end

try % To save the results
    if(~doLoad)
        % Save the mQRS positions
        res = which('analyzer');
        [aa, bb, cc] = fileparts(res);
        if(~isempty(aa))
            savePath = [aa '\Output\fQRSDetection'];
            if(~isdir(savePath))
                mkdir(savePath);
            end
            [aa, bb, cc] = fileparts(metaData.fileName);
            mQRS.info = 'The R wave positions are in fQRS.fQRS_struct.pos';
            fullFileName = [savePath '\' bb];
            doSave = 1;
            
            if(~dontDisturb && ~autoSave && exist([fullFileName '.mat'], 'file'))
                doSave = 0;
                choice = questdlg('File already exists, override results?', ...
                    'Warning', ...
                    'Yes','No. Save new file', 'Cancel', 'Cancel');
                % Handle response
                switch choice
                    case 'Yes',
                        doSave = 1;
                    case 'No. Save new file',
                        saveTime = datestr(datetime());
                        saveTime(saveTime==':') = '-';
                        fullFileName = [fullFileName '_' saveTime];
                        doSave = 1;
                    case 'Cancel',
                        doSave = 0;
                end
            end
            
            if(doSave)
                save(fullFileName, 'fQRS');
                disp('Results saved.');
            else
                disp('Results not saved.');
            end
        end
    end
catch excp
    dlg = warndlg('An error has occured during run time, refer to the log file or the command window for more info');     disp(excp.getReport());     pause(2);     try, close(dlg); end
end

if(analysisSteps==3)
    destroyWaitBar(waitbarHandle);
    return;
end

destroyWaitBar(waitbarHandle);

function pushbutton_meta_full_info_Callback(hObject, eventdata, handles)
global GCF;

metaData = getappdata(GCF, 'metaData');
if(isempty(metaData))
    disp('Meta data is not available');
    updateTextbox(handles.text1, 'Metadata is not available', 'replace');
    return;
end
disp(metaData);
updateTextbox(handles.text1, 'Metadata was displayed on command window', 'replace');

try
    if(strcmpi(metaData.db, 'nifecg'))
        !"D:\\Box_Sync\\""Ritmo R&D""\\Muhammad\\RnD\\Data\\nifecgdb\\metaInfo.xlsx" &
        disp('file opened');
    end
end


function updateMeta()
global GCF;
metaData = getappdata(GCF, 'metaData');
handles = getappdata(GCF, 'UsedByGUIData_m');
pnl = handles.uipanel14;
%basePos = get(pnl, 'position');
yS = 1;
x1 = 0.1;
wid = 0.3;
hit = 0.065;
x2 = 2*0.1 + wid;

flds = fields(metaData);
isCrt = 0;
for i = 1:length(flds)
    switch(flds{i})
        case {'fileName'},
            strName = 'FileName';
            strVal = metaData.(flds{i});
            isCrt = 1;
        case {'db'},
            strName = 'Database';
            strVal = metaData.(flds{i});
            isCrt = 1;
        case {'daq'},
            strName = 'DAQ';
            strVal = metaData.(flds{i});
            isCrt = 1;
        case {'Fs'},
            strName = 'Fs';
            strVal = metaData.(flds{i});
            isCrt = 1;
        case {'nNumOfChannels'},
            strName = '#Channels';
            strVal = metaData.(flds{i});
            isCrt = 1;
        case {'Gestation'},
            strName = 'Gest. age';
            strVal = metaData.(flds{i});
            if(isfield(metaData.Gestation, 'week'))
                strVal = num2str(metaData.Gestation.week);
            end
            if(isfield(metaData.Gestation, 'day'))
                strVal = [strVal '.' num2str(metaData.Gestation.day)];
            end
            isCrt = 1;
            
        otherwise,
            isCrt = 0;
    end
    if(isCrt)
        yS = yS-2*hit;
        txt = uicontrol(pnl, 'Style','text',...
            'String', strName,...
            'Units', 'normalized',...
            'backgroundcolor', [1 1 1],...
            'FontSize',10,...
            'Position', [x1 yS wid hit]);
        %         jh = findjobj(txt);
        %         jh.setVerticalAlignment(javax.swing.AbstractButton.CENTER);
        
        
        if(strcmpi(strName, 'FileName'))
            txt = uicontrol(pnl, 'Style','text',...
                'String', strVal,...
                'Units', 'normalized',...
                'backgroundcolor', [1 1 1],...
                'FontSize',10,...
                'Position', [x2 yS wid hit],...
                'ButtonDownFcn', @openFileFolder);
        else
            txt = uicontrol(pnl, 'Style','text',...
                'String', strVal,...
                'Units', 'normalized',...
                'backgroundcolor', [1 1 1],...
                'FontSize',10,...
                'Position', [x2 yS wid hit]);
        end
        
    end
    
end


function pushbutton12_Callback(hObject, eventdata, handles)


function run_spec(handles)

function dataType = run_ica(handles)
global GCF;
icaConfig = getICAConfig(handles);

dataType = lower(icaConfig.useData);
switch lower(icaConfig.useData)
    case {'filtered'},
        filterConfig = getFilterConfig(handles);
        [~, filtData] = doFilter(filterConfig, getappdata(GCF, 'rawData'));
        %         filtData = getappdata(GCF, 'filtData');
        if(isempty(filtData) || (max(size(filtData))==1 && filtData==-1))
            setappdata(GCF, 'icaData', -1);
            updateTextbox(handles.text1, 'Cannot perform ICA on the filtered data.', 'replace');
            return;
        end
        useData = filtData;
    case {'raw'},
        rawData = getappdata(GCF, 'rawData');
        if(isempty(rawData) || (max(size(rawData))==1 && rawData==-1))
            setappdata(GCF, 'icaData', -1);
            updateTextbox(handles.text1, 'Cannot perform ICA on the raw data.', 'replace');
            return;
        end
        useData = rawData;
    otherwise,
        useData = -1;
        setappdata(GCF, 'icaData', -1);
        updateTextbox(handles.text1, 'Cannot perform ICA on the selected type of data.', 'replace');
        return;
end

flds = fields(icaConfig);
inData = useData(:, icaConfig.chnls>0);
input = 'inData''';
for i=1:length(flds)-2
    fld = ['''' flds{i} ''''];
    if(isnumeric(icaConfig.(flds{i})))
        val = ['str2double(' '''' num2str(icaConfig.(flds{i})) '''' ')'];
    else
        val = ['''' icaConfig.(flds{i}) ''''];
    end
    input = [input ', ' fld ',' val];
end

eval(['icaData = fastica(' input ')'';']);
if(isempty(icaData))
    icaData = -1;
end
setappdata(GCF, 'icaData', icaData);

function icaConfig = getICAConfig(handles)
global GCF;
nons = {'pow3', 'tanh', 'gauss', 'skew'};
icaConfig.g = nons{get(handles.popupmenu_ica_nonlinearity, 'value')};
verb = {'off', 'on'};
icaConfig.verbose = verb{get(handles.checkbox_verbose, 'value') + 1};
apps = {'symm', 'defl'};
icaConfig.approach = apps{get(handles.popupmenu_ica_approach, 'value')};

dat = {'filtered', 'raw'};
icaConfig.useData = dat{get(handles.popupmenu_ica_use_data, 'value')};
plotConfig = getappdata(GCF, 'plotConfig');
icaConfig.chnls = plotConfig.chnlSelect;

function popupmenu_ica_nonlinearity_Callback(hObject, eventdata, handles)
if(get(handles.popupmenu_plot_type, 'value')==3)
    plotWithNewConfig(handles);
end

function popupmenu_ica_nonlinearity_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox_verbose_Callback(hObject, eventdata, handles)


function popupmenu_ica_approach_Callback(hObject, eventdata, handles)
if(get(handles.popupmenu_plot_type, 'value')==3)
    plotWithNewConfig(handles);
end


function popupmenu_ica_approach_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function destroyWaitBar(waitbarHandle)

try
    mywaitbar(waitbarHandle); % Kills the waitbar
end

function waitbarHandle = createWaitBar(msg)
waitbarHandle = mywaitbar(0,'Please wait...',msg, true);


function popupmenu_ica_use_data_Callback(hObject, eventdata, handles)
if(get(handles.popupmenu_plot_type, 'value')==3)
    plotWithNewConfig(handles);
end

function popupmenu_ica_use_data_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function chs = getChannelsByType(metaData, type)
chs = [];
for iCh=1:metaData.nNumOfChannels
    if(strcmpi(metaData.channelType{iCh}, type))
        chs = [chs iCh];
    end
end

function updateErrCodes(evnt)
global GCF;
setappdata(GCF, 'ERROR_CODES', getErrorCodes());


function checkbox_auto_filt_ecg_high_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_filt_ecg_high_fc_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_filt_ecg_high_fc_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_auto_filt_ecg_high_order_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);

function edit_auto_filt_ecg_high_order_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox_auto_filt_ecg_ma_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);


function edit_auto_filt_ecg_ma_len_Callback(hObject, eventdata, handles)
plotWithNewConfig(handles);


function edit_auto_filt_ecg_ma_len_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox_ecg_ana_auto_vis_Callback(hObject, eventdata, handles)


function ecgVisConfig = getECGVisConfig(handles)
ecgVisConfig.autoVis = get(handles.checkbox_ecg_ana_auto_vis, 'value');
ecgVisConfig.visChs = get(handles.radiobutton_ecg_ana_vis_chs, 'value');
ecgVisConfig.showHRC = get(handles.checkbox_ecg_ana_HRC, 'value');
dat = {'filtered', 'raw', 'ica'}; % Add more options
ecgVisConfig.useData = dat{get(handles.popupmenu_ecg_ana_vis_data, 'value')};
ecgVisConfig.plotSpec = get(handles.edit_ecg_ana_plot_spec, 'string');
ecgVisConfig.autoOpenResearchApp = get(handles.checkbox_auto_open_research, 'value');


function checkbox_ecg_ana_vis_chs_Callback(hObject, eventdata, handles)


function radiobutton_ecg_ana_vis_chs_Callback(hObject, eventdata, handles)
if(get(hObject, 'value'))
    set(hObject, 'string', 'Best Lead');
else
    set(hObject, 'string', 'All Leads');
end
visECGRes('offline', handles);

function checkbox_ecg_ana_HRC_Callback(hObject, eventdata, handles)
if(get(hObject, 'value'))
    visECGRes('offline', handles);
end
function popupmenu_ecg_ana_vis_data_Callback(hObject, eventdata, handles)
visECGRes('offline', handles);

function popupmenu_ecg_ana_vis_data_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function visECGRes(type, handles, axs, chnl)
global GCF;
if(nargin<3)
    axs = -1;
end
if(nargin<4)
    chnl = 0;
end
if(axs==-1 || isempty(axs))
    axs = handles.axes_main;
end
if(isempty(chnl))
    chnl = 0;
end

ecgVisConfig = getECGVisConfig(handles);
if(isempty(type))
    type = 'offline';
end

if(strcmpi(type, 'online') && ~ecgVisConfig.autoVis)
    return;
end

mQRS = getappdata(GCF, 'mQRS'); % Maternal QRS detection results struct
fQRS = getappdata(GCF, 'fQRS'); % Fetal QRS detection results struct
metaData = getappdata(GCF, 'metaData');
if(isempty(mQRS)) % no mQRS? go home, nothing to show...
    return;
end

if(~chnl)
    if(ecgVisConfig.visChs) % use the data of the best lead only
        visChnls = mQRS.mQRS_struct.bestLeadPeaks;
    else
        visChnls = mQRS.chnlInclude;
        visChnls(visChnls) = mQRS.mQRS_struct.leadsInclude;
    end
else
    visChnls = chnl;
end

if(~isempty(fQRS))
    peaks = fQRS.fQRS_struct.fQRS;
else
    peaks = mQRS.mQRS_struct.pos;
end

switch(ecgVisConfig.useData)
    case 'filtered',
        useData = 'filtData';
        data = getappdata(GCF, useData);
        if(isempty(data))
            filterConfig = getFilterConfig(handles);
            filterConfig.auto_filt.ecg.Fs = metaData.Fs;
            [~, data] = doFilter(filterConfig, getappdata(GCF, 'rawData'));
        end
        %data = getappdata(GCF, useData);
    case 'raw',
        useData = 'rawData';
        data = getappdata(GCF, useData);
    case 'ica',
        useData = 'icaData';
        data = getappdata(GCF, useData);
        if(isempty(data))
            run_ica(handles);
        end
        visChnls = mQRS.chnlInclude;
        data = getappdata(GCF, useData);
    otherwise,
        useData = 'rawData';
        data = getappdata(GCF, useData);
end

visData = data(visChnls, :);

axes(axs);
cla;
timeBase = (1:length(visData))/metaData.Fs;

if(isempty(mQRS.mTwave_struct.pos))
    plotWithPeaks(visData, peaks, 0, timeBase, ecgVisConfig.plotSpec);
else
    plotWithPeaks(visData, {peaks, mQRS.mTwave_struct.pos}, 0, timeBase, []);
end

grid on;
xlabel('Time [Sec]');
ylabel('Amplitude [V]');
hold off;

if(ecgVisConfig.showHRC)
    figure,
    plot(mQRS.HRC.samps);
    %     hold on;
    %     plot(mQRS.HRC.time);
    xlabel('Time [sec]');
    ylabel('HR [bpm]');
    grid on;
end

function edit_ecg_ana_plot_spec_Callback(hObject, eventdata, handles)
visECGRes('offline', handles);

function edit_ecg_ana_plot_spec_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function clearAppData()
global GCF autoFileName;
autoFileName = [];
appData = getappdata(GCF);
flds = fieldnames(appData);
rmFlds = {'Temp', 'rawData', 'nNumOfChannels', 'metaData', 'plotConfig', 'filtData', 'icaData', 'mQRS', 'fQRS'};
for i=1:length(flds)
    if(any(strcmpi(flds{i}, rmFlds)))
        rmappdata(GCF, flds{i});
    end
end


function pushbutton_ecg_ana_split_Callback(hObject, eventdata, handles)
global GCF;
nNumOfChannels = getappdata(GCF, 'nNumOfChannels');
metaData = getappdata(GCF, 'metaData');
fig = figure;

ECGchs = getChannelsByType(metaData, 'ecg');
nNumOfChannels = numel(ECGchs);

for i=1:nNumOfChannels
    axs(i) = subplot(nNumOfChannels, 1, i);
    visECGRes('offline_splitter', handles, axs(i), ECGchs(i));
    axis tight;
end
linkaxes(axs, 'x');

function rawData = checkData(rawData)
a=-1;
% check if there is some missing samples and try to solve the problem
siz = size(rawData,1);
nans = sum(isnan(rawData));
nansPerc = (nans/siz*100)>0.5;%
rawData(:,nansPerc) = nan;
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

function popupmenu_audio_ch_slct_Callback(hObject, eventdata, handles)


function popupmenu_audio_ch_slct_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_audio_play_Callback(hObject, eventdata, handles)
global GCF;

set(handles.pushbutton_audio_play, 'visible', 'off');
set(handles.pushbutton_audio_pause, 'visible', 'on');
playChnl = get(handles.popupmenu_audio_ch_slct, 'value'); % Channel to play
plotConfig = getappdata(GCF, 'plotConfig');

switch(lower(plotConfig.plotType))
    case 'raw',
        dataStr = 'raw';
    case 'filtered',
        dataStr = 'filt';
    case 'ica',
        dataStr = 'ica';
    otherwise,
        return;
end
dataStr = [dataStr 'Data'];
data = getappdata(GCF, dataStr);
if(isempty(data))
    data = getappdata(GCF, 'rawData');
end
metaData = getappdata(GCF, 'metaData');
Fs = metaData.Fs;
MICChs = getChannelsByType(metaData, 'MIC');

playSig = data(:, MICChs(playChnl));
playSig = playSig(:)./max(abs(playSig(:)));

global playObj i;
playObj = audioplayer(playSig, Fs);
set(playObj, 'TimerPeriod', 0.1, 'TimerFcn', @plotAdvnaceDuringPlay)
lenInSecs = length(playSig)/Fs;
pause(0.1);

playObj.play();
i = 0;
timeDelay = 0.1;
axes(handles.axes_main);
cla;
xDataFull = linspace(0, (length(playSig)-1)/Fs, length(playSig));
while(playObj.isplaying() && (i+1)*(timeDelay*Fs)<length(playSig))
    iCurr = i;
    plot(xDataFull, playSig); hold on;
    xData = 1+i*(timeDelay*Fs):(i+1)*(timeDelay*Fs);
    plot(xData/Fs,  playSig(xData));
    xlabel('Time [Sec]');
    grid on;
    hold off;
    while(iCurr==i && playObj.isplaying())
        pause(0.00001);
    end
end
set(handles.pushbutton_audio_pause, 'visible', 'off');
set(handles.pushbutton_audio_play, 'visible', 'on');

function plotAdvnaceDuringPlay(aa, bb)
global i;
i=i+1;

function pushbutton_audio_pause_Callback(hObject, eventdata, handles)
global playObj;
if(~isempty(playObj))
    playObj.pause();
end


function text1_ButtonDownFcn(hObject, eventdata, handles)


function openFileFolder(src, evnt)
global GCF;
handles = getappdata(GCF,'UsedByGUIData_m');
[aa,bb,cc] = fileparts(handles.file);
openFolder(aa);

function saveConfig(configName, configVal)

if(exist('appConfig.mat', 'file'))
    load appConfig.mat;
end
config.(configName) = configVal;

save('appConfig.mat', 'config');

function configVal = loadConfig(configName)
if(exist('appConfig.mat', 'file'))
    load appConfig.mat;
    if(isfield(config, configName))
        configVal = config.(configName);
    else
        configVal = [];
    end
else
    configVal = [];
end


function edit_ecg_steps_Callback(hObject, eventdata, handles)


function edit_ecg_steps_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox_chnl_view_slct_all_ecg_Callback(hObject, eventdata, handles)

set(handles.checkbox_chnl_view_slct_none, 'value', 0);
set(handles.checkbox_chnl_view_slct_all, 'value', 0);
set(handles.checkbox_chnl_view_slct_all_mic, 'value', 0);

activeChs = 1:4;
global GCF;
if(~isempty(GCF))
    metaData = getappdata(GCF, 'metaData');
    if(~isempty(metaData))
        activeChs = getChannelsByType(metaData, 'ECG');
    end
end

for i=1:10
    pause(0.05);
    if(any(activeChs==i))
        val = 1;
    else
        val = 0;
    end
    set(handles.(['checkbox_chnl_view_slct' num2str(i)]), 'value', val);
end
plotWithNewConfig(handles);


function checkbox_chnl_view_slct_all_mic_Callback(hObject, eventdata, handles)
set(handles.checkbox_chnl_view_slct_none, 'value', 0);
set(handles.checkbox_chnl_view_slct_all, 'value', 0);
set(handles.checkbox_chnl_view_slct_all_ecg, 'value', 0);

activeChs = 5:8;
global GCF;
if(~isempty(GCF))
    metaData = getappdata(GCF, 'metaData');
    if(~isempty(metaData))
        activeChs = getChannelsByType(metaData, 'MIC');
    end
end

for i=1:10
    pause(0.05);
    if(any(activeChs==i))
        val = 1;
    else
        val = 0;
    end
    set(handles.(['checkbox_chnl_view_slct' num2str(i)]), 'value', val);
end

plotWithNewConfig(handles);


function pos = getECGSensorPos(metaData, ECGCh)
pos = 'NA';
fldName = ['SensorlocationCH' num2str(ECGCh)];
if(isfield(metaData, fldName))
    pos = metaData.(fldName);
end


function pushbutton_database_analyzer_Callback(hObject, eventdata, handles)
choice = questdlg('This will run the analysis on the whole database and will take long time, are you sure?', '', 'Yup!', 'Cancel', 'Cancel');
global GCF;
switch choice
    case 'Yup!'
        dg = warndlg('Starting analysis. Analyzer will close now.');
        pause(2);
        close(dg);
        
        step = str2double(get(handles.edit_ecg_steps, 'string'));
        close(GCF);
        pause(0.01);
        
        if(isnumeric(step))
            analyzeDatabaseData(step);
        else
            analyzeDatabaseData();
        end
    case 'Cancel'
        disp('Analysis canceled.');
end


function checkbox_chnl_view_slct9_Callback(hObject, eventdata, handles)
updateChannelSelect(hObject, handles);

function checkbox_chnl_view_slct10_Callback(hObject, eventdata, handles)
updateChannelSelect(hObject, handles);


function ECGChs = includeActiveECGChs(handles, inChs)

plotConfig = getPlotConfig(handles);
ECGChs = inChs(plotConfig.chnlSelect(inChs));


function checkbox_auto_open_research_Callback(hObject, eventdata, handles)


function checkbox_dont_disturb_Callback(hObject, eventdata, handles)


function pushbutton_filter_design_Callback(hObject, eventdata, handles)
filterConfig = getFilterConfig(handles);

global GCF;
metaData = getappdata(GCF, 'metaData');
if(~isempty(metaData))
    if(isfield(metaData, 'Fs'))
        Fs = metaData.Fs;
    else
        Fs = -1;
    end
else
    Fs = -1;
end

if(Fs==-1)
    updateTextbox(handles.text1, 'Sampling rate is not available', 'replace');
    return;
end

if(filterConfig.autoApply)
    filterConfig.auto_filt.ecg.low.Order = filterConfig.auto_filt.ecg.low.order;
    filterConfig.auto_filt.ecg.low.Fc = filterConfig.auto_filt.ecg.low.fc/(Fs/2);
    
    try
        [~, b, a] = applyFilter('LOW_BUTTER', [], filterConfig.auto_filt.ecg.low);
    catch mexcp
        updateTextbox(handles.text1, mexcp.message, 'replace');
        updateTextbox(handles.text1, ['Sample rate: ' num2str(Fs) ' sps'], 'append');
        return;
    end
    fvtool(b, a);
    
else
    % low
    if(filterConfig.man_filt.low.active)
        filterConfig.man_filt.low.Order = filterConfig.man_filt.low.order;
        filterConfig.man_filt.low.Fc = filterConfig.man_filt.low.fc/(Fs/2);
        
        try
            [~, b, a] = applyFilter('LOW_BUTTER', [], filterConfig.man_filt.low);
            fvtool(b, a);
        catch mexcp
            updateTextbox(handles.text1, mexcp.message, 'replace');
            updateTextbox(handles.text1, ['Sample rate: ' num2str(Fs) ' sps'], 'append');
            updateTextbox(handles.text1, ['Low pass'], 'append');
        end
    end
    if(filterConfig.man_filt.high.active)
        % high
        filterConfig.man_filt.high.Order = filterConfig.man_filt.high.order;
        filterConfig.man_filt.high.Fc = filterConfig.man_filt.high.fc/(Fs/2);
        
        try
            [~, b, a] = applyFilter('HIGH_BUTTER', [], filterConfig.man_filt.high);
            fvtool(b, a);
        catch mexcp
            updateTextbox(handles.text1, mexcp.message, 'replace');
            updateTextbox(handles.text1, ['Sample rate: ' num2str(Fs) ' sps'], 'append');
            updateTextbox(handles.text1, ['High pass'], 'append');
        end
    end
end

function plotNow(handles, fileCont)
axes(handles.axes_main);
cla;
if(fileCont.fileFlag==12)
    plot(fileCont.fHRC); hold on;
    plot(fileCont.fHR_quality); hold on;
    plot(fileCont.mHRC); hold on;
    plot(fileCont.TOCO);
end

function leadsNames = getECGLeadsNames(metaData)
leadsNames = repmat({'NA'}, 1, metaData.nNumOfChannels);
if(~isfield(metaData, 'channelType'))
    return;
end

global configProvider;

chsECG = configProvider.getChannelsByType('ECG');

for i=1:length(chsECG)
    leadsNames{i} = metaData.(['SensorlocationCH' num2str(chsECG(i))]);
end

leadsNames(length(chsECG)+1:length(leadsNames)) = [];


function edit_auto_filt_ecg_power_freq_Callback(hObject, eventdata, handles)


function edit_auto_filt_ecg_power_freq_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton20_Callback(hObject, eventdata, handles)

filterConfig = getFilterConfig(handles);
filterConfig.auto_filt.ecg.Fs = 1000;
save('filterConfig', 'filterConfig')
disp('filterConfig was saved.');
