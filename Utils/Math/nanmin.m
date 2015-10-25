function [y, i] = nanmin(inData)

if(sum(isnan(inData(:)))==length(inData));
    y = nan;
    i = 1;
    return;
end

inData(isnan(inData)) = +inf;

[y, i] = min(inData);