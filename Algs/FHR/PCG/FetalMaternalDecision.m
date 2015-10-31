function [Maternal,Fetal]=FetalMaternalDecision(HRstruct,Score,Res,ScoreGrph)

% OneHRDetectedTh=10; %if estimated fetus HR and Maternal HR differ in less than this threshold only one HR was detected
% LowerFetalHRTh=115; % when only one HR is detected if above this thrshold declare as fetus
% HighFetalHRTh=180;
SystemAudioParams; % Load system params
HR=HRstruct.HR;


%% Maternal/Fetal HR
SerialNum=1:length(HR);

HR=HR(Score~=0);
SerialNum=SerialNum(Score~=0);
Res=Res(Score~=0);
ScoreGrph=ScoreGrph(Score~=0);
Score=Score(Score~=0);

HR=HR(Score~=999);
SerialNum=SerialNum(Score~=999);
Res=Res(Score~=999);
ScoreGrph=ScoreGrph(Score~=999);
Score=Score(Score~=999);

Score=Score(HR<HighFetalHRTh);
SerialNum=SerialNum(HR<HighFetalHRTh);
Res=Res(HR<HighFetalHRTh);
ScoreGrph=ScoreGrph(HR<HighFetalHRTh);
HR=HR(HR<HighFetalHRTh);



[idx, c]=kmedoids(HR,2,'Replicates',4);
DetRes=1:length(idx);
Grp1HR=HR(idx==1);
Grp1Scr=Score(idx==1);
DetRes1=DetRes(idx==1);
[nc,ind]=min(Grp1Scr);
HRmat(1,1)=Grp1HR(ind);
HRmat(1,2)=Grp1Scr(ind);
DETRES{1}=DetRes1(ind);

Grp2HR=HR(idx==2);
Grp2Scr=Score(idx==2);
DetRes2=DetRes(idx==2);
[nc,ind]=min(Grp2Scr);
HRmat(2,1)=Grp2HR(ind);
HRmat(2,2)=Grp2Scr(ind);
DETRES{2}=DetRes2(ind);
if abs(diff(HRmat(:,1)))<OneHRDetectedTh
    [nc,ind]=min( HRmat(:,2));
    if HRmat(1,ind)>LowerFeatalHRTh
        Fetal.HR=HRmat(ind,1);
        Fetal.Score=HRmat(ind,2);
        Fetal.IND=SerialNum(DETRES{ind});
        Fetal.Res=Res{DETRES{ind}};
        Fetal.ScoreGrph=ScoreGrph(DETRES{ind});
        Maternal.HR=[];
        Maternal.Score=[];
        Maternal.IND=[];
        Maternal.Res=[];
         Maternal.ScoreGrph=[];
    else
        Fetal.HR=[];
        Fetal.Score=[];
        Fetal.IND=[];
        Fetal.Res=[];
        Fetal.ScoreGrph=[];
        Maternal.HR=HRmat(ind,1);
        Maternal.Score=HRmat(ind,2);
        Maternal.IND=SerialNum(DETRES{ind});
        Maternal.Res=Res{DETRES{ind}};
        Maternal.ScoreGrph=ScoreGrph(DETRES{ind});
    end
else
    if diff(HRmat(:,1))>0
        Fetal.HR=HRmat(2,1);
        Fetal.Score=HRmat(2,2);
        Fetal.IND=SerialNum(DETRES{2});
        Fetal.Res=Res{DETRES{2}};
        Fetal.ScoreGrph=ScoreGrph(DETRES{2});



        Maternal.HR=HRmat(1,1);


        Maternal.Score=HRmat(1,2);
        Maternal.IND=SerialNum(DETRES{1});
        Maternal.Res=Res{DETRES{1}};
        Maternal.ScoreGrph=ScoreGrph(DETRES{1});
    else
        Fetal.HR=HRmat(1,1);
        Fetal.Score=HRmat(1,2);
        Fetal.IND=SerialNum(DETRES{1});
        Fetal.Res=Res{DETRES{1}};
        Fetal.ScoreGrph=ScoreGrph(DETRES{1});
        Maternal.HR=HRmat(2,1);
        Maternal.Score=HRmat(2,2);
        Maternal.IND=SerialNum(DETRES{2});
        Maternal.Res=Res{DETRES{2}};
         Maternal.ScoreGrph=ScoreGrph(DETRES{2});
    end
end
Fetal.Signal=[HRstruct.SignalNo(Fetal.IND),HRstruct.channel(Fetal.IND)] ;
Maternal.Signal=[HRstruct.SignalNo(Maternal.IND),HRstruct.channel(Maternal.IND)] ;

end




