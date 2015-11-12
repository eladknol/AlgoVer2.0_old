function [ FilesPaths ] = getFilesPaths(folder,ext)
% function receives a folder name 'folder' and file extension ext and returns the paths
% to the files
% input: 'folder' - folder where desired files are stored
%                 - ext - file extension
% output : FilesPaths - paths to files
% Example: 
% [ FilesPaths ] = getFilesPaths('C:\Users\Elad\Desktop','m') 
% returns apths to all .m files in users Desktop

% find all  files in folder
FilesData=dir(fullfile(folder,['*.' ext]));

if ~isempty(FilesData)
    FilesNames={FilesData(:).name}';    
   
    % sort files according to date
    [~,I]=sort([FilesData(:).datenum]);
    FilesNames=FilesNames(I);
    FilesPaths=fullfile(folder,FilesNames);      
  else
    FilesPaths=[];
end
end



