function plotWithPeaks(signal, peaks, newFigure, timeBase, spec)

if(nargin<5)
    spec = {'*r', 'ok', 'sg', 'vb', '>r', '<r'};
end
if(nargin<4)
    timeBase = 1:length(signal);
end
if(nargin<3)
    newFigure = 0;
end
if(isempty(newFigure))
    newFigure = 0;
end
if(isempty(spec))
    spec = {'*r', 'ok', 'sg', 'vb', '>r', '<r'};
end
if(isempty(timeBase))
    timeBase = 1:length(signal);
end

if(newFigure)
    figure;
end
plot(timeBase,signal);
hold on;
grid on;

if(iscell(peaks))
    while(numel(peaks)>numel(spec))
        spec = [spec spec];
    end
    for i= 1:numel(peaks)
        plot(timeBase(peaks{i}),signal(peaks{i}),spec{i});
    end
else
    if(strcmpi(spec, 'line'))
        xS = timeBase(peaks);
        mx = 1.5*max(signal(:));
        mn = 1.5*min(signal(:));
        line([xS' xS']', repmat([mn mx], length(xS), 1)', 'color', [1 0 0]);
        plot(timeBase(peaks), ones(size(peaks))*mx, 'vb');
    elseif(strcmpi(spec, 'linecount'))
        xS = timeBase(peaks);
        mx = 1.5*max(signal);
        mn = 1.5*min(signal);
        line([xS' xS']', repmat([mn mx], length(xS), 1)', 'color', [1 0 0]);
        len = xS(end)+10;
        for i=1:length(xS)
            annotation('textbox', [xS(i)/len 0.7 0.01 0.01], 'String', num2str(i));
        end
    else
        if(iscell(spec))
            plot(timeBase(peaks),signal(peaks),spec{1});
        else
            plot(timeBase(peaks),signal(peaks),spec);
        end
    end
end

hold off;