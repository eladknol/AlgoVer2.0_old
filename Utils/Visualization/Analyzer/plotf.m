function plotf(vec, aHold)

if(nargin==0)
    f;
    return;
end

if(nargin<2)
    aHold = 0;
end

if(iscell(vec))
    for i=1:numel(vec)
        plotf(vec{i}, aHold);
    end
else
    
    
    if(aHold)
        gcf;
        hold on;
    else
        f,
    end
    
    sz = size(vec);
    
    if(sz(2)>sz(1))
        vec = vec';
    end
    
    plot(vec);
end