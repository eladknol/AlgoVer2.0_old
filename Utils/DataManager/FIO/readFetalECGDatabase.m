function readFetalECGDatabase(dbName, readType)
% readType = 'raw' : read from raw files, 
%          = 'proc': read from pre-proc files

if(nargin<2)
    readType = 'raw';
end

switch (lower(dbName))
    case {'cinc2013'},
        readCinCDB(readType);
    case {'nifecgdb'},
        readNonInvDB(readType);
    otherwise
        disp('What?!');
end