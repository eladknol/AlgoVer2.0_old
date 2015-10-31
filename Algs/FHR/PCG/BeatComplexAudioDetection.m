
function Results=BeatComplexAudioDetection(Sig,SampleRate)

% BeatComplexAudioDetection, Detects PCG complexes
%Results=BeatComplexAudioDetection(Sig,SampleRate)
%Sig is the singla vector, SampleRate is in Hz

%% Set function params
if nargin<2 || SampleRate-floor(SampleRate)>0
Fs=1000;
else
    Fs=SampleRate;
end
% SlowEnvelope=round(250e-3*Fs);
% FastEnvelope=round(100e-3*Fs);
% PeakDiscardThresh=0.05;
% MinDistanceBetweenGroups=50;
% minDetPerSec=10;
SystemAudioParams;% load System Params
%  SlowEnvelope=200e-3;
%  FastEnvelope=80e-3;
%% Start initial coarse detection
SlowWin1=round(SlowEnvelope*Fs);
AudioEnergyEnvelopeSlow=filtfilt(ones(1,SlowWin1)/SlowWin1,1,abs(hilbert(Sig))); % Slow envelope of signal
Results.SlowEnvelope=SlowEnvelope; 

candid1=FirstStageRREstimation(AudioEnergyEnvelopeSlow,Fs);

[N,~]=histcounts(candid1.Locs);
K1=abs(kurtosis(N',1)-3);

SlowWin2=round((SlowEnvelope-50e-3)*Fs);
AudioEnergyEnvelopeSlow=filtfilt(ones(1,SlowWin2)/(SlowWin2),1,abs(hilbert(Sig))); % Slow envelope of signal
Results.SlowEnvelope=SlowEnvelope; 
%% First stage HR detection (very coarse detection)
candid2=FirstStageRREstimation(AudioEnergyEnvelopeSlow,Fs);
[N,~]=histcounts(candid2.Locs);
K2=abs(kurtosis(N',1)-3);

if K2>K1
    candid=candid1;
   
else
    candid=candid2;
  
end



%% Second Stage fine tune detection 1
o=FineTuneSdetectionV1_1(candid.Locs,Sig,SlowEnvelope,FastEnvelope,Fs);

Results=o;

end

