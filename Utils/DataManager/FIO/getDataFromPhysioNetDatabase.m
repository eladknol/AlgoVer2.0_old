function getDataFromPhysioNetDatabase(dbURL)

if(~nargin)
    dbURL = 'http://physionet.org/pn3/nifecgdb/';
end
% Get records files names
try
    recordsSubURL = 'RECORDS';
    urlwrite([dbURL recordsSubURL],'RECORDS.txt');
    fid = fopen('RECORDS.txt');
    rNames = textscan(fid, '%s');
    fclose(fid);
catch
    rNames = -1;
end
if(iscell(rNames))
    rNames = rNames{1};
    h = waitbar(0,'Reading records...');
    nNumOfRecords = numel(rNames);
    for iRec = 1:nNumOfRecords
        waitbar(iRec/nNumOfRecords,h,'Reading records...');
        recName = [rNames{iRec}];
        db = dbURL(1:end-1);
        ind = find(db=='/',1,'last');
        dbName = db(ind+1:end);
        path = [pwd '\RawData\' dbName '\'];
        if(~exist(path,'dir'))
            mkdir(path);
        end
        fileName = [path recName];
        [pth, file, ext] = fileparts(fileName);
        if(isempty(ext))
            fileName = [fileName '.dat'];
            [pth, file, ext] = fileparts(fileName);
        end
        try
            urlwrite([dbURL recName ext], fileName);
            
            if(strcmpi(ext, '.dat'))
                urlwrite([dbURL recName '.hea'], strrep(fileName, ext, '.hea'));
            else
                urlwrite([dbURL recName '.qrs'],[fileName '.qrs']);
            end
            disp(['Res: ' recName ' succ']);
            
        catch
            disp(['Res: ' recName ' failed']);
        end
    end
    close(h);
else
    if(rNames<0)
        MAX_NUM_OF_RECORDS = 1000;
        for i = 1:MAX_NUM_OF_RECORDS
            try
                fileName = ['ecgca' num2str(i)];
                fileURL = [dbURL fileName];
                urlwrite(fileURL, [fileName '.edf']);
            catch
                % nothing to catch, file doesn't exist
            end
        end
    end
end