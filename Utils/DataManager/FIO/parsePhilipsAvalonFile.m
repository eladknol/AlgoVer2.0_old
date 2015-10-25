function [succ, resData] = parsePhilipsAvalonFile(fileName)
succ = 1;
resData = struct();

if(~exist(fileName))
    succ = 0;
    return;
end

fid = fopen(fileName, 'r+');

if(fid<0)
    succ = 0;
    return;
end

raw = textscan(fid, '%s');
fclose(fid);

if(isempty(raw))
    succ = 0;
    return;
end

raw = raw{1};

timeStamps = [];
fHR = [];
fHR_quality = [];
mHR = [];
TOCO = [];

for i=1:numel(raw)
    switch(lower(raw{i}))
        case 'time:'
            timeStamps = [timeStamps; datevec(raw{i+1}(1:end-1), 'HH:MM:SS')];
        case 'hr1:',
            ind = strfind(raw{i+1}(1:end-1), '-');
            value = raw{i+1}(1:ind-1);
            fHR = [fHR str2double(value)];
            switch raw{i+1}(ind+1)
                case 'G',
                    quality = 2;
                case 'Y',
                    quality = 1;
                case 'R',
                    quality = 0;
                otherwise
                    quality = 0;
            end
            fHR_quality = [fHR_quality quality];
            
        case 'mhr:',
            mHR = [mHR str2double(raw{i+1}(1:end-1))];
        case 'toco:',
            TOCO = [TOCO str2double(raw{i+1}(1:end-1))];
    end
end

resData.timeStamps = timeStamps;
resData.fHRC = fHR;
resData.fHR_quality = fHR_quality;
resData.mHRC = mHR;
resData.TOCO = TOCO;