function varargout = fetalAnalyzer(varargin)
% FETALANALYZER MATLAB code for fetalAnalyzer.fig
%      FETALANALYZER, by itself, creates a new FETALANALYZER or raises the existing
%      singleton*.
%
%      H = FETALANALYZER returns the handle to a new FETALANALYZER or the handle to
%      the existing singleton*.
%
%      FETALANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FETALANALYZER.M with the given input arguments.
%
%      FETALANALYZER('Property','Value',...) creates a new FETALANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fetalAnalyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fetalAnalyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fetalAnalyzer

% Last Modified by GUIDE v2.5 18-May-2015 16:16:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @fetalAnalyzer_OpeningFcn, ...
    'gui_OutputFcn',  @fetalAnalyzer_OutputFcn, ...
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


% --- Executes just before fetalAnalyzer is made visible.
function fetalAnalyzer_OpeningFcn(hObject, eventdata, handles, varargin)
global autoFileName;
% Choose default command line output for fetalAnalyzer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fetalAnalyzer wait for user response (see UIRESUME)
% uiwait(handles.figure1);
if(~isempty(autoFileName))
    % Check if the file name is relative, if so add the full path prefix
    if(strcmp(autoFileName(1:4), '...\'))
        base = [getNGFBaseDir('rel') '\'];
        autoFileName = strrep(autoFileName, '...\', base);
        save('nanana.mat', 'autoFileName');
    end
    
    eventdata.auto_load_file = 1;
    pushbutton_load_file_Callback(hObject, eventdata, handles);
end


% --- Outputs from this function are returned to the command line.
function varargout = fetalAnalyzer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function pushbutton_load_file_Callback(hObject, eventdata, handles)
global GCF_LOCAL;
GCF_LOCAL = handles.figure1;

skipGui = 0;
if(isfield(eventdata, 'auto_load_file') && eventdata.auto_load_file)
    skipGui = 1;
    global autoFileName;
    fileName = autoFileName;
end

handles.lastOpenPath = loadConfig('lastOpenPath_fetal');
if(isfield(handles, 'lastOpenPath') && ~isempty(handles.lastOpenPath) && sum(handles.lastOpenPath~=0)>0)
    startDir = handles.lastOpenPath;
else
    startDir = 'C:\Users\Admin\Google_Drive\Rnd\Software\Nuvo\Analyzer\Output';
end

if(~skipGui)
    [fileName, openPath] = getfile(startDir, '.mat');
else
    [f, openPath] = getFileName(fileName);
    openPath = [openPath '\'];
end

handles.lastOpenPath = openPath;

singleType = 1;
% parse path and file name
try
    exps = regexp(openPath, {'fQRSDetection\', 'mECGElimination\', 'mQRSDetection\'}, 'once');
    if(~isempty(exps))
        ind = [exps{:}]-1;
        
        [aa, ~, cc] = getFileName(fileName);
        fileName = [aa cc];
        
        resPath.mQRS = fullfile([openPath(1:ind) '\mQRSDetection'], fileName); %#ok<MFAMB>
        resPath.mECG = fullfile([openPath(1:ind) '\mECGElimination'], fileName);
        resPath.fQRS = fullfile([openPath(1:ind) '\fQRSDetection'], fileName);
        if(exist(resPath.mQRS) && exist(resPath.mECG) && exist(resPath.fQRS))
            singleType = 0;
        else
            % Look for the files in the database
            if(length(openPath) - ind > 3)
                if(~isempty(exps{1}))
                    strLen = length('fQRSDetection');
                elseif(~isempty(exps{2}))
                    strLen = length('mECGElimination');
                elseif(~isempty(exps{3}))
                    strLen = length('mQRSDetection');
                else
                    error('Cause an error')
                    singleType = 1; % 
                end
                
                fileName = [openPath(strLen+ind+1:end) fileName];
                resPath.mQRS = fullfile([openPath(1:ind) '\mQRSDetection'], fileName); 
                resPath.mECG = fullfile([openPath(1:ind) '\mECGElimination'], fileName);
                resPath.fQRS = fullfile([openPath(1:ind) '\fQRSDetection'], fileName);
                if(exist(resPath.mQRS) && exist(resPath.mECG) && exist(resPath.fQRS))
                    singleType = 0;
                end
            end
            
        end
        
        annotDataExist = 0;
    end
    
catch
    
end

if(~singleType)
    temp = load(resPath.mQRS);
    loadData.mQRS = temp.mQRS;
    
    temp = load(resPath.mECG);
    loadData.removeStruct = temp.removeStruct;
    
    temp = load(resPath.fQRS);
    if(isfield(temp,'fQRS'))
        loadData.fQRS = temp.fQRS;
    elseif(isfield(temp,'fQRS_struct'))
        loadData.fQRS.fQRS_struct = temp.fQRS_struct;
    else
        loadData.fQRS = temp;
    end
    
    
    % Annotated fQRS positions
    if(isfield(temp, 'fQRS') && isfield(temp.fQRS, 'annot'))
        annotDataExist = 1;
        loadData.annotfQRSPos = temp.fQRS.annot;
    else
        annotFileName = [aa '.fqrs' '.txt'];
        res = findSpecFile(annotFileName, 'txt', 'C:\Users\Admin\Google_Drive\Nuvo Algorithm team\Database', 0);
        if(~isempty(res))
            if(iscell(res))
                res = res{1};
            end
            temp = load(res);
            if(isnumeric(temp))
                annotDataExist = 1;
                resPath.fQRS_annot = res;
            end
        end
        if(annotDataExist)
            temp = load(resPath.fQRS_annot);
            loadData.annotfQRSPos = temp;
        else
            loadData.annotfQRSPos = [];
        end
    end
    
    if(isempty(loadData.annotfQRSPos))
        set(handles.checkbox_fetal_annot, 'enable', 'off')
    end
    
    if(isempty(loadData.fQRS))
        set(handles.checkbox_fetal_calc, 'enable', 'off')
    end
    
    
else
    error('TBU');
end
if(~exist('loadData', 'var'))
    loadData = struct; % empty
end

setappdata(GCF_LOCAL, 'loadData', loadData);

for i=1:size(loadData.removeStruct.filtData)
    str1{i} = num2str(i);
end
set(handles.popupmenu_channel_select, 'string', str1);

visData('load', handles);

saveConfig('lastOpenPath_fetal', handles.lastOpenPath);


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

function saveConfig(configName, configVal)
if(exist('appConfig.mat', 'file'))
    load appConfig.mat;
end
config.(configName) = configVal;

save('appConfig.mat', 'config');


function visData(type, handles)

global GCF_LOCAL;
loadData = getappdata(GCF_LOCAL, 'loadData');

CH = get(handles.popupmenu_channel_select, 'value');

% maternal ECG and mQRS positions

axes(handles.axes_mat);
matSpec = '^r';
timeBase = (1:length(loadData.removeStruct.filtData(CH,:)))/(loadData.fQRS.fQRS_struct.calcConfig.Fs);
plotWithPeaks(loadData.removeStruct.filtData(CH,:), loadData.mQRS.mQRS_struct.pos, 0, timeBase, matSpec);
title('Filtered data (Maternal&Fetal)');

axes(handles.axes_fet);

fetSpec = {'ok', '*g'};

plotWithPeaks(loadData.removeStruct.fetData(CH,:), {loadData.fQRS.fQRS_struct.fQRS loadData.annotfQRSPos}, 0, timeBase, fetSpec);
title('Fetal data');
if(~isempty(loadData.annotfQRSPos))
    legend('fECG', 'Calulated', 'Annotated');
end

linkaxes([handles.axes_fet, handles.axes_mat], 'x')
CURSORBARS(1) = Cursorbar(handles.axes_fet);
CURSORBARS(2) = Cursorbar(handles.axes_fet);

CURSORBARS(1).addlistener('EndDrag', @plotNow);
CURSORBARS(2).addlistener('EndDrag', @plotNow);

CURSORBARS(1).addlistener('BeginDrag', @lockSliders);
CURSORBARS(2).addlistener('BeginDrag', @lockSliders);

setappdata(GCF_LOCAL, 'CURSORBARS', CURSORBARS);

axes(handles.axes_fet_HR);
cla;
hold on;

if(get(handles.checkbox_fetal_calc, 'value'))
    plot(60./(diff(loadData.fQRS.fQRS_struct.fQRS)/loadData.fQRS.fQRS_struct.calcConfig.Fs), '.b');
    legend('Calulated');
end

if(get(handles.checkbox_fetal_annot, 'value') && ~isempty(loadData.annotfQRSPos))
    plot(60./(diff(loadData.annotfQRSPos)/loadData.fQRS.fQRS_struct.calcConfig.Fs), '-k');
    
    if(get(handles.checkbox_fetal_calc, 'value'))
        legend('Calulated', 'Annotated');
    else
        legend('Annotated');
    end
end

if(get(handles.checkbox_maternal, 'value'))
    plot(60./(diff(loadData.mQRS.mQRS_struct.pos)/loadData.fQRS.fQRS_struct.calcConfig.Fs), '.m');
    
    switch(get(handles.checkbox_fetal_calc, 'value') + get(handles.checkbox_fetal_annot, 'value'))
        case 2,
            legend('Calulated', 'Annotated', 'Maternal');
        case 1,
            legend('Fetal', 'Maternal');
        case 0,
            legend('Maternal');
    end
end

title('Beat-2-Beat HR');
xlabel('Beat #')
ylabel('Heart rate [BPM]');
grid on;
hold off;


function popupmenu_channel_select_Callback(hObject, eventdata, handles)
visData('update', handles);

function popupmenu_channel_select_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function plotNow(src, evntData)

global GCF_LOCAL initialLocation;

CURSORBARS = getappdata(GCF_LOCAL, 'CURSORBARS');
if(isempty(CURSORBARS))
    return;
end
if(isempty(initialLocation))
    initialLocation = 0;
end
handles = getappdata(GCF_LOCAL, 'UsedByGUIData_m');
if(get(handles.checkbox_lock_sliders, 'value'))
    %initialArea
    movedCurser = find(([CURSORBARS.Location] == src.Location)==1);
    stayedInPlaceCurser = find(([CURSORBARS.Location] == src.Location)==0);
    
    CURSORBARS(stayedInPlaceCurser).Location = CURSORBARS(stayedInPlaceCurser).Location + (CURSORBARS(movedCurser).Location - initialLocation);
    CURSORBARS(stayedInPlaceCurser).Position(1) = CURSORBARS(stayedInPlaceCurser).Location;
    CURSORBARS(stayedInPlaceCurser).notify('UpdateCursorBar');
end

selectedArea = sort([CURSORBARS.Location]);

loadData = getappdata(GCF_LOCAL, 'loadData');
selectedArea = round(selectedArea*loadData.fQRS.fQRS_struct.calcConfig.Fs);

axes(handles.axes_fet_HR);
cla;
hold on;
% selected area to highlight
selectedPos = (loadData.fQRS.fQRS_struct.fQRS>=selectedArea(1) & loadData.fQRS.fQRS_struct.fQRS<selectedArea(2));

if(get(handles.checkbox_fetal_calc, 'value'))
    plot(60./(diff(loadData.fQRS.fQRS_struct.fQRS)/loadData.fQRS.fQRS_struct.calcConfig.Fs), '.b');
    HR_vals.calc = 60./(diff(loadData.fQRS.fQRS_struct.fQRS)/loadData.fQRS.fQRS_struct.calcConfig.Fs);
    HR_vals.calc = HR_vals.calc.*selectedPos(2:end);
    HR_vals.calc(HR_vals.calc==0) = nan;
end

if(get(handles.checkbox_fetal_annot, 'value') && ~isempty(loadData.annotfQRSPos))
    plot(60./(diff(loadData.annotfQRSPos)/loadData.fQRS.fQRS_struct.calcConfig.Fs), '-k');
    selectedPos = (loadData.annotfQRSPos>=selectedArea(1) & loadData.annotfQRSPos<selectedArea(2));
    
    HR_vals.annot = 60./(diff(loadData.annotfQRSPos)/loadData.fQRS.fQRS_struct.calcConfig.Fs);
    HR_vals.annot = HR_vals.annot.*selectedPos(2:end);
    HR_vals.annot(HR_vals.annot==0) = nan;
end

if(get(handles.checkbox_fetal_calc, 'value'))
    plot(HR_vals.calc, '.r');
end

if(get(handles.checkbox_fetal_annot, 'value') && ~isempty(loadData.annotfQRSPos))
    plot(HR_vals.annot, 'og');
end

title('Noisy beat-2-beat fHR');
xlabel('Beat#')
ylabel('Heart rate [BPM]');
grid on;
hold off;

fetSum = sprintf('%s \n ->%s \n ->%s \n ->%s \n ->%s \n', 'fHR Measures:',...
    ['Mean   fHR:' num2str(round(nanmean(HR_vals.calc)))],...
    ['Median fHR:' num2str(round(nanmedian(HR_vals.calc)))],...
    ['STD    fHR:' num2str(round(nanstd(HR_vals.calc)))],...
    ['Var Energy:' num2str(round(nanrms((diff(HR_vals.calc)))))]...
    );

set(handles.text_fetal_meas, 'string', fetSum);


function checkbox_lock_sliders_Callback(hObject, eventdata, handles)


function lockSliders(src, evntData)

global GCF_LOCAL initialLocation;
CURSORBARS = getappdata(GCF_LOCAL, 'CURSORBARS');
if(isempty(CURSORBARS))
    return;
end

initialLocation = src.Location;


function togglebutton1_Callback(hObject, eventdata, handles)


function togglebutton_clear_Callback(hObject, eventdata, handles)
plotToolsToggler(hObject, handles);


function togglebutton_zoom_Callback(hObject, eventdata, handles)
plotToolsToggler(hObject, handles);

function togglebutton_pan_Callback(hObject, eventdata, handles)
plotToolsToggler(hObject, handles);

function togglebutton_datacursor_Callback(hObject, eventdata, handles)
plotToolsToggler(hObject, handles);

function checkbox_fetal_calc_Callback(hObject, eventdata, handles)
visData('update', handles);

function checkbox_fetal_annot_Callback(hObject, eventdata, handles)
visData('update', handles);

function checkbox_maternal_Callback(hObject, eventdata, handles)
visData('update', handles);


function pushbutton_deep_analysis_Callback(hObject, eventdata, handles)
global GCF_LOCAL;
loadData = getappdata(GCF_LOCAL, 'loadData');
if(isempty(loadData))
    return;
end

try
    fetData.proc = loadData.removeStruct.fetData;
    fetData.raw = loadData.removeStruct.filtData;
    [Out1, Out2, Out3] = fastica(fetData.proc,'g','tanh','verbose','on');
    
    for i=1:size(fetData.proc, 1)
        fetalTemplate.proc(i, :) = getECGTemplate(fetData.proc(i,:), loadData.fQRS.fQRS_struct.fQRS);
        fetalTemplate.raw(i, :) = getECGTemplate(fetData.raw(i,:), loadData.fQRS.fQRS_struct.fQRS);
        fetalTemplate.ica(i, :) = getECGTemplate(Out1(i,:), loadData.fQRS.fQRS_struct.fQRS);
        fetalTemplate.ica(i, :) = fetalTemplate.ica(i, :)/max(fetalTemplate.ica(i, :))*max(fetalTemplate.proc(i, :));
    end
    
    curFig = subPlot(fetalTemplate.ica, subPlot(fetalTemplate.raw, subPlot(fetalTemplate.proc)));
    figure(curFig);
    subplot(size(fetData.proc, 1), 1, 1);
    legend('Extracted fECG template', 'Raw fECG template', 'ICA template');
    
    for i=1:size(fetData.proc, 1)
        subplot(size(fetData.proc, 1), 1, i);
        title(['CH' num2str(i)]);
    end
    
    set(curFig, 'units', 'normalized');
    set(curFig, 'position', [0 0 1 1]);
    
    fHRC = 60./(diff(loadData.fQRS.fQRS_struct.fQRS)/loadData.fQRS.fQRS_struct.calcConfig.Fs);
    
    curFig = figure;
    ax(1) = subplot(3, 2, 1);
    plot(fHRC, '.b');
    title('fHRC [BPM]');
    grid on;
    
    ax(2) = subplot(3, 2, 2);
    plot(diff(fHRC));
    hold on;
    winLen = 5;
    plot(winRMS(diff(fHRC), winLen, 1));
    title(['fHR changes - winLen = ' num2str(winLen)]);
    legend('fHR Derivative', 'Derivative energy');
    grid on;
    hold off;
    
    linkaxes(ax, 'x');
    
    config.medLen = floor((length(fHRC) + 1)/5);
    config.maLength = 13;
    
    RRC = fHRC;
    tempRRC = medfilt1([RRC RRC RRC], config.medLen);
    tempRRC = applyFilter('ma', tempRRC, config);
    tempRRC = tempRRC(length(RRC):2*length(RRC)-1);
    
    meanRR = mean(tempRRC);
    
    theoNumOfPeaks = length(fetalTemplate.proc(i, :))/meanRR;
    
    nG = 5;
    %gmModel = fitgmdist(diff(RRC(1:end-2))', nG);
    %clust = cluster(gmModel, diff(RRC)');
    
    [clust, C] = kmedoids(diff(RRC)', nG, 'Replicates', nG+1);
    
    md = abs(median(C));
    sm = sum( ((abs(C)-md)/md) < 3 ) - 1;
    
    if(sm == nG-1)
    elseif(sm == nG-2) % two clusters are close, reduce the number of cluster and re cluster the data
        nG = nG - 1;
        [clust, C] = kmedoids(diff(RRC)', nG, 'Replicates', nG+1);
    else
        
    end
    clust = [0; clust];
    
    subplot(3,2, [3,4]);
    plot(tempRRC); hold on;
    plot(RRC, 'ok');
    opts = 'rgbkm';
    for i=1:nG
        inds = find(clust==i);
        plot(inds, RRC(clust==i), ['*' opts(i)]);
    end
    
    Diff = tempRRC - RRC;
    for i=1:nG
        inds = find(clust==i);
        ng(i) = length(inds);
        df(i) = norm(Diff(clust==i));
    end
    
    [y, goodGroup] = min(df./ng);
    inds = find(clust==goodGroup);
    plot(inds, RRC(inds), '^m');
    grid on;
    title('Fetal beats clusters');
    
    
    RRC = RRC(inds);
    config.medLen = 15;
    config.maLength = 9;
    tempRRC = medfilt1([RRC RRC RRC], config.medLen);
    tempRRC = applyFilter('ma', tempRRC, config);
    tempRRC = tempRRC(length(RRC):2*length(RRC)-1);
    subplot(3,2, [5,6]);
    plot(RRC, '.r'); hold on
    plot(tempRRC, '-k');
    grid on;
    title('Predicted fHRC')
    ylabel('BPM');
    set(curFig, 'units', 'normalized');
    set(curFig, 'position', [-1 0 1 1]);
    
    if(~isempty(loadData.annotfQRSPos))
        hold on;
        GSfHRC = 60./(diff(loadData.annotfQRSPos)/loadData.fQRS.fQRS_struct.calcConfig.Fs);
        plot(GSfHRC, '-g');
        legend('Calculated', 'Predicted', 'Gold Standard')
    end
    
    res = [];
    HRC = RRC;
    reps = round(HRC/0.1);
    for i=1:length(HRC)
        res = [res repmat(HRC(i), 1, reps(i))];
    end
    opts.size = floor(median(reps));
    sig = smooth(res, 'MA', opts);
    sig = sig(1:1/0.1:end);
    sig = smooth(sig);
    sig = sig(round(opts.size/2)+1:end-round(opts.size/2)-1);
    time = linspace(0,length(sig)/loadData.fQRS.fQRS_struct.calcConfig.Fs*(length(fetData.raw(1,:))/length(sig)), length(sig));
    figure,
    plot(time, sig);
    grid minor;
    title('fetal Heart Rate - NUVO');
    ylabel('BPM');
    xlabel('Time [Seconds]');
    
catch mexcp
    disp(mexcp.getReport());
end


function plotToolsToggler(hObject, handles)

if(isfield(handles, 'fetalCurser'))
    handles.fetalCurser.removeAllDataCursors;
end

if(get(handles.togglebutton_clear,'value'))
    zoom off;
    datacursormode off;
    pan off;
elseif(get(handles.togglebutton_zoom,'value'))
    zoom on;
elseif(get(handles.togglebutton_pan,'value'))
    pan on;
elseif(get(handles.togglebutton_datacursor,'value'))
    handles.fetalCurser = datacursormode;
    set(handles.fetalCurser, 'UpdateFcn', @showFetalBeat)
end
guidata(hObject, handles);

