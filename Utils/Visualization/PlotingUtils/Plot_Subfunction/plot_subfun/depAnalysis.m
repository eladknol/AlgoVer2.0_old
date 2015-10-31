function depAnalysis(funcName, isSaveImage, children)

if(~nargin)
    funcName = 'analyzeSingleECGRecord'; % ECG    
end

if(nargin<2)
    children = 0;
    isSaveImage = 0;
end

if(nargin<3)
    children = 0;
end

if(isSaveImage)
    res = plot_subfun(funcName, '-extsub', '-nomain');
    fHandle = res.fig.fig.main;
    set(fHandle, 'Units', 'normalized');
    set(fHandle, 'Position', [0 0 1 1]);
    saveImageFileName = strrep(res.foo, '.m', '.png');
    print(fHandle, '-dpng', '-r600', saveImageFileName);
else
    plot_subfun(funcName, '-extsub', '-nomain');
end

% plot_subfun(funcName, '-extsub', '-nomain', '-unhide', 'getMaternalQRSPos', 'fastica', 'applyFilter', 'plotf', 'findRWavesPCA', 'findRWavesWavelet', 'findRWavesDirect', 'classPeaks', 'direcPeaks', 'reFindPeaks', 'examinePeaks');

fig = gcf;
set(fig, 'units', 'normalized');
set(fig, 'position', [0 0 1 1]);
waitfor(fig);

if(children)
    strctList =  analyzeECGDependies(funcName);
    lvl1Funcs = fieldnames(strctList);
    for i=1:numel(lvl1Funcs)
        disp(['Analyzing : ' lvl1Funcs{i} ]);
        plot_subfun(lvl1Funcs{i}, '-extsub', '-nomain');
        fig = gcf;
        set(fig, 'units', 'normalized');
        set(fig, 'position', [0 0 1 1]);
        waitfor(fig);
    end
end
% print(fig,[getFileName(funcName) '.png'], '-dpng', '-r600')