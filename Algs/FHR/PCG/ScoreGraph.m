function [ Score ] = ScoreGraph(Locs, varargin )
%


SystemAudioParams; %load system params
ParseArgs(varargin);
if ~exist('Fs', 'var')
    Fs=1000;
end


OverLapPercent=0.5;%in precentage

NumOfRRs=length(Locs);
WinLength=max(round(NumOfRRs/5),24);
OverLap=round(WinLength*OverLapPercent);
flag=true;

FrameNum=0;
StartRR=1;
while flag
    
    Frame=Locs(StartRR:StartRR+WinLength-1);
    StartRR=StartRR+WinLength-OverLap;
    
    if StartRR+WinLength>=NumOfRRs
        flag=false;
    end
    FrameNum=FrameNum+1;
    
    [RRestim,Scr,Bl]=RRestimationAndCalcScore('Locations',Frame,'DistFromBaseLine',true,'usevalidation',false,'Fs',Fs);
    Score.Frame{FrameNum}=Frame;
    Score.Score(FrameNum)=Scr.score;
    
    Score.StartFrame(FrameNum)=Frame(1);% +round((Frame(end)-Frame(1))/2);
    
    Score.EndFrame(FrameNum)=Frame(end);
    
    Score.RRestim(FrameNum)=RRestim;
    RRs(FrameNum).RR=Scr.RR;
    
    
    
    
end

%% Estim Avarage RR from only good sections of signal
indx=Score.Score<AcceptedDetectionRes;

RRgood=vertcat(RRs(indx).RR);

Score.AvgRR=median(RRgood);

[SortScore,indx]=sort(Score.Score);

if length(indx)>6
    mn=6;
else
    mn=length(indx);
end
ScoreSelected=[SortScore(1:mn)',indx(1:mn)', ones(mn,1),arrayfun(@(x)median(x.RR),RRs(indx(1:mn)))'];
ScoreSelected(ScoreSelected(:,1)>AcceptedDetectionRes,3)=0;

ScoreSelected=sortrows(ScoreSelected,2);

ind0=find(ScoreSelected(:,3)==0);
ind1=find(ScoreSelected(:,3)==1);
Score.HRvec=zeros(6,1);
Score.HRvec(ind1)=ScoreSelected(ind1,4);
if length(ind0)==mn
    Score.HRvec=-1*ones(6,1);
elseif length(ind1)==mn
    Score.HRvec=round(60./ScoreSelected(:,4));
else
    for k=1:length(ind0)
        if ind0(k)==1
            Score.HRvec(ind0(k))=ScoreSelected(ind1(1),4);
        elseif ind0(k)==mn
            Score.HRvec(ind0(k))=ScoreSelected(ind1(end),4);
        elseif length(ind1)==1
            Score.HRvec(ind0(k))=ScoreSelected(ind1(1),4);
        else
            df=(ind1-ind0(k));
            df(df<0)=999;
            [mn,ii]=min(df);
            hr1=ScoreSelected(ind1(ii),4);
            df=(ind1-ind0(k));
            df(df>0)=-999;
            [mn,ii]=max(df);
            hr2=ScoreSelected(ind1(ii),4);
            
            
            
            Score.HRvec(ind0(k))=(hr1+hr2)/2;
        end
    end
    Score.HRvec=round(60./Score.HRvec);
end
HRV=Score.HRvec;
HRV(isinf(HRV))=mean(HRV(~isinf(HRV)));
if exist('GlobHR','var') && exist('GlobScore','var')
    if sum(HRV)==-6
        if GlobScore<AcceptedDetectionRes
            HRV=GlobHR;
        end
    end
end

Score.HRvec=round(ones(size(Score.HRvec)).*HRV);

    









