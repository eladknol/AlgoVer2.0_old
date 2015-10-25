function [fData, mData] = removeMaternalECG(signals, mRWaves, config)

% signals: filtered ECG data (including maternal ECG)
% fData: the data after removing the maternal ECG
% mRWaves: maternal R-Waves positions


SIZE = size(signals);

nNumOfSigs = min(SIZE);
for i = 1:nNumOfSigs
    [fData(i,:), mData(i,:)] = remMECG(signals(i,:), mRWaves, config);
end


%%
function [fECG, mECG] = remMECG(signal, mRWaves, config)

minCorrCoef = config.minMaternalCorrCoef;

% up-sample data for better percision
reqFs = 4000; % 4kHz
matchFreq = ceil(reqFs/config.Fs);
signalHR = resample(signal, matchFreq, 1);
signalHR = [signalHR(1)*ones(1, matchFreq-1) signalHR];
signalHR(end-(matchFreq-2):end) = [];
peaks = mRWaves*matchFreq; % new R-wave positions

nNumOfPks = length(mRWaves);
meanIntrv = floor(mean(diff(peaks))/2);
minIntrv = floor(min(diff(peaks))/2);

% high res averaged template

signalHR_adapted = signalHR;

for jPeak = 2:nNumOfPks-1
    
    beatInterval = getBeatInterval(peaks, jPeak);
    
    template = getECGTemplate(signalHR, peaks, beatInterval); % changes slightly every time
    
    [fECG, currPeakInd] = getCurrBeatECG(signalHR, peaks(jPeak), beatInterval, jPeak==1 || jPeak==nNumOfPks);
    [corr, lag] = xcorr(template,fECG,'coef');
    [y, i] = max(corr);
    if(y>minCorrCoef)
        fECG = circshift(fECG, [0, lag(i)]);
        ecg_adapted = adaptBeatECG(fECG, template); % the ecg to-be removed
    else
        %badBeat, remove the template only
        ecg_adapted = template;
    end
    %     ecg_new = template;
    
    signalHR_adapted = rmvECGCmplx(signalHR_adapted, ecg_adapted, peaks(jPeak), beatInterval, jPeak==1 || jPeak==nNumOfPks); 
end

fECG = downsample(signalHR-signalHR_adapted, matchFreq);
mECG = downsample(signalHR_adapted, matchFreq);

%%
function phi_c = adaptBeatECG(ecg, template)

PHI_M = ecg;
nNumOfSegments = 1; % devide the ECG into segments
reconParams = getReconParams(template, nNumOfSegments, 0);

iti=1;
R = reconParams.val;
E = 1e7;
dR = 1;
k = 1;
lambda = 0.1;
R_good = R;
err = 1;
Niti = 15;
c1 = 10;
c2 = 10;
reconParams.val = R;

while iti<Niti && dR>1e-4 && err(end)>5e-4
    phi_c = adaptTemplate(template, reconParams);
    err(iti) = norm(phi_c - PHI_M)^2;
    flag = floor(E(end)/err(end));
    
    if flag
        J = Jacobian(template, phi_c, reconParams);
        E(end+1) = err(end);
        lambda(end+1) = lambda(end)/c1;
        R_good = reconParams.val;
        k = k+1;
    else
        lambda(end+1) = lambda(end)*c2;
    end
    
    J_T_J=J'*J;
    R(k,:) = R_good - (((J_T_J+lambda(end)*diag(diag(J_T_J)))^-1)*J'*((phi_c-PHI_M)'))';
    dR = sum(abs((reconParams.val-R(k,:)))); % delta_R: change in R
    
    
    reconParams.val(:) = R(end,:);
%     opts.size = 5;
%     reconParams.val(:) = smooth(R(end,:), 'MA', opts);
    iti=iti+1;
end

opts.size = 9;
phi_c = smooth(adaptTemplate(template, reconParams),'MA',opts);


%%
function J = Jacobian(template, phi_c, reconParams)
nNumOfSegs = length(reconParams.val);
lenPot = length(phi_c);
J = zeros(nNumOfSegs, lenPot);
delta = 0.005;
R = reconParams.val;
for i = 1:nNumOfSegs
    R_temp = R;
    R_temp(i) = R_temp(i) + delta;
    reconParams.val = R_temp;
    phi = adaptTemplate(template, reconParams);
    J(i,:) = (phi-phi_c)/delta;
end
J = J';

%%
function reconParams = getReconParams(template, nNumOfSegments, adaptiveMesh)
if(nargin<3)
    adaptiveMesh = false;
end

if(length(template) == 1)
    tempLen = template;
else
    tempLen = length(template);
end

if(~adaptiveMesh)
    dst = floor(tempLen/nNumOfSegments);
    for i=1:nNumOfSegments
        reconParams.ind.start(i) = (i-1)*dst+1;
        reconParams.ind.end(i) = i*dst;
        reconParams.val(i) = 1;
    end
    reconParams.ind.end(end) = tempLen;
else
    Diff = abs(diff(template));
    %     ...
end

%%
function phi_c = adaptTemplate(template, reconParams)

nNumOfSegs = length(reconParams.val);
zoh = zeros(1,length(template));

for iSeg = 1:nNumOfSegs
    iStrt = reconParams.ind.start(iSeg);
    iEnd = reconParams.ind.end(iSeg);
    zoh(iStrt:iEnd) = reconParams.val(iSeg);
end

phi_c = template.*zoh;

%%
function signalHR_adapted = rmvECGCmplx(signalHR, ecg_adapted, peakPos, beatInterval, brdPeak)

signalHR_adapted = signalHR;

[beatOnset, beatOffset] = getBeatPos(peakPos, beatInterval, length(signalHR), brdPeak);
beatRange = beatOnset:beatOffset;

if(length(beatRange) == length(ecg_adapted))
    signalHR_adapted(beatRange) = ecg_adapted;
%     signalHR_adapted = smoothEdges(signalHR_adapted, beatRange);
end

function signal = smoothEdges(signal, beatRange)

smoothSize = 50;
edgeLeft = max(1,(beatRange(1)-smoothSize)):(beatRange(1)+smoothSize);
edgeRight = (beatRange(end)-smoothSize):min((beatRange(end)+smoothSize), length(signal));

opts.size = smoothSize*2;
smoothLeft = smooth(signal(edgeLeft),'MA',opts);
smoothRight = smooth(signal(edgeRight),'MA',opts);

signal(edgeLeft) = smoothLeft;
signal(edgeRight) = smoothRight;