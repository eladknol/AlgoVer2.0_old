function [ResStructFrame, AudioOut,ECGout]=LongDetection(inputStruct,Limit,DetectionType)

% LongDetection, Performs detection on long signals by frames.
%[ResStructFrame, AudioOut]=LongDetection(inputStruct)
%
%inputStruct  has two fields meta, and data
%ResStructFrame is a structere that is the size of the number of frames.
%It can be saved using NGOWrite
% AudioOut is the results of the Audio detection for inspection and graphs

SystemAudioParams; % load parameters, WinLen;

if nargin==1
    Limit=[];
    DetectionType=1;
elseif nargin==2
    DetectionType=1;
end

data=inputStruct.data;

if diff(size(data))>0
    data=data';
end
SampNum=size(data,1);
n=1;
ResStructFrame.resData(n).StartSample=1;% Set the first signal frame 1 - WinLen seconds
ResStructFrame.resData(n).EndSample=ResStructFrame.resData(n).StartSample+WinLen*inputStruct.meta.Samplerate-1;
flag=true;
while flag % Start detection loop on signals
    
    inputStruct.data=data(ResStructFrame.resData(n).StartSample:ResStructFrame.resData(n).EndSample,:); % update data in inputStruct to desired frame
    
    %     tic
    
    
    %% Detection function
    % [Audio_out, Out]=GetAudioDetctions(hdr,data);
    try
        
        [OneFrame,AudioOut{n},ECGout{n}]=DecisionFusionLogic(inputStruct,DetectionType); % upply detection using ECG and Audio and get best result.
        
        if n==1
            ResStructFrame=struct('analysisType',[],'bmi',[]','Fs',[],'gestAge',[],'patID',[], 'unqID',[]);
            
            expectedFieldNames={'Audio_mSPos','Audio_fSPos','Audio_avgMHR','Audio_avgFHR','Fetal_ECG_Score','Maternal_ECG_Score','Fetal_Audio_Score','Maternal_Audio_Score' ...
                ,'Fetal_Final_Modality','Fetal_Final_Score','Fetal_Final_avgBestFHR','Fetal_DetectionSuccesfull','Maternal_Final_Modality','Maternal_Final_Score','Maternal_Final_avgBestMHR'...
                ,'Maternal_DetectionSuccesfull','mHRvec','fHRvec','StartSample','EndSample','ECG_mQRSPos','ECG_avgMHR','ECG_fQRSPos','ECG_avgFHR','ECG_scoreArray','ECG_globalScore','ECG_avgBestFHR'};
            
            for no=1:length(expectedFieldNames)
                ResStructFrame.resData.(expectedFieldNames{no})=[];
            end
                        
            ResStructFrame=structCopy(OneFrame,ResStructFrame);
            ResStructFrame.resData(n).StartSample=1;
            ResStructFrame.resData(n).EndSample=ResStructFrame.resData(n).StartSample+WinLen*inputStruct.meta.Samplerate-1;
        else
            tmpRes=structCopy(OneFrame.resData,ResStructFrame.resData(n));
            flds=fieldnames(tmpRes);
            for no=1:length(flds)
            ResStructFrame.resData(n).(flds{no})=tmpRes.(flds{no});
            end
        end
        
        
        %         RunTime=toc;
        %
        %         display(['run time = ',num2str(RunTime)]);
        %         display(['Signal length = ', num2str(size(inputStruct.data,1)/inputStruct.meta.Samplerate)]);
        %         display(['Ratio = ', num2str(RunTime/(size(inputStruct.data,1)/inputStruct.meta.Samplerate))]);
        n=n+1
        ResStructFrame.resData(n).StartSample= ResStructFrame.resData(n-1).EndSample+1;
        ResStructFrame.resData(n).EndSample=ResStructFrame.resData(n).StartSample+WinLen*inputStruct.meta.Samplerate-1;
        if ResStructFrame.resData(n).EndSample>SampNum
            if ResStructFrame.resData(n).StartSample<SampNum
                ResStructFrame.resData(n).EndSample=SampNum;
                flag=false;
            else
                flag=false;
            end
        end
    catch
        %         Frame(n)=[];
        
        %         ResStructFrame=[];
        %         AudioOut=[];
        ECGOut=[];
        return
        
    end
    if nargin>1 & ~isempty(Limit)
        if n>Limit
            flag=false;
        end
    end
    
end

try
    ResStructFrame.resData=ResStructFrame.resData(1:n-1);
catch
end

end


