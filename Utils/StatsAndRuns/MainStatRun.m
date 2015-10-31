function out=MainStatRun()

% Run Detecion on files for statistical performance analysis

%Load file  list file
try
load('C:\Users\Admin\Google Drive\Nuvo\code\AlgoVer1.0\AmitCode\StatsAndRuns\FileList1.mat')
catch
    load('C:\Users\Administrator\Google Drive\Nuvo\code\AlgoVer1.0\AmitCode\StatsAndRuns\FileList1.mat')
     
end

out=RunFullDetectionOnList(FileList,false);

save out
end
