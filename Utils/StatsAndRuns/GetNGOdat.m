function ngo=GetNGOdat(FileName);

if nargin<1
    [FileName,PathName,FilterIndex]=uigetfile('*.ngo','Select a file','C:\Users\Admin\Google Drive\Nuvo Algorithm team\OutputStatRun\');
end

[ngo.suc,ngo.out]=readNGO(fullfile(PathName,FileName));
end
