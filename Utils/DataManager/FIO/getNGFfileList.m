function List=getNGFfileList(DirectoryName,list)
% getNGFfileList, this function returns a list of all the NGF type files.
% ls=getNGFfileList(DirectoryName)
% Input: the full directory path to be searched in
% Output: a cell array contains all the NGF file names with full path

if nargin>1
    List=list;
else
    List={};
end
if isempty(DirectoryName)
    DirectoryName=uigetdir('C:\Users\Admin\Google Drive\Nuvo Algorithm team\Recordings');
end
DirInfo=dir(DirectoryName);

currList=getNGFfilesIndirectory(DirectoryName);
List=[List, currList];

indx=find([DirInfo.isdir]);
if length(indx>2)
    for k=3:length(indx)
        dirname=fullfile(DirectoryName, DirInfo(indx(k)).name);
        List=getNGFfileList(dirname,List);
    end
end

end

%%
function ls=getNGFfilesIndirectory(DirectoryName)
DirInfo=dir(DirectoryName);

indx=find(~[DirInfo.isdir]);

filesStruct=DirInfo(indx);
FileList={filesStruct.name};
isngf=regexpi(FileList,'.ngf');

ls=[];
for k=1:length(isngf)
    if ~isempty(isngf{k})
        ls=[ls, {fullfile(DirectoryName,FileList{k})}];
    end
end
end
