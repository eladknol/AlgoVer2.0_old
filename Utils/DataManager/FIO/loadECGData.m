function fileCont = loadECGData(input)
% Load ECG data form file or input structure
% This function only loads the data without performing any check on the data. Make sure to DIY!

if(ischar(input)) % The first input is a char array, assume it is the file name
    if(~exist(input, 'file'))
        fileCont = -1;
        return;
    end
    
    [~, ~, ext] = getFileName(input);
    
    switch(ext)
        case {'.mat', 'mat'},
            fileCont = load(input);
            siz = size(fileCont.data);
            if(siz(1)>siz(2)) % Auto transfer the data if it is NxL to
                fileCont.data = fileCont.data';
            end
            fileCont.meta.satLevel = 10;
            fileCont.meta.Samplerate = 1000;
            fileCont.meta.ChannelsTypes = repmat(struct('value', 'AAA'), 1, min(siz));
            for i=1:6
                fileCont.meta.ChannelsTypes(i).value = 'ECG';
            end
            fileCont.meta.Age = 27;
            fileCont.meta.SubjectID = 'AA0000';
            fileCont.meta.BMIbeforepregnancy = 0;
            fileCont.meta.Weekofpregnancy = 0;
            
            return;
        case {'.edf', 'edf'},
            [edf.meta, edf.data] = edfread(input);
            if(strfind(edf.meta.patientID, 'X F X'))
                % same preg woman database
                fileCont = edf;
            end
            fileCont = -2;
            return;
        case {'.ngf', 'ngf'},
            [ngf.meta, ngf.data] = ReadNGF(input);
            siz = size(ngf.data);
            if(siz(1)>siz(2)) % Auto transfer the data if it is NxL to
                ngf.data = ngf.data';
            end
            ngf.meta.satLevel = 10;
            fileCont = ngf;
            clear ngf;
        otherwise
            fileCont = -3;
            return;
    end
else
    % A batch for passing the data directly for analysis
    % firstInput must be a structure array and contain a filed called 'data' and meta
    fileCont = input;
end
