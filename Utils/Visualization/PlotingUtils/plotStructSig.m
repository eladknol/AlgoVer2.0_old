function plotStructSig(S,mQRSPos)


t=(0:length(S.Res.Signal)-1)./S.Res.Fs;

plot(t,S.Res.Signal);
hold on
plot(t,S.Res.SlowEnvelope,'r')
plot(t(S.Res.Locs),S.Res.SlowEnvelope(S.Res.Locs),'*k')
% plot(t(S.Res.Locs)+0.25,S.Res.SlowEnvelope(S.Res.Locs),'*c')
% plot(t(S.Res.Locs)-0.25,S.Res.SlowEnvelope(S.Res.Locs),'*y')
% plot(t,S.Res.FastEnvelope,'m')
% if nargin>1
%     plot(mQRSPos/S.Res.Fs,0,'^g')
% end
    

hold off
end