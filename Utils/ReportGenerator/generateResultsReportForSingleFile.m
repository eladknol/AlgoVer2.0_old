function generateResultsReportForSingleFile(fileName, autoOpen)

if(~nargin)
    disp('Where is my file name?');
    return;
end

if(nargin<2)
    autoOpen = [];
end

if(isempty(autoOpen))
    autoOpen = 1;
end

options.format = 'pdf';
options.showCode = false;
options.imageFormat = 'bmp';
options.evalCode = true;
options.catchError = true;
options.figureSnapMethod = 'getframe';


baseDir = [getNGFBaseDir() '\Output\Reports'];
if(~isdir(baseDir))
    mkdir(baseDir);
end

options.outputDir = baseDir;


%% Load the results
global publishData;

[~,~, ext] = getFileName(fileName);
switch(ext)
    case {'mat', '.mat'},
        openPath = fileName;
        allResExist = 0;
        exps = regexp(openPath, {'fQRSDetection\', 'mECGElimination\', 'mQRSDetection\'}, 'once');
        if(~isempty(exps))
            ind = [exps{:}]-1;
            
            [aa, ~, cc] = getFileName(fileName);
            fileName = [aa cc];
            
            resPath.mQRS = fullfile([openPath(1:ind) '\mQRSDetection'], fileName); %#ok<MFAMB>
            resPath.mECG = fullfile([openPath(1:ind) '\mECGElimination'], fileName);
            resPath.fQRS = fullfile([openPath(1:ind) '\fQRSDetection'], fileName);
            if(exist(resPath.mQRS) && exist(resPath.mECG) && exist(resPath.fQRS))
                allResExist = 1;
            else
                % Look for the files in the database
                if(length(openPath) - ind > 3)
                    if(~isempty(exps{1}))
                        strLen = length('fQRSDetection');
                    elseif(~isempty(exps{2}))
                        strLen = length('mECGElimination');
                    elseif(~isempty(exps{3}))
                        strLen = length('mQRSDetection');
                    else
                        allResExist = 0;
                        error('Cause an error')
                    end
                    
                    fileName = [openPath(strLen+ind+1:end) fileName];
                    resPath.mQRS = fullfile([openPath(1:ind) '\mQRSDetection'], fileName);
                    resPath.mECG = fullfile([openPath(1:ind) '\mECGElimination'], fileName);
                    resPath.fQRS = fullfile([openPath(1:ind) '\fQRSDetection'], fileName);
                    if(exist(resPath.mQRS) && exist(resPath.mECG) && exist(resPath.fQRS))
                        allResExist = 1;
                    end
                end
            end
            
            if(allResExist)
                temp = load(resPath.mQRS);
                publishData.mQRS = temp.mQRS;
                
                temp = load(resPath.mECG);
                publishData.removeStruct = temp.removeStruct;
                
                publishData.metaData  = publishData.removeStruct.metaData;
                
                temp = load(resPath.fQRS);
                if(isfield(temp,'fQRS'))
                    publishData.fQRS = temp.fQRS;
                elseif(isfield(temp,'fQRS_struct'))
                    publishData.fQRS.fQRS_struct = temp.fQRS_struct;
                else
                    publishData.fQRS = temp;
                end
                
                
                % Annotated fQRS positions
                annotDataExist = 0;
                if(isfield(temp, 'fQRS') && isfield(temp.fQRS, 'annot'))
                    annotDataExist = 1;
                    publishData.annotfQRSPos = temp.fQRS.annot;
                else
                    annotFileName = [aa '.fqrs' '.txt'];
                    res = findSpecFile(annotFileName, 'txt', 'C:\Users\Admin\Google_Drive\Nuvo Algorithm team\Database', 0);
                    if(~isempty(res))
                        if(iscell(res))
                            res = res{1};
                        end
                        temp = load(res);
                        if(isnumeric(temp))
                            annotDataExist = 1;
                            resPath.fQRS_annot = res;
                        end
                    end
                    if(annotDataExist)
                        temp = load(resPath.fQRS_annot);
                        publishData.annotfQRSPos = temp;
                    else
                        publishData.annotfQRSPos = [];
                    end
                end
            end
            
            
        end
    case {'ngo', '.ngo'},
        [succ, outStruct] = readNGO(fileName);
        if(~succ)
            error(['Cannot read results file: ' fileName]);
        end
        publishData.mQRS.pos = outStruct.resData.ECG_mQRSPos;
        publishData.mQRS.avgMHR = outStruct.resData.ECG_avgMHR;
        
        publishData.fQRS.pos = outStruct.resData.ECG_fQRSPos;
        publishData.fQRS.avgFHR = outStruct.resData.ECG_avgFHR;
        publishData.fQRS.globalScore = outStruct.resData.ECG_globalScore;
        
        publishData.metaData.SubjectID = outStruct.patID;
        publishData.metaData.Gestation.week = outStruct.gestAge;
        publishData.metaData.Gestation.day = 0;
        publishData.metaData.BMIbeforepregnancy = outStruct.bmi;
        publishData.metaData.Fs = outStruct.Fs;
        publishData.metaData.fileVer = outStruct.fileVer;
        publishData.metaData.fileSaveTime = outStruct.dateTime;
        publishData.metaData.fileUnqID = outStruct.unqID;
        
        
    otherwise,
        error('Results file type is not supported');
end

%% Do publish the report
try
    publish('reportTemplate.m', options);
catch mexcp
    warning('Cannot generate report');
    disp(mexcp.getReport());
end

%%

inFile = [baseDir '\reportTemplate.' options.format];
if(exist(inFile, 'file'))
    outFile = [baseDir '\' getFileName(fileName) '.' options.format];
    if(exist(outFile, 'file'))
        suff = datestr(datetime);
        suff(suff == ':') = '-';
        outFile = [baseDir '\' getFileName(fileName) '_'  suff '.' options.format];
    end
    movefile(inFile, outFile, 'f');
else
    
end
if(autoOpen)
    
    system([outFile ' &'])
end