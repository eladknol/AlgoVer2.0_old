load('filtersConfig.mat');
load('ecgData.mat');
ecgData = ecgData(:, 1:120000);

tic;
[~, filtECGData.matlab] = doFilter(filtersConfig, ecgData);
toc

tic;
[~, filtECGData.mex] = doFilter_mex(filtersConfig, ecgData);
toc

plotf(filtECGData.matlab - filtECGData.mex); 
