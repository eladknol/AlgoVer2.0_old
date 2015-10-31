function publish_all_functions(function_name,varargin)
% This function extends the capability of the publish command to publish
% <function_name> and its subfunctions together into one
% document/html/pdf/...
%
% Syntax: >>publish_all_functions(<function_name>,options)
% <function_name> - Name of the main function that has to be published.
% Use the same options format of "publish" command.
%
% Example:
% 1. >> publish_all_functions(<function_name>,'pdf').
% 2. >> opts.outputDir = 'C:\';
%    >> opts.format = 'html';
%    >> publish_all_functions (<function_name>',opts);
%
% Here are activities done by this utility.
%   - Reads all the subfunctions of "<function_name>".
%   - Creates a new file with the name "<function_name>", and copies the main
%   function and the all the subfunctions into this.
%   - Lists all the "other files" pcodes, mex files and others that are
%   called by <function_name>.m to the user.
%   - Publish the new file.
%
% All files are placed in directory publish_files_<date>. If the
% directory already available, then it overwrites the contents.
%
% Constraint: All functions should use either one of the closing command
% "return" or "end" uniformly between them. Else the function will stop the
% publishing process.
%
% Developed by: Neelakanda Bharathiraja.
%


% Input validations.
if nargin<2
    options = [];
else
    options = varargin{1};
end

try
    % Find the dependant functions in the tools directory.
    trace_list = depfun(function_name,'-quiet');
catch
    disp(['The function ' function_name ' is not available in the MATLAB path!']);
    return;
end

% Remove the functions that are from matlabroot
trace_list(strncmp(matlabroot,trace_list,length(matlabroot)))=[];

% Group the m-files and other files.
function_files = {};
other_files = {};
for ii = 1:length(trace_list)
    [file_dir, name, ext]= fileparts(trace_list{ii});
    if strcmp(ext,'.m')
        function_files = [function_files trace_list(ii)];
    else
        other_files = [other_files trace_list(ii)];
    end
end

% Copy the contents of all the mfiles and write it into the <function_name>.m
current_dir = pwd;
publish_dir = sprintf('%s\\publish_files_%s', current_dir,date);
mkdir(publish_dir);
cd(publish_dir);
fileID = fopen([function_name '.m'], 'w+');
for ii = 1:length(function_files)
    fid = fopen(function_files{ii});
    [file_dir, file_name, ext]= fileparts(trace_list{ii});
    fwrite(fileID, ['%% ' file_name char(10)]);
    tline = fgets(fid);
    while ischar(tline)
        fwrite(fileID, tline);
        tline = fgets(fid);
    end
    fclose(fid);
    fwrite(fileID, char(10));
end

% Print the dependant files.
if ~isempty(other_files)
    fwrite(fileID,['%% List of other functions that are called:' char(10)]);
    for ii = 1:length(other_files)
        [file_dir, file_name, ext]= fileparts(other_files{ii});
        fwrite(fileID, [file_name ext char(10)]);
    end
end
fclose(fileID);

try
    % Publish it now.
    if isempty(options)
        publish([publish_dir '\' function_name '.m']);
    else
        publish([publish_dir '\' function_name '.m'],options);
    end
catch
    disp(['Publish process is not successful.'  char(10) ...
        'Check the file ' publish_dir '\' function_name '.m']);
    return;
end

return;
