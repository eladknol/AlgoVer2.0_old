function [y, i] = nanmax(inData)

if(sum(isnan(inData(:)))==length(inData));
    y = nan;
    i = 1;
    return;
end

inData(isnan(inData)) = -inf;

[y, i] = max(inData);