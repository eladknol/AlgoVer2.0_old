function out=CTGvsNuvo(CTG,OutStruct)

%% Get Nuvo
AcceptedDetectionRes=0.2; 

ECGGood=OutStruct.resData(1).Fetal_ECG_Score>AcceptedDetectionRes;
ECGPos=OutStruct.resData(1).ECG_fQRSPos;
AudioPos=OutStruct.resData(1).Audio_fSPos;
AudioGood=OutStruct.resData(1).Fetal_Audio_Score>AcceptedDetectionRes;
Fs=OutStruct.Fs;
tECG=cumsum([ECGPos(1), diff(ECGPos)])/Fs;
tAudio=cumsum([AudioPos(1) ;diff(AudioPos)])/Fs;

RRECG=diff(ECGPos)/Fs;
HRECG=60./RRECG;
HRECG=medfilt(HRECG,5);
RRAudio=diff(AudioPos)/Fs;
HRAudio=60./RRAudio;
HRAudio=medfilt(HRAudio,5);

figure
subplot(311)
plot(tECG(2:end),HRECG);

subplot(312)
plot(tAudio(2:end),HRAudio);




MXctg=4*(max([tECG(end),tAudio(end)])+10);

tCTG=(0:MXctg-1)/4;
ctgFHR=CTG.fHRC(1:MXctg);
ctgFHR=medfilt(ctgFHR,5);



subplot(313)
plot(tCTG,ctgFHR);


HR=HRAudio;
t=tAudio;
tnew=t(1):0.25:t(end);
HRint=interp1(t(2:end),HR,tnew);
tnew=tCTG(~isnan(HRint));
HRint=HRint(~isnan(HRint));
trunNo=round(0.2*length(HRint));
HRintshort=HRint(trunNo:end-trunNo);
zNo=round((length(ctgFHR)-length(HRintshort))/2);
HRintshort=[zeros(1,zNo),HRintshort,zeros(1,zNo)];

[acor,lag]=xcorr(medfilt1(HRintshort,5),medfilt1(ctgFHR',5),round(0.9*trunNo));
[~,ind]=max(acor);
LagDiff=lag(ind);

ctgn=ctgFHR(-LagDiff:end);

tCTG=(0:length(ctgn)-1)/4;
figure
plot(tCTG,ctgn);
hold
plot(tnew,HRint);



out.lag=lag;
out.acor=acor;
out.ctg=ctgFHR;
out.HRA=HRAudio;







