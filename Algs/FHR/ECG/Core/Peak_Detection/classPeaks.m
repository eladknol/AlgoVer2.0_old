function peaks = classPeaks(signal, predPeaks)

% Detect peaks (all of them) and then classify good peaks
% This classification depends on the morphology of the peaks

[peaksVals, peaksInd] = findpeaks(signal);

% [group, C] = kmeans(peaksVals, 2); % matlab version
[group, C] = k_means(peaksVals', 2);

if(C(1)>C(2)) % assumption: peaks have higher values
    peaksG = 1;
else
    peaksG = 2;
end
peaks = (peaksInd(group==peaksG))'; 

MAX_ACC_PEAK_SHIFT = ceil(0.1*nanmean(diff(predPeaks)));
INC = 1;
EXC = 0;

for i=1:length(peaks)
    ind = sum(abs(predPeaks-peaks(i))<MAX_ACC_PEAK_SHIFT);
    if(ind==1)
        Peaks(i) = INC;
    else
        Peaks(i) = EXC;
    end
end

predTemplate = getTemplate(signal, peaks(Peaks==INC));
noiseTemplate = getTemplate(signal, peaks(Peaks==EXC));

classy.g = ['m'; 'n'];
classy.trainingSet = [predTemplate(:)'; noiseTemplate(:)'];
for iPeak=1:length(peaks)
    try
        sampleQRS = getQRSComplex(signal, peaks(iPeak));
        class(iPeak) = knnclassify(sampleQRS, classy.trainingSet, classy.g);
    catch
        class(iPeak) = 'n';
    end
end

actualPeaks = peaks(class==classy.g(1));

temp = zeros(length(signal),1);
temp(actualPeaks)=1;
minDist = floor(0.1*mean(diff(actualPeaks)));
MAX_PEAKS_DST = floor(1.15*mean(diff(actualPeaks)));
[peakss, peaksInd] = findpeaks(temp,'MINPEAKDISTANCE', minDist);
ind=1;

for i=1:length(actualPeaks)-1
   fInd = sum(peaksInd==actualPeaks(i));
   if(fInd==1)
       if((actualPeaks(i+1)-actualPeaks(i))>MAX_PEAKS_DST)
           surePeaks(ind) = floor(mean([actualPeaks(i+1) actualPeaks(i)]));
       else
           surePeaks(ind) = actualPeaks(i);
       end
       ind=ind+1;
   else
       %actualPeaks(i)=[];
   end
end
 
fInd = sum(peaksInd==actualPeaks(end));
if(fInd)
    surePeaks(end+1) = actualPeaks(end);
end
% peaks = actualPeaks;
peaks = surePeaks;