function WriteRunParams(DestFold)

filename=fullfile(DestFold,'ConfigSetUp.txt');

fid=fopen(filename, 'w');

SystemAudioParams;

fprintf(fid,'\r\n\r\n Audio Params \r\n _____________\r\n\r\n');

fprintf(fid,'Window length:  %d Seconds\r\n\r\n', WinLen);

filtSpec=[FBCutoffFrequency1', FBCutoffFrequency2'];
filtSpec=[(1:size(filtSpec,1))',filtSpec];

fprintf(fid, '%4s %8s %6s\r\n', 'No', 'Low', 'High');
fprintf(fid, '%4d)  %5dHz %3dHz\r\n', filtSpec');

if UseICA
    tmpstr='True';
else
    tmpstr='False';
end
fprintf(fid, '\r\n\r\n ICA used in Audio: %s\r\n', tmpstr);

tmpstr=strjoin(ICAfunctionsBank(ICAfunctionsUsed));

fprintf(fid, 'Non Linear functions used: %s\r\n\r\n', tmpstr);

fprintf(fid, 'Slow Envelope window size: %dms\r\n',SlowEnvelope*1000);
fprintf(fid, 'Slow Envelope window size: %dms\r\n',FastEnvelope*1000);

fclose(fid);