function varargout = NG_AnalyzeSF(varargin)
% NG_ANALYZESF MATLAB code for NG_AnalyzeSF.fig
%      NG_ANALYZESF, by itself, creates a new NG_ANALYZESF or raises the existing
%      singleton*.
%
%      H = NG_ANALYZESF returns the handle to a new NG_ANALYZESF or the handle to
%      the existing singleton*.
%
%      NG_ANALYZESF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NG_ANALYZESF.M with the given input arguments.
%
%      NG_ANALYZESF('Property','Value',...) creates a new NG_ANALYZESF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NG_AnalyzeSF_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NG_AnalyzeSF_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NG_AnalyzeSF

% Last Modified by GUIDE v2.5 30-Oct-2014 15:52:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @NG_AnalyzeSF_OpeningFcn, ...
    'gui_OutputFcn',  @NG_AnalyzeSF_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


%% --- Executes just before NG_AnalyzeSF is made visible.
function NG_AnalyzeSF_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NG_AnalyzeSF (see VARARGIN)

% Choose default command line output for NG_AnalyzeSF
handles.output = hObject;
set(handles.figure1,'Units','Pixels');
handles.firstRun = 1;
handles.currFileFullPath = [];
handles.GUI_Common = GUI_CommonClass();
handles.verbose = true; % for future develepment (to prevent printing results to the command window)


handles.ERROR_CODE = getErrorCodes('ecg');
handles.PLOT_TYPES = getPlotTypes('ecg');
handles.PLOT_TYPES_STR = struct2cell(getPlotTypesString('ecg'));
set(handles.popupmenu_plotType, 'String', handles.PLOT_TYPES_STR);

handles.timeBaseResString = {'1', '5', '10', '30', '60', '120'};
handles.timeBaseResValue = [1, 5, 10, 30, 60, 120]; % seconds
set(handles.popupmenu_time_block, 'String', handles.timeBaseResString);


handles = initiateNewFile(handles);
handles = runFullAnalysis(handles);
if(~handles.CalculationsCanceled)
    handles = showAnalysisResults(handles);
end

handles = populateFilesList(handles);
try
    temp = get(handles.figure1);
    guidata(hObject, handles);
catch
    if(handles.verbose)
        disp('Figure closed');
    end
end


% Update handles structure
% guidata(hObject, handles);
% UIWAIT makes NG_AnalyzeSF wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NG_AnalyzeSF_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
try
    varargout{1} = handles.output;
end


% General functions
function handles = initiateNewFile(handles)

handles.errorCode = handles.ERROR_CODE.FREE;

firstRun = 0;
if(~isfield(handles,'firstRun'))
    firstRun = 1;
else
    if(handles.firstRun==1)
        firstRun = 1;
    else
        firstRun=0;
    end
end

try
    if(firstRun)
        handles.currFileFullPath = handles.GUI_Common.getECGFile('cinc2013');
    end
catch
    if(handles.verbose)
        disp('Cannot get file');
    end
end

if(~isempty(handles.currFileFullPath))
    
    handles.patName = getFileName(handles.currFileFullPath);
    % load data from file
    try
        handles = loadFile(handles);
    catch
        if(handles.verbose)
            disp(getErrorString(handles.ERROR_CODE.LOADING));
        end
        
        handles.errorCode = handles.ERROR_CODE.LOADING;
        initiateFigure(handles, 'empty');
    end
    
    % initiate figure based on the loaded data
    try
        handles = initiateFigure(handles);
    catch
        if(handles.verbose)
            disp(getErrorString(handles.ERROR_CODE.GUI_GENERAL));
            disp('Initiating empty figure.');
        end
        handles.errorCode = handles.ERROR_CODE.GUI_GENERAL;
        %         handles = initiateFigure(handles);
    end
else
    %handles = initiateFigure(handles);
    close(gcf);
end
handles.firstRun = 0;


function handles = loadFile(handles)

tmp = load(handles.currFileFullPath);
handles.data = tmp.data;


function handles = initiateFigure(handles)

if(isfield(handles,'data')) % This check also handles the case of empty figure
    handles.figureProps.nNumOfPlots = handles.data.nNumOfLeads;
else
    handles.figureProps.nNumOfPlots = 4;
end

handles.figureProps.winSize = getWinSize(handles);

Width = handles.figureProps.winSize(3);
Heigth = handles.figureProps.winSize(4);

% calculate the positions of the plots
temp = factor(handles.figureProps.nNumOfPlots);

if(length(temp)==3)
    temp(1) = temp(1)*temp(2);
    temp(2) = temp(3);
    temp(3) = [];
elseif(length(temp)==1)
    temp = factor(handles.figureProps.nNumOfPlots-1);
end

nNumOfPlotsX = temp(1);
nNumOfPlotsY = temp(2);
sizeX = 0.23*Width;
sizeY = 0.23*Heigth;
padSize = getPadSize(handles);
x = [];
y = [];
for i=1:nNumOfPlotsX-1
    x = [x padSize + zeros(1,nNumOfPlotsY) 0.5*padSize+repmat(padSize+sizeX,1,nNumOfPlotsY)] ;
end

for i=1:nNumOfPlotsY-1
    y = [y 0.5*padSize + zeros(nNumOfPlotsX,1) 0.5*padSize+repmat(0.5*padSize+sizeY,nNumOfPlotsX,1)] ;
end
y = y';
y=y(:)';
width = sizeX * ones(1,handles.figureProps.nNumOfPlots);
heigth = sizeY * ones(1,handles.figureProps.nNumOfPlots);
% create the plots
for i = 1:handles.figureProps.nNumOfPlots
    handles.figureProps.plotsHandles{i} =...
        axes('Units','pixels','Position',[x(i) y(i) width(i) heigth(i)]);
end

pSize = 0.28*(Width+Heigth)/2;

pStrt = [Width - pSize - 0.2*padSize, Heigth - pSize - 0.2*padSize];

handles.figureProps.templatePlotHandle = ...
    axes('Units','pixels','Position',[pStrt(1) pStrt(2) pSize pSize]);


function winSize = getWinSize(handles)

try
    winSize = get(handles.figure1,'Position');
catch
    winSize = [1 1 300 60];
end

function padSize = getPadSize(handles)
try
    padSize = 0.1*mean(handles.figureProps.winSize(3:4));
catch
    padSize = 60;
end


% --- Executes on selection change in PopupmenuSelectFile.
function PopupmenuSelectFile_Callback(hObject, eventdata, handles)
% Called when the user clicks on an item only (not by value changes by code)
handles.currFileFullPath = handles.ecgFilesList{get(hObject,'Value')};

handles = clearFigure(handles);
handles = clearTextBoxes(handles);

handles = initiateNewFile(handles);
handles = runFullAnalysis(handles);
if(~handles.CalculationsCanceled)
    handles = showAnalysisResults(handles);
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PopupmenuSelectFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopupmenuSelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = populateFilesList(handles)

handles.ecgFilesList = handles.GUI_Common.getECGFilesList('cinc2013');
for i = 1:length(handles.ecgFilesList)
    Files{i} = getFileName(handles.ecgFilesList{i});
end
set(handles.PopupmenuSelectFile,'string',Files);

currFileName = getFileName(handles.currFileFullPath);
bin = strfind(Files,currFileName);
fileInd = 1;
for i=1:length(bin)
    if(bin{i}==1)
        fileInd = i;
        break;
    end
end
set(handles.PopupmenuSelectFile,'value',fileInd);


function handles = clearFigure(handles)
for i=1:handles.figureProps.nNumOfPlots
    delete(handles.figureProps.plotsHandles{i});
end
delete(handles.figureProps.templatePlotHandle);


function handles = clearTextBoxes(handles)
updateTextbox(handles.TextboxAnalysisResults, 'clear');


function handles = clearAxes(handles, isClearTemplateAxes)
if(nargin<2)
    isClearTemplateAxes = 1;
end
for i=1:handles.figureProps.nNumOfPlots
    cla(handles.figureProps.plotsHandles{i},'reset');
end
if(isClearTemplateAxes)
    cla(handles.figureProps.templatePlotHandle,'reset');
end


%%
function handles = runFullAnalysis(handles)

% get config from the user
handles.CalculationsCanceled = 0;
handles.calcConfig = getUserConfig();

if(~isstruct(handles.calcConfig) && handles.calcConfig==-1)
    handles.CalculationsCanceled = 1;
end
if(~handles.CalculationsCanceled)
    % adapt the data
    Data = anounced2Mat(handles.data.RawData, 1);
    handles.data.MatData = Data;
    handles = adaptTimeBase(handles);
    
    % filter the raw data
    try
        filtersConfig = getFiltersConfig(handles.calcConfig);
        handles = applyFilters(handles, filtersConfig);
        handles.filtDataOrigOrder = handles.filtData;
    catch
        if(handles.verbose)
            disp(getErrorString(handles.ERROR_CODE.FILTERING));
        end
        handles.errorCode = handles.ERROR_CODE.FILTERING;
        handles.filtData = Data;
    end
    
    % rearrange the data
    try
        handles = reArrange(handles);
    catch
        if(handles.verbose)
            disp(getErrorString(handles.ERROR_CODE.ARRANGING));
        end
        handles.errorCode = handles.ERROR_CODE.ARRANGING;
        handles.filtData = handles.filtData;
    end
    
    % perform mQRS detection
    try
        handles.calcConfig.procType = 'maternal';
        [handles.mQRSDetection.mQRS, handles.mQRSDetection.bestLead, handles.mQRSDetection.bestLeadPeaks] = getMaternalQRSPos(handles.filtData, handles.calcConfig);
    catch
        if(handles.verbose)
            disp(getErrorString(handles.ERROR_CODE.MQRS_DETECTION));
        end
        handles.errorCode = handles.ERROR_CODE.MQRS_DETECTION;
        handles.mQRSDetection.mQRS = -1;
    end
    
    % perform, separetaly from the procedure done in the mQRS detector, ICA
    % on the full filtered ECG data
    try
        [Out1, Out2, Out3] = fastica(handles.filtData,'g','tanh','verbose','off');
        handles.ICA_fullECG = Out1;
    catch
        if(handles.verbose)
            disp(getErrorString(handles.ERROR_CODE.FULL_ECG_ICA));
        end
        handles.errorCode = handles.ERROR_CODE.FULL_ECG_ICA;
    end
    
    if(handles.mQRSDetection.mQRS ~= -1)
        handles.mQRSDetection.HR.calc.vec = 1./(diff(handles.mQRSDetection.mQRS)/handles.calcConfig.Fs)*60;
        handles.mQRSDetection.HR.calc.Avg = mean(handles.mQRSDetection.HR.calc.vec);
        handles.mQRSDetection.HR.calc.Std = std(handles.mQRSDetection.HR.calc.vec);
        handles.mQRSDetection.HR.calc.smooth = smooth(handles.mQRSDetection.HR.calc.vec);
        
        try
            [handles.fetalData, handles.maternalData] = removeMaternalECG(handles.filtData, handles.mQRSDetection.mQRS, handles.calcConfig); % actually, it's 'non-maternal Data'
        catch
            if(handles.verbose)
                disp(getErrorString(handles.ERROR_CODE.MECG_SUBSTRACTION));
            end
            handles.errorCode = handles.ERROR_CODE.MECG_SUBSTRACTION;
            handles.fetalData = -1;
        end
    else
        handles.fetalData = -1;
    end
    
    if(handles.fetalData ~= -1)
        try
            handles.calcConfig.procType = 'fetal';
            handles.fetalDataDenoised = denoise(handles.fetalData, 'fetalECG', handles);
            [handles.fQRSDetection.fQRS, handles.fQRSDetection.bestLead, handles.fQRSDetection.bestLeadPeaks] = getFetalQRSPos(handles.fetalDataDenoised, handles.mQRSDetection.mQRS, handles.calcConfig);
        catch
            if(handles.verbose)
                disp(getErrorString(handles.ERROR_CODE.FQRS_DETECTION));
            end
            handles.errorCode = handles.ERROR_CODE.FQRS_DETECTION;
            handles.fQRSDetection.fQRS = -1;
        end
        % perform, separetaly from the procedure done in the fQRS detector, ICA
        % on the calculated fetal ECG data (after maternal substracting)
        try
            [Out1, Out2, Out3] = fastica(handles.fetalData,'g','tanh','verbose','off');
            handles.ICA_fetalECG = Out1;
        catch
            if(handles.verbose)
                disp(getErrorString(handles.ERROR_CODE.FETAL_ECG_ICA));
            end
            handles.errorCode = handles.ERROR_CODE.FETAL_ECG_ICA;
        end
        
    else
        handles.fQRSDetection.fQRS = -1;
    end
    
    if(handles.fQRSDetection.fQRS ~= -1)
        % analyze the results:
        
        annfQRS = handles.data.anFQRSPos;
        calcfQRS = handles.fQRSDetection.fQRS;
        
        % 1. Calculate the FHR curve
        handles.fQRSDetection.HR.calc.vec = 1./(diff(calcfQRS)/handles.calcConfig.Fs)*60;
        handles.fQRSDetection.HR.calc.Avg = mean(handles.fQRSDetection.HR.calc.vec);
        handles.fQRSDetection.HR.calc.Std = std(handles.fQRSDetection.HR.calc.vec);
        handles.fQRSDetection.HR.calc.smooth = smooth(handles.fQRSDetection.HR.calc.vec);
        
        handles.fQRSDetection.HR.real.vec = 1./(diff(annfQRS)/handles.calcConfig.Fs)*60;
        handles.fQRSDetection.HR.real.Avg = mean(handles.fQRSDetection.HR.real.vec);
        handles.fQRSDetection.HR.real.Std = std(handles.fQRSDetection.HR.real.vec);
        handles.fQRSDetection.HR.real.smooth = smooth(handles.fQRSDetection.HR.real.vec);
                
        % 2. Compare the peaks positions to the announced values
        nNumOfRealPeaks = length(annfQRS);
        MAX_ACC_PEAK_SHIFT = ceil(0.1*nanmean(diff(annfQRS)));
        hit  = 0;
        miss = 0;
        ind = 1;
        
        for jPeak = 1:nNumOfRealPeaks
            temp = abs(calcfQRS - annfQRS(jPeak))<MAX_ACC_PEAK_SHIFT;
            fInd = find(temp,1);
            if(~isempty(fInd))
                hit = hit+1;
            else
                missedPeaks(ind) = annfQRS(jPeak);
                miss = miss+1;
                ind = ind+1;
            end
        end
        handles.fQRSDetection.missedPeaks = missedPeaks;
        
        % 3. Calulate hit rate (and sens)
        handles.fQRSDetection.stats.hit = hit;
        handles.fQRSDetection.stats.miss = miss;
        handles.fQRSDetection.stats.hitPrcnt = (hit/nNumOfRealPeaks)*100;
        
        % 4. compare the calculated HR curve to the real HR curve
                
        
    end
end

function filterConfig = getFiltersConfig(Config)

filterConfig = [];

flds = {'flt_PWR', 'flt_BSLN', 'flt_EMG'};
types = {'PWR', 'BSLN', 'EMG'};
ind = 1;
for i=1:length(flds)
    if(isfield(Config, flds{i}))
        if(Config.(flds{i})>0)
            filterConfig{ind} = getFilterConfig(types{i}, Config.(flds{i}));
            filterConfig{ind}.type = types{i};
            filterConfig{ind}.Fs = Config.Fs;
            ind = ind+1;
        end
    end
end

function handles = applyFilters(handles, filtersConfig)
handles.filtData = anounced2Mat(handles.data.RawData, 1);
if(~isempty(filtersConfig))
    for i = 1:numel(filtersConfig)
        handles.filtData = applyFilter(filtersConfig{i}.type, handles.filtData, filtersConfig{i});
    end
end

function handles = updateConfig(handles)

function handles = reArrange(handles)
% re-arrange the data:
% in the arranged data the first row will include the signal with the
% highest RMS. the other signals will stay the same (only 2 signals replace positions)
handles.closestElectrode = getClosestElectrode(handles.filtData, handles.calcConfig);
if(length(handles.closestElectrode)>1 || sum(handles.closestElectrode~=1)>0)
    handles.filtData = reArrangeData(handles.filtData, handles.closestElectrode);
else
    handles.filtData = handles.filtData;
end

function handles = showAnalysisResults(handles)


if(handles.errorCode>0)
    updateTextbox(handles.TextboxAnalysisResults, getErrorString(handles.errorCode));
else
    updateTextbox(handles.TextboxAnalysisResults, 'Analysis Results:');
    updateTextbox(handles.TextboxAnalysisResults, ['Hits: '     num2str(handles.fQRSDetection.stats.hit)     ...
        ', Misses: ' num2str(handles.fQRSDetection.stats.miss)    ...
        '; Hit%: '   num2str(handles.fQRSDetection.stats.hitPrcnt)...
        ]);
    updateTextbox(handles.TextboxAnalysisResults, ['Calculated FHR: ' num2str(floor(handles.fQRSDetection.HR.calc.Avg)) '±' num2str(floor(handles.fQRSDetection.HR.calc.Std)) ...
        ', Actual FHR: ' num2str(floor(handles.fQRSDetection.HR.real.Avg)) '±' num2str(floor(handles.fQRSDetection.HR.real.Std)) ...
        ]);
    
    updateTextbox(handles.TextboxAnalysisResults, ['Calculated MHR: ' num2str(floor(handles.mQRSDetection.HR.calc.Avg)) '±' num2str(floor(handles.mQRSDetection.HR.calc.Std))]);
    
end
handles = clearAxes(handles);

switch(handles.errorCode)
    case handles.ERROR_CODE.FREE,
        handles = updateFigures(handles, handles.PLOT_TYPES.MndF_FULL);
        set(handles.popupmenu_plotType, 'value', handles.PLOT_TYPES.MndF_FULL);
        set(handles.popupmenu_time_block, 'value', 3);
        handles = popupmenu_time_block_Callback(handles.popupmenu_time_block, 0, handles);
end

function handles = updateFigures(handles, plotType)
switch(plotType)
    case handles.PLOT_TYPES.MndF_FULL_RAW
        for i=1:handles.figureProps.nNumOfPlots
            axes(handles.figureProps.plotsHandles{i});
            plotWithPeaks(handles.data.MatData(i,:), {handles.mQRSDetection.mQRS, handles.fQRSDetection.fQRS}, 0, handles.timeBase.timeInd);
            grid on;
        end
         
    case handles.PLOT_TYPES.MndF_FULL_PreProc
        for i=1:handles.figureProps.nNumOfPlots
            axes(handles.figureProps.plotsHandles{i});
            plot(handles.timeBase.timeInd, handles.data.MatData(i,:));
            hold on;
            plot(handles.timeBase.timeInd, handles.filtDataOrigOrder(i,:), 'r');
            grid on;
        end
        
    case handles.PLOT_TYPES.MndF_FULL,
        for i=1:handles.figureProps.nNumOfPlots
            axes(handles.figureProps.plotsHandles{i});
            plotWithPeaks(handles.filtData(i,:), {handles.mQRSDetection.mQRS, handles.fQRSDetection.fQRS}, 0, handles.timeBase.timeInd);
            grid on;
        end
        handles.mECGTemplate = getTemplateForDsiplay(handles.filtData(handles.mQRSDetection.bestLead,:), handles.mQRSDetection.mQRS);
        handles.fECGTemplate = getTemplateForDsiplay(handles.fetalData(handles.fQRSDetection.bestLead,:), handles.fQRSDetection.fQRS);
        axes(handles.figureProps.templatePlotHandle);
        [AX, H1, H2] = plotyy(1:length(handles.mECGTemplate),handles.mECGTemplate, 1:length(handles.fECGTemplate), handles.fECGTemplate);
        ylabel(AX(1),'mV') % left y-axis
        ylabel(AX(2),'mV') % right y-axis
        set(AX(1),'xlim',[0 length(handles.mECGTemplate)+5]);
        set(AX(2),'xlim',[0 length(handles.fECGTemplate)+5]);
        grid on;
        
    case handles.PLOT_TYPES.MaternalECGWithQRS,
        for i=1:handles.figureProps.nNumOfPlots
            axes(handles.figureProps.plotsHandles{i});
            plotWithPeaks(handles.maternalData(i,:), {handles.mQRSDetection.mQRS}, 0, handles.timeBase.timeInd);
            grid on;
        end
        
    case handles.PLOT_TYPES.FetalECGWithQRS,
        for i=1:handles.figureProps.nNumOfPlots
            axes(handles.figureProps.plotsHandles{i});
            plotWithPeaks(handles.ICA_fullECG(i,:), {handles.data.anFQRSPos, handles.fQRSDetection.fQRS}, 0, handles.timeBase.timeInd);
            grid on;
        end
        
    case handles.PLOT_TYPES.FullECGICA,
        for i=1:handles.figureProps.nNumOfPlots
            axes(handles.figureProps.plotsHandles{i});
            plotWithPeaks(handles.ICA_fullECG(i,:), {handles.data.anFQRSPos}, 0, handles.timeBase.timeInd);
            grid on;
        end
    case handles.PLOT_TYPES.FetalECGICA,
        for i=1:handles.figureProps.nNumOfPlots
            axes(handles.figureProps.plotsHandles{i});
            plotWithPeaks(handles.ICA_fetalECG(i,:), {handles.fQRSDetection.fQRS}, 0, handles.timeBase.timeInd);
            grid on;
        end
    case handles.PLOT_TYPES.MndF_FULL_RAW_withAnnfQRS
        for i=1:handles.figureProps.nNumOfPlots
            axes(handles.figureProps.plotsHandles{i});
            plotWithPeaks(handles.filtData(i,:), {handles.data.anFQRSPos, handles.fQRSDetection.fQRS}, 0, handles.timeBase.timeInd);
            grid on;
        end
        
    case handles.PLOT_TYPES.MndF_FULL_Proc_withAnnfQRS
        for i=1:handles.figureProps.nNumOfPlots
            axes(handles.figureProps.plotsHandles{i});
            plotWithPeaks(handles.filtData(i,:), {handles.data.anFQRSPos, handles.fQRSDetection.fQRS}, 0, handles.timeBase.timeInd);
            grid on;
        end
    case handles.PLOT_TYPES.FetalECGICA_withAnnfQRS
        for i=1:handles.figureProps.nNumOfPlots
            axes(handles.figureProps.plotsHandles{i});
            plotWithPeaks(handles.ICA_fetalECG(i,:), {handles.data.anFQRSPos, handles.fQRSDetection.fQRS, handles.fQRSDetection.missedPeaks}, 0, handles.timeBase.timeInd);
            grid on;
        end
    case handles.PLOT_TYPES.MaternalECG_withRawECG,
        for i=1:handles.figureProps.nNumOfPlots
            axes(handles.figureProps.plotsHandles{i});
            plot(handles.timeBase.timeInd, handles.filtData(i,:));
            hold on;
            plot(handles.timeBase.timeInd, handles.maternalData(i,:), 'r');
            grid on;
        end
        
end


function updateTextbox(handle, newStr)
str = '';
if(strcmpi(newStr,'clear'))
    str = '';
else
    oldStr = get(handle,'string');
    for i=1:size(oldStr,1)
        str = [str sprintf('%s\n', oldStr(i,:))];
    end
    str = [str sprintf('%s', newStr)];
end
set(handle,'string', str);


% --- Executes on slider movement.
function slider_Timer_Callback(hObject, eventdata, handles)

handles = getPlotInterval(handles);
handles = updateTimeBase(handles);
guidata(hObject, handles);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over slider_Timer.
function slider_Timer_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to slider_Timer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function handles = adaptTimeBase(handles)

Fs = handles.calcConfig.Fs;
nNumOfSamples = length(handles.data.MatData(1,:));
handles.timeBase.timeLen = nNumOfSamples/Fs;
handles.timeBase.timeInd = linspace(0, handles.timeBase.timeLen, nNumOfSamples);
handles.timeBase.units = 'Sec';

% Initiate timing slider
handles = initTimingSldr(handles);

handles = getPlotInterval(handles);


function handles = initTimingSldr(handles)

zoomLevel = handles.timeBaseResValue(get(handles.popupmenu_time_block,'Value')); % in secs
nNumOfSlidingSteps = max(floor(handles.timeBase.timeLen/zoomLevel), 1);

strtPoint = 0;
endPoint = handles.timeBase.timeLen;
handles.timeBase.step_size = handles.timeBase.timeLen/nNumOfSlidingSteps;
handles.timeBase.dispBlockSize = handles.timeBase.step_size*handles.calcConfig.Fs;

slider_step(1) = 1*handles.timeBase.step_size/(endPoint-strtPoint);
slider_step(2) = 1*handles.timeBase.step_size/(endPoint-strtPoint);

set(handles.slider_Timer, 'Min', strtPoint, 'Max', endPoint, 'Sliderstep', slider_step);


function handles = getPlotInterval(handles)

step = floor(get(handles.slider_Timer, 'Value')/handles.timeBase.step_size);

% step=max causes an error, should be corrected
if(step==handles.timeBase.timeLen/handles.timeBase.step_size)
    step = step-1;
end

strtInd = max(1+(step)*handles.timeBase.dispBlockSize, 1);
endInd = min((step+1)*handles.timeBase.dispBlockSize, length(handles.timeBase.timeInd));

handles.timeBase.dispInd = [strtInd, endInd];


% --- Executes during object creation, after setting all properties.
function slider_Timer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Timer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu_time_block.
function handles = popupmenu_time_block_Callback(hObject, eventdata, handles)
handles = initTimingSldr(handles);
handles = getPlotInterval(handles);
handles = updateTimeBase(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_time_block_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_time_block (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles = updateTimeBase(handles)

for i=1:handles.figureProps.nNumOfPlots
    axes(handles.figureProps.plotsHandles{i});
    xInterval = handles.timeBase.dispInd/handles.calcConfig.Fs;
    xlim(xInterval);
end


% --- Executes on button press in pushbutton_zoom_toggle.
function pushbutton_zoom_toggle_Callback(hObject, eventdata, handles)
zoom;

% --- Executes on button press in pushbutton_dataCursor_toggle.
function pushbutton_dataCursor_toggle_Callback(hObject, eventdata, handles)
datacursormode toggle;


% --- Executes on button press in pushbutton_pan_toggle.
function pushbutton_pan_toggle_Callback(hObject, eventdata, handles)
pan on;


% --- Executes on button press in checkbox_filter_powerline.
function checkbox_filter_powerline_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_filter_powerline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_filter_powerline


% --- Executes on button press in checkbox_filter_baseline.
function checkbox_filter_baseline_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_filter_baseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_filter_baseline


% --- Executes on button press in checkbox_filter_emg.
function checkbox_filter_emg_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_filter_emg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_filter_emg


% --- Executes on selection change in popupmenu_plotType.
function popupmenu_plotType_Callback(hObject, eventdata, handles)

plotType = get(hObject,'value');
handles = clearAxes(handles, 0);
handles = updateFigures(handles, plotType);
set(handles.popupmenu_time_block, 'value', 3);
handles = popupmenu_time_block_Callback(handles.popupmenu_time_block, 0, handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_plotType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_plotType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function signalDen = denoise(signal, type, handles)

% perform wavelet de-noising
switch(type)
    case {'fetalECG'}
        config.N = 500;
        config.Fc = [0.001, 49]/(handles.calcConfig.Fs/2);
        for i = 1:handles.data.nNumOfLeads
            signalDen(i,:) = wden(signal(i,:), 'sqtwolog', 's', 'one', 5, 'sym8');
            signalDen(i,:) = applyFilter('FIR', signalDen(i,:), config);
        end
end
