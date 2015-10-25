function filterProps = get50HzFilterProps()

filterProps.QF = 1.5;
filterProps.Fc = 50; %Hz

filterProps.nNumOfHarmonics = 4; % number of 50Hz harmonics (50, 100, 150, 200,...)
filterProps.winSize = 1000;


filterProps.Fs = 1000;