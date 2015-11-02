function plotRR(peakPos, holdIt)

if(nargin<2)
    holdIt = 0;
end
plotf(diff(peakPos), holdIt);
grid on;
xlabel('Beat#');
ylabel('RR interval [mSec]');
title('Beat-2-Beat RR intervals');
