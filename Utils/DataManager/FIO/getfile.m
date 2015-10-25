function [file, path] = getfile(startDir, fileType)

if(nargin<2)
    fileType = '.mat';
end
if(isempty(fileType))
    fileType = '.mat';
end

if(nargin<1)
    startDir = pwd;
end

filesTypes = {'*.ngf', 'NGF data files (*.ngf)'; ...
              '*.mat', 'MAT-files (*.mat)'; ...
              '*.edf', 'EDF data files (*.edf)'; ...
              '*.ecg', 'ECG data files (*.ecg)'; ...
              '*.dat', 'DAT data files (*.dat)'; ...
              '*.txt', 'CTG results files (*.txt)'; ...
              '*.ngo', 'NGO results files (*.ngo)'
              };
          

tmp = filesTypes(:,1);

if(isempty(strfind(fileType, '*')))
    fileType = ['*' fileType];
end

ind = find(strcmpi(tmp, fileType)==1);

inds = 1:length(tmp);
inds(inds==ind) = [];
inds = [ind, inds];
inds(inds==0)=[];

filesTypes(:,1) = filesTypes(inds,1);
filesTypes(:,2) = filesTypes(inds,2);

[file, path] = uigetfile(filesTypes, 'Select a file', startDir);

if(isempty(file) && isempty(strfind(file, '.mat')) && isempty(strfind(file, '.edf')) && isempty(strfind(file, '.ngf')))
    file = 0;
    return;
end
file = [path file];