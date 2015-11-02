function varargout = mywaitbar(varargin)
%MYWAITBAR Display multi functional wait bar.
%   H = MYWAITBAR(X,'Title','message',CircularScroll);
%   creates and displays a waitbar of fractional length X, a Title and a
%   message. It adds the option to make an indeterminate time waitbar
%   through the option CircularScroll (true or false).
%   The handle to the waitbar figure is returned in H.
%
%
%   MYWAITBAR(X,H) will set the length of the bar in waitbar H (already
%   created) to the fractional length X.
%
%   MYWAITBAR(X,H,'message') will update the message text in
%   the waitbar figure, in addition to setting the fractional
%   length to X.
%
%   MYWAITBAR(X,H,'message','title') will update the title in
%   the waitbar figure, in addition to setting the fractional
%   length to X and the message text to 'message'
%
%   MYWAITBAR('CircScroll',H) makes the waitbar with undefined value,
%   scrolling contiuously.
%
%   MYWAITBAR('CircScroll',H,'message') makes the waitbar with undefined
%   value, scrolling contiuously with a custom message.
%
%   MYWAITBAR('CircScroll',H,'message','title') makes the waitbar with
%   undefined value, scrolling contiuously with a custom message and title.
%
%   This waitbar can be used in a for loop or before an operation whose
%   duration cannot be predicted
%
%   Example:
%       h = mywaitbar(0,'Please wait...','Computing...',true);
%       pause(3);
%       for i=1:300,
%           % computation here %
%           pause(0.01);
%           mywaitbar(i/300,h,[num2str(i) '/300'],sprintf('Running (%.0f%%)',i/300*100));
%       end
%       mywaitbar(i/300,h,[num2str(i) '/300'],'Finished');
%       pause(1);
%       mywaitbar('circscroll',h,'Last operations...');
%       pause(2);
%       close(h);

%   Created by Daniel Pereira dpereira@s2msolutions.com
%   Date: 2014/06/10 12:42:00

%   Updated By Muhammad Mhajna,
%   Date: 05/11/14

switch nargin
    case 1
        wb = StopMyWaitbar(varargin{1});
        delete(wb);
    case 2 % 2 inputs
        if isnumeric(varargin{1}) % Numeric varargin{1} -> UpdateMyWaitbar
            wb = UpdateMyWaitbar(varargin{1},varargin{2});
        elseif strcmpi(varargin{1},'CircScroll') % CircScroll -> CircularScroll
            wb = MakeCircularScroll(varargin{2});
        end
    case 3 % 3 inputs
        if isnumeric(varargin{1}) % Numeric varargin{1} -> UpdateMyWaitbar
            wb = UpdateMyWaitbar(varargin{1},varargin{2},varargin{3});
        elseif strcmpi(varargin{1},'CircScroll') % CircScroll -> CircularScroll
            wb = MakeCircularScroll(varargin{2},varargin{3});
        end
    case 4 % 4 inputs
        if ischar(varargin{2}) % varargin{2} = 'Title' -> StartMyWaitbar
            wb = StartMyWaitbar(varargin{1},varargin{2},varargin{3},varargin{4});
        elseif strcmpi(varargin{1},'CircScroll') % CircScroll -> CircularScroll
            wb = MakeCircularScroll(varargin{2},varargin{3},varargin{4});
        else  % varargin{2} = wb (handle) -> UpdateMyWaitbar
            wb = UpdateMyWaitbar(varargin{1},varargin{2},varargin{3},varargin{4});
        end
    
end
drawnow;

if nargout==1
    varargout{1}=wb;
else
    varargout={};
end


function fh = MakeCircularScroll(fh,varargin)
wb = guidata(fh);
set(wb.bar,'visible','on');
try start(wb.ani); end %#ok                                 % Try to start. Do not start if timer is already running
if ~isempty(varargin)                                       % If there are more than two inputs
    set(wb.txt,'string',varargin{1});                       % Update message
    if numel(varargin)==2                                   % If there are 2 additional inputs
        set(wb.fig,'name',varargin{2});                     % Update figure's title.
    end
end

function fh = StopMyWaitbar(fh)
wb = guidata(fh);
try stop(wb.ani); end %#ok                                  % Try to stop the timer (if it exist)


function fh = UpdateMyWaitbar(val,fh,varargin)

wb = guidata(fh);
try stop(wb.ani); end %#ok                                  % Try to stop the timer (if it exist)
if val==0; Activo = 'off'; val = 1; else Activo = 'on'; end % If value is 0, prevent width=0 and hide the green bar
set(wb.bar,'pos',[10 19 360*val 18],'visible',Activo);      % Update green bar's position
if ~isempty(varargin)                                       % If there are more than two inputs
    set(wb.txt,'string',varargin{1});                       % Update message
    if numel(varargin)==2                                   % If there are 2 additional inputs
        set(wb.fig,'name',varargin{2});                     % Update figure's title.
    end
end
drawnow;

function fh = StartMyWaitbar(Value,Title,String,CircularScroll)
Value  = min(max(0,Value),1); % Limit possible Values
width  = 400;                 % Figure width (inner)
height = 67;                  % Figure height (inner)
scSize = get(0,'screensize'); % Screensize
wb.fig = figure('position',[(scSize(3)-width)/2 (scSize(4)-height)/2 width height],'menubar','none','toolbar','none','numbertitle','off','color',240/255*[1 1 1],'resize','off'); % Open a figure that will contain the objects
set(wb.fig,'name',Title);     % Define figure's title.

if Value==0; Activo = 'off'; Value = 1; else Activo = 'on'; end % Prevent barwidth=0 deactivating it in that case

wb.edg = uicontrol('style','text','pos',[09 18 362 20],       'String','',    'backgroundcolor',[1 1 1] *188/255);                  % This will act as edge (2px wider and taller than the bars)
wb.bak = uicontrol('style','text','pos',[10 19 360 18],       'String','',    'backgroundcolor',[1 1 1] *230/255);                  % Empty bar (background)
wb.bar = uicontrol('style','text','pos',[10 19 360*Value 18], 'String','',    'backgroundcolor',[6 176 37]*1/255,'visible',Activo); % Filled bar (green)
wb.txt = uicontrol('style','text','pos',[10 42 385 17],       'String',String,'backgroundcolor',[1 1 1] *240/255,'horizontalalignment','left','fontsize',10); % Text message

if(exist('spinner.gif'))
    gifPath = which('spinner.gif');
    gif = sprintf('<html><img src="file:/%s"/></html>',gifPath);
else
    gif = sprintf('<html><img src="file:/%s\\spinner.gif"/></html>',pwd); % Path to the animation file (must be the same size or smaller than the next uicontrol), hmtl code to display image.
end
uicontrol('style','push', 'pos',[378 19 18 18], 'String',gif,'enable','inactive','CData',uint8(240*ones(18,18,3))); % Use an inactive (not disabled) pushbutton to display the gif. Use CData instead of background color to flatten.
drawnow;          % Update figure's content

wb.dt  = 0.01;    % timer function time step
wb.ani = timer('TimerFcn', {@TimerCircularScrollmyWaitbar,wb},'BusyMode','Queue','ExecutionMode','FixedRate','Period', wb.dt); % Set timer properties

global time;      % Make time global variable
global SCR_TMR;
SCR_TMR = wb.ani;
if CircularScroll % If circular scroll is active
    set(wb.bar,'visible','on'); % Show the green bar in case it was hidden
    time = 0;     % Initialize variable "time"
    start(wb.ani);% Start timer.
end

fh = wb.fig;
guidata(fh,wb);

function TimerCircularScrollmyWaitbar(~,~,wb)
try
    global time
    width = 50;                             % Width of the green bar while circular scroll
    A     = (360-width);                    % Amplitude of the movement. 360 is get(wb.edg,'pos')(3)
    x     = (sin(time/1*pi)+1)*A/2+10;      % Set the x value for the green bar
    set(wb.bar,'position',[x 19 width 18]); % Copy from the wb.bar.
    drawnow;                                % Update figure's content
    time  = time+wb.dt;                     % Update variable "time"
end