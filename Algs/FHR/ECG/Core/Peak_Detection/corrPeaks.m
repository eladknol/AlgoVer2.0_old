function peaks = corrPeaks(signal, predPeaks)
%#codegen

% Parameters to identify the QRS complex. this params depend on the QRS duration
% for more accurate estiamtion you need to perform QRS detection (onset and offset)

peaksInd = zeros(0, 1);
peaksVals = zeros(0, 1);
peaks = zeros(0, 1);
group = int32(zeros(0, 1));

coder.varsize('peaksInd', [5000, 1], [1 0]);
coder.varsize('peaksVals', [5000, 1], [1 0]);
coder.varsize('peaks', [5000, 1], [1 0]);
coder.varsize('group', [5000, 1], [1 0]);

% Calculate template
template = getTemplate(signal, predPeaks);
shift = ceil(length(template)/2)+1; % shift caused due to the size of the template

corr = conv(signal, template, 'same'); % calculate the correlation using the conv and not xcorr
corr = corr./max(corr(:));
minDist = 100; % minimum distance between two peaks (depends on the heart rate and the sampling freq.)
minDCorr = 0.8;
[peaksVals, peaksInd] = findpeaks(corr', 'MINPEAKDISTANCE', minDist, 'MinPeakProminence', minDCorr); % very high sensitivy with a lot of false positives
if(length(peaksVals)<=2)
    minDCorr = minDCorr/2;
    [peaksVals, peaksInd] = findpeaks(corr', 'MINPEAKDISTANCE', minDist, 'MinPeakProminence', minDCorr); % very high sensitivy with a lot of false positives
end
% peaks = findpeaks(signal); % another version (faster - with more flase positives)

% classify the peaks into two main groups: actual peaks and false positives
% this 'classification' depends on the value of the peak 
% [group, C] = kmeans(peaksVals, 2); % matlab version

nG = 3;
if(nG>length(peaksVals))
    peaks = zeros(0, 1);
    return;
end

% #CODER_REMOVE
% if(config.useStats) % use matlab's functions if toolbox is avavaiable
%     [group, C] = kmedoids(peaksVals, nG, 'Replicates', nG+1);
% else
%     [group, C] = kmedoids_ext(peaksVals', nG);
%     C = C(:);
%     group = group(:);
% end

[group, C] = kMedoids(peaksVals, nG, nG+1, true(1));

md = 0;
md = abs(median(C));
sm = sum( ((abs(C)-md)/md) < 0.3 ) - 1;
if(sm == nG-1)
    % Cool, no need to continue, the clusters are very close hence no need to classify the peaks...
    peaks = peaksInd;
    len = length(peaks);
    for i=1:len
        [~, peaks(i)] = getQRSComplex(signal, peaks(i), i==1 || i==len);
    end
    % Some times the S is higher in abs value than the R...
    vals = sign(signal(peaks));
    md = median(vals);
    exPeaks = vals~=md;
    sm = sum(exPeaks);
    if(sm>0 && sm<0.3*length(vals))
        ind = find(exPeaks);
        for i=1:length(ind)
            if(md<0)
                [~, peaks(ind(i))] = getQRSComplex(-signal, peaks(ind(i)), ind(i)==1 || ind(i)==len, 1, 1);
            else
                [~, peaks(ind(i))] = getQRSComplex(signal, peaks(ind(i)), ind(i)==1 || ind(i)==len, 1, 1);
            end
        end
    end
    
    return;
elseif(sm == nG-2) % two clusters are close, reduce the number of cluster and re cluster the data
    nG = nG - 1;
    % #CODER_REMOVE
    %     if(config.useStats) % use matlab's functions if toolbox is avavaiable
    %         [group, C] = kmedoids(peaksVals, nG);
    %     else
    %         [group, C] = kmedoids_ext(peaksVals', nG);
    %         C = C(:);
    %         group = group(:);
    %     end
    
    [group, C] = kMedoids(peaksVals, nG, 1, true(1));
else
    
end

numPksInClust = zeros(nG, 1);
for i = 1:nG
    numPksInClust(i) = sum(group==i);
end

if(length(numPksInClust)==2) % two main clusters
    df = abs(numPksInClust(2) - numPksInClust(1));
    if(df>0.3*min(numPksInClust))
        [~, noiseG] = min(numPksInClust);
    else
        [~, noiseG] = min(C);
    end
else % There are three main clusters,
    [~, noiseG] = min(numPksInClust);
end

peaks = peaksInd(group~=noiseG);

% sometimes there will be a shift in the peaks caused by the convolotion,
% correct it:

len = length(peaks);
for i=1:len
    [~, maxInd] = getQRSComplex(signal, peaks(i), i==1 || i==len);
    peaks(i) = maxInd-1;
end
