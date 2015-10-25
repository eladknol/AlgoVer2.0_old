function [template, siz] = getECGTemplate(signal, peaks, interval)
%#codegen

% Extract template for the full ecg signal (not only the QRS complex)
if(nargin<3)
    val = floor(mean(diff(peaks))/2);
    interval.onset = val;
    interval.offset = val;
end

templateSize.onset  = -interval.onset;
templateSize.offset = +interval.offset;

% template(1:-templateSize.onset+templateSize.offset+1) = 0;
template = zeros(1, -templateSize.onset+templateSize.offset+1);

siz = size(template);

if(nargout==2)
    return;
end

if(isempty(peaks))
    template(:) = nan;
end

QRSOnset    = peaks + templateSize.onset;
QRSOffset   = peaks + templateSize.offset;

QRSOffset(QRSOnset<0) = [];
QRSOnset(QRSOnset<0) = [];
QRSOnset(QRSOffset>length(signal)) = [];
QRSOffset(QRSOffset>length(signal)) = [];
nNumOfpeaks = length(QRSOffset);
for i=1:nNumOfpeaks
    template = template + signal(QRSOnset(i):QRSOffset(i));
end
template = template/nNumOfpeaks;
