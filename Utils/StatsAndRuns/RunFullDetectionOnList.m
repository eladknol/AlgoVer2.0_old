function out=RunFullDetectionOnList(FileList,AWSrun)
global AWSFLAG
if nargin<2
    AWSrun=false;
    AWSFLAG=false;
else
    AWSFLAG=AWSrun;
end

NumOfFiles=length(FileList);

OutPutDir='C:\Users\Administrator\Google Drive\Nuvo\Database\V2Run\Run051115_IIR3';
WriteRunParams(OutPutDir);

for k=1:1 %NumOfFiles
    fnam=FileList{k};
    out(k).FileName=fnam;
    [pathstr,name,ext]=fileparts(fnam);
    DirParts=strsplit(pathstr,'\');
    DestFname=fullfile(OutPutDir,DirParts{end-1},DirParts{end},[name,'.ngo']);
    DestFname2=fullfile(OutPutDir,DirParts{end-1},DirParts{end},[name,'.mat']);
    if AWSrun
        [out(k).ReadSucc, tempFilePath] = getFileFromAWSS3(fnam);
    else
        tempFilePath=fnam;
        out(k).ReadSucc=true;
    end
    if out(k).ReadSucc
        try
        [inputStruct.meta,inputStruct.data]=ReadNGF(tempFilePath);
        if ~isfield(inputStruct.meta, 'satLevel')
            inputStruct.meta.satLevel=10;
        end
        [OutStruct,Audio,ECG]=LongDetection(inputStruct,[],1);
        
        [out(k).WriteSucc,out(k).Resfname]=writeNGO(DestFname,OutStruct);
        save(DestFname2, 'Audio', 'ECG','OutStruct');
        catch
        end
    end
    if AWSrun
        delete(tempFilePath);
    end
end



