function [succ, tempFilePath] = getFileFromAWSS3(fullFileName)
%% DOC
% [succ, tempFilePath] = getFileFromAWSS3(fullFileName)
% 
% Outputs:
%        1->succ         : true if the file was saved successfully to a temporary local directory
%        2->tempFilePath : The full path of the temporary file; empty if succ is false
% 
% Inputs:
%        1->fullFileName: the full name of the file (it accepts files with full path of relative path using the '...\' prefix).
% 
% Limitations:
%        1-> The input file name must contain the 'Database' keyword once and only once
%        2-> Apparently (kid), you need a valid internet connection
% 
% 
% Usage examples:
%       fullFileName = '...\Database\20150312\subject2\ALU_36-5_LYG_ECG_BPC_2_1.ngf'
%       [succ, tempFilePath] = getFileFromAWSS3(fullFileName)


%% CODE
try
    onlineBase = getNGFBaseDir([], 'web');
    localBase = getNGFBaseDir('temp', 'local');
    
    if(~isdir(localBase))
        mkdir(localBase);
    end
    
    shortFileName.local = fullFileName(strfind(fullFileName, 'Database'):end);
    shortFileName.online = strrep(shortFileName.local, '\', '/');
    
    clear fullFileName;
    fullFileName.local = [localBase shortFileName.local(length('Database')+1:end)];
    fullFileName.online = [onlineBase shortFileName.online(length('Database')+1:end)];
    
    [~, path, ~] = getFileName(fullFileName.local);
    if(~isdir(path))
        mkdir(path);
    end
    
    [tempFilePath, downTime] = downloadFileFromAWSS3(fullFileName.local, fullFileName.online);
    if(downTime>20)
        warning('It is taking too much time to download a file, consider using the local database.');
    end
    
    if(exist(tempFilePath, 'file'))
        succ = 1;
    else
        succ = 0;
    end
    
catch excp
    disp(excp.getReport());
    tempFilePath = '';
    succ = 0;
end
