function template = getTemplate(signal, peaks, templateSize) %#codegen
%template = getTemplate(signal, peaks, templateSize)

% TBU
% TO-DO
% add a better template selsection alg... i.e. correlation update only
if(nargin<3)
    %     templateSize = getQRSTemplateSize();
    templateSize = getQRSTemplateSize(2);
end

template = zeros(1, -templateSize.onset+templateSize.offset+1);

% CODER_REPLACE
% template(1:-templateSize.onset+templateSize.offset+1) = 0;

if(isempty(peaks))
    template(:) = nan;
end

QRSOnset    = peaks + templateSize.onset;
QRSOffset   = peaks + templateSize.offset;

QRSOffset(QRSOnset<1) = [];
QRSOnset(QRSOnset<1) = [];
QRSOnset(QRSOffset>length(signal)) = [];
QRSOffset(QRSOffset>length(signal)) = [];
nNumOfpeaks = length(QRSOffset);

for i=1:nNumOfpeaks
    template = template + signal(QRSOnset(i):QRSOffset(i));
end
template = template/nNumOfpeaks;
