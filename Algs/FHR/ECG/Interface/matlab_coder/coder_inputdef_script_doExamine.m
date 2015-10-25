runCase = 1;

load(['configProvider_doExamine_' num2str(runCase) '.mat']);
load(['ecgData_doExamine_' num2str(runCase) '.mat']);
ecgData = ecgData(:, 1:120000);

if(runCase == 1)
    tic;
    [satInds.matlab, chnlInclude.matlab] = doExamine(ecgData, [], 'ECG_AUTO'); % Perform basic examination of the data
    toc
    tic
    [satInds.mex, chnlInclude.mex] = doExamine_mex(ecgData, [], 'ECG_AUTO'); 
    toc
elseif(runCase == 2)
    filtersConfig.auto_filt.ecg = configProvider.ECG_CFG.filters;
    filtersConfig.autoApply = true(1);
    filtersConfig.apply2All = true(1);
    filtersConfig.dataType = 'ECG';
    filtersConfig.auto_filt.ecg.median.active = false(1);
    [sts, filtECGData] = doFilter(filtersConfig, ecgData); % dont save the filtered data to the 'GCF'
    tic
    [~, ~, closestElectrode.matlab, filtData.matlab] = doExamine(ecgData, filtECGData, 'ECG'); % Perform basic examination of the data
    toc
    tic
    [~, ~, closestElectrode.mex, filtData.mex] = doExamine_mex(ecgData, filtECGData, 'ECG'); 
    toc
end

