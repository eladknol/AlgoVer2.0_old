function plotStructScore(S)
cla;
locsSt=S.ScoreGrph.StartFrame;
locsEn=S.ScoreGrph.EndFrame;
Sc=S.ScoreGrph.Score;
Fs=S.Res.Fs;
plotStr={'r-^','g-o'};

hold on
for k=1:length(locsSt)
    str=plotStr{mod(k,2)+1};
    plot([locsSt(k), locsEn(k)]./Fs,[Sc(k), Sc(k)],str)
end
    
plot([locsSt(1), locsEn(end)]./Fs,[0.2, 0.2],':b')    
end    