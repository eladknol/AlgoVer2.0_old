function [filePath, downTime] = downloadFileFromAWSS3(local_name, online_name)
downTime = tic;

timeOut = 10;
try
    res = evalc('!ping -n 1 8.8.8.8');
    strt = regexp(res, 'bytes=')+length('bytes=');
    for i=strt:length(res)
        if(isnan(str2double(res(i))))
            break;
        end
    end
    packetSizeInBytes = str2double(res(strt:i-1));
    
    res = res(regexp(res, 'Average = [0-9][0-9]') + length('Average = '):end);
    pingTime = str2double(res(1:regexp(res, 'ms')-1));
    
    if(~isnan(pingTime) && ~isnan(packetSizeInBytes))
        connSpeed = (packetSizeInBytes/1024)/(pingTime/1000); % MByte/Sec
        % Estimate the maximum download time, given a maximum fle size of 30MB
        maxFileSize = 30; % MB
        maxDownTime = maxFileSize/connSpeed;
        timeOut = maxDownTime;
        
        if(maxDownTime>100) % sec
            disp('Your internet connection is too slow, consider using the local database');
        end
    end
    
catch
end

opts = weboptions('TimeOut', timeOut);
filePath = websave(local_name, online_name, opts);

downTime = toc(downTime);