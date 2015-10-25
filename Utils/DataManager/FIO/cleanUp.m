function [succ, info] = cleanUp(fullFileName)

% Run after run clean up
% This function is useful when using temp file (downloaded form AWS S3 for example)
% Limitations: The main assumptions behind the clean up procedure is to preserve un-used disk space. If the file is locked by another program (or even MATLAB), the file will not be deleted and no info will be given
% The procedure is very useful in most of the cases where the analysis time will take enough time so the file will be unlocked by the other
% programs (for example Google Drive)
% To overcome this issue, run the procedure after finishing all of the analysis. In this case 'fullFileName' is a cell of strings containing
% the files names.
% Note: This procedure will not delete the folders containing the files, so it is safe to save output files in the same folders


if(iscell(fullFileName))
    for i=1:numel(fullFileName)
        cleanUp(fullFileName{i});
    end
    
    succ = 1;
    return;
end

info = '';

try
    if(~exist(fullFileName, 'file')) %#ok<*MFAMB>
        error('File does not exist.');
    end
    recycle('off');
    delete(fullFileName);
    
    succ = 1;
    
catch mexcp
    succ = 0;
    info = mexcp.getReport();
end