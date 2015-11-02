function Config = getUserChannelTypes(nNumOfChannels)

global typeFig;
global configFlag defTypes config control;

typeFig = [];
configFlag = [];
defTypes = [];
config = [];
control = [];

type.hdr = [];
defTypes = {'ECG', 'MIC', 'GEN', 'NONE'};
for i=1:nNumOfChannels
    type.hdr{i} = ['Channel ' num2str(i)];
    if(i<=6)
        type.val{i} = 'ECG';
    else
        type.val{i} = 'MIC';
    end
end

typeFig = figure();
set(typeFig,'name','Set the type of each channel')
set(typeFig,'Resize','off')
winSize = get(typeFig,'Position');

fldWidth = winSize(3)/4;
fldHeight = 0.5*(winSize(4)/nNumOfChannels);
y = winSize(4) - 20;

for i=1:nNumOfChannels
    x = winSize(3)/2 - 1.1*fldWidth;
    y = y - 1.4*fldHeight;
    txt = uicontrol('Style','text',...
        'position',[x  y fldWidth fldHeight],...
        'string',type.hdr{i},...
        'FontSize',12,...
        'BackgroundColor',[0.7 0.7 0.7]...
        );
%     jh = findjobj(txt);
%     jh.setVerticalAlignment( javax.swing.AbstractButton.CENTER );

    x = x + 1.2*fldWidth;
    control{i} = uicontrol('Style','popupmenu',...
        'position',[x  y fldWidth fldHeight],...
        'String', defTypes,...
        'Value', 1+(i>6)...
        ); 
end

x = winSize(3)/2 - 1.1*fldWidth;
y = y - 1.4*fldHeight - 20;

uicontrol('Style','pushbutton',...
    'position',[x  y fldWidth fldHeight+20],...
    'string','Go!',...
    'Callback',@go_button_callback);

x = x + 1.2*fldWidth;

uicontrol('Style','pushbutton',...
    'position',[x y fldWidth fldHeight+20],...
    'string','Cancel',...
    'Callback',@cancel_button_callback);

waitfor(typeFig);

if(configFlag)
    for i = 1:nNumOfChannels
        type.val{i} = config{i};
    end
    Config = type.val;
else
    Config = -1;
end

%%
function cancel_button_callback(hObject,eventdata)
global typeFig;
global configFlag;
configFlag = 0;
close(typeFig);

function go_button_callback(hObject,eventdata)

global configFlag typeFig config control defTypes;
configFlag = 1;
% get config values and save them in 'config'

for i= 1:numel(control)
    config{i} = defTypes{get(control{i},'Value')};
end

close(typeFig);
