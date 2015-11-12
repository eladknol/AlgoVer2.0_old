function varargout = AlgVerificationHistGUI(varargin)
% AlgVerificationHistGUI MATLAB code for AlgVerificationHistGUI.fig
%      AlgVerificationHistGUI, by itself, creates a new AlgVerificationHistGUI or raises the existing
%      singleton*.
%
%      H = AlgVerificationHistGUI returns the handle to a new AlgVerificationHistGUI or the handle to
%      the existing singleton*.
%
%      AlgVerificationHistGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AlgVerificationHistGUI.M with the given input arguments.
%
%      AlgVerificationHistGUI('Property','Value',...) creates a new AlgVerificationHistGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AlgVerificationHistGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AlgVerificationHistGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AlgVerificationHistGUI

% Last Modified by GUIDE v2.5 09-Nov-2015 11:48:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AlgVerificationHistGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @AlgVerificationHistGUI_OutputFcn, ...
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


% --- Executes just before AlgVerificationHistGUI is made visible.
function AlgVerificationHistGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AlgVerificationHistGUI (see VARARGIN)

% Choose default command line output for AlgVerificationHistGUI
handles.output = hObject;

%get table data and headers
handles.data=varargin{1};
handles.Headers=varargin{2};

% set popupmenu with plot options
handles.Headers=[' ' ; handles.Headers];

set(handles.popupmenu1,'String',handles.Headers);
set(handles.popupmenu4,'String',handles.Headers);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AlgVerificationHistGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AlgVerificationHistGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pum_val_1=get(handles.popupmenu1,'Value');
pum_val_4=get(handles.popupmenu4,'Value');

handles.XData=cell2matEmpty2Val(handles.data(:,pum_val_1-1),-1);
handles.XLabel=handles.Headers{pum_val_1};
XTick=unique(handles.XData);


figure;
barData=[];
if pum_val_4~=1   % if histograms should be according to a specific parameter
    handles.SortParamData=cell2matEmpty2Val(handles.data(:,pum_val_4-1),-1);
    handles.SortParamUniqueVals=unique(handles.SortParamData);
    c=jet(length(handles.SortParamUniqueVals));
    for i_val=1:length(handles.SortParamUniqueVals)
        idx=handles.SortParamData==handles.SortParamUniqueVals(i_val);
        histData=histc(handles.XData(idx),XTick);
        barData=horzcat(barData,histData(:));
        legendinf{i_val}=num2str(handles.SortParamUniqueVals(i_val));
    end
    h_bar=bar(XTick,barData,'stacked');
    for i_val=1:length(handles.SortParamUniqueVals)
        set(h_bar(i_val),'facecolor',c(i_val,:));
    end
    legend(legendinf);
    tit=['Detection by ' handles.XLabel ', ' handles.Headers{pum_val_4}];
    tit=strrepUS2Space(tit);
    title(tit);
else
    barData=horzcat(barData,histc(handles.XData,XTick));
    bar(XTick,barData);
    tit=['Detection by ' handles.XLabel];
    tit=strrepUS2Space(tit);
    title(tit);
end
xlabel(strrepUS2Space(handles.XLabel));ylabel('Count');
set(gca,'XTick',XTick);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes during object creation, after setting all properties.
function pushbutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


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
