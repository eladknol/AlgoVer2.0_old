function PlotResult(AlgOut,mQRSPos,PlotMaternal,fignum)

if nargin==1
    PlotMaternal=true;
    AddQRSPos=false;
elseif nargin==2
    if ~islogical(mQRSPos)
    PlotMaternal=true;
    AddQRSPos=true;
    else
        AddQRSPos=flase;
        PlotMaternal=mQRSPos;
    end
else
    AddQRSPos=true;
    
end
if nargin>3
figure(fignum)
else
    figure
end

ax_h(1)=subplot(311);
if AddQRSPos
plotStructSig(AlgOut.Fetal,mQRSPos); axis tight
else
    plotStructSig(AlgOut.Fetal); axis tight
end
title('Fetal Detections')
ax_h(2)=subplot(312);
plotStructRR(AlgOut.Fetal);
title('HR Graph')

ax_h(3)=subplot(313)
plotStructScore(AlgOut.Fetal);
% stairs(AlgOut.Fetal.ScoreGrph.OutLocation/AlgOut.Fetal.Res.Fs,AlgOut.Fetal.ScoreGrph.Score);
linkaxes(ax_h,'x');
xlabel('Time (Seconds)')
title('Score Graph');

if PlotMaternal
if nargin>3
figure(fignum+2)
else
    figure
end

ax_h(1)=subplot(311);
if AddQRSPos
plotStructSig(AlgOut.Maternal,mQRSPos); axis tight
else
    plotStructSig(AlgOut.Maternal); axis tight
end
title('Maternal Detections')
ax_h(2)=subplot(312);
plotStructRR(AlgOut.Maternal);
title('HR Graph')

ax_h(3)=subplot(313)
plotStructScore(AlgOut.Maternal);
% stairs(AlgOut.Maternal.ScoreGrph.OutLocation/AlgOut.Maternal.Res.Fs,AlgOut.Maternal.ScoreGrph.Score);
linkaxes(ax_h,'x');
xlabel('Time (Seconds)')
title('Score Graph');
end

if nargin>3
figure(fignum+1)
else
    figure
end
h(1)=subplot(211);
 plotStructSig(AlgOut.Maternal);
 h(2)=subplot(212)
  plotStructSig(AlgOut.Fetal);
  linkaxes(h,'x');

end

% 
% function plotStructSig(S)
% 
% 
% t=(0:length(S.Res.Signal)-1)./S.Res.Fs;
% 
% plot(t,S.Res.Signal);
% hold on
% plot(t,S.Res.SlowEnvelope,'r')
% plot(t(S.Res.Locs),S.Res.SlowEnvelope(S.Res.Locs),'*k')
% 
% hold off
% end
% 
% function plotStructRR(S)
% locs=S.Res.Locs;
% Fs=S.Res.Fs;
% 
% RR=diff(locs);
% t=(cumsum(RR)+locs(1))/Fs;
% plot(t,Fs*60./RR)
% 
%  BaseLine=medfilt1(Fs*60./RR,20);
%  hold
%  plot(t,BaseLine, 'r');
% end
% 
% function plotStructScore(S)
% locsSt=S.ScoreGrph.StartFrame;
% locsEn=S.ScoreGrph.EndFrame;
% Sc=S.ScoreGrph.Score;
% Fs=S.Res.Fs;
% plotStr={'r-^','g-o'};
% 
% hold on
% for k=1:length(locsSt)
%     str=plotStr{mod(k,2)+1};
%     plot([locsSt(k), locsEn(k)]./Fs,[Sc(k), Sc(k)],str)
% end
%     
%     
% end    
% 
% 
