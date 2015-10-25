
%% CinC2013 database
relBDPath = '\RawData\cincchlng2013\set-a-text\';
recID = 'a01';

dataFName = [pwd relBDPath recID '.csv'];
anounFQRSName = [pwd relBDPath recID '.fqrs.txt'];

% read data
isAnounced = 1;
RawData = read2013ChlngFile(dataFName, isAnounced);
anFQRSPos = getAnouncedFQRSPos(anounFQRSName);
visCinCData(RawData, anFQRSPos, 1);

%% Non-Invasive Fetal ECG database

relBDPath = '\RawData\nifecgdb\';
recID = 'ecgca746';

dataFName = [pwd relBDPath recID '.edf'];
anounFQRSName = [pwd relBDPath recID '.edf.qrs'];

[hdr, data] = edfread(dataFName);
