function ecg_cfg = getECGconfig(sampleRate)
%#codegen

% --- General ---
ECGChs = 1:6;

ecg_cfg.general.ECGChs = ECGChs;
coder.varsize('ecg_cfg.general.ECGChs', [1 20], [0 1]);

ecg_cfg.general.nNumOfChs = length(ECGChs);
ecg_cfg.general.nNumOfActiveChs = length(ECGChs);

ecg_cfg.general.maxSatPerc = 10; % %
ecg_cfg.general.binSatPerc = 0.98;
ecg_cfg.general.maxNaNPerc = 10; % %
ecg_cfg.general.maxPredMHR = 220-30;
ecg_cfg.general.nfft = 1024;
%ecg_cfg.general.procType = 'maternal';
ecg_cfg.general.procType = 1;% 1:'maternal', 2:'fetal'

% --- Filters ---
ecg_cfg.filters.Fs = sampleRate;
% Low pass filter
ecg_cfg.filters.low.active = true(1);
ecg_cfg.filters.low.fc = 70;
ecg_cfg.filters.low.order = 12;
% High pass filter
ecg_cfg.filters.high.active = false(1);
ecg_cfg.filters.high.fc = 2;
ecg_cfg.filters.high.order = 5;
% MA filter
ecg_cfg.filters.ma.active = true(1);
ecg_cfg.filters.ma.len = round(201/1000 * sampleRate);
% Median filter
ecg_cfg.filters.median.active = false(1);
ecg_cfg.filters.median.len = round(100/1000 * sampleRate);
% Power line filter
ecg_cfg.filters.power.active = true(1);
ecg_cfg.filters.power.win = 0.5;
ecg_cfg.filters.power.order = 10;
ecg_cfg.filters.power.freq = 50;
ecg_cfg.filters.power.highBinLvl = 0.2;

% --- mQRS detection ---
ecg_cfg.mQRS.maxPredMaternalHR = 220-30;
ecg_cfg.mQRS.minPredMaternalHR = 40;
ecg_cfg.mQRS.relMaternalPeaksEnergy = 0.8;
ecg_cfg.mQRS.minMaternalCorrCoef = 0.8;
ecg_cfg.mQRS.minPeakHeight = 0.15;
ecg_cfg.mQRS.analWinLen = 10; % seconds
ecg_cfg.mQRS.forceDetect = false(1); % seconds

% --- mTwave detection ---
ecg_cfg.mTwave.filters.low.Fc = 20; % Hz
ecg_cfg.mTwave.filters.low.Order = 12; % seconds

% --- mECG elimination ---
ecg_cfg.mECG.minMaternalCorrCoef = 0.8;
ecg_cfg.mECG.resampleFreq = 4e3;
ecg_cfg.mECG.CLT.filter.type = 'bandpass';
%coder.varsize('ecg_cfg.mECG.CLT.filter.type', [1 length('bandpass')], [0 1]);
ecg_cfg.mECG.CLT.filter.order = 100;
ecg_cfg.mECG.CLT.filter.fc = [5, 20];
ecg_cfg.mECG.CLT.filter.winsize = round(100/1000 * sampleRate);
ecg_cfg.mECG.incCorrCoef = 0.98;
ecg_cfg.mECG.incNumBeats = 10;
ecg_cfg.mECG.incBounds = 50;
ecg_cfg.mECG.incThresh = 0.5;
ecg_cfg.mECG.fetSmoothOrder = 5;

ecg_cfg.mECG.LMA.QRSMultCorct = 1.05;
ecg_cfg.mECG.LMA.initE = 1e7;
ecg_cfg.mECG.LMA.dR = 1;
ecg_cfg.mECG.LMA.lambda = 0.001;
ecg_cfg.mECG.LMA.maxIti = 15;
ecg_cfg.mECG.LMA.corctP1 = 10;
ecg_cfg.mECG.LMA.corctP2 = 10;
ecg_cfg.mECG.LMA.jacbDelta = 0.05;
ecg_cfg.mECG.LMA.multsSmoother = 15;

ecg_cfg.fECG.ICA.nonLin = 'tanh';
%coder.varsize('ecg_cfg.fECG.ICA.nonLin', [1 length('tanh')], [0 1]);
ecg_cfg.fECG.Gen.RMSWinLen = 100;
ecg_cfg.fECG.Gen.maLength = 51;


ecg_cfg.fQRS.relFetalPeaksEnergy = 0.4;
ecg_cfg.fQRS.minPredFetalHR = 80;
ecg_cfg.fQRS.maxPredFetalHR = 200;
ecg_cfg.fQRS.analWinLen = 10; % seconds
ecg_cfg.fQRS.peak2Mean.winLen = 100;
ecg_cfg.fQRS.peak2Mean.smoothWinLen = 15;
ecg_cfg.fQRS.peak2Mean.peakDetection.minPeakHeight = 0.2;
ecg_cfg.fQRS.peak2Mean.peakDetection.kmed_nG = 3;
ecg_cfg.fQRS.peak2Mean.peakDetection.susRRThresh = 30;
ecg_cfg.fQRS.peak2Mean.peakDetection.xcorr_rms_winLen = 100;
ecg_cfg.fQRS.peak2Mean.peakDetection.xcorr_MA_winLen = 50;
ecg_cfg.fQRS.peak2Mean.peakDetection.peakRMSThresh = 10;
ecg_cfg.fQRS.peak2Mean.peakDetection.RMSRel = [2.5, 0.25];
ecg_cfg.fQRS.extnddAnalss.filters.low.fc = 70;
ecg_cfg.fQRS.extnddAnalss.filters.low.order = 8;
ecg_cfg.fQRS.extnddAnalss.filters.high.fc = 15;
ecg_cfg.fQRS.extnddAnalss.filters.high.order = 7;
ecg_cfg.fQRS.extnddAnalss.filters.ma.winLen = 501;
ecg_cfg.fQRS.extnddAnalss.wavelet.rms_winLen = 50;
ecg_cfg.fQRS.extnddAnalss.wavelet.filters.low.fc = 35;
ecg_cfg.fQRS.extnddAnalss.wavelet.filters.low.order = 8;
ecg_cfg.fQRS.extnddAnalss.wavelet.initHR = 171;
ecg_cfg.fQRS.extnddAnalss.wavelet.AGCSmoothWinLen = 15;
ecg_cfg.fQRS.peakDetection.minPeakDist = round(20/1000*sampleRate);
ecg_cfg.fQRS.peakDetection.minPeakH = 0.4;
ecg_cfg.fQRS.peakExamination.maxFetalRRInterSTD = 20;
ecg_cfg.fQRS.peakExamination.goodSegPeaks = 5;
ecg_cfg.fQRS.peakExamination.FHRSTDV = 0.5;
ecg_cfg.fQRS.peakExamination.minAccShift = round(40/1000*sampleRate);
ecg_cfg.fQRS.peakExamination.minAccCorrCoeff = 0.6;
ecg_cfg.fQRS.peakExamination.beatMult = 2;
ecg_cfg.fQRS.peakExamination.timeSeries.maLength = 13;
ecg_cfg.fQRS.peakExamination.scoring.goodSegPeaks = 5;
ecg_cfg.fQRS.peakExamination.scoring.minPeakHeight = 0.8;
ecg_cfg.fQRS.peakExamination.scoring.minPeakHeightUpdate = 0.9;
ecg_cfg.fQRS.peakExamination.scoring.maxIti = 5;
ecg_cfg.fQRS.peakExamination.scoring.closePerc = 10;
ecg_cfg.fQRS.peakExamination.scoring.minAccCorrCoeff = 0.8;

ecg_cfg.fQRS.nonLin = 'tanh';%ecg_cfg.fECG.ICA.nonLin;
%coder.varsize('ecg_cfg.fQRS.nonLin', [1 length('tanh')], [0 1]);
