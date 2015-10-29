function [exitFlag, secOut, thrdOut] = analyzeFECGInterval(inputStruct)

exitFlag = -1;
secOut = [];
thrdOut = [];

if(~nargin || ~isstruct(inputStruct))
    try
        error('Input data must be a structure array!');
    catch mexcp
        exitFlag = -1;
        secOut = mexcp;
        thrdOut = [];
    end
    return;
end

try
    [exitFlag, outData] = analyzeSingleECGRecord__CDR(inputStruct, 0);
    secOut = outData.secOut;
    thrdOut = outData.thrdOut; 
catch mexcp
    exitFlag = -1;
    secOut = mexcp;
    thrdOut = [];
end
