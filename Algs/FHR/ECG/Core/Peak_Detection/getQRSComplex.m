function [QRS, maxInd] = getQRSComplex(signal, peakPos, brdPeak, mult, reCorrect, forceInc)

%[QRS, maxInd] = getQRSComplex(signal, peakPos, brdPeak, mult, reCorrect, forceInc)
% get a specific qrs complex
% signal: ecg signal
% peakPos: position of the peak
% brdPeak: is this the first/last peak?

if(nargin<3)
    brdPeak = 0;
end
if(nargin<4)
    mult = 1;
end
if(nargin<5)
    reCorrect = 0;
end
if(nargin<6)
    forceInc = 0;
end


templateSize = getQRSTemplateSize(mult);

QRSOnset    = peakPos + templateSize.onset;
QRSOffset   = peakPos + templateSize.offset;

coder.varsize('QRSOnset', [1 1], [0 1]);
coder.varsize('QRSOffset', [1 1], [0 1]);

if(brdPeak)
    QRSOnset(QRSOnset<1) = 1;
    QRSOffset(QRSOffset>length(signal)) = length(signal);
else
    if(forceInc)
        QRSOnset(QRSOnset<1) = 1;
        QRSOffset(QRSOffset>length(signal)) = length(signal);
        
    else
        QRSOffset(QRSOnset<1) = [];
        QRSOnset(QRSOnset<1) = [];
        
        QRSOnset(QRSOffset>length(signal)) = [];
        QRSOffset(QRSOffset>length(signal)) = [];
    end
end


if(isempty(QRSOnset) || isempty(QRSOffset))
    QRS = 0;
    maxInd = 0;
    return;
end
QRS = signal(QRSOnset(1):QRSOffset(1));

if(nargout>1)
    if(reCorrect)
        [val, maxInd] = max(QRS);
    else
        [val, maxInd] = max(abs(QRS));
    end
    maxInd = maxInd + QRSOnset(1) - 1;
end

if(coder.target('matlab'))
    if(~nargout)
        plotf(QRS,1);
    end
end
