function Config = getUserConfig()

dConfig = getDefaultConfig();
global conFig configFlag control fldVal config;

fldHdr = fields(dConfig.hdr);
fldVal = fields(dConfig.val);
nNumOfFields = numel(fldHdr) + 1;

conFig = figure();
configFlag = 0;
set(conFig,'name','Set the configuration')
screenSize = get(0,'screensize');
winSize = get(conFig,'Position');
width = 600;
fldSize = 40;
strtY = max(1 + screenSize(4) - fldSize*(nNumOfFields + 9), 1);
set(conFig,'Position',[screenSize(3)/3 strtY width 50*nNumOfFields]);
set(conFig,'Resize','off')
fldStrt = width/4 - 10;
fldWidth = fldStrt;
padSize = 50;

for i = 1:nNumOfFields-1
    x = fldStrt;
    y = 40 + (i-1)*(fldSize + padSize/10) + 1.5*fldSize;
    
    uicontrol('Style','text',...
        'position',[x  y fldWidth fldSize],...
        'string',dConfig.hdr.(fldHdr{i}),...
        'FontSize',12,...
        'BackgroundColor',[0.7 0.7 0.7]...
        );
    
    x = fldStrt + 4*padSize;
    control{i} = uicontrol('Style','edit',...
        'position',[x  y fldWidth fldSize],...
        'string',num2str(dConfig.val.(fldVal{i})));
    
end

i=1;
x = fldStrt;
y = 10 + (i-1)*(fldSize + padSize/10);
uicontrol('Style','pushbutton',...
    'position',[x-20  y fldWidth+20 fldSize],...
    'string','Go!',...
    'Callback',@go_button_callback);

x = fldStrt + 4*padSize;
uicontrol('Style','pushbutton',...
    'position',[x  y fldWidth+20 fldSize],...
    'string','Cancel',...
    'Callback',@cancel_button_callback);

waitfor(conFig);

if(configFlag)
    cpyConfig = config;
    for i = 1:numel(fldVal)
        Config.(fldVal{i}) = cpyConfig.(fldVal{i});
    end
else
    Config = -1;
end


function cancel_button_callback(hObject,eventdata)
global conFig;
global configFlag;
configFlag = 0;
close(conFig);

function go_button_callback(hObject,eventdata)

global configFlag conFig config control fldVal;
configFlag = 1;
% get config values and save them in 'config'

for i= 1:numel(fldVal)
    config.(fldVal{i}) = str2double(get(control{i},'String'));
end

close(conFig);