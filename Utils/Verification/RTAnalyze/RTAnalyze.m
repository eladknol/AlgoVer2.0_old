function varargout = RTAnalyze(varargin)
% RTANALYZE MATLAB code for RTAnalyze.fig
%      RTANALYZE, by itself, creates a new RTANALYZE or raises the existing
%      singleton*.
%
%      H = RTANALYZE returns the handle to a new RTANALYZE or the handle to
%      the existing singleton*.
%
%      RTANALYZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RTANALYZE.M with the given input arguments.
%
%      RTANALYZE('Property','Value',...) creates a new RTANALYZE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RTAnalyze_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RTAnalyze_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RTAnalyze

% Last Modified by GUIDE v2.5 17-Nov-2015 09:05:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @RTAnalyze_OpeningFcn, ...
    'gui_OutputFcn',  @RTAnalyze_OutputFcn, ...
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


% --- Executes just before RTAnalyze is made visible.
function RTAnalyze_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for RTAnalyze
addpath(genpath('C:\Users\Elad\Documents\GitHub\AlgoVer1.0\'));
warning off;
try
    parpool
catch
end

handles.debugFlag=1;

if handles.debugFlag;
    u_path=userpath;
    handles.debugDir=fullfile(u_path(1:end-1),['RT_debug_' datestr(datetime,'YYYY_mm_dd_HH_MM_SS')]);
    mkdir(handles.debugDir);
end

% set window size
set(handles.figure1,'WindowStyle','docked');
set(handles.figure1,'Position',[54.8571   11.6471  149.0000   32.0588]);
set(handles.figure1,'Color',[1 1 1]);
% params
handles.deltaT=60;
handles.LastAnalysisT=[];

% load start and stop buttton images
handles.Startim=imread('startim.jpg');
handles.Stopim=imread('stopim.jpg');

% handles.Channels_LUT=[4;5;6;7;8;9;10;1;2;3];
handles.Channels_LUT=(1:10)';

% Setting axes labels and titles
handles.axes1.Title.String='mHR [bpm]';
handles.axes2.Title.String='fHR [bpm]';

handles.axes1.XLabel.String='Time [sec]';
handles.axes2.XLabel.String='Time [sec]';

% create patch for fetal HR limits
handles.FetalXlim=get(handles.axes2,'XLim');
plotshadedonaxes(handles.axes2,handles.FetalXlim,[repmat(110,1,length(handles.FetalXlim));repmat(160,1,length(handles.FetalXlim))],'g');

handles.output = hObject;

handles.folder=[];
handles.PrevAcqPath=[];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RTAnalyze wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RTAnalyze_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function edit1_Callback(hObject, eventdata, handles)
handles.folder=get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
if get(hObject,'Value')==0;
    set(hObject, 'ForegroundColor',[0 0.498 0]);
    set(hObject,'cdata',handles.Startim);
    set(hObject,'Enable','on');
    set(handles.text6,'String','');
    drawnow;
    RTAnalyzeAcq2mat(handles)
    guidata(hObject,handles);
else if get(hObject,'Value')==1;
        if isempty(handles.folder)
            warndlg('Please enter folder path','');
            set(hObject,'Value',0);
            set(hObject,'Enable','on');
            guidata(hObject,handles);
        else
            set(hObject, 'ForegroundColor',[1 0 0]);
            %             set(hObject, 'String','Stop');
            set(hObject,'cdata',handles.Stopim);
            set(hObject,'Enable','on');
            drawnow;
            guidata(hObject,handles);
        end
    end
end

% while start button is pressed
while get(hObject,'Value')==1
    pause(0.5);
    if ~isempty(handles.folder)
        % check if a .acq file exists
        handles.acqFilePaths=getFilesPaths(handles.folder,'acq');
        while isempty(handles.acqFilePaths)&&(get(hObject,'Value')==1);
            set(handles.text6,'String','No acq file available yet');
            pause(1);
            handles.acqFilePaths=getFilesPaths(handles.folder,'acq');
        end;
        
        if ~isempty(handles.acqFilePaths)&&(get(hObject,'Value')==1) % file exists and start is pressed
            if isempty(handles.LastAnalysisT)||(etime(clock,handles.LastAnalysisT)>61); % no file has been analyzed for the past minute
                % change button appearance when processing starts
                set(hObject,'cdata',handles.Stopim);
                set(handles.text6,'String','Processing...');
                drawnow;
                
                % update last analysis time
                handles.LastAnalysisT=clock;
              
                % load .acq file
                source=handles.acqFilePaths{end};
                % get file name and parent directory name for display
                handles.acqFilePath=source;
                [handles.SubjectName,handles.acqFileName,~]=fileparts(handles.acqFilePath);
                idx = max(strfind(handles.SubjectName,'\'));
                handles.SubjectName=handles.SubjectName(idx+1:end);
                set(handles.text8,'String',handles.SubjectName);
                set(handles.text7,'String',handles.acqFileName);
                drawnow;
                
                % load data
                tic
                handles.TempacqData.data=[];  % prepare empty struct for data
                try
                    handles.TempacqData=load_acq_mod(handles.acqFilePath);
                    handles.Fs=1000/handles.TempacqData.hdr.graph.sample_time;
                catch ME
                    RTAnalyzeLog(handles,ME);
                end
                
                if isempty(handles.TempacqData.data);
                    set(handles.text6,'String','acq file has no data!');
                    pause(1);
                    continue;
                end
                toc
                
                % look for end of file (zero sequence for temp .acq file)
                strlen=30;
                i=strfind(handles.TempacqData.data(100:end,1)',zeros(strlen,1)');
                if ~isempty(i);
                    EndSample=i(1)+strlen-2;
                else %
                    EndSample=length(handles.TempacqData.data(:,1));
                end;
                
                % Take last 60 seconds of data or less
                handles.NSamples=handles.Fs*handles.deltaT;
                StartSample=EndSample-handles.NSamples+1;
                
                if StartSample>0 % duration of acq data is longer than 1 minute
                    % get number of channels
                    N_Channels=size(handles.TempacqData.data,2);
                    % get data
                    handles.acqData.data=zeros(EndSample-StartSample+1,N_Channels);
                    % file is temp, need to rearrange channels according to LUT
                    for i_channel=1:N_Channels
                        handles.acqData.data(:,i_channel)=handles.TempacqData.data(StartSample:EndSample,handles.Channels_LUT(i_channel));
                    end
                    
                    % acq file is not temp, closed by acqknowledge, take data as is (last 60 seconds, no rearanging);
                    %                     handles.acqData.data=handles.TempacqData.data(StartSample:EndSample,:);
                    handles.TempacqData.data=[]; % clear temp data
                    handles.Ttag=(10*handles.Fs:10*handles.Fs:handles.NSamples)/handles.Fs;
                    
                    % create inputs
                    InputStruct=CreateInputStruct;
                    InputStruct.data=handles.acqData.data;
                    InputStruct.meta.Samplerate=handles.Fs;
                    
                    % save input data to .mat file for debugging
                    if handles.debugFlag
                        [~,FileName,~]=fileparts(handles.acqFilePath);
                        InStructFileName=strcat([datestr(datetime,'HH_MM_SS') '_' FileName,'_In.mat']);
                        InStructFilePath=fullfile(handles.debugDir,InStructFileName);
                        save(InStructFilePath,'-struct','InputStruct');
                    end
                    
                    % get detection results
                    OutStruct=[];
                    try
                        OutStruct=DecisionFusionLogic(InputStruct);
                    catch ME
                        RTAnalyzeLog(handles,ME)
                    end
                    
                    % update GUI
                    set(hObject,'Enable','on');
                    set(hObject,'cdata',handles.Stopim);
                    set(handles.text6,'String','');
                    drawnow;
                    
                    % prepare data for plotting, if available
                    if ~isempty(OutStruct); % some result exists, meaning alg did not crash
                        % patch for bug when HR vectors are smaller than 6
                        % elements
                        if length(OutStruct.resData.mHRvec)<6
                            OutStruct.resData.mHRvec=vertcat(OutStruct.resData.mHRvec,repmat(OutStruct.resData.mHRvec(end),[6-length(OutStruct.resData.mHRvec) 1]));
                        end
                        if length(OutStruct.resData.fHRvec)<6
                            OutStruct.resData.fHRvec=vertcat(OutStruct.resData.fHRvec,repmat(OutStruct.resData.fHRvec(end),[6-length(OutStruct.resData.fHRvec) 1]));
                        end
                        handles.mHR=OutStruct.resData.mHRvec;
                        handles.fHR=OutStruct.resData.fHRvec;
                        
                        if  ~(length(unique(handles.mHR))==1 && (unique(handles.mHR)==-1)) % valid mHR result
                            % plot maternal
                            cla(handles.axes1);
                            p1=plot(handles.axes1,handles.Ttag,handles.mHR,'--o','MarkerFaceColor','b');ylim(handles.axes1,[50 150]);
                            text(28,100,OutStruct.resData.Maternal_Final_Modality,'Color',[0.8 0.9 1],'FontSize',30,'Parent',handles.axes1);
                            text((10:10:60)+0.5,handles.mHR+6,num2str(handles.mHR),'FontSize',8,'Parent',handles.axes1);
                            uistack(p1,'top');
                            handles.axes1.XTickLabel={handles.Ttag};
                            handles.axes1.XTick=[handles.Ttag];
                            xlabel(handles.axes1,'Time [sec]');
                            title(handles.axes1,'mHR [bpm]');
                        else
                            cla(handles.axes1);
                            text(28,100,'No result','Color','r','FontSize',30,'Parent',handles.axes1);
                        end
                        
                        if ~(length(unique(handles.fHR))==1 && (unique(handles.fHR)==-1)) % valid fHR result
                            % plot Fetal
                            cla(handles.axes2);
                            plotshadedonaxes(handles.axes2,handles.FetalXlim,[repmat(110,1,length(handles.FetalXlim));repmat(160,1,length(handles.FetalXlim))],'g');hold(handles.axes2,'on');
                            p2=plot(handles.axes2,handles.Ttag,handles.fHR,'--o','MarkerFaceColor','b');ylim(handles.axes2,[70 200]);
                            text(28,130,OutStruct.resData.Fetal_Final_Modality,'Color',[0.8 0.9 1],'FontSize',30,'Parent',handles.axes2);
                            text((10:10:60)+0.5,handles.fHR+6,num2str(handles.fHR),'FontSize',8,'Parent',handles.axes2);
                            uistack(p2,'top');
                            handles.axes2.XTickLabel={handles.Ttag};
                            handles.axes2.XTick=[handles.Ttag];
                            xlabel(handles.axes2,'Time [sec]');
                            title(handles.axes2,'fHR [bpm]');
                        else
                            cla(handles.axes2);
                            plotshadedonaxes(handles.axes2,handles.FetalXlim,[repmat(110,1,length(handles.FetalXlim));repmat(160,1,length(handles.FetalXlim))],'g');
                            text(28,130,'No result','Color','r','FontSize',30,'Parent',handles.axes2);
                        end
                        drawnow;
                        
                    else %%% remove old plot and plot 'No result'
                        cla(handles.axes1);
                        cla(handles.axes2);
                        plotshadedonaxes(handles.axes2,handles.FetalXlim,[repmat(110,1,length(xlim));repmat(160,1,length(xlim))],'g');
                        text(28,100,'No result','Color','r','FontSize',30,'Parent',handles.axes1);
                        text(28,130,'No result','Color','r','FontSize',30,'Parent',handles.axes2);
                    end
                    
                    % get CTG results
                    [OutStruct.resData.fHRCTG,OutStruct.resData.mHRCTG]=RTAnalyzegetCTGData(handles);
                    % Plot CTG results if available
                    if ~isempty(OutStruct.resData.mHRCTG);
                        hold(handles.axes1,'on');
                        plot(handles.axes1,0.25:0.25:60,OutStruct.resData.mHRCTG,'r');
                    end
                    if ~isempty(OutStruct.resData.fHRCTG);
                        hold(handles.axes2,'on');
                        plotshadedonaxes(handles.axes2,handles.FetalXlim,[repmat(110,1,length(xlim));repmat(160,1,length(xlim))],'g');
                        plot(handles.axes2,0.25:0.25:60,OutStruct.resData.fHRCTG,'r');
                    end
                    
                    % save output data to .mat file for debugging
                    if handles.debugFlag
                        OutStructFileName=strcat([datestr(datetime,'HH_MM_SS') '_' FileName,'_Out.mat']);
                        OutStructFilePath=fullfile(handles.debugDir,OutStructFileName);
                        OutStruct.resData.toolData.FileName=FileName;
                        OutStruct.resData.toolData.SubjectName=handles.SubjectName;
                        save(OutStructFilePath,'-struct','OutStruct','resData');
                    end;
                    
                else % duration of acq file is shorter than 1 minute
                    disp('file is shorter than 1 minute');
                end;
            else % less than a minute had passed since last analysis
                set(handles.text6,'String',['Next analysis in ' num2str(round(61-etime(clock,handles.LastAnalysisT))) ' seconds']);
            end
        end
    end
    %handles.PrevAcqPath=handles.NewAcqPath;
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
set(hObject,'XTickMode','Manual','XlimMode','Manual','XTickLabelMode','Manual',...
    'Xlim',[10 60],'YLim',[40 160],'XTick',10:10:60,'XTickLabel',{10 20 30 40 50 60},'YTick',40:20:160,'YTickLabel',{40 60 80 100 120 140 160},'NextPlot','replacechildren');
grid on;

function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
set(hObject,'XTickMode','Manual','XlimMode','Manual','XTickLabelMode','Manual',...
    'Xlim',[10 60],'YLim',[70 200],'XTick',10:10:60,'XTickLabel',{10 20 30 40 50 60},'YTick',60:20:200,'YTickLabel',{60 80 100 120 140 160 180 200},'NextPlot','replacechildren');
grid on;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);

% --- Executes on button press in pushbutton2.
% function pushbutton2_Callback(hObject, eventdata, handles)
% % hObject    handle to pushbutton2 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
%
% % Hint: get(hObject,'Value') returns toggle state of pushbutton2
%
% if get(hObject,'Value')==1;
%     if isempty(handles.folder)
%         warndlg('Please enter folder path','');
%     else
%         try
%             %         set(hObject,'Enable','off');
%             set(handles.text6,'String','Converting acq2mat');
%             drawnow;
%             count=acq2matFunc(handles.folder);
%             if ~isempty(count)
%                 switch count
%                     case 0
%                         warndlg('No files were converted','');
%                     case 1
%                         warndlg([ num2str(count) ' file was successfully converted']);
%                     otherwise
%                         warndlg([ num2str(count) ' files were successfully converted']);
%                 end;
%                 set(hObject,'Enable','on');
%                 drawnow;
%             end
%         catch ME
%             set(hObject,'Enable','on');
%             drawnow;
%             warndlg('File conversion from .acq to .mat had failed','');
%             RTAnalyzeLog(handles,ME);
%         end
%         drawnow;
%         guidata(hObject,handles);
%     end
% end

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text6.
function text6_ButtonDownFcn(hObject, eventdata, handles)  % text box for displaying tool status
% hObject    handle to text6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function pushbutton2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'Visible', 'Off');



% --- Executes during object creation, after setting all properties.
function text7_CreateFcn(hObject, eventdata, handles)  % text box for displaying current analyzed session name
% hObject    handle to text7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes4
imshow(imread('baby.jpg'));


% --- Executes during object creation, after setting all properties.
function axes5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes5
imshow(imread('mom.jpg'));


% --- Executes during object creation, after setting all properties.
function text8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

RTAnalyzeDispRTdebug(handles.debugDir);


% --- Executes during object creation, after setting all properties.
function pushbutton4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
