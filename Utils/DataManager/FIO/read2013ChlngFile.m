function data = read2013ChlngFile(fName, isAnounced)

% read2013ChlngFile
% DESCR: read data file from CinC 2013 challenge database
% INPUT: fName: excel file name
%        isAnounced: if true return result as an anounced structure. if
%        false return results as a matrix
% OUTPUT: ECG data
% for more info about the database see '...RawData\cincchlng2013\Info.txt'

if(nargin<2)
    isAnounced = 0;
end

% fName='C:\Users\Muhammad\Dropbox\fetal\RawData\cincchlng2013\set-a-text\a01.csv';

if(isAnounced)
    % retunr the results as a structure
    try
        [NUM, TXT] = xlsread(fName);
        for i=1:size(TXT,2)
            tmp = TXT{1,i};
            tmp(tmp=='''') = []; % remove ' special char
            tmp(tmp==' ') = '_'; % remove spaces
            hdr{i} = tmp;
            data.(hdr{i}) = NUM(:,i);
        end
    catch
        disp('Cannot read excel file');
        data = -1;
    end 
else
    % return the data as a matrix
    try
        data = xlsread(fName);
    catch
        disp('Cannot read excel file');
        data = -1;
    end
end
