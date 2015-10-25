function direc = getNGFBaseDir(pathType, dirType)
% This function returns the base directory of the Database folder
% The output can be a local folder of the database (mainly for local development usage),
% or a web url to the base directory (for usage in th eAWS EC2 instances)

% Inputs:
%       pathType: the type of the output path, full path or relative path
%       dirType: the type of the directory, local or web


if(nargin<1), pathType = 'full'; end
if(nargin<2), dirType = 'local'; end
if(isempty(pathType)),  pathType = 'full'; end
if(isempty(dirType)),   dirType = 'local'; end


if(strcmpi(dirType, 'local'))
    switch(getenv('computername'))
        case {'MUHAMMAD-THINK'}, % Muhammad's Laptop
            direc = 'C:\Users\Admin\Google_Drive\Nuvo Algorithm team\Database';
        case {'MUHAMMAD-SERVER'}, % Dead local server
            direc = 'E:\Google_Drive\Nuvo Algorithm team\Database';
        case {'WIN-BLGMTAJ06ET'}, % Amazon EC2 Muhammad's instance
            direc = 'C:\Users\Administrator\Google Drive'; % This will be also the output base dir
        otherwise,
            direc = [pwd '\Temp\Database'];
            if(~isdir(direc))
                mkdir(direc);
            end
    end
    
    switch(pathType)
        case {'rel'},
            ind = strfind(direc, '\');
            if(~isempty(ind))
                ind = ind(end);
                direc = direc(1:ind-1);
            end
        case {'output'},
            direc = [direc '\Output'];
            mkdir(direc);
        case {'temp'}
            direc = [direc '\Temp\Database'];
            if(~isdir(direc))
                mkdir(direc);
            end
    end
    
elseif(strcmpi(dirType, 'web'))
    direc = 'http://nuvogroup-algorithm-samples.s3.amazonaws.com/Database';
elseif(strcmpi(dirType, 'locaNetworkDrive'))
    direc = 'P:\Database';
else
    error('Go home...');
end
