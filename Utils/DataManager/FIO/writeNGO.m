function [succ, outFileName] = writeNGO(fileName, inStruct)

% [succ, outFileName] = writeNGO(fileName)
%   Write NGO file
% inStruct should have the following fields:
%       unqID: Unique ID of the NGF file
%       Fs: Sampling rate
%       analysisType: See table in difinition document
%       patID: Patient ID (6 chars convention) 
%       bmi: Patient BMI (6 chars convention) 
%       gestAge: Gestation age in weeks
%       resData: results data structure. Don't use nested structures! The names of the fileds in the structure will be saved in the file,
%                the datatypes will be detected automatically 


%% Global
succ = 1;
[fileName, path] = getFileName(fileName);

if(isempty(fileName))
    succ = 0;
    return;
end

if(isempty(path))
    path = cd;
end
ext = '.ngo';
outFileName = [path '\' fileName ext];
mkdir(path);
fid = fopen(outFileName, 'Wb');

if(fid<=0)
    succ = 0;
    outFileName = '';
    return;
end

patIDMaxLen = 8;

%----------------------------------------------------%
% Writing
%% General header
flds2Write.val.fileVer = '1.1.1';
flds2Write.type.fileVer  = '*char';

flds2Write.val.dateTime = getTimeForSave();
flds2Write.type.dateTime  = '*char';

if(isfield(inStruct, 'unqID'))
    flds2Write.val.unqID = inStruct.unqID;
else
    flds2Write.val.unqID = 'aaaaaaaaaa';
end
flds2Write.type.unqID  = '*char';

if(isfield(inStruct, 'Fs'))
    flds2Write.val.Fs = int16(inStruct.Fs);
else
    flds2Write.val.Fs = int16(-1);
end
flds2Write.type.Fs  = 'int16';

if(isfield(inStruct, 'analysisType'))
    flds2Write.val.analysisType = int16(inStruct.analysisType);
else
    flds2Write.val.analysisType = int16(-1);
end
flds2Write.type.analysisType  = 'int16';

flds = fieldnames(flds2Write.val);
for ii=1:numel(flds)
    fwrite(fid, flds2Write.val.(flds{ii}), flds2Write.type.(flds{ii}));
end

%% Patient information
clear flds2Write;

% Patient ID
if(isfield(inStruct, 'patID'))
    flds2Write.val.patID = inStruct.patID;
    if(length(flds2Write.val.patID)<patIDMaxLen)
        flds2Write.val.patID = [flds2Write.val.patID repmat('0', 1, patIDMaxLen-length(flds2Write.val.patID))];
    elseif(length(flds2Write.val.patID)>patIDMaxLen)
        error(['Maximum length of the field patID is ' num2str(patIDMaxLen) ' chars.']);
    end
else
    flds2Write.val.patID = 'aaaaaaa';
end
flds2Write.type.patID  = '*char';

% Patient BMI
if(isfield(inStruct, 'bmi'))
    flds2Write.val.bmi = single(inStruct.bmi);
else
    flds2Write.val.bmi = 0;
end
flds2Write.type.bmi  = 'float';

% Gestation Age
if(isfield(inStruct, 'gestAge'))
    flds2Write.val.gestAge = int16(inStruct.gestAge);
else
    flds2Write.val.gestAge = 0;
end
flds2Write.type.gestAge  = 'int16';

flds = fieldnames(flds2Write.val);
for ii=1:numel(flds)
    fwrite(fid, flds2Write.val.(flds{ii}), flds2Write.type.(flds{ii}));
end

%% Results data
clear flds;
flds.names = fieldnames(inStruct.resData);

% Number of fields
nNumOfFlds = numel(flds.names);
fwrite(fid, int16(nNumOfFlds), 'int16');

% Fields names
for ii=1:nNumOfFlds
    fwrite(fid, 'char', '*char');
    fwrite(fid, int16(length(flds.names{ii})), 'int16');
    fwrite(fid, flds.names{ii}, '*char');
end

% Fields types
for ii=1:nNumOfFlds
%     flds.types{ii} = class(inStruct.resData.(flds.names{ii}));
    
%     flds.types{ii} = class(inStruct.resData.(flds.names{ii}));
    flds.types{ii} = class(inStruct.resData(1).(flds.names{ii}));
    
end

for ii=1:nNumOfFlds
    fwrite(fid, 'char', '*char');
    fwrite(fid, int16(length(flds.types{ii})), 'int16');
    fwrite(fid, flds.types{ii}, '*char');
end

% Fields sizes
% for ii=1:nNumOfFlds
%     fwrite(fid, int32(length(inStruct.resData(1).(flds.names{ii}))), 'int32');
% end

% Actual data to write
% for ii=1:nNumOfFlds
%     fwrite(fid, inStruct.resData.(flds.names{ii}), flds.types{ii});
% end
% for ii=1:nNumOfFlds
%     fwrite(fid, inStruct.resData(1).(flds.names{ii}), flds.types{ii});
% Number of Signal Frames
nNumOfFrames=length(inStruct.resData);
fwrite(fid, int16(nNumOfFrames), 'int16');
for jj=1:nNumOfFrames
    % Fields sizes
    for ii=1:nNumOfFlds
        fwrite(fid, int32(length(inStruct.resData(jj).(flds.names{ii}))), 'int32');
    end
    
    % Actual data to write
    
    for ii=1:nNumOfFlds
        fwrite(fid, inStruct.resData(jj).(flds.names{ii}), flds.types{ii});
    end
end
%% Finalize
fclose(fid);
