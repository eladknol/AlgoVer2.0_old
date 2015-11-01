warning off;
try
    load('SearchDir.mat');
catch
    PathName='C:\Users\Admin\Google Drive\Nuvo Algorithm team\Database\';
end


[filename,PathName,ind]=uigetfile('*.ngf','Select File', PathName);
if filename==0
    return
end

save('SearchDir.mat','PathName');

[fn,pth,exten]=fileparts(filename);
switch exten
    case '.ngf'
[inputStruct.meta,inputStruct.data,ctg]=ReadNGF(fullfile(PathName,filename));
    case '.mat'
      load  DemoInputStruct
      load(fullfile(PathName,filename));
      inputStruct.data=data;
end

[OutStruct,AudioOut,ECGOut]=LongDetection(inputStruct,3,1);
