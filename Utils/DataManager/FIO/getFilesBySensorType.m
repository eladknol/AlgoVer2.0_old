function getFilesBySensorType()

[filesList, db] = getDatabaseFiles('all');

filesList = [];

% Get any file with any appearance of C+ electrodews in it
sensType = 'ECG , CLOTHING+';
for i=1:6
    quer = ['ECG_type_' num2str(i)];
    filesList = [filesList; getDatabaseFiles(quer, {sensType}, db)];
end

filesList = unique(filesList); % remove repetitions

filesList
