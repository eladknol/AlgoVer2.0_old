function [succ, outStruct] = readNGO(inFileName)

% [succ, outFileName] = writeNGO(fileName)
%   Write NGO file

%% Global
succ = 1;

if(nargin<1 || isempty(inFileName) || ~exist(inFileName, 'file'))
    succ = 0;
    return;
end

fid = fopen(inFileName, 'r+');

if(fid<=0)
    succ = 0;
    outStruct = struct();
    return;
end

patIDMaxLen = 8;

%----------------------------------------------------%
% Reading
%% General header

flds2Read.names = {'fileVer', 'dateTime', 'unqID', 'Fs'   , 'analysisType'};
flds2Read.types = {'*char'  , '*char'   , '*char', 'int16', 'int16'};
flds2Read.sizes = {5        , length(getTimeForSave())        , length(getFileUnqIDTemp())     , 1      , 1};

for ii=1:numel(flds2Read.names)
    readRes.(flds2Read.names{ii}) = fread(fid, flds2Read.sizes{ii}, flds2Read.types{ii})';
end

%% Patient information
clear flds2Read;

flds2Read.names = {'patID', 'bmi'   , 'gestAge'};
flds2Read.types = {'*char', 'single', 'int16'};
flds2Read.sizes = {patIDMaxLen      , 1       , 1 };

for ii=1:numel(flds2Read.names)
    readRes.(flds2Read.names{ii}) = fread(fid, flds2Read.sizes{ii}, flds2Read.types{ii})';
end

%% Results data

% Number of fields
nNumOfFlds = fread(fid, 1, 'int16');

% Fields names
for ii=1:nNumOfFlds
    check = strcmpi(fread(fid, 4, '*char')', 'char');
    if(~check)
        succ = 0;
        outStruct = struct();
        return;
    end
    Len = fread(fid, 1, 'int16');
    fldName{ii}.Name = fread(fid, Len, '*char')';
end


% Fields types
for ii=1:nNumOfFlds
    check = strcmpi(fread(fid, 4, '*char')', 'char');
    if(~check)
        succ = 0;
        outStruct = struct();
        return;
    end
    Len = fread(fid, 1, 'int16');
    fldName{ii}.Type = fread(fid, Len, '*char')';
end

nNumOfFrames=fread(fid, 1, 'int16');
for jj=1:nNumOfFrames
    % Fields sizes
    for ii=1:nNumOfFlds
        fldName{ii}.Len = fread(fid, 1, 'int32');function [succ, outStruct] = readNGO(inFileName)

% [succ, outFileName] = writeNGO(fileName)
%   Write NGO file


%% Global
succ = 1;

if(nargin<1 || isempty(inFileName) || ~exist(inFileName, 'file'))
    succ = 0;
    return;
end

fid = fopen(inFileName, 'r+');

if(fid<=0)
    succ = 0;
    outStruct = struct();
    return;
end

patIDMaxLen = 8;

%----------------------------------------------------%
% Reading
%% General header

flds2Read.names = {'fileVer', 'dateTime', 'unqID', 'Fs'   , 'analysisType'};
flds2Read.types = {'*char'  , '*char'   , '*char', 'int16', 'int16'};
flds2Read.sizes = {5        , length(getTimeForSave())        , length(getFileUnqIDTemp())     , 1      , 1};

for ii=1:numel(flds2Read.names)
    readRes.(flds2Read.names{ii}) = fread(fid, flds2Read.sizes{ii}, flds2Read.types{ii})';
end

%% Patient information
clear flds2Read;

flds2Read.names = {'patID', 'bmi'   , 'gestAge'};
flds2Read.types = {'*char', 'single', 'int16'};
flds2Read.sizes = {patIDMaxLen      , 1       , 1 };

for ii=1:numel(flds2Read.names)
    readRes.(flds2Read.names{ii}) = fread(fid, flds2Read.sizes{ii}, flds2Read.types{ii})';
end

%% Results data

% Number of fields
nNumOfFlds = fread(fid, 1, 'int16');

% Fields names
for ii=1:nNumOfFlds
    check = strcmpi(fread(fid, 4, '*char')', 'char');
    if(~check)
        succ = 0;
        outStruct = struct();
        return;
    end
    Len = fread(fid, 1, 'int16');
    fldName{ii}.Name = fread(fid, Len, '*char')';
end


% Fields types
for ii=1:nNumOfFlds
    check = strcmpi(fread(fid, 4, '*char')', 'char');
    if(~check)
        succ = 0;
        outStruct = struct();
        return;
    end
    Len = fread(fid, 1, 'int16');
    fldName{ii}.Type = fread(fid, Len, '*char')';
end

nNumOfFrames=fread(fid, 1, 'int16');
for jj=1:nNumOfFrames
    % Fields sizes
    for ii=1:nNumOfFlds
        fldName{ii}.Len = fread(fid, 1, 'int32');
    end
    
    
    % Actual data to read
    
    for ii=1:nNumOfFlds
        %     readRes.resData.(fldName{ii}.Name) = fread(fid, fldName{ii}.Len, fldName{ii}.Type)';
        type = fldName{ii}.Type;
        if(strcmpi(fldName{ii}.Type, 'char'))
            type = ['*' type];
        end
        readRes.resData(jj).(fldName{ii}.Name) =( fread(fid, fldName{ii}.Len, type)');
        
    end
    
end


%% Finalize
fclose(fid);

outStruct = readRes;

    end
    
    % Actual data to read    
    for ii=1:nNumOfFlds
        %     readRes.resData.(fldName{ii}.Name) = fread(fid, fldName{ii}.Len, fldName{ii}.Type)';
        type = fldName{ii}.Type;
        if(strcmpi(fldName{ii}.Type, 'char'))
            type = ['*' type];
        end
        readRes.resData(jj).(fldName{ii}.Name) =( fread(fid, fldName{ii}.Len, type)'); 
    end
end

%% Finalize
fclose(fid);

outStruct = readRes;
