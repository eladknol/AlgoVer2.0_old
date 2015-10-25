function anFQRSPos = getAnouncedFQRSPos(anounFQRSName)
% Read feta QRS positions from a given text file
% this function assumes that the QRS positions are saved as integers in the
% .txt file (or .mat file)

if(isempty(strfind(anounFQRSName,'fqrs.txt')) && isempty(strfind(anounFQRSName,'.mat')))
    % If the input file name is just the record ID, add an extension to it
    % and try to read the file
    anounFQRSName = [anounFQRSName '.fqrs.txt']; % CinC2013 challenge database
end

try
    anFQRSPos = load(anounFQRSName);
catch
    disp('Cannot read fqrs file.');
    anFQRSPos = -1;
end