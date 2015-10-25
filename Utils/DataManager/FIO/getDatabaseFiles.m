function [filesList, db] = getDatabaseFiles(query, values, db, isOnline, dataBaseFileName)

%filesList = getDatabaseFiles(query, values, db)
%   query: a string (for example: 'BMI')
%   values: the values for the query. It can have the following structure:
%           1. Structure array: must have two fields, start and end (query = 'BMI'; values.lower = 20; values.upper = 25; will inclues the files with BMI in the 20-25 range)
%           2. Numeric array: have two elements, start and end (query = 'BMI'; values(1) = 20; values(2) = 25; will inclues the files with BMI in the 20-25 range)
%           If the query is not numeric, the 1st option is preferred and only one field is needed (only the first is used!). If you use the 2nd option make sure to have the data in a cell array.

filesList = [];

verbose = 1;
if(nargin<1), query = 'all'; end

if(nargin<2)
    if(strcmpi(query, 'all'))
        values = [];
    else
        error('Values cannot be empty for this query.');
    end
end

if(nargin<4), isOnline = 0; end % Get Database_stats.xlsx form the web

if(nargin<5)
    dataBaseFileName = 'Database_stats.xlsx';
end

if(nargin<3)
    db = [getNGFBaseDir() '\' dataBaseFileName];
else
    if(isempty(db))
        if(isOnline)
            try
                if(~isdir([pwd '\Temp']))
                    mkdir([pwd '\Temp'])
                end
                disp('Retrieving database info from the cloud.');
                db = downloadFileFromAWSS3([pwd '\Temp\Database_stats.xlsx'], [getNGFBaseDir([], 'web') '/Database_stats.xlsx']);
                if(~isempty(db))
                    fprintf(1, 'Database info downloaded succ. \n' )
                    fprintf(1, 'Analyzing info' )
                    for iii=1:15
                        fprintf(1, '.');
                        pause(0.1);
                    end
                    fprintf(1, '\n');
                else
                    error('Cannot downlaod database file');
                end
            catch mexcp
                disp(mexcp.getReport());
                db = [];
                error('Cannot download file from the web');
            end
        else
            db = [getNGFBaseDir() '\Database_stats.xlsx'];
        end
    end
end

if(ischar(db))
    try
        Disp(verbose, 'Reading database...', 0);
        [~, ~, raw] = xlsread(db);
        Disp(verbose, 'Database read.');
        header = raw(1,:);
        bin = strcmpi(header, 'fullpath');
        fld_ind = find(bin, 1, 'first');
        temp = raw(2:end,fld_ind);
        if(~isempty(strfind(temp{1}, '...\')))
            aa=getNGFBaseDir();
            
            temp = strrep(temp, ['...' aa(find(aa=='\',1, 'last'):end)], getNGFBaseDir());
        end
        raw(2:end,fld_ind) = temp;
        db = raw;
        
    catch excp
        disp('Cannot read database file');
        disp(excp.getReport());
    end
end

if(isempty(db))
    return;
end

fld_ind = find(strcmpi(db(1,:), 'fullpath'), 1, 'first');

switch(query)
    case 'all',
        filesList = db(2:end, fld_ind);
    otherwise,
        header = db(1,:);
        if(any(strcmpi(header, query)))
            filesList = db(includeFiles(db, query, values), fld_ind);
        end
end

if(isempty(filesList))
    warning('There was no match for the requested query. Check your query!');
end

function [inds, queryVals] = includeFiles(db, fld, vals)
inds = [];
header = db(1,:);
if(sum(strcmpi(header, fld))>1)
    warning('There are multible fields that match your query. Using the first field.');
end
fld_ind = find(strcmpi(header, fld), 1, 'first');
vec = db(2:end, fld_ind);
if(isnumeric(vec{1}))
    vec = [vec{:}];
    dataType = 'num';
elseif(ischar(vec{1}))
    dataType = 'char';
else
    error('This data type is not supporterd.');
end

if(isstruct(vals))
    if(numel(fields(vals)) == 2 && sum(isfield(vals, {'lower', 'upper'})) ~= 2)
        error('Lower and upper limits must be specified.');
    end
    
    switch(dataType)
        case 'num',
            inds = vec>=vals.lower & vec<=vals.upper;
        case 'char',
            fld = fields(vals);
            inds = strcmp(vec, vals.(fld{1}));
    end
elseif(iscell(vals))
    switch(dataType)
        case 'num',
            inds = vec>=vals{1} & vec<=vals{2};
        case 'char',
            inds = strcmp(vec, vals{1});
    end
else
    if(length(vals)~=2)
        error('Lower and upper limits must be specified. values cannot have a length that is different than 2.');
    end
    
    switch(dataType)
        case 'num',
            inds = vec>=vals(1) & vec<=vals(2);
        case 'char',
            inds = strcmp(vec, vals(1));
    end
end

if(~isempty(inds))
    inds = find(inds)+1;
end

queryVals = vec(inds-1);