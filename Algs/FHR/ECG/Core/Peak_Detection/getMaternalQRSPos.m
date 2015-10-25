function mQRS_struct = getMaternalQRSPos(matDetectorStruct)
%#codegen
% GETMATERNALQRSPOS Performs maternal Rwave detection on ECG signals
%   Inputs:
%           {'detectorStruct' : structure containing the detection structure:
%               {'signals'      : Maternal ECG data                     , NxL matrix}
%               {'filtSignals'  : Filtered ECG data                     , NxL matrix}
%               {'config'       : Detection configuration               , config structure}
%               {'chnlInclude'  : Which channels to use for detection   , Structure}
% This is done by 3 steps:
%       1) Apply additional filters to the filtered data and detect R-waves (if not provided in 'filtSignals')
%       2) Detect Rwaves using 'getRWaves'
%       3) If step 2 is failed, perform ICA on the data and redetect the maternal Rwaves. This step shouldn't be reached that much!!
%       4) If the detection steps are succ, examine the detected Rwaves  using 'examineMaternalPeaks'


% IMPORTANT NOTE: the QRS complex is distored in a different way in each one of the methods,
% so you cannot assume anything about it!!! - if you want to use
% morphology-related detection use the raw data and not the processed data!

global configProvider;
signals = matDetectorStruct.signals;
filtSignals = matDetectorStruct.filtSignals;
config = matDetectorStruct.config;
% chnlInclude = matDetectorStruct.chnlInclude;
%clear detectorStruct varargin;
mQRS_struct.err = false(1);
%% Find the R waves and kill them
%[R_Waves.FNL, RelValidSigs.FNL, bestLead, bestLeadPeaks, leadsInclude] = getRWaves(signals, 'final', config);

[R_Waves.FNL, RelValidSigs.FNL, bestLead, bestLeadPeaks, leadsInclude] = findMatRWaves(signals, config);

counter = 0;
for i=1:numel(R_Waves.FNL)
    if(length(R_Waves.FNL(i).value) == 1 && R_Waves.FNL(i).value(1) == -1)
        counter = counter+1;
    end
end

if(counter == config.nNumOfChs || RelValidSigs.FNL<=0)
    icaSigs = filtSignals; % Make sure that 'icaSigs' is the signals without median filtering
    
    Out1 = fastICA(icaSigs, 'tanh');
    configNew = config;
    configNew.forceDetect = true(1);
    configNew.relMaternalPeaksEnergy = 0.6; % lower it!
    
    
    filtersConfig.auto_filt.ecg = configProvider.ECG_CFG.filters;
    filtersConfig.autoApply = true(1);
    filtersConfig.apply2All = true(1);
    filtersConfig.dataType = 'ECG';
    filtersConfig.auto_filt.ecg.median.active = true(1);
    filtersConfig.auto_filt.ecg.low.active = false(1);
    filtersConfig.auto_filt.ecg.high.active = false(1);
    filtersConfig.auto_filt.ecg.ma.active = false(1);
    filtersConfig.auto_filt.ecg.power.active = false(1);
    
    [~, signals_new] = doFilter(filtersConfig, Out1);
    %signals_new = applyFilter('BSLN', Out1, configNew); % Apply the baseline removal after applying ICA (in case that you are using median)
    % #CODER_REMOVE
    %[R_Waves.FNL, RelValidSigs.FNL, bestLead, bestLeadPeaks, leadsInclude]= getRWaves(signals_new, 'final', configNew);
    [R_Waves.FNL, RelValidSigs.FNL, bestLead, bestLeadPeaks, leadsInclude] = findMatRWaves(signals_new, configNew);
end

% CODER_REMOVE
% if((~iscell(R_Waves.FNL) && R_Waves.FNL==-1) || RelValidSigs.FNL<=0)
%     icaSigs = filtSignals; % Make sure that 'icaSigs' is the signals without median filtering
%
%     [Out1, Out2, Out3] = fastica(icaSigs, 'g', 'tanh', 'verbose', 'off');
%     config.forceDetect = 1;
%     config.relMaternalPeaksEnergy = 0.6; % lower it!
%     signals_new = applyFilter('BSLN', Out1); % Apply the baseline removal after applying ICA (in case that you are using median)
%     [R_Waves.FNL, RelValidSigs.FNL, bestLead, bestLeadPeaks, leadsInclude]= getRWaves(signals_new, 'final', config);
% end

% #CODER_TEST
% if(isfield(RelValidSigs,'FNL'))
%     if(RelValidSigs.FNL<=0)
%         R_Waves.direct = getRWaves(signals, 'direct', config);
%     end
% end

% flds = fields(R_Waves);
% for i=1:length(flds)
%     pks{i} = R_Waves.(flds{i});
% end

pks = R_Waves.FNL; % Keep it like that for now

mQRS_struct.bestLead = bestLead;
mQRS_struct.bestLeadPeaks = bestLeadPeaks;
mQRS_struct.leadsInclude = leadsInclude;

% disp('Performing maternal QRS examination...');
[mQRS_struct.pos, mQRS_struct.rel] = examineMaternalPeaks(pks, signals, bestLead, bestLeadPeaks, leadsInclude);

if(isempty(mQRS_struct.pos) || mQRS_struct.rel==0)
    mQRS_struct.err = true(1);
end
