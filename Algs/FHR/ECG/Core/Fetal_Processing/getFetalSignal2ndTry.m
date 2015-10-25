function [signalsRes_procSig, signalsRes_signals, bestSig, doProc] = getFetalSignal2ndTry(signals, config, skipStep1)
%#codegen

coder.varsize('signals_temp'        , [6 120000], [1 1]);  % #CODER_VARSIZE
coder.varsize('tempo_curr'          , [1 5000  ], [0 1]);  % #CODER_VARSIZE
coder.varsize('signalsRes_procSig'  , [6 120000], [1 1]);  % #CODER_VARSIZE
coder.varsize('tempSigs'            , [6 120000], [1 1]);  % #CODER_VARSIZE
coder.varsize('temp_here'           , [1 120000], [0 1]);  % #CODER_VARSIZE

% seed = rng;
% rng(seed);
if(nargin<3)
    skipStep1 = 0;
end
signalsSave = signals;
if(size(signals,1)==1)
    skipStep1 = 1;
    bestSig = 1;
end
bestSig = 1;
signalsRes_procSig = [];

if(~skipStep1)
    nS = min(size(signals)) - 1;
    [u,s,v] = svds_loc(signals, nS);
    res = u*s*v';
    Out1 = fastICA(res, config.nonLin);
    signals_temp = Out1;
    signalsRes_signals = signals_temp;
    
    maxRR = 1/(config.minPredFetalHR/60)*config.Fs;
    minRR = 1/(config.maxPredFetalHR/60)*config.Fs;
    nNumOfSigs = size(signals_temp, 1);
    len = 100;
    ovrlap = 1;
    if(ovrlap==1)
        inc = 1;
    else
        inc = floor((1-ovrlap)*len);
    end
    rel = inf(1, nNumOfSigs);
    for iSig=1:nNumOfSigs
        sig = signals_temp(iSig, :);
        sig = sig./max(abs(sig));
        %normalize = max(max(sig), -min(sig));
        % pkMean = peak2mean(sig, len);
        if(coder.target('MaTlAb'))
            pkMean = peak2mean_mex(sig, config.peak2Mean.winLen); % mex version, >20 times faster
        else
            pkMean = peak2mean(sig, config.peak2Mean.winLen); 
        end
        
        df = diff(pkMean);
        procSig = -df.*(df<0);
        procSig = smooth(procSig, 'MA', config.peak2Mean.smoothWinLen);
        
        procSig = procSig./max(procSig);
        [~, pks] = findpeaks(procSig, 'minpeakheight', config.peak2Mean.peakDetection.minPeakHeight);
        
        df = diff(pks);
        nG = config.peak2Mean.peakDetection.kmed_nG; % 3
        %[clust, C] = kmedoids(df', nG);
        [clust, C] = kMedoids(df', nG, nG+1, false(1));
        
        N = zeros(nG, 1);
        RMS = zeros(nG, 1);
        for i=1:nG
            N(i) = sum(clust==i);
            RMS(i) = rms(diff(df(clust==i)));
        end
        meas = N./RMS;
        [NULL, goodGroup] = max(meas);
        %clear NULL;
        
        susRR = median(diff(pks(clust==goodGroup)));
        susRR = round(susRR/10)*10;
        if(susRR>minRR && susRR<maxRR)
            if(any(abs(susRR - [minRR, maxRR])<config.peak2Mean.peakDetection.susRRThresh))
                tempo_curr = winRMS(signals_temp(iSig, :), config.peak2Mean.peakDetection.xcorr_rms_winLen);
                tmp = xcorr(tempo_curr);
                temp_config1.maLength = config.peak2Mean.peakDetection.xcorr_MA_winLen;
                tmp = maFilter(tmp, temp_config1);
                if(peak2rms(tmp)>config.peak2Mean.peakDetection.peakRMSThresh)
                    break;
                end
            end
            
            temp_config2.winSize = susRR;
            temp_config2.isNorm = 1;
            res = winAGC(procSig, temp_config2);
            
            rel(iSig) = rms(res)/rms(procSig);
            if(rel(iSig)<config.peak2Mean.peakDetection.RMSRel(1) && rel(iSig)>config.peak2Mean.peakDetection.RMSRel(2))
                signalsRes_procSig = [signalsRes_procSig; [res, procSig(end-(length(procSig) - length(res)-1):end)]];
            else
                signalsRes_procSig = [signalsRes_procSig; procSig];
            end
        else
            signalsRes_procSig = [signalsRes_procSig; procSig];
        end
    end
    
    [NULL, bestSig] = min(rel);
    
    if(sum(rel==inf)<nNumOfSigs)
        doProc = 'bestOnly';
        return;
    end
end
%% The data is not good enough, lets have fun!
% pre-proc
signals = signalsSave;
signalsRes_signals = signals;

temp_config3 = config;
temp_config3.lowCutoff = config.extnddAnalss.filters.low.fc;
temp_config3.highCutoff = config.extnddAnalss.filters.high.fc;
temp_config3.maLength = config.extnddAnalss.filters.ma.winLen;

temp_config3.Order = config.extnddAnalss.filters.low.order;
temp_config3.Fc = 0;
temp_config3.Fc = temp_config3.lowCutoff/(config.Fs/2);

[sts, filtSigs] = applyFilter('LOW_BUTTER', signals, temp_config3);

temp_config3.Fc = temp_config3.highCutoff/(config.Fs/2);
temp_config3.Order = config.extnddAnalss.filters.high.order;
[sts, filtSigs] = applyFilter('HIGH_BUTTER', filtSigs, temp_config3);

% wavelet denoise
nNumOfSigs = min(size(filtSigs));

% config.usePar=0;
tempSigs = zeros(6, length(filtSigs(1,:)) - config.extnddAnalss.wavelet.rms_winLen);

if(nNumOfSigs>1 && config.usePar && coder.target('matlab'))
    parfor i=1:nNumOfSigs
        sigDEN = func_denoise_sw1d_try1(filtSigs(i,:));
        tempSigs(i, :) = winRMS(sigDEN, config.extnddAnalss.wavelet.rms_winLen, 1);
    end
else
    if(coder.target('matlab'))
        % Use wavelet toolbox until an external wavelet lib is validated
        
        for i=1:nNumOfSigs
            %[sigDEN(i,:), wDEC] = func_denoise_sw1d_try1(filtSigs(i,:));
            sigDEN = func_denoise_sw1d_try1(filtSigs(i,:));
            temp_here = winRMS(sigDEN, config.extnddAnalss.wavelet.rms_winLen, 1)';
            tempSigs(i, :) = temp_here;
        end
    else
        for i=1:nNumOfSigs
            %[sigDEN(i,:), wDEC] = func_denoise_sw1d_try1(filtSigs(i,:));
            %sigDEN = func_denoise_sw1d_try1(filtSigs(i,:));
            sigDEN = func_denoise_sw1d_try1_dummy(filtSigs(i,:));
            temp_here = winRMS(sigDEN, config.extnddAnalss.wavelet.rms_winLen, 1)';
            tempSigs(i, :) = temp_here;
        end
    end
end

[sts, tempSigs] = applyFilter('ma', tempSigs, temp_config3);
% signals(1,1:59950).*tempSigs(1,1:59950) ??

newConfig.lowCutoff = config.extnddAnalss.wavelet.filters.low.fc;
newConfig.Fc = config.extnddAnalss.wavelet.filters.low.fc/(config.Fs/2);
newConfig.Order = config.extnddAnalss.wavelet.filters.low.order;
[sts, resSigs] = applyFilter('LOW_BUTTER', tempSigs, newConfig);

initRR = 1/(config.extnddAnalss.wavelet.initHR/60)*config.Fs;
newConfig1.winSize = round(initRR);
newConfig1.isNorm = 1;
signalsRes_procSig = [];

for i=1:nNumOfSigs
    resSigs(i,:) = resSigs(i,:)./max(resSigs(i,:));
    procSig = smooth(winAGC(resSigs(i,:), newConfig1), 'MA', config.extnddAnalss.wavelet.AGCSmoothWinLen);
    signalsRes_procSig = [signalsRes_procSig; procSig'];
end

doProc = 'all';
