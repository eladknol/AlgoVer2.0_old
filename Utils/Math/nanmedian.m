function y = nanmedian(inData)

inData = inData(:);
if(sum(isnan(inData))==length(inData));
    y = nan;
    return;
end

inData(isnan(inData)) = [];

y = median(inData);