function resStruct = readEHGFile(fileName)

warning('off');
resStruct = [];

if(~exist(fileName, 'file'))
    disp('File does not exist!');
    return;
end

[path, file, ext] = fileparts(fileName);

% remove the extention of the file, but save it!
if(~isempty(ext))
    fileName = strrep(fileName, ext, '');
end

%% Read the header file

hdrFile = [fileName '.hea'];

if(exist(hdrFile, 'file'))
    try
        fid = fopen(hdrFile);
        if(fid>0)
            str = textscan(fid, '%s');
            fclose(fid);
            % Parse the file
            if(~isempty(str))
                str = str{1};
                shift = find(strcmp(str, file), 1, 'first');
                if(isempty(shift))
                    error('Cannot read file');
                end
                flds = {'fileName', 'nNumOfChs', 'Fs', 'nNumOfSamples'};
                for i=1:numel(flds)
                    tmp = str2double(str{shift - 1 + i});
                    if(isnan(tmp))
                        meta.(flds{i}) = str{shift - 1 + i};
                    else
                        meta.(flds{i}) = tmp;
                    end
                end
                
                addFlds = {'Rectime', 'Gestation', 'Placental_position', 'Age', 'Weight', 'Bleeding_first_trimester', 'Bleeding_second_trimester', 'Funneling', 'Hypertension', 'Diabetes', 'Abortions'};
                addFldsRes = {'gestationAge', 'gestationDuration', 'placentalPosition', 'age', 'weight', 'bleedingFirstTrimester', 'bleedingSecondTrimester', 'funneling', 'hypertension', 'diabetes', 'abortions'};
                
                for i=1:numel(addFlds)
                    shift = find(strcmp(str, addFlds{i}), 1, 'first');
                    tmp = str2double(str{shift + 1});
                    if(isnan(tmp))
                        meta.(addFldsRes{i}) = str{shift + 1};
                    else
                        meta.(addFldsRes{i}) = tmp;
                    end
                end
                
                meta.filters.filt1.order = 0;
                meta.filters.filt1.freq = [0, 10]; % Hz
                meta.filters.filt2.order = 4;
                meta.filters.filt2.freq = [0.08, 4]; % Hz
                meta.filters.filt3.order = 4;
                meta.filters.filt3.freq = [0.3, 3]; % Hz
                meta.filters.filt4.order = 4;
                meta.filters.filt4.freq = [0.3, 4]; % Hz
                
                meta.DeviceID = 'ehgdb';
                resStruct.meta = meta;
                
            else
                error('Cannot read file');
            end
        else
            error('Cannot open file');
        end
    catch mexcp
        disp(mexcp.getReport());
    end
else
    resStruct = [];
    error('Cannot read header file');
end


%% Read the data file

datFile = [fileName '.dat'];

if(exist(datFile, 'file'))
    try
        fid = fopen(datFile);
        if(fid>0)
            rawData = fread(fid,[resStruct.meta.nNumOfChs, resStruct.meta.nNumOfSamples], 'int16');
            fclose(fid);
            resStruct.allData = rawData;            
            resStruct.data = rawData(1:4:end, :);
            resStruct.meta.nNumOfChannels = min(size(resStruct.data));
        end
    catch
        resStruct.data = [];
        error('Cannot read data file');
    end
end
