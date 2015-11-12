function varargout = AlgVerificationGUI(varargin)
% AlgVerificationGUI MATLAB code for AlgVerificationGUI.fig
%      AlgVerificationGUI, by itself, creates a new AlgVerificationGUI or raises the existing
%      singleton*.
%
%      H = AlgVerificationGUI returns the handle to a new AlgVerificationGUI or the handle to
%      the existing singleton*.
%
%      AlgVerificationGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AlgVerificationGUI.M with the given input arguments.
%
%      AlgVerificationGUI('Property','Value',...) creates a new AlgVerificationGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AlgVerificationGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AlgVerificationGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AlgVerificationGUI

% Last Modified by GUIDE v2.5 11-Nov-2015 15:22:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AlgVerificationGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @AlgVerificationGUI_OutputFcn, ...
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


% --- Executes just before AlgVerificationGUI is made visible.
function AlgVerificationGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AlgVerificationGUI (see VARARGIN)

% Choose default command line output for AlgVerificationGUI
handles.output = hObject;

% initial parameters
handles.params.Min_Gest_Age=[];
handles.params.Max_Gest_Age=[];
handles.params.Has_CTG=[];
handles.params.Min_Age=[];
handles.params.Max_Age=[];
handles.params.Min_BMI=[];
handles.params.Max_BMI=[];
handles.params.Fetal_Detection_Module=[];
handles.params.Fetal_ECG_Detection_Score=[];
handles.params.Fetal_Aud_Detection_Score=[];
handles.params.Fetal_ECG_HR_AVG=[];
handles.params.Fetal_Aud_HR_AVG=[];
handles.params.Overlap=[];
handles.med_win_size=20;
handles.ECG_VV_Status=[];
handles.Audio_VV_Status=[];

% Update plots
% Titles
handles.axes1.Title.String='ECG Filtered'; handles.axes1.Title.FontSize=7;
handles.axes2.Title.String='Audio Filtered';handles.axes2.Title.FontSize=7;
handles.axes3.Title.String='ECG HR';handles.axes3.Title.FontSize=7;
handles.axes4.Title.String='Audio HR';handles.axes4.Title.FontSize=7;
handles.axes5.Title.String='ECG Score';handles.axes5.Title.FontSize=7;
handles.axes6.Title.String='Audio Score';handles.axes6.Title.FontSize=7;
handles.axes7.Title.String='ECG Raw';handles.axes7.Title.FontSize=7;
handles.axes8.Title.String='Audio Raw';handles.axes8.Title.FontSize=7;

% Labels
% handles.axes1.XLabel.String='Time [sec]'; handles.axes1.XLabel.FontSize=7;
handles.axes1.YLabel.String='Amp [v]';handles.axes1.YLabel.FontSize=7;
% handles.axes2.XLabel.String='Time [sec]';handles.axes2.XLabel.FontSize=7;
handles.axes2.YLabel.String='Amp [v]';handles.axes2.YLabel.FontSize=7;
% handles.axes3.XLabel.String='Time [sec]'; handles.axes3.XLabel.FontSize=7;
handles.axes3.YLabel.String='HR [bpm]';handles.axes3.YLabel.FontSize=7;
% handles.axes4.XLabel.String='Time [sec]'; handles.axes4.XLabel.FontSize=7;
handles.axes4.YLabel.String='HR [bpm]';handles.axes4.YLabel.FontSize=7;
% handles.axes5.XLabel.String='Time [sec]'; handles.axes5.XLabel.FontSize=7;
% handles.axes6.XLabel.String='Time [sec]';handles.axes6.XLabel.FontSize=7;
% handles.axes7.XLabel.String='Time [sec]'; handles.axes7.XLabel.FontSize=7;
handles.axes7.YLabel.String='Amp [v]';handles.axes7.YLabel.FontSize=7;
% handles.axes8.XLabel.String='Time [sec]';handles.axes8.XLabel.FontSize=7;
handles.axes8.YLabel.String='Amp [v]';handles.axes8.YLabel.FontSize=7;

% Add menus with Accelerators
mymenu = uimenu('Parent',handles.figure1,'Label','Hot Keys');
uimenu('Parent',mymenu,'Label','Zoom','Accelerator','.','Callback',@(src,evt)zoom(handles.figure1,'on'));
uimenu('Parent',mymenu,'Label','Pan','Accelerator','/','Callback',@(src,evt)pan(handles.figure1,'on'));
uimenu('Parent',mymenu,'Label','Data Cursor','Accelerator',',','Callback',@(src,evt)datacursormode(handles.figure1,'on'));

set(handles.edit20,'String',handles.med_win_size);
set(handles.figure1,'WindowStyle','normal');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AlgVerificationGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AlgVerificationGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.TableData=[];
handles=AlgVerificationGetParams(handles);

% Get folder path
if isfield(handles,'NGO_Folder_Path');
    answers=inputdlg({'parent folder path:','matching parent folder path (for comparing results):'},'Input',[1 60],{handles.NGO_Folder_Path,handles.NGO_Folder_Path_4_Match});
    handles.NGO_Folder_Path=answers{1};
    handles.NGO_Folder_Path_4_Match=answers{2};
else
    answers=inputdlg({'parent folder path:','matching parent folder path (for comparing results):'},'Input',[1 60]);
    handles.NGO_Folder_Path=answers{1};
    handles.NGO_Folder_Path_4_Match=answers{2};
end
set(handles.pushbutton1,'TooltipString',handles.NGO_Folder_Path);

% Run main verification function 
handles=FusionBenchmarkMain(handles,1);
set(handles.uitable1,'Data',handles.TableData(:,handles.TableColumns4Show));
set(handles.uitable1,'RearrangeableColumns','on');
guidata(hObject,handles);
AlgVerificationSortFilterTable(handles.uitable1)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.TableData=[];
handles=AlgVerificationGetParams(handles);

% Get folder path
if isfield(handles,'NGO_Folder_Path');
    answers=inputdlg({'parent folder path:','matching parent folder path (for comparing results):'},'Input',[1 60],{handles.NGO_Folder_Path,handles.NGO_Folder_Path_4_Match});
    handles.NGO_Folder_Path=answers{1};
    handles.NGO_Folder_Path_4_Match=answers{2};
else
    answers=inputdlg({'parent folder path:','matching parent folder path (for comparing results):'},'Input',[1 60]);
    handles.NGO_Folder_Path=answers{1};
    handles.NGO_Folder_Path_4_Match=answers{2};
end

set(handles.pushbutton2,'TooltipString',handles.NGO_Folder_Path);


%Run main verification function
handles=FusionBenchmarkMain(handles,0);
set(handles.uitable1,'Data',[]);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function uitable1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3
handles.TableColumns=cellstr(get(hObject,'String'));
handles.TableColumns4Show=get(hObject,'Value');
set(handles.uitable1,'Columnname',handles.TableColumns(handles.TableColumns4Show))
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx=str2double(get(handles.edit17,'String')); %get selected interval # for verification
try
    handles.Interval4Verf=handles.TableData(idx,:);
    guidata(hObject,handles);
    mat_file_name=strcat(fullfile(handles.Interval4Verf{~cellfun(@isempty,strfind(handles.TableColumns,'Subject Path'))},...
        handles.Interval4Verf{~cellfun(@isempty,strfind(handles.TableColumns,'File Name'))}),'.mat');
    i_Interval=handles.Interval4Verf{~cellfun(@isempty,strfind(handles.TableColumns,'Interval'))};
    res=[];
    res=load(mat_file_name);
catch
    warndlg('mat file is N/A');
end
if ~isempty(res);
    AlgVerificationUpdatePlots(res,i_Interval,handles);
end

% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

%  handles.CellSelection.row = eventdata.Indices(1);
% %  handles.CellSelection.col = eventdata.Indices(2);
%  
%  handles.CellSelection.rowData=handles.uitable1.Data(handles.CellSelection.row,:);
%  guidata(hObject,handles);



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% save to NGO file
NGO_file_path=strcat(fullfile(handles.Interval4Verf{~cellfun(@isempty,strfind(handles.TableColumns,'Subject Path'))},...
        handles.Interval4Verf{~cellfun(@isempty,strfind(handles.TableColumns,'File Name'))}),'.ngo');
[read_status,NGO_Data]=readNGO(NGO_file_path);
if read_status
   i_Interval=handles.Interval4Verf{~cellfun(@isempty,strfind(handles.TableColumns,'Interval'))};
    
    % ECG verification status
    contents1 = cellstr(get(handles.popupmenu5,'String')) ;
    ECG_VV_Status=contents1{get(handles.popupmenu5,'Value')};
    if ~isempty(ECG_VV_Status)
                        ECG_VV_Status=strtrim(ECG_VV_Status);
                        switch ECG_VV_Status
                            case 'Fail'
                                NGO_Data.resData(i_Interval).ECG_VV_Status=int8(0);
                            case 'Pass'
                                NGO_Data.resData(i_Interval).ECG_VV_Status=int8(1);
                            case 'Pending'
                                NGO_Data.resData(i_Interval).ECG_VV_Status=int8(2);
                            case ''
                                NGO_Data.resData(i_Interval).ECG_VV_Status=int8(-1);
                        end
    else
           NGO_Data.resData(i_Interval).ECG_VV_Status=int8(-1);
    end
    
    % Audio verification status
    contents2 = cellstr(get(handles.popupmenu6,'String')) ;
    Audio_VV_Status=contents2{get(handles.popupmenu6,'Value')};
    if ~isempty(Audio_VV_Status)
                        Audio_VV_Status=strtrim(Audio_VV_Status);
                        switch Audio_VV_Status
                            case 'Fail'
                                NGO_Data.resData(i_Interval).Audio_VV_Status=int8(0);
                            case 'Pass'
                                NGO_Data.resData(i_Interval).Audio_VV_Status=int8(1);
                            case 'Pending'
                                NGO_Data.resData(i_Interval).Audio_VV_Status=int8(2);
                            case ''
                                NGO_Data.resData(i_Interval).Audio_VV_Status=int8(-1);
                        end
    else
           NGO_Data.resData(i_Interval).Audio_VV_Status=int8(-1);
    end
    
    % ECG verification comments
    ECG_VV_Comments=get(handles.edit18,'String');
    if ~isempty(ECG_VV_Comments)
        NGO_Data.resData(i_Interval).ECG_VV_Comments=ECG_VV_Comments;
    else
        NGO_Data.resData(i_Interval).ECG_VV_Comments='';
    end
    
   % Audio verification comments
    Audio_VV_Comments=get(handles.edit19,'String');
    if ~isempty(Audio_VV_Comments)
        NGO_Data.resData(i_Interval).Audio_VV_Comments=Audio_VV_Comments;
    else
        NGO_Data.resData(i_Interval).Audio_VV_Comments='';
    end
    
    % Fix old empty comment fields that are not strings
    for i=1:length(NGO_Data.resData);
        if isempty(NGO_Data.resData(i).ECG_VV_Comments)
            NGO_Data.resData(i).ECG_VV_Comments='';
        end
        
        if isempty(NGO_Data.resData(i).Audio_VV_Comments)
            NGO_Data.resData(i).Audio_VV_Comments='';
        end
    end
    
    % write data back to NGO file
    [write_status,~]=writeNGO(NGO_file_path,NGO_Data);
    if ~write_status
        warndlg('Cannot save data to NGO file');
    end    
end



% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx=str2double(get(handles.edit17,'String')); %get prev interval # for verification
if ~isempty(idx)
    set(handles.edit17,'String',num2str(idx-1));
    pushbutton5_Callback(hObject, eventdata, handles)
    pushbutton4_Callback(hObject, eventdata, handles)
end

 
% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


idx=str2double(get(handles.edit17,'String')); %get prev interval # for verification
if ~isempty(idx)
    set(handles.edit17,'String',num2str(idx+1));
    pushbutton5_Callback(hObject, eventdata, handles)
    pushbutton4_Callback(hObject, eventdata, handles)
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xls_file_name=strcat(fullfile(handles.NGO_Folder_Path,strcat('data_' ,datestr(datetime,'YYYY_mm_dd_HH_MM_SS'))),'.xlsx');
xlswrite(xls_file_name,vertcat(handles.TableColumns',handles.TableData));
winopen(xls_file_name);


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

med_win_size=handles.med_win_size;
i_Interval=handles.Interval4Verf{~cellfun(@isempty,strfind(handles.TableColumns,'Interval'))};

NGO_file_path=strcat(fullfile(handles.Interval4Verf{~cellfun(@isempty,strfind(handles.TableColumns,'Subject Path'))},...
        handles.Interval4Verf{~cellfun(@isempty,strfind(handles.TableColumns,'File Name'))}),'.ngo');
GT_file_path=strrep(NGO_file_path,handles.NGO_Folder_Path,handles.GT_Folder_Path);
GT_subject_folder_path=fileparts(GT_file_path);

[NGO_read_status,NGO_Data]=readNGO(NGO_file_path);
[GT_read_status,GT_Data]=readNGO(GT_file_path);
    
if ~NGO_read_status
    warndlg('Cannot read NGO file!','');
    return;
else
    Fs=NGO_Data.Fs;
    if GT_read_status % NGO file already exists in GT DB, copy data only for the specific interval!
        NGO_fldnames=fieldnames(NGO_Data.resData);
        GT_fldnames=fieldnames(GT_Data.resData);
        fldnames=intersect(NGO_fldnames,GT_fldnames);
        for i_fld=1:length(fldnames)
            GT_Data.resData(i_Interval).(fldnames{i_fld})=NGO_Data.resData(i_Interval).(fldnames{i_fld});
        end
        NGO_Data=GT_Data; 
    else % Use new NGO data for GT 
       [NGO_Data.resData.GT_Source]=deal(''); % create empty values for string field
    end

    choice=questdlg('Select source for Ground Truth:','GT','ECG','Audio','Cancel','Cancel');
    switch choice
        case 'ECG'
            [NGO_Data.resData(i_Interval).GT_HR_INST,NGO_Data.resData(i_Interval).GT_HR_MED]=AlgVerificationCalcHR(NGO_Data.resData(i_Interval).ECG_fQRSPos,med_win_size,Fs);
            NGO_Data.resData(i_Interval).med_win_size=med_win_size;
            NGO_Data.resData(i_Interval).GT_Source='ECG';
            mkdir(GT_subject_folder_path);
            [write_status,~]=writeNGO(GT_file_path,NGO_Data);
        case 'Audio'
            [NGO_Data.resData(i_Interval).GT_HR_INST,NGO_Data.resData(i_Interval).GT_HR_MED]=AlgVerificationCalcHR(NGO_Data.resData(i_Interval).Audio_fSPos,med_win_size,Fs);
            NGO_Data.resData(i_Interval).med_win_size=med_win_size;
            NGO_Data.resData(i_Interval).GT_Source='Audio';
            mkdir(GT_subject_folder_path);
            [write_status,~]=writeNGO(GT_file_path,NGO_Data);
        case 'Cancel'
            return;
    end
    % Display notification message
    if write_status
        warndlg('GT saved successfully','');
        disp(['GT Path:' GT_file_path]);
    else
        warndlg('Cannot save data to NGO file!','');
    end

end

function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double

handles.med_win_size=str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox6.
function listbox6_Callback(hObject, eventdata, handles)
% hObject    handle to listbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox6


% --- Executes during object creation, after setting all properties.
function listbox6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox7.
function listbox7_Callback(hObject, eventdata, handles)
% hObject    handle to listbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox7


% --- Executes during object creation, after setting all properties.
function listbox7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

AlgVerificationScatterGUI(handles.TableData,handles.TableColumns);


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

AlgVerificationHistGUI(handles.TableData,handles.TableColumns);



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
