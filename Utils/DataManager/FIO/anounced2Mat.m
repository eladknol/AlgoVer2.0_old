function Data = anounced2Mat(data, isRemNan, nanMethod)
if(nargin<2)
    isRemNan = 0; % remove nan's from the data
end

if(~isstruct(data))
    Data = data;
    return;
end
flds = fields(data);
for i=1:4
    Data(i,:) = data.(flds{i+1}); % to ignore the Elapsed_Time field
end

if(isRemNan)
    if(nargin<3)
        nanMethod = 'interpolate';
    end
    switch(nanMethod)
        case 'zeroReplace',
            Data(isnan(Data)) = 0;
        case 'interpolate',
            nNumOfSigs = size(Data,1);
            for i = 1:nNumOfSigs
                removed = 0;
                indStrt = find(isnan(Data(i,:)), 1, 'first');
                while(~isempty(indStrt))
                    indEnd = indStrt;
                    while(isnan(Data(i,indEnd)) || indEnd>=length(Data(i,:)))
                        indEnd = indEnd+1;
                    end
                    indEnd = indEnd-1;
                    
                    if(indEnd>1)
                        valStrt = Data(i,indStrt-1);
                    else
                        valStrt = 0;
                    end
                    
                    if(indEnd<length(Data(i,:)))
                        valEnd = Data(i,indEnd+1);
                    else
                        valEnd = 0;
                    end
                    
                    Data(i,indStrt:indEnd) = linspace(valStrt,valEnd, indEnd-indStrt+1); % linear interpolation
                    indStrt = find(isnan(Data(i,:)), 1, 'first');
                    removed = 1;
                end
                if(removed)
                    % perform light smoothing
                    opts.size = 3;
                    Data(i,:) = smooth(Data(i,:), 'MA',opts);
                end
            end 
    end
end