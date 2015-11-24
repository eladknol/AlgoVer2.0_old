function varargout = AlgVerificationScatterGUI(varargin)
% ALGVERIFICATIONSCATTERGUI MATLAB code for AlgVerificationScatterGUI.fig
%      ALGVERIFICATIONSCATTERGUI, by itself, creates a new ALGVERIFICATIONSCATTERGUI or raises the existing
%      singleton*.
%
%      H = ALGVERIFICATIONSCATTERGUI returns the handle to a new ALGVERIFICATIONSCATTERGUI or the handle to
%      the existing singleton*.
%
%      ALGVERIFICATIONSCATTERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ALGVERIFICATIONSCATTERGUI.M with the given input arguments.
%
%      ALGVERIFICATIONSCATTERGUI('Property','Value',...) creates a new ALGVERIFICATIONSCATTERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AlgVerificationScatterGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AlgVerificationScatterGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AlgVerificationScatterGUI

% Last Modified by GUIDE v2.5 09-Nov-2015 11:06:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AlgVerificationScatterGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @AlgVerificationScatterGUI_OutputFcn, ...
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


% --- Executes just before AlgVerificationScatterGUI is made visible.
function AlgVerificationScatterGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AlgVerificationScatterGUI (see VARARGIN)

% Choose default command line output for AlgVerificationScatterGUI
handles.output = hObject;

%get table data and headers
handles.data=varargin{1};
handles.Headers=varargin{2};

% set popupmenu with plot options
handles.Headers=[' ' ; handles.Headers];

set(handles.popupmenu1,'String',handles.Headers);
set(handles.popupmenu2,'String',handles.Headers);
set(handles.popupmenu3,'String',handles.Headers);
set(handles.popupmenu4,'String',handles.Headers);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AlgVerificationScatterGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AlgVerificationScatterGUI_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pum_val_1=get(handles.popupmenu1,'Value');
pum_val_2=get(handles.popupmenu2,'Value');
pum_val_3=get(handles.popupmenu3,'Value');
pum_val_4=get(handles.popupmenu4,'Value');

handles.XData=cell2matEmpty2Val(handles.data(:,pum_val_1-1),-1);
handles.YData=cell2matEmpty2Val(handles.data(:,pum_val_2-1),-1);


handles.XLabel=handles.Headers{pum_val_1}; 
handles.YLabel=handles.Headers{pum_val_2};
handles.ZLabel=handles.Headers{pum_val_3};

figure;
if pum_val_3==1  % scatter
    if pum_val_4~=1; % if scattered data should be sorted by color
        handles.SortParamData=cell2matEmpty2Val(handles.data(:,pum_val_4-1),-1);
        if ischar(handles.SortParamData)
            handles.SortParamData=handles.data(:,pum_val_4-1);
            ischar_flag=1;
        else
            ischar_flag=0;
        end
        handles.SortParamUniqueVals=unique(handles.SortParamData);
        for i_val=1:length(handles.SortParamUniqueVals)
           if ischar_flag
                idx=strcmp(handles.SortParamData,handles.SortParamUniqueVals{i_val});
                legendinf{i_val}=handles.SortParamUniqueVals{i_val};
            else
                idx=handles.SortParamData==handles.SortParamUniqueVals(i_val);
                legendinf{i_val}=num2str(handles.SortParamUniqueVals(i_val));
            end
            scatter(handles.XData(idx),handles.YData(idx),5);hold on;
        end;
        tit=[ handles.YLabel '=f(' handles.XLabel '), sorted by ' handles.Headers{pum_val_4}];
        tit=strrepUS2Space(tit);
        title(tit);
        legend(legendinf);
    else
        scatter(handles.XData,handles.YData,5);
        tit=[ handles.YLabel '=f(' handles.XLabel ')'];
        tit=strrepUS2Space(tit);
        title(tit);
    end
    xlabel(strrepUS2Space(handles.XLabel));ylabel(strrepUS2Space(handles.YLabel));
    
else % scatter 3
    handles.ZData=cell2matEmpty2Val(handles.data(:,pum_val_3-1),-1); % get Z data
    if pum_val_4~=1; % if scattered data should be sorted by color
        handles.SortParamData=cell2matEmpty2Val(handles.data(:,pum_val_4-1),-1);
        if ischar(handles.SortParamData)
            handles.SortParamData=handles.data(:,pum_val_4-1);
            ischar_flag=1;
        else
            ischar_flag=0;
        end
        handles.SortParamUniqueVals=unique(handles.SortParamData);
        for i_val=1:length(handles.SortParamUniqueVals)
            if ischar_flag
                idx=strcmp(handles.SortParamData,handles.SortParamUniqueVals{i_val});
                legendinf{i_val}=handles.SortParamUniqueVals{i_val};
            else
                idx=handles.SortParamData==handles.SortParamUniqueVals(i_val);
                legendinf{i_val}=num2str(handles.SortParamUniqueVals(i_val));
            end
            scatter3(handles.XData(idx),handles.YData(idx),handles.ZData(idx),5);hold on;
        end;
        tit=[handles.ZLabel '=f(' handles.XLabel ',' handles.YLabel '), sorted by ' handles.Headers{pum_val_4}];
        tit=strrepUS2Space(tit);
        title(tit);
        legend(legendinf);
    else
        scatter3(handles.XData,handles.YData,handles.ZData,5);
        tit=[handles.ZLabel '=f(' handles.XLabel ',' handles.YLabel ')'];
        tit=strrepUS2Space(tit);title(tit);
    end
    xlabel(strrepUS2Space(handles.XLabel));ylabel(strrepUS2Space(handles.YLabel));zlabel(strrepUS2Space(handles.ZLabel));
end



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


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
