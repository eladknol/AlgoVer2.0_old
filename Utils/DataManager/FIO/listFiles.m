function varargout = listFiles(directory, fileType, verbose, override)
% List all files in directory
% The list adds the properties of the ECG only, a patch

if(nargin<4), override = 1;                 end; % Override database stats file
if(nargin<3), verbose = 1;                  end; % Verbose to command window
if(nargin<2), fileType = 'ngf';             end; % Files type to read
if(nargin<1), directory = getNGFBaseDir();  end; % Directory of the database

switch(lower(fileType))
    case {'ngf', '.ngf', '*.ngf'},
        filesList = getNGFfileList(directory);
    otherwise
        error([fileType ' Files are not supported. A patch might be needed.'])
end

%% Read files
if(verbose)
    clc;
    disp('Reading files...');
    waitBar = waitbar(0, 'Reading files...');
end

ID_vec = {};
DATE_VEC{1} = [];
ind = 0;

flds.In     = {'SubjectID', 'Filename', 'Date', 'BMIbeforepregnancy', 'Weekofpregnancy', 'HasCTG'};
flds.Out    = {'ID'       , 'FileName', 'Date', 'BMI'               , 'GestationAge', 'CTG'};
flds.type   = {'str', 'str', 'str', 'num', 'num', 'str'};

distFields = {  'distance_B1B3'
    'distance_B2B4'
    'distance_BbB1'
    'distance_BbB2'
    'distance_BbB3'
    'distance_BbB4'
    'distance_BbA1'
    'distance_BbA2'
    'distance_BbA3'
    'distance_BbA4'};

useDistData = false;
maxNumOfECGChs = 6;
maxNumOfChs = 10;
for i=1:maxNumOfChs
    flds.In = [flds.In {['SensorlocationCH' num2str(i)]}];
    flds.type = [flds.type {'str'}];
    
    flds.In = [flds.In {['SensortypeCH' num2str(i)]}];
    flds.type = [flds.type {'str'}];
    
    flds.Out = [flds.Out {['SENS_pos_' num2str(i)]}];
    flds.Out = [flds.Out {['SENS_type_' num2str(i)]}];
end

if(useDistData)
    flds.In = [flds.In distFields'];
    flds.type = [flds.type repmat({'num'}, 1, length(distFields))];
    flds.Out = [flds.Out distFields'];
end

flds.Out_extra = {'FullPath'};

nNumOfFiles = numel(filesList);
forceStop = 0;
fprintf(1, repmat('|', 1, 1));
for iFile = 1:nNumOfFiles
    try
        if(verbose)
            try
                waitbar(iFile/nNumOfFiles, waitBar, 'Reading files...');
                fprintf(1, repmat('.', 1, 1));
                
                if(~mod(iFile, 30))
                    fprintf(1, '\n');
                    fprintf(1, repmat('|', 1, 1));
                end
                
            catch
                forceStop = 1;
                break;
            end
        end
        
        meta = ReadNGF(filesList{iFile});
        
        % Check file type, new or old NGF files
        if(isfield(meta, 'HasCTG'))
            fileFormat = 'new';
        else
            fileFormat = 'old';
        end
        
        if(strcmpi(fileFormat, 'old')) % Backward comp with the old NGF file format
            
            meta.Date = datestr(datevec(meta.Date,'dd-mm-yyyy HH:MM:SS'),'yyyy-mm-dd HH:MM:SS');
            
        else % New NGF files format
            
            meta.Date = [meta.Create_Date(1:10) ' ' meta.Create_Date(12:16)];
            meta.Date = datestr(datevec(meta.Date,'yyyy-mm-dd HH:MM'),'yyyy-mm-dd HH:MM:SS');
            
            % Add the following fields to the new meta data
            for ch=1:numel(meta.Channels)
                if(meta.Channels(ch).Channel_Type == 0) % ECG
                    meta.(['SensorlocationCH' num2str(ch)]) = parseECGLocation(meta.Channels(ch).Channel_Locations);
                    meta.(['SensortypeCH' num2str(ch)]) = parseECGType(meta.Channels(ch).Channel_Version);
                elseif(meta.Channels(ch).Channel_Type == 1) % MIC
                    % Do nothing with the location for now
                    meta.(['SensortypeCH' num2str(ch)]) = parseMICType(meta.Channels(ch).Channel_Version);
                end
            end
            
        end
        
        meta.Filename(meta.Filename == ' ') = [];
        for jFld=1:length(flds.In)
            if(isfield(meta, flds.In{jFld}))
                if(~isempty(cell2mat(regexp(flds.In{jFld}, {'Sensorlocation', 'Sensortype'}))))
                    ch = [flds.In{jFld}(regexp(flds.In{jFld}, 'Sensorlocation') + length('Sensorlocation'):end) flds.In{jFld}(regexp(flds.In{jFld}, 'Sensortype') + length('Sensortype'):end)];
                    if(~isempty(strfind(meta.(['Sensortype' ch]), 'ECG')))
                        newFileInfo.(flds.Out{jFld}) = meta.(flds.In{jFld});
                    elseif(~isempty(strfind(meta.(['Sensortype' ch]), 'MIC')))
                        newFileInfo.(flds.Out{jFld}) = meta.(flds.In{jFld});
                    else
                        if(strcmpi(flds.type{jFld}, 'num'))
                            newFileInfo.(flds.Out{jFld}) = nan;
                        else
                            newFileInfo.(flds.Out{jFld}) = 'na';
                        end
                    end
                else
                    if(strcmpi(flds.type{jFld}, 'num') && ~isnumeric(meta.(flds.In{jFld})))
                        newFileInfo.(flds.Out{jFld}) = nan;
                    else
                        newFileInfo.(flds.Out{jFld}) = meta.(flds.In{jFld});
                    end
                end
            else
                if(strcmpi(flds.type{jFld}, 'num'))
                    newFileInfo.(flds.Out{jFld}) = nan;
                else
                    newFileInfo.(flds.Out{jFld}) = 'na';
                end
            end
        end
        
        strtInd = strfind(filesList{iFile}, 'Database');
        newFileInfo.(flds.Out_extra{1}) = ['...\' filesList{iFile}(strtInd:end)];
        
        subjInd = find(strcmpi(ID_vec, newFileInfo.ID), 1);
        
        
        if(isempty(subjInd))
            % This needs to be changed
            % This is intended to make a cross-check between the ID format of the new and old files
            % this is not perfect yet the error cost is not fatal!!!
            % YOu can use the BMI as an additional check
            
            IDs_here = [];
            unq_here = [];
            
            unq_here = newFileInfo.ID([1 2 2+((length(newFileInfo.ID))==6)*3 + 1 ]);
            for i_here = 1:numel(ID_vec)
                IDs_here{i_here} = ID_vec{i_here}([1 2 2+((length(ID_vec{1}))==6)*3 + 1 ]);
            end
            
            ind_here = find(strcmpi(IDs_here, unq_here),1);
            if(~isempty(ID_vec) && ~isempty(ind_here) && length(ID_vec{ind_here}) ~= length(newFileInfo.ID))
                % Append a new field for this subject
                subjInd = ind_here;
                Info{subjInd} = [Info{subjInd} newFileInfo];
                DATE_VEC{subjInd} = [DATE_VEC{subjInd} datenum(newFileInfo.Date)];
            else
                % Create a new field for this new subject
                ID_vec{end+1} = newFileInfo.ID;
                ind = ind+1;
                subjInd = ind;
                Info{subjInd} = newFileInfo;
                DATE_VEC{subjInd} = datenum(newFileInfo.Date);
            end
        else
            % Append a new field for this subject
            Info{subjInd} = [Info{subjInd} newFileInfo];
            DATE_VEC{subjInd} = [DATE_VEC{subjInd} datenum(newFileInfo.Date)];
        end
        
    catch excp
        disp(['Cannot read file: ' filesList{iFile}]);
        disp(excp.getReport());
    end
end

if(forceStop)
    varargout = cell(0);
    fprintf(1, '\nListing stoped by the user.\n');
    return;
end
%% Analyze files
if(verbose)
    disp('Analyzing files...');
    nNumOfSubs = numel(DATE_VEC);
    for ii=nNumOfSubs:-1:1
        waitbar(ii/nNumOfSubs, waitBar, 'Analyzing files...');
        pause(0.005)
    end
end

nNumOfSubs = numel(DATE_VEC);
for iSubj = 1:nNumOfSubs
    if(verbose)
        waitbar(iSubj/nNumOfSubs, waitBar, 'Analyzing files...');
    end
    currDates = DATE_VEC{iSubj};
    % Sort tests by Date
    [y, inds] = sort(currDates);
    Info{iSubj} = Info{iSubj}(inds);
    
    ID_S{iSubj} = Info{iSubj}(1).ID;
    pause(0.005);
end

% Sort subjects by ID (alphab)
[~, inds] = sort(ID_S);
Info = Info(inds);

HEADER = [flds.Out flds.Out_extra];
ind = 2;

Res = HEADER;
for iSubj = 1:numel(Info)
    for jTst = 1:numel(Info{iSubj})
        for kFld = 1:numel(HEADER)
            Res{ind, kFld} = Info{iSubj}(jTst).(HEADER{kFld});
        end
        ind = ind+1;
    end
end

%% Save results
if(verbose)
    disp('Writing Results to excel file.');
    waitbar(0.5, waitBar, 'Writing Results to excel file...');
end

try
    excelFileName = [directory '\Database_stats'];
    if(override)
        sheet = 1;
    else
        if(exist([excelFileName '.xlsx'], 'file'))
            [~, shit] = xlsfinfo(excelFileName);
            sheet = numel(shit) + 1;
        else
            sheet = 1;
        end
    end
    
    ID_S = sort(ID_S);
    writeData2Excel(excelFileName, Res, sheet, ID_S);
    openFolder(directory);
    
catch excp
    disp('Cannot write data to excel file.');
    disp(excp.getReport());
end

if(verbose)
    disp('Done.');
    try
        close(waitBar);
    end
end

if(nargout==1)
    varargout = Res;
    return;
end

%% Show results
try
    if(verbose)
        figure,
        subplot(2,2,1); histogram(cell2mat(Res(2:end,4))); grid on; title('File counts vs BMI'); xlabel('BMI'); ylabel('Records');
        subplot(2,2,2); histogram(cell2mat(Res(2:end,5))); grid on; title('File counts vs Age'); xlabel('Gestation age [weeks]'); ylabel('Records');
        subplot(2,2,[3, 4]);hist3([cell2mat(Res(2:end,5)) cell2mat(Res(2:end,4))]); grid on; title('File counts vs Age vs BMI '); xlabel('Gestation age'); ylabel('BMI'); zlabel('Records');
    end
catch me
    disp(me.getReport());
end

function writeData2Excel(excelFileName, Res, sheet, ID_S)
% Supports up to 52 columns of data


% Write data
warning('off','MATLAB:xlswrite:AddSheet')
xlswrite([excelFileName '.xlsx'], Res, sheet);
e = actxserver('Excel.Application');
e.DisplayAlerts = false;
eWorkbook = e.Workbooks;
exlFile = eWorkbook.Open([excelFileName '.xlsx']);
e.Visible = 1;
eSheets = exlFile.Sheets;
eSheet = eSheets.get('Item', sheet);
eSheet.Activate;
eSheet.Name = ['SHT' num2str(sheet) ' CRTD__' date];
exlFile.Save();
eWorkbook.Close();
e.Quit();

delete([excelFileName '_Vis.xlsx']);
xlswrite([excelFileName '_Vis.xlsx'], Res, sheet);

if(size(Res,2)>52)
    warning('The function supports up to 52 colums of data, aborting formatting the excel file');
    return;
end

% Edit the excel file
e = actxserver('Excel.Application');
e.DisplayAlerts = false;
eWorkbook = e.Workbooks;
exlFile = eWorkbook.Open([excelFileName '_Vis.xlsx']);
e.Visible = 1;
eSheets = exlFile.Sheets;
eSheet = eSheets.get('Item', sheet);
eSheet.Activate;
eSheet.Name = date;

range.start = 'A1';

if(char('A' + size(Res, 2) - 1) <= 'Z')
    range.end = [char('A' + size(Res, 2) - 1) '1'];
else
    range.end = ['A' char(char('A' + size(Res, 2) - 1) - 'Z' + 'A' - 1) '1'];
end

eActivesheetRange = e.Activesheet.get('Range', [range.start ':' range.end]);
eActivesheetRange.Font.Bold = 1;
eActivesheetRange.HorizontalAlignment = 3;
eActivesheetRange.VerticalAlignment = 2;
eActivesheetRange.Border.Color = 1;
eActivesheetRange.EntireColumn.AutoFit;

ind_id = find(strcmp(Res(1,:), 'ID'), 1);
ID_COL = char(64+ind_id);
toogleColor = 1;
COLOR = {hex2dec('d7cdc8'), hex2dec('FFFFFF')};

for i=1:numel(ID_S)
    currID = ID_S{i};
    bin = strcmp(Res(:,ind_id), currID);
    
    range.start = [ID_COL num2str(find(bin, 1, 'first'))];
    range.end = [ID_COL num2str(find(bin, 1, 'last'))];
    
    eActivesheetRange = e.Activesheet.get('Range', [range.start ':' range.end]);
    eActivesheetRange.MergeCells = 1;
    eActivesheetRange.HorizontalAlignment = 3;
    eActivesheetRange.VerticalAlignment = 2;
    eActivesheetRange.Border.Color = 1;
    
    range.end = [char('A' + size(Res, 2) - 1) num2str(find(bin, 1, 'last'))];
    eActivesheetRange = e.Activesheet.get('Range', [range.start ':' range.end]);
    eActivesheetRange.Border.Color = 1;
    
    eActivesheetRange.Interior.Color = COLOR{double(toogleColor>0) + 1};
    toogleColor = ~toogleColor;
end

exlFile.Save();
eWorkbook.Close();
e.Quit();

function location = parseECGLocation(Channel_Locations)

[a, b] = strread(Channel_Locations, '[%d,%d]');

if(all(isnumeric([a, b])))
    a = a+1;
    b = b+1;
    ECGLOCS = {'A1', 'A2', 'A3', 'A4', 'B1', 'B2', 'B3', 'B11', 'B12'};
    location = [ECGLOCS{a} ' - ' ECGLOCS{b}];
else
    error('Cannot parse ECG channel location.')
end

function type = parseECGType(Channel_Version)

ind = Channel_Version + 1;

if(isnumeric(ind))
    ECGTYPE = {'GE', 'Demo Elect', 'Ext Demo Elect'};
    type = ['ECG , ' ECGTYPE{ind}];
else
    error('Cannot parse ECG channel type.')
end

function type = parseMICType(Channel_Version)

ind = Channel_Version + 1;

if(isnumeric(ind))
    MICTYPE = {
        '13.1- ALU_36_5_PRIMO158_cap1',
        '13.2- ALU_36_5_PRIMO158_cap2',
        '13.3- ALU_36_5_PRIMO158_cap3',
        '13.4- ALU_36_5_PRIMO158_cap4',
        '18.1- ALU_36_5_PRIMO158_cap1',
        '18.2- ALU_36_5_PRIMO158_cap2',
        '18.3- ALU_36_5_PRIMO158_cap3',
        '18.4- ALU_36_5_PRIMO158_cap4',
        '19.1- ALU_36_5_PRIMO158_New-Membrane_cap1',
        '19.2- ALU_36_5_PRIMO158_New-Membrane_cap2',
        '19.3- ALU_36_5_PRIMO158_New-Membrane_cap3',
        '19.4- ALU_36_5_PRIMO158_New-Membrane_cap4',
        '15.1- ALU_DEMO_BELT_cap1',
        '15.2- ALU_DEMO_BELT_cap2',
        '15.3- ALU_DEMO_BELT_cap3',
        '15.4- ALU_DEMO_BELT_cap4',
        '16.1- ALU_32_5_PRIMO158_cap1',
        '16.2- ALU_32_5_PRIMO158_cap2',
        '16.3- ALU_32_5_PRIMO158_cap3',
        '16.4- ALU_32_5_PRIMO158_cap4',
        '17.1- ALU_EXT_DEMO_BELT_cap1',
        '17.2- ALU_EXT_DEMO_BELT_cap2',
        '17.3- ALU_EXT_DEMO_BELT_cap3',
        '17.4- ALU_EXT_DEMO_BELT_cap4',
        '17.1- ALU_EXT_DEMO_BELT_cap1'};
    type = ['MIC , ' MICTYPE{ind}];
else
    error('Cannot parse ECG channel type.')
end
