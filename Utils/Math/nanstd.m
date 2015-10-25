function y = nanstd(inData, dim)
if(nargin<2)
    dim = 1;
end

if(dim==1)
    inData = inData(:);
    if(sum(isnan(inData))==length(inData));
        y = nan;
        return;
    end
    
    inData(isnan(inData)) = [];
    y = std(inData);
else
    for i=1:size(inData,2)
        tmp = inData(~isnan(inData(:,i)), i);
        STD(i) = std(tmp);
    end
    y = STD;
end