%%% Audio config parameters

%%Global 
WinLen=60;


%Filter Bank
%

FiltType='bandpassfir';
FilterOrder=200;




FBCutoffFrequency1=[  10  10  20  20  25  25  25  30  30  40  40  55  55 20] ;
FBCutoffFrequency2=[  30  45  40  50  50  55  65  55  65  65  75  80  95 80 ];
% FBCutoffFrequency1=[  10    25    55   15] ;
% FBCutoffFrequency2=[  45    65    95   80 ];



UseICA=false;
% Audio smaple rate should be availble 

%% ICA parameters
ICAfunctionsBank={'pow3', 'tanh' , 'gaus', 'skew'};
ICAfunctionsUsed=[1, 2];
approach= 'defl';


%% Beat Detection Params

SlowEnvelope=250e-3; %ms
FastEnvelope=80e-3;  %ms

PeakDiscardThresh=0.05;
GMMRegularizationValue=1e-4; %Regularization Value for GMM training
MinDistanceBetweenGroups=50;
minDetPerSec=10;
LstMissingRRThresh=0.5;
MinNumForGroup=10;
MinRRTime=200e-3;

%% RR estimation and score



OutliersThresh=0.15;

HistBinNumForRRestim=200;
MedWinLenForBaseLine=20;

%% Score Graph 
RRWinLength=20;
RROverLap=10;

%% Maternal / Fetal Heartrate decision logic

OneHRDetectedTh=10; %if estimated fetus HR and Maternal HR differ in less than this threshold only one HR was detected
LowerFeatalHRTh=115; % when only one HR is detected if above this thrshold declare as fetus
 HighFetalHRTh=180;
%% DecisionFusionDetectionRes

AcceptedDetectionRes=0.2;
Modalities={'ECG', 'Audio'};
