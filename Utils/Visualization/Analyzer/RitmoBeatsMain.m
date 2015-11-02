function varargout = RitmoBeatsMain(varargin)
% RITMOBEATSMAIN MATLAB code for RitmoBeatsMain.fig
%      RITMOBEATSMAIN, by itself, creates a new RITMOBEATSMAIN or raises the existing
%      singleton*.
%
%      H = RITMOBEATSMAIN returns the handle to a new RITMOBEATSMAIN or the handle to
%      the existing singleton*.
%
%      RITMOBEATSMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RITMOBEATSMAIN.M with the given input arguments.
%
%      RITMOBEATSMAIN('Property','Value',...) creates a new RITMOBEATSMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RitmoBeatsMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RitmoBeatsMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RitmoBeatsMain

% Last Modified by GUIDE v2.5 28-Aug-2014 17:00:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @RitmoBeatsMain_OpeningFcn, ...
    'gui_OutputFcn',  @RitmoBeatsMain_OutputFcn, ...
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


% --- Executes just before RitmoBeatsMain is made visible.
function RitmoBeatsMain_OpeningFcn(hObject, eventdata, handles, varargin)

%% Choose default command line output for RitmoBeatsMain
handles.output = hObject;
if(isempty(varargin))
    % Manual mode, the user started the app manually
    handles.procType = 'offline';
else
    % Auto mode, the app is being started by another app
    if(strcmpi(varargin{1}, 'type'))
        handles.procType = varargin{2};
    else
        handles.procType = 'offline';
    end
end


% Online mode 
    %-> Since it is a simulation only, a file is selected, read and fed to
    % the real time processor
    %-> The real time processor processes 10 seconds buffer and processes
    % it
    %-> When it finishes it triggers the offline processor 

% Offline mode:
    % Only the offline processor is runned 

%% Common initiation
% Plot config
handles.ERROR_CODES = getErrorCodes();
handles.PLOT_TYPES = getPlotTypes();
handles.PLOT_TYPES_STR = struct2cell(getPlotTypesString());





% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RitmoBeatsMain wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function varargout = RitmoBeatsMain_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
meme='mememe';