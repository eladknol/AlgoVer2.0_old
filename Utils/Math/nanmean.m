function y = nanmean(inData, dim) %#codegen

% Calulate mean excluding NaN values
% if the data contains only NaNs, the function returns NaN(1x1)

if(nargin<2)
    dim = 1;
end

if(dim==1)
    inData = inData(:);
    
    if(sum(isnan(inData))==length(inData));
        y = nan(1); 
        return;
    end
    
    %inData(isnan(inData)) = [];
    
    y = mean(inData(~isnan(inData)));
    
else
    siz = size(inData, 2);
    MEAN = zeros(1, siz);
    
    for i=1:siz
        tmp = inData(~isnan(inData(:,i)), i);
        MEAN(i) = mean(tmp);
    end
    y = MEAN;
    
end

