
function [ResOut, AudioOut]=GetAudioDetctions(inputStruct);

%%GetAudioDetctions
%%
% [ResOut, Out]=GetAudioDetctions(hdr,data)
%  Detects PCG in a signal
%
%  inputs:
%  hdr : meta data of the signals
%  data: all the channels recorded
%
%  Outputs:
%  Resout: Standard output for creating NGO file
%  Out: Other info for analysis and display

%%
%
% <<C:\Users\Admin\Google Drive\Nuvo\code\documantation\GetAudioDetections.png>>
%

%% Prepare data for analyzing
data=inputStruct.data;
meta=inputStruct.meta;

if diff(size(data))>0 %Make Sure each coloumn is channel
    data=data';
end

audiodata=data(:,meta.MICchannels);
% ecgdata=data(:,meta.ECGchannels);
Fs=meta.Samplerate;



%% Raw signal  -->  filter Bank --> ICA
% Transfer raw Audio Signals into all BP signals and ICA signals for each channel
%%
%
% <<C:\Users\Admin\Google Drive\Nuvo\code\documantation\Signals2BPSignals.png>>
%


Signals=Signal2BPsignals(audiodata,meta.Samplerate);
%output is a c
%% Start Loop on all preprocessed signals
% *perform detection* on each of the signals created by Signal2BPsignals and
% collect results into 'Res
for k=1:length(Signals) %loop on all channels
    ListRow{k}=[Signals(k).SigName, num2str(Signals(k).BandPass)];
    Sig=Signals(k).filtsignal;
    for n=1:4;%size(Sig,2) %loop on all signals from each channel (BP and ICA)
        %% Detect beat complexes
        % look for repetative complexes that are possible heart beats in a signal
        %%
        %
        % <<C:\Users\Admin\Google Drive\Nuvo\code\documantation\BeatComplexAudioDetection.png>>
        %
        if n<=size(Sig,2)
        try
            tmp=BeatComplexAudioDetection(Sig(:,n),Fs);% Detect Audio complexes
            tmp.Signal=Sig(:,n);
            tmp.Fs=Fs;
            Res{k,n}=tmp; % k: signal number in list, n: Channel Selected
        catch
            Res{k,n}=struct;
        end
        channel(k,n)=n;
            SignalNo(k,n)=k;
        %% RR estimation and Calc Score
        % Estimate the average RR from the beat complexes detected and
        % calculate score for goodness of detection
        %%
        %
        % <<C:\Users\Admin\Google Drive\Nuvo\code\documantation\RRestimationAndCalcScore.png>>


        %
        

        try
            [RRestim(k,n),Score(k,n),BaseLine{k,n}]=RRestimationAndCalcScore('Locations',Res{k,n}.Locs,'Fs', Fs ); %Estimate  avarage RR and score for the whole signal
        catch
            RRestim(k,n)=-1;
            
            Score(k,n).MeanfromRR=[999];
            Score(k,n).STDfromRR=[999];
            Score(k,n).OverbyMoreThen15per=[999];
            Score(k,n).score=[999];
            Score(k,n).NumOfOutliers=NaN;
        end
        try

            ScoreGrph(k,n)  = ScoreGraph(Res{k,n}.Locs, 'Fs',Fs );% Estimate score as function of time

        catch
            %             ScoreGrph(k,n)=[];
        end
        else
         RRestim(k,n)=-1;
            
            Score(k,n).MeanfromRR=[999];
            Score(k,n).STDfromRR=[999];
            Score(k,n).OverbyMoreThen15per=[999];
            Score(k,n).score=[999];
            Score(k,n).NumOfOutliers=NaN;
        end
    end
end





%% Get Maternal heart rate and Fetal heart rate
% Get the detction results from all signals (Estimated heart rate and
% scores) and decide what is the best estimation for the Fetal heart rate
% and what is the Maternal heart rate


Score=Score';

channel=channel';
SignalNo=SignalNo';

AudioOut.Score=Score;
RRestim=RRestim';
Res=Res';
Res=Res(:);
ScoreGrph=ScoreGrph';
ScoreGrph=ScoreGrph(:);
HR.HR=60./(RRestim(:));
HR.channel=channel(:);
HR.SignalNo=SignalNo(:);
AudioOut.HR=HR;
[AudioOut.Maternal,AudioOut.Fetal]=FetalMaternalDecision(HR,[Score(:).score],Res,ScoreGrph);

ResOut.Audio_mSPos=AudioOut.Maternal.Res.Locs;
ResOut.Audio_fSPos=AudioOut.Fetal.Res.Locs;
ResOut.Audio_avgMHR=AudioOut.Maternal.HR;
ResOut.Audio_avgFHR=AudioOut.Fetal.HR;

end

