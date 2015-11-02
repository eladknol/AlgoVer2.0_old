function template = getTemplateForDsiplay(signal, peaks)

templateSize = getQRSTemplateSize(2);

template(1:-templateSize.onset+templateSize.offset+1) = 0;

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
