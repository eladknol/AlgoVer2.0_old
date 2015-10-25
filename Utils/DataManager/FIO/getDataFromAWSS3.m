% Get database files from AWS S3 clound storage 
filesList = getDatabaseFiles('all', [], [], 1); % get the files list  form the database file

localBase = getNGFBaseDir(); % base directory
probDownFiles = [];
for iFile = 1:numel(filesList)
    shortFileName = strrep(filesList{iFile}, localBase, '...');
    fprintf(1, '\n');
    fprintf(1, 'Reading file: ');
    fprintf(1, '%s', shortFileName);
    
    [succ, tempFileName] = getFileFromAWSS3(filesList{iFile}); % Download the file and save it
    if(succ)
        res = 'V';
    else
        res = 'X';
        probDownFiles = [probDownFiles filesList(iFile)];
    end
    fprintf(1, ': (%s)', res);
end
save([localBase '\probDownFiles.mat'], 'probDownFiles')
