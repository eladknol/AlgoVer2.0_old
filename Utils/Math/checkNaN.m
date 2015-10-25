function [nanPerc, nanInd] = checkNaN(data)
%#codegen

% Also works with multi channel data, NxL
nanInd = isnan(data);
nanPerc = sum(nanInd')/length(data)*100;
