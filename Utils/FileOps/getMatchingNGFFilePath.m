function [ status , NGF_file_path ] = getMatchingNGFFilePath( parent_folder_path, NGO_file_path)
%getMatchingNGFFilePath returns matching NGO file for NGf file, found under
%parent_folder_path
%   Inputs: parent_folder_path - input of designated parent folder path,
%           where NGF file shold be found
%           NGO_file_path - path to NGO file
%   Outputs: status - existance of file
%            NGF_file_path - path to matching NGF file path 

 % get NGF file path
 C=strsplit(NGO_file_path,'\');
 NGF_file_path=fullfile(parent_folder_path,C{end-2},C{end-1},strcat(C{end}(1:end-1),'f'));
 
 if exist(NGF_file_path,'file')==2;
     status=1;
     return;
 else
     status=0;
     return;    
 end

