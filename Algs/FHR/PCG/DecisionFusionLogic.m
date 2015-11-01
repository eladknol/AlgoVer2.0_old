function [outStruct,AuidoOut,ECGOut]=DecisionFusionLogic(inputStruct,DetectionType)

%% DecisionFusionLogic
%% applies ECG and Audio detection on the data and
% decide what is the best estimation of the fetus HR. The response is of
% heart beat for every 10 sec.
%%
%DetectionType - 1 is full detection 0 only audio, default is full
%detection
% <<C:\Users\Admin\Google Drive\Nuvo\code\documantation\DecisionFusionLogicFlow.png>>
%


%% Load Params
SystemAudioParams;
% AcceptedDetectionRes=0.2;
if nargin==1
    DetectionType=1;
end
%% Check inputStruct add satLevel to meta data
if ~isfield(inputStruct,'meta')
    error('No meta data availble, check inputStruct');
elseif ~isfield(inputStruct, 'data')
    error('No data availble, check inputStuct');
% else
%     inputStruct.meta.satLevel = 10;
end

Fs=inputStruct.meta.Samplerate;
outStruct.analysisType=-1;
outStruct.bmi=inputStruct.meta.BMIbeforepregnancy;
outStruct.Fs=Fs;
outStruct.gestAge=inputStruct.meta.Weekofpregnancy;
outStruct.patID=inputStruct.meta.SubjectID;
outStruct.unqID='thisistheunqfileiddd';
outStruct.resData=struct;
if DetectionType ==1
    
%     [res, secOut, outStructECG] = analyzeSingleECGRecord(inputStruct); % Get detection from ECG
% inputStructECG=inputStruct;
% inputStructECG.data=inputStructECG.data';
[res, secOut, outStructECG] = analyzeFECGInterval(inputStruct);
    
if res ~= -1
    % Channel=secOut.fQRS_struct.bestLeadPeaks;
    % ECGOut.FetSig=secOut.removeStruct.fetData(Channel,:);
    ECGOut.FetSig=secOut.fQRS_struct.fetSignal;
else
    ECGOut.FetSig=999;
end
else
    outStructECG=[];
    ECGOut.FetSig=999;
end

if ~isempty(outStructECG)
    outStruct=structCopy(outStructECG, outStruct);
end


[Audio_outStruct, AuidoOut]=GetAudioDetctions(inputStruct); % Get detections from Audio
outStruct.resData=structCopy(Audio_outStruct, outStruct.resData);
% try
if isfield(outStruct.resData,'ECG_fQRSPos')
    if ~isempty(outStruct.resData.ECG_fQRSPos)
        [ECG_RRestim,ECG_Score,nc]=RRestimationAndCalcScore('Locations',outStruct.resData.ECG_fQRSPos' ,'Fs',Fs); %  Run Analysis of ECG results, gets estimated avarage RR and score of the ECG detections
        outStruct.resData.Fetal_ECG_Score=ECG_Score.score;
    else
        outStruct.resData.Fetal_ECG_Score=999;
    end
else
    outStruct.resData.Fetal_ECG_Score=999;
end

if isfield(outStruct.resData,'ECG_mQRSPos')
    if ~isempty(outStruct.resData.ECG_mQRSPos)
        [ECG_RRestim,ECG_Score,nc]=RRestimationAndCalcScore('Locations',outStruct.resData.ECG_mQRSPos' ,'Fs',Fs); %  Run Analysis of ECG results, gets estimated avarage RR and score of the ECG detections
        outStruct.resData.Maternal_ECG_Score=ECG_Score.score;
    else
        outStruct.resData.Maternal_ECG_Score=999;
    end
else
    outStruct.resData.Maternal_ECG_Score=999;
end




% catch
%     Out.resData.ECG_Score=999;
% end

[Audio_RRestim,Audio_Score,nc]=RRestimationAndCalcScore('Locations',Audio_outStruct.Audio_fSPos,'Fs',Fs); % %  Run Analysis of Audio results, gets estimated avarage RR and score of the Audio detections
outStruct.resData.Fetal_Audio_Score=Audio_Score.score;
[Audio_RRestim,Audio_Score,nc]=RRestimationAndCalcScore('Locations',Audio_outStruct.Audio_mSPos,'Fs',Fs); % %  Run Analysis of Audio results, gets estimated avarage RR and score of the Audio detections
outStruct.resData.Maternal_Audio_Score=Audio_Score.score;

%% Decision logic
if outStruct.resData.Fetal_ECG_Score<outStruct.resData.Fetal_Audio_Score % Check which modality is better
    
    %     out.SelectedPos=Out.resData.ECG_fQRSPos;
    outStruct.resData.Fetal_Final_Modality='ECG';
    outStruct.resData.Fetal_Final_Score=outStruct.resData.Fetal_ECG_Score;
    outStruct.resData.Fetal_Final_avgBestFHR=outStruct.resData.ECG_avgFHR;
    fetalGrph=ScoreGraph(outStruct.resData.ECG_fQRSPos,'GlobScore',outStruct.resData.Fetal_Final_Score,'GlobHR',outStruct.resData.Fetal_Final_avgBestFHR,'Fs',Fs);
    %     Out.resData.
    
else
    
    %     out.SelectedPos=out.Audio_out.Audio_fSPos;
    outStruct.resData.Fetal_Final_Modality='Audio';
    outStruct.resData.Fetal_Final_Score=outStruct.resData.Fetal_Audio_Score;
    outStruct.resData.Fetal_Final_avgBestFHR=outStruct.resData.Audio_avgFHR;
    fetalGrph=ScoreGraph(Audio_outStruct.Audio_fSPos,'GlobScore',outStruct.resData.Fetal_Final_Score,'GlobHR',outStruct.resData.Fetal_Final_avgBestFHR,'Fs',Fs);
    
    %     Out.resData.
end


% ScGrph=ScoreGraph(out.SelectedPos,'Fs',Fs); %Get RR and scores on
% subsegments of signal
if outStruct.resData.Fetal_Final_Score<AcceptedDetectionRes % If signal is over accepted threshold give results
    
    
    outStruct.resData.Fetal_DetectionSuccesfull=true;
else
    
    outStruct.resData.Fetal_DetectionSuccesfull=false;
    
end
%% Maternal HR logic
if outStruct.resData.Maternal_ECG_Score<outStruct.resData.Maternal_Audio_Score % Check which modality is better
    
    %     out.SelectedPos=Out.resData.ECG_fQRSPos;
    outStruct.resData.Maternal_Final_Modality='ECG';
    outStruct.resData.Maternal_Final_Score=outStruct.resData.Maternal_ECG_Score;
    outStruct.resData.Maternal_Final_avgBestMHR=outStruct.resData.ECG_avgMHR;
    maternalGrph=ScoreGraph(outStruct.resData.ECG_mQRSPos,'GlobScore',outStruct.resData.Maternal_Final_Score,'GlobHR',outStruct.resData.Maternal_Final_avgBestMHR,'Fs',Fs);
    %     Out.resData.
    
else
    
    %     out.SelectedPos=out.Audio_out.Audio_fSPos;
    outStruct.resData.Maternal_Final_Modality='Audio';
    outStruct.resData.Maternal_Final_Score=outStruct.resData.Maternal_Audio_Score;
    outStruct.resData.Maternal_Final_avgBestMHR=outStruct.resData.Audio_avgMHR;
    maternalGrph=ScoreGraph(Audio_outStruct.Audio_mSPos,'GlobScore',outStruct.resData.Maternal_Final_Score,'GlobHR',outStruct.resData.Maternal_Final_avgBestMHR,'Fs',Fs);
    
    %     Out.resData.
end


% ScGrph=ScoreGraph(out.SelectedPos,'Fs',Fs); %Get RR and scores on
% subsegments of signal
if outStruct.resData.Maternal_Final_Score<AcceptedDetectionRes % If signal is over accepted threshold give results
    
    
    outStruct.resData.Maternal_DetectionSuccesfull=true;
else
    
    outStruct.resData.Maternal_DetectionSuccesfull=false;
    
end



% if isfield(outStruct.resData,'ECG_mQRSPos')
% maternalGrph=ScoreGraph(outStruct.resData.ECG_mQRSPos,'Fs',Fs);
% outStruct.resData.Maternal_Final_Modality='ECG';
% else
%    maternalGrph=ScoreGraph(outStruct.resData.Audio_mSPos,'Fs',Fs);
%    outStruct.resData.Maternal_Final_Modality='Audio';
% end

outStruct.resData.mHRvec=maternalGrph.HRvec;
outStruct.resData.fHRvec=fetalGrph.HRvec;

end











