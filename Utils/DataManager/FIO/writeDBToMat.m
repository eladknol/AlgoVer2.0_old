function writeDBToMat()
ccd = cd;
disp('Reading databases...');
h = waitbar(0,'Reading...');
cincchlng2013 =0;
nifecgdb = 1;
%% CinC2013 database
if(cincchlng2013)
    relBDPath{1} = '\RawData\cincchlng2013\';
    
    tmpDir = dir([pwd relBDPath{1}]);
    tmpDir(1) = []; tmpDir(1) = [];
    for i=1:length(tmpDir)
        if(tmpDir(i).isdir)
            currDir = [pwd relBDPath{1} tmpDir(i).name '\'];
            cd(currDir);
            files = dir('*.csv');
            cd(ccd);
            len = length(files);
            for j=1:len
                waitbar(j/len, h, 'reading...');
                currFile = [currDir files(j).name];
                RawData = read2013ChlngFile(currFile, 1);
                anounFQRSName = strrep(currFile,'.csv','.fqrs.txt');
                anFQRSPos = getAnouncedFQRSPos(anounFQRSName);
                
                data.RawData = RawData;
                data.anFQRSPos = anFQRSPos;
                data.nNumOfLeads = 4;
                
                [aa,bb,cc] = fileparts(currFile);
                matFile = [pwd relBDPath{1} 'matFiles\' bb '.mat'];
                save(matFile,'data');
            end
        end
    end
    
end
%% Non-Invasive Fetal ECG database
if(nifecgdb)
    relBDPath{2} = '\RawData\nifecgdb\';
    
    cd([pwd relBDPath{2}]);
    files = dir('*.edf');
    cd(ccd);
    len = length(files);
    for i=1:len
        waitbar(i/len, h, 'reading...');
        currFile = [pwd relBDPath{2} files(i).name];
        [hdr, tmpData] = edfread(currFile);
        
        data.RawData = tmpData;
        data.anFQRSPos = 0; % read the qrs positions form the .qrs file
        data.nNumOfLeads = hdr.ns;
        
        [aa,bb,cc] = fileparts(currFile);
        matFile = [pwd relBDPath{2} 'matFiles\' bb '.mat'];
        save(matFile,'data');
    end
end
close(h);