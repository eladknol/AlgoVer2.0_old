function [satPerc, satInd] = checkSaturation(signal, saturationLevel)
%#codegen

%[satPerc, satInd] = checkSaturation(signal, saturationLevel)
% Also works with multi channel data, NxL
% satPerc is in % (100!)

satInd = abs(signal)>=0.98*saturationLevel;
satPerc = sum(satInd')/length(signal)*100;
