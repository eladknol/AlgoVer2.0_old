function varargout = mainSimulator(varargin)
% MAINSIMULATOR MATLAB code for mainSimulator.fig
%      MAINSIMULATOR, by itself, creates a new MAINSIMULATOR or raises the existing
%      singleton*.
%
%      H = MAINSIMULATOR returns the handle to a new MAINSIMULATOR or the handle to
%      the existing singleton*.
%
%      MAINSIMULATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINSIMULATOR.M with the given input arguments.
%
%      MAINSIMULATOR('Property','Value',...) creates a new MAINSIMULATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mainSimulator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mainSimulator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainSimulator

% Last Modified by GUIDE v2.5 03-Sep-2014 14:49:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mainSimulator_OpeningFcn, ...
                   'gui_OutputFcn',  @mainSimulator_OutputFcn, ...
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

function mainSimulator_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

function varargout = mainSimulator_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function pushbutton_go_Callback(hObject, eventdata, handles)

%% get user config
prods = {'beats', 'moments', 'duet'};
for i=1:length(prods)
    if(get(handles.(['radiobutton_' prods{i}]), 'value'))
        userConfig.product = prods{i};
        break;
    end
end

types = {'online', 'offline'};
for i=1:length(types)
    if(get(handles.(['radiobutton_' types{i}]), 'value'))
        userConfig.type = types{i};
        break;
    end
end

%% Run the approperiate apps

close(handles.figure1);
switch lower(userConfig.product)
    case 'beats',
        RitmoBeatsMain('Type',userConfig.type);
    case 'moments',
        RitmoMomentsMain('Type',userConfig.type);
    case 'duet',
        RitmoDuetMain('Type',userConfig.type);     
    otherwise
        disp('Not supported yet');
        return;
end
