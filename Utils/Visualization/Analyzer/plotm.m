function plotm(newFig, varargin)

for ii=1:numel(varargin)
    if(newFig)
        f,
    else
        hold on;
    end
    plot(varargin{ii});
end
