function [ status , NGO_file_path ] = getMatchingNGOFilePath( parent_folder_path, NGF_file_path)
%getMatchingNGOFilePath returns matching NGO file for NGF file, found under
%parent_folder_path
%   Inputs: parent_folder_path - input of designated parent folder path,
%                                where NGF file should be found.
%           NGF_file_path - path to NGO file
%   Outputs: status - existance of file
%           NGO_file_path - path to matching NGO file path 

 % get NGF file path
 C=strsplit(NGF_file_path,'\');
 NGO_file_path=fullfile(parent_folder_path,C{end-2},C{end-1},strcat(C{end}(1:end-1),'o'));
 
 if exist(NGF_file_path,'file')==2;
     status=1;
     return;
 else
     status=0;
     return;    
 end

