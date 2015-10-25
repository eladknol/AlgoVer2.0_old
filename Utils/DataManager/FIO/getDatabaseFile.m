function getDatabaseFile()

% Get the database xlsx file
try
    base = 'http://nuvogroup-algorithm-samples.s3.amazonaws.com/Database/';
    shortFileName = 'Database_stats.xlsx';
    onlineFileName = [base shortFileName];
    localFileName = [getNGFBaseDir() '\' shortFileName];
    res = websave(localFileName, onlineFileName);
    if(exist(res, 'file'))
        disp('Database file succ saved.');
    else
        disp('Cannot save database file.');
    end
catch excp
    disp(excp.getReport());
end