% function readECGFile()

[file, path] = uigetfile();

tmp = load([path file]);
data = tmp.data;
clear tmp;

if(strfind(path,'cincchlng2013')>0)
    visCinCData(data.RawData, data.anFQRSPos, 1);
%     clear;
%     fasticag
%     plot(diff(data.anFQRSPos),'*');
else
    ind=4;
    [b,a] =fir1(500,[3 40]/(500));
    plot(filtfilt(b,1,data.RawData(ind,:)));
end