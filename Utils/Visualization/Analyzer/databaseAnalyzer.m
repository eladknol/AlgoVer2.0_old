function varargout = databaseAnalyzer(varargin)
% DATABASEANALYZER MATLAB code for databaseAnalyzer.fig
%      DATABASEANALYZER, by itself, creates a new DATABASEANALYZER or raises the existing
%      singleton*.
%
%      H = DATABASEANALYZER returns the handle to a new DATABASEANALYZER or the handle to
%      the existing singleton*.
%
%      DATABASEANALYZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATABASEANALYZER.M with the given input arguments.
%
%      DATABASEANALYZER('Property','Value',...) creates a new DATABASEANALYZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before databaseAnalyzer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to databaseAnalyzer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help databaseAnalyzer

% Last Modified by GUIDE v2.5 20-May-2015 15:31:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @databaseAnalyzer_OpeningFcn, ...
    'gui_OutputFcn',  @databaseAnalyzer_OutputFcn, ...
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


% --- Executes just before databaseAnalyzer is made visible.
function databaseAnalyzer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to databaseAnalyzer (see VARARGIN)

% Choose default command line output for databaseAnalyzer
handles.output = hObject;
jh = findjobj(handles.text_curr_file_name);
jh.setVerticalAlignment( javax.swing.AbstractButton.CENTER );
set(handles.text_curr_file_name, 'ButtonDownFcn', @openFileFolder);
handles.probFiles = [];
handles.probFiles_ana_type = [];
handles.probFiles_for_checking = [];
handles.probFiles_scores = [];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes databaseAnalyzer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = databaseAnalyzer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function pushbutton_prev_file_Callback(hObject, eventdata, handles)

global globFigH;
if(~isempty(globFigH))
    try
        close(globFigH);
    end
end

try
    if(handles.currFileInd>1)
        handles.currFileInd = handles.currFileInd - 1;
    end
    handles = VisECGDataForCurrFile(handles);
end
guidata(hObject, handles);

function pushbutton_next_file_Callback(hObject, eventdata, handles)
global globFigH;
if(~isempty(globFigH))
    try
        close(globFigH);
    end
end

try
    if(strcmpi(getTypesStr(get(handles.popupmenu_ana_type, 'value')), 'mecgelimination') || strcmpi(getTypesStr(get(handles.popupmenu_ana_type, 'value')), 'fqrsdetection'))
        % Reg current file saving the snr values
        handles= regEvent(handles);
        global fetalECG;
        fetalECG = [];
    end
    if(handles.currFileInd<numel(handles.filesList.full))
        handles.currFileInd = handles.currFileInd + 1;
    end
    handles = VisECGDataForCurrFile(handles);
catch mexcp
    warndlg('Cannot display the current file data.');
end
guidata(hObject, handles);


function pushbutton_start_Callback(hObject, eventdata, handles)
set(handles.text_database_table, 'visible', 'off');
databaseTable = [getNGFBaseDir() '\Database_stats.xlsx'];
[file, path] = uigetfile({'*.xlsx', 'XLSX-files (*.xlsx)'; '*.xls', 'XLS files (*.xls)'}, 'Select a file',databaseTable);
if(isempty(file) | file==0)
    return;
end
databaseTable = [path file];

set(handles.text_database_table, 'visible', 'on');
set(handles.pushbutton_reg_file, 'visible', 'on');
set(handles.text_num_prob_files, 'visible', 'on');
set(handles.pushbutton_finish, 'visible', 'on');

[aa, bb, cc] = fileparts(databaseTable);
set(handles.text_database_table, 'string', [bb cc]);
jh = findjobj(handles.text_database_table);
jh.setVerticalAlignment( javax.swing.AbstractButton.CENTER );

global FileToOpen;
FileToOpen = databaseTable;
set(handles.text_database_table, 'ButtonDownFcn', @openFile);

handles = loadDatabaseTable(FileToOpen, handles);
strtInd = str2double(get(handles.edit_start_ind, 'string'));
if(isnan(strtInd))
    strtInd = 1;
end
handles.currFileInd = strtInd;
handles = VisECGDataForCurrFile(handles);

guidata(hObject, handles);

function openFileFolder(a, b)
try
    handles = getappdata(gcf, 'UsedByGUIData_m');
    [~, path, ~] = getFileName(handles.filesList.full{handles.currFileInd});
    openFolder(path);
    system(['explorer ' handles.filesList.full{handles.currFileInd}])
end
function openFile(a, b)
global FileToOpen;
try
    e = actxserver('Excel.Application');
    eWorkbook = e.Workbooks;
    exlFile = eWorkbook.Open(FileToOpen);
    e.Visible = 1;
    eSheets = exlFile.Sheets;
    eSheet = eSheets.get('Item', 1);
    eSheet.Activate;
    %open(FileToOpen);
catch mxcp
    disp(mxcp.getReport());
end

function pushbutton_reg_file_Callback(hObject, eventdata, handles)
handles = regEvent(handles);

guidata(hObject, handles);

function  handles = loadDatabaseTable(databaseTable, handles)
[num,txt,raw] = xlsread(databaseTable);
header = raw(1,:);
bin = strcmpi(header, 'fullpath');
fld_ind = find(bin, 1, 'first');
temp = raw(2:end,fld_ind);
if(~isempty(strfind(temp{1}, '...\')))
    temp = strrep(temp, '...\Database', getNGFBaseDir());
end
filesList.full = temp;

for i=1:numel(filesList.full)
    [aa, bb, cc] = fileparts(filesList.full{i});
    filesList.short{i, 1} = bb;
end
handles.filesList = filesList;

function handles = VisECGDataForCurrFile(handles)

set(handles.text_file_ind, 'string', [num2str(handles.currFileInd) '/' num2str(numel(handles.filesList.full))]);
currFile = handles.filesList.full{handles.currFileInd};
currFile_short = handles.filesList.short{handles.currFileInd};
set(handles.text_curr_file_name, 'string', currFile_short);
try
    [hdr, data] = ReadNGF(currFile);
catch
    handles = regEvent(handles);
    warndlg('Cannot read a corrupted file. The file is registered.');
    return;
end

typeStr = getTypesStr(get(handles.popupmenu_ana_type, 'value'));
signals = data(:, hdr.ECGchannels)';
nNumOfSigs = length(hdr.ECGchannels);

Fs = hdr.Samplerate;
xData = (1:length(signals))/Fs;
if(~ischar(typeStr))
    typeStr = 'raw';
end

global fetalECG;

resBase = [getNGFBaseDir() '\Output\mQRSDetection'];
resExt = '.mat';
currFileRes = strrep(currFile, getNGFBaseDir(), resBase);
[file, path, ~] = getFileName(currFileRes);
currFileRes = [path '\' file resExt];
global resFilesPath globFigH;
resFilesPath = currFileRes;

switch(lower(typeStr))
    case 'raw',
        for iPlot = 1:nNumOfSigs
            axH(iPlot) = subplot(nNumOfSigs, 2, 1 + (iPlot-1)*2);
            plot(xData, signals(iPlot,:));
            ylabel(['CH' num2str(iPlot)])
            if(iPlot==1)
                title('Time signal');
            end
            if(iPlot==nNumOfSigs)
                xlabel('Time [sec]');
            end
            grid on;
            axis tight;
        end
        linkaxes(axH, 'x');
        
        for iPlot = 1:nNumOfSigs
            axH(iPlot) = subplot(nNumOfSigs, 2, 2 + (iPlot-1)*2);
            [pxx, w] = pwelch(signals(iPlot,:),[],[],[], Fs);
            plot(w, 10*log10(pxx))
            if(iPlot==1)
                title('Spectrum estimate');
            end
            if(iPlot==nNumOfSigs)
                xlabel('Freq [Hz]');
            end
            grid on;
            axis tight;
        end
        linkaxes(axH, 'x');
        
        zoom on;
    case 'filtered',
        
    case 'mqrsdetection',
        global filtSig pksPos 
        resBase = [getNGFBaseDir() '\Output\mQRSDetection'];
        resExt = '.mat';
        currFileRes = strrep(currFile, getNGFBaseDir(), resBase);
        [file, path, ~] = getFileName(currFileRes);
        currFileRes = [path '\' file resExt];
        if(exist(currFileRes, 'file'))
            res = load(currFileRes);
        else
            warndlg('Results file does not exist');
        end
        
        xData = xData(1:2:end);
        signals = signals(:, 1:2:end);
        pksPos = floor(res.mQRS.mQRS_struct.pos/2);
        for iPlot = 1:nNumOfSigs
            axH(iPlot) = subplot(nNumOfSigs, 2, 1 + (iPlot-1)*2);
            plotWithPeaks(signals(iPlot,:), pksPos, 0, xData)
            ylabel(['CH' num2str(iPlot)])
            if(iPlot==1)
                title('Time signal');
            end
            if(iPlot==nNumOfSigs)
                xlabel('Time [sec]');
            end
            grid on;
            axis tight;
        end
        linkaxes(axH, 'x');
        
        
        ecgData = signals(res.mQRS.mQRS_struct.bestLeadPeaks, :);
        filtersConfig = getFiltersConfig();
        filtersConfig.autoApply = 1;
        filtersConfig.apply2All = 1;
        filtersConfig.dataType = 'ECG';
        filtersConfig.auto_filt.ecg.median.active = 0;
        metaData.nNumOfChannels = 1;
        metaData.Fs = 1000;
        
        filtSig = doFilter(filtersConfig, ecgData', metaData);
        
        iPlot = 1:2;
        AXES = subplot(nNumOfSigs, 2, 2 + (iPlot-1)*2);
        plotWithPeaks(filtSig, pksPos, 0, xData)
        title('Best lead with peaks');
        xlabel('Time [sec]');
        grid on;
        axis tight;
        
        iPlot = 3:4;
        subplot(nNumOfSigs, 2, 2 + (iPlot-1)*2);
        plot(60000./diff(res.mQRS.mQRS_struct.pos));
        title('HRC');
        xlabel('Beat');
        ylabel('Beat-2-Beat Heart Rate')
        grid on;
        axis tight;
        
        zoom on;
        iPlot = 5:6;
        h = subplot(nNumOfSigs, 2, 2 + (iPlot-1)*2);
        delete(h);
    case 'mecgelimination', 
        resBase = [getNGFBaseDir() '\Output\mQRSDetection'];
        resExt = '.mat';
        currFileRes = strrep(currFile, getNGFBaseDir(), resBase);
        [file, path, ~] = getFileName(currFileRes);
        currFileRes = [path '\' file resExt];
        if(exist(currFileRes, 'file'))
            res = load(currFileRes);
        else
            warndlg('Results file does not exist');
            handles = regEvent(handles);
            return;
        end
        pksPos = floor(res.mQRS.mQRS_struct.pos/2);
        
        resBase = [getNGFBaseDir() '\Output\mECGElimination'];
        resExt = '.mat';
        currFileRes = strrep(currFile, getNGFBaseDir(), resBase);
        [file, path, ~] = getFileName(currFileRes);
        currFileRes = [path '\' file resExt];
        if(exist(currFileRes, 'file'))
            res = load(currFileRes);
        else
            warndlg('Results file does not exist');
            handles = regEvent(handles);
            return;
        end
        
        xData = xData(1:2:end);
        
        signals = res.removeStruct.filtData;
        signals = signals(:,1:2:end);
        
        for iPlot = 1:nNumOfSigs
            axH(iPlot) = subplot(nNumOfSigs, 2, 1 + (iPlot-1)*2);
            plotWithPeaks(signals(iPlot,:), pksPos, 0, xData);
            ylabel(['CH' num2str(iPlot)])
            
            if(iPlot==1)
                title('Filtered data -- mat+fet');
            end
            if(iPlot==nNumOfSigs)
                xlabel('Time [sec]');
            end
            grid on;
            axis tight;
        end
        linkaxes(axH, 'x');
        
        signals = res.removeStruct.fetData;
        signals = signals(:,1:2:end);
        
        fetalECG = res.removeStruct.fetData;
        
        for iPlot = 1:nNumOfSigs
            set(handles.(['popupmenu_ch' num2str(iPlot) '_snr_man']), 'visible', 'on');
            axH(iPlot) = subplot(nNumOfSigs, 2, 2 + (iPlot-1)*2);
            plot(xData, signals(iPlot,:));
            ylabel(hdr.(['SensorlocationCH' num2str(iPlot)]));
            if(iPlot==1)
                title('fetData');
            end
            if(iPlot==nNumOfSigs)
                xlabel('Time [sec]');
            end
            grid on;
            axis tight;
        end
        set(handles.popupmenu_global_snr_man, 'visible', 'on');
        linkaxes(axH, 'x');        
        zoom on;
    case 'fqrsdetection',
        
        % fpos
        resBase = [getNGFBaseDir() '\Output\fQRSDetection'];
        resExt = '.mat';
        currFileRes = strrep(currFile, getNGFBaseDir(), resBase);
        [file, path, ~] = getFileName(currFileRes);
        currFileRes = [path '\' file resExt];
        if(exist(currFileRes, 'file'))
            res = load(currFileRes);
        else
            warndlg('Results file does not exist');
            handles = regEvent(handles);
            return;
        end
        
        fres = res;
        
        % fdata
        resBase = [getNGFBaseDir() '\Output\mECGElimination'];
        resExt = '.mat';
        currFileRes = strrep(currFile, getNGFBaseDir(), resBase);
        [file, path, ~] = getFileName(currFileRes);
        currFileRes = [path '\' file resExt];
        if(exist(currFileRes, 'file'))
            res = load(currFileRes);
        else
            warndlg('Results file does not exist');
            handles = regEvent(handles);
            return;
        end
        
        nNumOfSigs = size(res.removeStruct.fetData,1);
        timeBase = (1:length(res.removeStruct.fetData(1,:)))/res.removeStruct.metaData.Fs;
        
        for iPlot = 1:nNumOfSigs
            set(handles.(['popupmenu_ch' num2str(iPlot) '_snr_man']), 'visible', 'on');
        end
        set(handles.popupmenu_global_snr_man, 'visible', 'on');
        
        xData = xData(1:2:end);
        
        signals = res.removeStruct.matData;
        signals = signals(:,1:2:end);
        
        for iPlot = 1:nNumOfSigs
            axH(iPlot) = subplot(nNumOfSigs, 2, 1 + (iPlot-1)*2);
            plotWithPeaks(signals(iPlot,:), round(res.removeStruct.mQRS_struct.pos/2), 0, xData);
            ylabel(['CH' num2str(iPlot)])
            
            if(iPlot==1)
                title('Maternal data');
            end
            
            if(iPlot==nNumOfSigs)
                xlabel('Time [sec]');
            end
            grid on;
            axis tight;
        end
        linkaxes(axH, 'x');
        
        signals = res.removeStruct.fetData;
        signals = signals(:,1:2:end);
        
        for iPlot = 1:nNumOfSigs
            axH(iPlot) = subplot(nNumOfSigs, 2, 2 + (iPlot-1)*2);
            plotWithPeaks(signals(iPlot,:), round(fres.fQRS_struct.fQRS/2), 0, xData);
            ylabel(['CH' num2str(iPlot)])
            
            if(iPlot==1)
                title('Fetal peaks');
            end
            
            if(iPlot==nNumOfSigs)
                xlabel('Time [sec]');
            end
            grid on;
            axis tight;
        end
        linkaxes(axH, 'x');
        
        globFigH = figure;
        plot(60./(diff(fres.fQRS_struct.fQRS)/res.removeStruct.metaData.Fs));
        grid on;
        xlabel('Beat#');
        ylabel('mSec')
        title('Fetal RR-intervals');
        
        fetalECG = res.removeStruct.fetData;
        
        zoom on;
end
function pushbutton_finish_Callback(hObject, eventdata, handles)

global FileToOpen fetalECG;
[fileName, path, ext] = getFileName(FileToOpen);
newFileName = [path '\' fileName '_ProblematicFiles_' date ext];
XLSDATA{1,1} = 'Full files';
XLSDATA{1,2} = 'Analysis type';
XLSDATA = [XLSDATA; handles.probFiles' handles.probFiles_ana_type'];

if(strcmpi(getTypesStr(get(handles.popupmenu_ana_type, 'value')), 'mecgelimination') || strcmpi(getTypesStr(get(handles.popupmenu_ana_type, 'value')), 'fqrsdetection'))
    sz1 = size(XLSDATA,2) + 1;
    for i=sz1:sz1+size(fetalECG,1)-1
        XLSDATA{1,i} = ['CH' num2str(i-sz1+1) '_SNR'];
    end
    XLSDATA{1,i+1} = ['Global_SNR'];
    sz1 = size(handles.probFiles_scores, 2);
    for i=1:size(handles.probFiles_scores,2)
        if(length(handles.probFiles_scores{i})==5)
            handles.probFiles_scores{i} = [handles.probFiles_scores{i}, -1,-1];
        end
    end
    sz2 = size(handles.probFiles_scores{1}, 2);
    for i=1:sz1
        XLSDATA(i+1, 3:3+sz2-1) = num2cell(handles.probFiles_scores{i})';
    end
end

xlswrite(newFileName, XLSDATA);
disp(['Results saved to: ' newFileName]);
if(isempty(handles.probFiles))
    dlg = warndlg('No corrupted files were registered.');
    waitfor(dlg);
    return;
end
close(handles.figure1);

function handles = regEvent(handles)

if(any(handles.probFiles_for_checking == handles.currFileInd))
    return;
end
anaType = getTypesStr(get(handles.popupmenu_ana_type, 'value'));
handles.probFiles = [handles.probFiles handles.filesList.full(handles.currFileInd)];

handles.probFiles_ana_type = [handles.probFiles_ana_type {anaType}];
handles.probFiles_for_checking = sort([handles.probFiles_for_checking handles.currFileInd]);

if(strcmpi(getTypesStr(get(handles.popupmenu_ana_type, 'value')), 'mecgelimination') || strcmpi(getTypesStr(get(handles.popupmenu_ana_type, 'value')), 'fqrsdetection'))
    SNR = [-1, -1, -1, -1, -1];
    global fetalECG;
    if(~isempty(fetalECG))
        for i=1:size(fetalECG, 1)
            SNR(i) = get(handles.(['popupmenu_ch' num2str(i) '_snr_man']), 'value') - 1;
        end
        SNR(i+1) = get(handles.popupmenu_global_snr_man, 'value') - 1;
    else
        % The mECG cannot be eliminated, keep SNR(:) = -1
    end
    handles.probFiles_scores = [handles.probFiles_scores {SNR}];
end

num = numel(handles.probFiles);
set(handles.text_num_prob_files, 'string', num2str(num));


function popupmenu_ana_type_Callback(hObject, eventdata, handles)
try
    handles = VisECGDataForCurrFile(handles);
catch mexcp
    disp(mexcp.getReport());
end
guidata(hObject, handles);

function popupmenu_ana_type_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function strs = getTypesStr(ind)
strs = {'Raw', 'Filtered', 'mQRSDetection', 'mECGElimination', 'fQRSDetection'};
if(nargin)
    if(ind>=1 && ind<=numel(strs))
        strs = strs{ind};
    end
end

function filtersConfig = getFiltersConfig()
% This should be moved from here...
% The filters config should be loaded and requested from the FilterManager

filtersConfig.doFilt = 1;
filtersConfig.autoApply = 1;
filtersConfig.auto_filt.ecg.low.active = 1;
filtersConfig.auto_filt.ecg.low.fc = 70;
filtersConfig.auto_filt.ecg.low.order = 12;

filtersConfig.auto_filt.ecg.high.active = 0;
filtersConfig.auto_filt.ecg.high.fc = 2;
filtersConfig.auto_filt.ecg.high.order = 5;

filtersConfig.auto_filt.ecg.ma.active = 1;
filtersConfig.auto_filt.ecg.ma.len = 501;

filtersConfig.auto_filt.ecg.median.active = 0;
filtersConfig.auto_filt.ecg.median.len = 100;

filtersConfig.auto_filt.ecg.power.active = 1;
filtersConfig.auto_filt.ecg.power.win = 0.5;
filtersConfig.auto_filt.ecg.power.order = 10;


function pushbutton_toogle_zoom_cursor_Callback(hObject, eventdata, handles)

global lastVal;
if(isempty(lastVal))
    lastVal = 1;
else
    lastVal = ~lastVal;
end
% global dataCursor;

if(lastVal)
    zoom on;
    datacursormode off;
    dataCursor = [];
else
    zoom off;
    dataCursor = datacursormode;
    if(strcmpi(getTypesStr(get(handles.popupmenu_ana_type, 'value')), 'mqrsdetection'))
        set(dataCursor, 'UpdateFcn', @onCurserSelect)
    end
end

function txt = onCurserSelect(input1, event_obj)
global DONE
if(isempty(DONE))
    DONE = 0;
else
    DONE = ~DONE;
end
Fs = 1000/2;
pos = get(event_obj, 'Position');
RR = 60*Fs./get(get(event_obj, 'Target'), 'YData');
timeInt = (sum(RR(1:floor(pos(1)))) + floor(mean(RR)/2))/Fs;
ind = floor(pos(1));

txt = {['Beat#: ', num2str(pos(1))],...
    ['Time [S]: ', num2str(timeInt)]};

if(DONE)
    global filtSig pksPos
    figure;
    xData = (1:length(filtSig))/Fs;
    plotWithPeaks(filtSig, {pksPos pksPos(ind)}, 0, xData) 
end


function popupmenu_ch1_snr_man_Callback(hObject, eventdata, handles)


function popupmenu_ch1_snr_man_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu_ch2_snr_man_Callback(hObject, eventdata, handles)


function popupmenu_ch2_snr_man_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu_ch3_snr_man_Callback(hObject, eventdata, handles)


function popupmenu_ch3_snr_man_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu_ch4_snr_man_Callback(hObject, eventdata, handles)


function popupmenu_ch4_snr_man_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_ica_Callback(hObject, eventdata, handles)

global fetalECG;
if(~isempty(fetalECG))
    [Out1, Out2, Out3] = fastica(fetalECG,'g','tanh','verbose','off');
    subPlot(Out1);
end
currFile = handles.filesList.full{handles.currFileInd};
resBase = [getNGFBaseDir() '\Output\fQRSDetection'];
resExt = '.mat';
currFileRes = strrep(currFile, getNGFBaseDir(), resBase);
[file, path, ~] = getFileName(currFileRes);
currFileRes = [path '\' file resExt];

if(exist(currFileRes, 'file'))
    rr = load(currFileRes);
    disp(rr.fQRS_struct.info);
    timeBase = (1:length(fetalECG(1,:)))/1000;
    figure,
    for i=1:4
        ax(i) = subplot(4,1,i);
        plotWithPeaks(fetalECG(i,:), rr.fQRS_struct.fQRS, 0, timeBase, '*r');
    end
    linkaxes(ax, 'x');
    axes(ax(1));
    title('Fetal peaks');
    plotf(diff(rr.fQRS_struct.fQRS));
    grid on;
    title('Fetal RR-intervals');
    
    disp(['Best fetal lead: ' num2str(rr.fQRS_struct.bestLead)]);
    disp(['Best Pre-Proc Lead: ' num2str(rr.fQRS_struct.bestPreProcLead)]);
    disp(['Best Peaks lead: ' num2str(rr.fQRS_struct.bestLeadPeaks)]);
    disp(['Leads include: ' num2str(rr.fQRS_struct.leadsInclude)]);
end


function popupmenu_global_snr_man_Callback(hObject, eventdata, handles)


function popupmenu_global_snr_man_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_start_ind_Callback(hObject, eventdata, handles)


function edit_start_ind_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu_ch5_snr_man_Callback(hObject, eventdata, handles)


function popupmenu_ch5_snr_man_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu_ch6_snr_man_Callback(hObject, eventdata, handles)


function popupmenu_ch6_snr_man_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_open_fetal_analyzer_Callback(hObject, eventdata, handles)
global resFilesPath;
fileName = resFilesPath;
fetalAnalyzer([], 'filename', fileName);
