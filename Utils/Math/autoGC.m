function res = autoGC(signal, startInd, endInd, THRESHOLD_VALUE)

if(nargin<4)
    THRESHOLD_VALUE = -60; % to control noise (make sure not to amplify it!)
end
% output power range
OUTPUT_POWER_MIN = -82;
OUTPUT_POWER_MAX = +82;

N = endInd - startInd;

energy = sum(signal(startInd:endInd).^2);

if(10*log10(energy/N) < THRESHOLD_VALUE)
    res = signal(startInd:endInd);
    return;
end

gainLevelDB = OUTPUT_POWER_MAX;
output_power_Normal = 10^(gainLevelDB/10);

K = sqrt( (output_power_Normal*N) / energy);

res = signal(startInd:endInd) * K;
