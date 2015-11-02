function [figH, axH] = subPlot(signals, figH, xData)

[nNumOfSigs, ii] = min(size(signals));

if(ii==2)
    signals = signals';
end

if(nargin<2)
    figH = figure;
end

if(nargin<3)
    Fs = 1000;
    xData = (1:max(size(signals)))/Fs;
end

if(isempty(figH))
    figH = figure;
end
figure(figH);

for iPlot = 1:nNumOfSigs
    axH(iPlot) = subplot(nNumOfSigs, 1, iPlot);
    hold on;
    plot(xData, signals(iPlot,:));
    grid on;
    axis tight;
end
linkaxes(axH, 'x');