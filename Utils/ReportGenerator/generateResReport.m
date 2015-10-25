function varargout = generateResReport(varargin)
% GENERATERESREPORT MATLAB code for generateResReport.fig
%      GENERATERESREPORT, by itself, creates a new GENERATERESREPORT or raises the existing
%      singleton*.
%
%      H = GENERATERESREPORT returns the handle to a new GENERATERESREPORT or the handle to
%      the existing singleton*.
%
%      GENERATERESREPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GENERATERESREPORT.M with the given input arguments.
%
%      GENERATERESREPORT('Property','Value',...) creates a new GENERATERESREPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before generateResReport_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to generateResReport_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help generateResReport

% Last Modified by GUIDE v2.5 28-May-2015 10:55:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @generateResReport_OpeningFcn, ...
                   'gui_OutputFcn',  @generateResReport_OutputFcn, ...
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


% --- Executes just before generateResReport is made visible.
function generateResReport_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to generateResReport (see VARARGIN)

% Choose default command line output for generateResReport
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes generateResReport wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = generateResReport_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function pushbutton1_Callback(hObject, eventdata, handles)

handles.lastOpenPath = loadConfig('lastOpenPath_fetal');
if(isfield(handles, 'lastOpenPath') && ~isempty(handles.lastOpenPath) && sum(handles.lastOpenPath~=0)>0)
    startDir = handles.lastOpenPath;
else
    startDir = 'C:\Users\Admin\Google_Drive\Rnd\Software\Nuvo\Analyzer\Output';
end

[fileName, openPath] = getfile(startDir);
if(~any(fileName))
    return;
end
generateResultsReportForSingleFile(fileName);

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