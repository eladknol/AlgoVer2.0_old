function SignalStruct=Signal2BPsignals(Signal,Fs)


% FBstart=[5  25   55];
% FBend=[45  65   95];
SystemAudioParams; % Load params
if diff(size(Signal))>0
    Signal=Signal';
end


for k=1:length(FBCutoffFrequency1)

%     BP{k} = designfilt('bandpassfir','FilterOrder',100,'CutoffFrequency1',FBCutoffFrequency1(k),'CutoffFrequency2',FBCutoffFrequency2(k),'SampleRate',Fs);
    BP{k} = designfilt('bandpassiir','FilterOrder',10,'HalfPowerFrequency1',FBCutoffFrequency1(k),'HalfPowerFrequency2',FBCutoffFrequency2(k),  'SampleRate',Fs);
    
    
    
% %     BP{k} = designfilt('bandpassiir', ...       % Response type
%        'StopbandFrequency1',FBCutoffFrequency1(k)-5, ...    % Frequency constraints
%        'PassbandFrequency1',FBCutoffFrequency1(k), ...
%        'PassbandFrequency2',FBCutoffFrequency2(k), ...
%        'StopbandFrequency2',FBCutoffFrequency2(k)+5, ...
%        'StopbandAttenuation1',20, ...   % Magnitude constraints
%        'PassbandRipple',0.5, ...
%        'StopbandAttenuation2',20, ...
%        'DesignMethod','ellip', ...      % Design method
%        'MatchExactly','passband', ...   % Design method options
%        'SampleRate',Fs)  ;             % Sample rate

end
N=length(BP);
for fl=1:N
   SignalStruct(fl).filtsignal=filtfilt(BP{fl},Signal);
%    [SignalStruct(fl).filtsignal_N,SignalStruct(fl).Nb,SignalStruct(fl).Na] =NathanFilter(Signal,FBCutoffFrequency1(fl),FBCutoffFrequency2(fl),Fs);
   SignalStruct(fl).SigName='Filtered';
   SignalStruct(fl).BandPass=[FBCutoffFrequency1(fl),FBCutoffFrequency2(fl)];
   SignalStruct(fl).Fs=Fs;
   SignalStruct(fl).Filter=BP{fl};
end

if UseICA

% change to parfor for speed
for fl=1:N
    ICA=ICAall(SignalStruct(fl).filtsignal);
for icach=1:length(ICA)
    
    
    %tmpSig=ICA(icach).FastICA{1};    
    
   SignalStruct(N*icach+fl).filtsignal=ICA(icach).FastICA{1};%filter(BP{fl},tmpSig);
   SignalStruct(N*icach+fl).SigName=ICA(icach).FunctionName;
   SignalStruct(N*icach+fl).BandPass=[FBCutoffFrequency1(fl),FBCutoffFrequency2(fl)];
   SignalStruct(N*icach+fl).Fs=Fs;
   SignalStruct(N*icach+fl).W=ICA(icach).FastICA{3};
end
end

end