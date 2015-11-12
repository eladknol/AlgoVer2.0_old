function RTAnalyzeLog(handles,ME)
%RTAnalyzeLognClose logs error to log and closed tool
% open file
fid = fopen(fullfile(handles.debugDir,'log.txt'),'a+');
fprintf(fid,'%s: %s\n',datestr(datetime),ME.message);

for e=1:length(ME.stack)
    fprintf(fid,'%s at %i\n', ME.stack(e).name,ME.stack(e).line);
end
    fprintf(fid,'\n');
% close file
fclose(fid);
end

