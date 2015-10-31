function plotStructRR(S)
locs=S.Res.Locs;
Fs=S.Res.Fs;

RR=diff(locs);
t=(cumsum(RR)+locs(1))/Fs;
hold off
HR=Fs*60./RR;
HR=medfilt1(HR,3);
plot(t,HR);

 BaseLine=medfilt1(Fs*60./RR,20);
 hold on
 plot(t,BaseLine, 'r');
 hold off
end