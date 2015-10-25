function peaksInd = findPeaks(procSig, origSig, minDst, minPeakH, isClass, isAGC, Fs, isRefine, isNorm, config)
%#codegen

coder.extrinsic('disp');

%[peaksVals, peaksInd] = findPeaks(procSig, origSig, minDst, minPeakH, isClass, isAGC, Fs)

%% $TODO
% 1. Add input checking
%% General code
if(nargin<3), minDst = floor(length(procSig)/3);    end
if(nargin<4), minPeakH = 1;                         end
if(nargin<5), isClass = 0;                          end
if(nargin<6), isAGC = 0;                            end
if(nargin<7), Fs = 1000;                            end
if(nargin<8), isRefine = 1;                         end
if(nargin<9), isNorm = 1;                           end

%% Find the peaks

if(isNorm)
    procSig = procSig/max(abs(procSig));
end

if(isAGC)
    % perform AGC in the signal so it will be easier to detect peaks and remove noise
    config.isNorm = 1;
    procSig = winAGC(procSig, config);
end

if(isNorm)
    procSig = procSig.*procSig;
    procSig = procSig/max((procSig));
end

% Do 10 sec analysis
winLenTime = config.analWinLen;
winLen = winLenTime*Fs;

if(length(procSig)>winLen)
    nNumOfWins = floor(length(procSig)/winLen);
    remWin = mod(length(procSig), winLen);
    
    peaksInd = zeros(1, 0);
    coder.varsize('peaksInd', [1, 5000], [0 1]); % #CODER_VARSIZE
    
    numPeaks = zeros(1, nNumOfWins);
    for iWin = 1:nNumOfWins
        ind = 1 + (iWin-1)*winLen : iWin*winLen;
        sig = procSig(ind);
        sig = sig/max(sig);
        padLen = 20;
        sig = padArr(sig, 0, padLen);
        [~, Inds] = findpeaks(sig, 'MINPEAKDISTANCE', minDst, 'MINPEAKHEIGHT', minPeakH);% 'MinPeakProminence', minPeakP);
        numPeaks(iWin) = length(Inds);
        peaksInd = [peaksInd Inds+(iWin-1)*winLen - padLen];
    end
    if(remWin>0.01*winLen)
        ind = 1 + iWin*winLen : length(procSig);
        sig = procSig(ind);
        sig = sig/max(sig);
        if(minDst>0.5*remWin)
            minDst = 1;
        end
        [~, Inds] = findpeaks(sig, 'MINPEAKDISTANCE', minDst, 'MINPEAKHEIGHT', minPeakH);
        peaksInd = [peaksInd Inds+(iWin)*winLen];
    end
    
    % The number of peaks in each window should be similar: numPeaks (ignore the last window if not full)
    nG = 3;
    if(length(numPeaks)>nG)
        
        % kMedoids uses targeting
        [group, C] = kMedoids(numPeaks', nG, nG+1, true(1)); % more robust to outlairs than k-means
        
        % #CODER_REMOVE
        %         if(config.useStats) % use matlab's functions if toolbox is avavaiable
        %             [group, C] = kmedoids(numPeaks', nG, 'Replicates', nG+1); % more robust to outlairs than k-means
        %             %[group, C] = kmeans(numPeaks', 3); % if you use it remove outlairs first
        %         else
        %             [group, C] = kmedoids_ext(numPeaks, nG);
        %             group = group(:);
        %             C = C(:);
        %             %[group, C] = k_means(numPeaks, 3);  % use a simple provided function. $TBC
        %             % if you use it remove outlairs first
        %         end
        
        [cntSort, i] = sort(C);
        pksDiff = abs(diff(cntSort))>0.3*cntSort(2);
        if(any(pksDiff))
            %warning('check code here for ==');
            %GRP = find(C==cntSort([pksDiff(1) 0 pksDiff(2)]>0));
            
            coder.varsize('GRP', [10 1], [1 0]); % #CODER_VARSIZE
            GRP = 0;
            
            if(~isempty(cntSort([pksDiff(1) 0 0]>0)))
                GRP = find(C==cntSort([pksDiff(1) 0 0]>0));
            end
            
            %             if(isempty(cntSort([pksDiff(1) 0 0]>0)))
            %                 GRP = 0;
            %             else
            %                 GRP = find(C==cntSort([pksDiff(1) 0 0]>0));
            %             end
            
            % find peaks again for this group
            if(length(GRP)==1 && all(GRP==0))
                % NOTHINH
                GRP = 0;
            else
                coder.varsize('tmp_here', [20 1], [1 0]);
                
                numPeaks = zeros(1, nNumOfWins);
                for grp = 1:length(GRP)
                    tmp_here = find(group == GRP(grp))';
                    for iWin = 1:length(tmp_here)
                        ind = 1 + (tmp_here(iWin)-1)*winLen : tmp_here(iWin)*winLen;
                        if(C(GRP(grp))<C(i(2)))
                            % Few peaks have been detected
                            % The main reason for this issue is very high spikes...
                            % Try increase the small peaks by applying AGC
                            % This could be dangrous in the case that there are no peaks at all.
                            cfg.isNorm = 1;
                            sig = winAGC(procSig(ind), cfg, C(i(2)));
                            [peaksVals, Inds] = findpeaks(sig,'MINPEAKDISTANCE',minDst,'MINPEAKHEIGHT',minPeakH);
                            numPksNew = length(Inds);
                            if(abs(numPksNew-C(i(2)))<0.3*C(i(2)))
                                % Cool, worth the shot!
                                % Remove old peaks in this window and add the new ones
                                bfr = sum(numPeaks(1: tmp_here(iWin)-1));
                                indRmv = bfr+1:bfr+1+numPeaks( tmp_here(iWin))-1;
                                peaksInd(indRmv) = [];
                                if( tmp_here(iWin)==1)
                                    peaksInd = [Inds' peaksInd];
                                elseif( tmp_here(iWin)==nNumOfWins)
                                    Inds = Inds + ( tmp_here(iWin)-1)*winLen;
                                    peaksInd = [peaksInd Inds'];
                                else
                                    Inds = Inds + ( tmp_here(iWin)-1)*winLen;
                                    peaksInd = [peaksInd(1:bfr) Inds'-1 peaksInd(bfr+1:end)];
                                end
                                numPeaks( tmp_here(iWin)) = numPksNew;
                            else
                                % Never mind, don't use the new peaks
                            end
                        else % a lot of peaks have been detected
                            %do nothing maybe...
                        end
                    end
                end
            end
            
            %             for grp = GRP
            %                 for iWin = find(group == grp)'
            %                     ind = 1 + (iWin-1)*winLen : iWin*winLen;
            %                     if(C(grp)<C(i(2)))
            %                         % Few peaks have been detected
            %                         % The main reason for this issue is very high spikes...
            %                         % Try increase the small peaks by applying AGC
            %                         % This could be dangrous in the case that there are no peaks at all.
            %                         cfg.isNorm = 1;
            %                         sig = winAGC(procSig(ind), cfg, C(i(2)));
            %                         [peaksVals, Inds] = findpeaks(sig,'MINPEAKDISTANCE',minDst,'MINPEAKHEIGHT',minPeakH);
            %                         numPksNew = length(Inds);
            %                         if(abs(numPksNew-C(i(2)))<0.3*C(i(2)))
            %                             % Cool, worth the shot!
            %                             % Remove old peaks in this window and add the new ones
            %                             bfr = sum(numPeaks(1:iWin-1));
            %                             indRmv = bfr+1:bfr+1+numPeaks(iWin)-1;
            %                             peaksInd(indRmv) = [];
            %                             if(iWin==1)
            %                                 peaksInd = [Inds peaksInd];
            %                             elseif(iWin==nNumOfWins)
            %                                 Inds = Inds + (iWin-1)*winLen;
            %                                 peaksInd = [peaksInd Inds];
            %                             else
            %                                 Inds = Inds + (iWin-1)*winLen;
            %                                 peaksInd = [peaksInd(1:bfr) Inds'-1 peaksInd(bfr+1:end)];
            %                             end
            %                             numPeaks(iWin) = numPksNew;
            %                         else
            %                             % Never mind, don't use the new peaks
            %                         end
            %                     else % a lot of peaks have been detected
            %                         %do nothing maybe...
            %                     end
            %                 end
            %             end
            % For max val:
        end
    end
else
    winLen = length(procSig);
    [~, peaksInd] = findpeaks(procSig,'MINPEAKDISTANCE',minDst, 'MINPEAKHEIGHT', minPeakH); %'MINPEAKHEIGHT',minPeakH);
end

if(isempty(peaksInd))
    return;
end

% After finding the peaks, refine the positions of the detected peaks (the exact pos of the R-wave)
if(isRefine)
    peaksInd_temp = peaksInd;
    len = length(peaksInd);
    for iPeak =1:len
        [~, maxInd] = getQRSComplex(origSig, peaksInd(iPeak), iPeak==1 || iPeak==len, 2, 0, 1); % use a mult of 2 since the peak pos isn't acc yet...
        peaksInd_temp(iPeak) = maxInd;
    end
    peaksInd = peaksInd_temp;
end
peaksInd(diff(peaksInd)==0) = [];

%% Semi-supervised learner algorithm: - *TBU*
% 1. Perform k-means clustering to build a preliminary model
% 2. Perform iterative knn (or SVM):
% update the model after each classification iteration
if(~config.useStats)
    return;
end
if(isClass)
    % classify the peaks into two main groups: actual peaks and false positives
    % this 'classification' depends on the value of the peak
    peaksVals = origSig(peaksInd);
    nG = 3;
    %     if(config.useStats)
    %         [group, C] = kmedoids(peaksVals', nG, 'Replicates', nG+1); % check if Replicates helps here
    %     else
    %         [group, C] = kmedoids_ext(peaksVals, nG);
    %         group = group(:);
    %         C = C(:);
    %     end
    [group, C] = kMedoids(peaksVals, nG, nG+1, false); % check if Replicates helps here
    
    md = abs(median(C));
    sm = sum( ((abs(C)-md)/md) < 0.3 ) - 1;
    if(sm == nG-1)
        % Cool, no need to continue, the clusters are very close hence no need to classify the peaks...
        return;
    elseif(sm == nG-2) % two clusters are close, reduce the number of cluster and re cluster the data
        nG = nG - 1;
%         if(config.useStats)
%             [group, C] = kmedoids(peaksVals', nG, 'Replicates', nG+1);
%         else
%             [group, C] = kmedoids_ext(peaksVals, nG+1);
%             group = group(:);
%             C = C(:);
%         end
        [group, C] = kMedoids(peaksVals, nG, nG+1, false); % check if Replicates helps here
        
    else
        
    end
    
    numPksInClust = zeros(1, nG);
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
    
    peaksInd = peaksInd(group~=noiseG);
    peaksVals = origSig(peaksInd);
    % stop here for now...
    return;
    
    % CODER_REMOVE
    %     susPeaks = peaksInd(group~=noiseG); % suspected as peaks (maybe part of them are not real peaks)
    %     susnPeaks = peaksInd(group==noiseG);% suspected as not-peaks (maybe part of them are real peaks)
    %
    %     brdPeaks = [peaksInd(1) peaksInd(end)];
    %     for i=1:length(susPeaks)
    %         susPeaksQRS(i,:) = getQRSComplex(origSig, susPeaks(i), sum(susPeaks(i)==brdPeaks), 2); % same size
    %     end
    %
    %     for i=1:length(susnPeaks)
    %         susnPeaksQRS(i,:) = getQRSComplex(origSig, susnPeaks(i), sum(susnPeaks(i)==brdPeaks), 2); % same size
    %     end
    %
    %     peaksTemplate = mean(susPeaksQRS);
    %     notPeaksTemplate = mean(susnPeaksQRS);
    %
    %     % pre-Proc: remove negative-correlated peaks (assumption: during a short recording the R-wave won't cahnge direction)
    %     % this cannot be done to the non-peaks (cause there are noise...)
    %
    %     ind = 1;
    %     removeInd = [];
    %     MAX_CORR_FOR_DIREC_INVER = -0.65;
    %
    %     for i=1:length(susnPeaks)
    %         negCorr = min(xcorr(susPeaksQRS(i,:), peaksTemplate, 'coef'));
    %         if(negCorr<MAX_CORR_FOR_DIREC_INVER)
    %             removeInd(ind) = i;
    %             ind = ind+1;
    %         end
    %     end
    %
    %     susnPeaksQRS = [susnPeaksQRS ;susPeaksQRS(removeInd,:)];
    %     susPeaksQRS(removeInd,:) = [];
    %
    %     peaksTemplate = mean(susPeaksQRS);
    %     notPeaksTemplate = mean(susnPeaksQRS);
    %
    %     classModel.classGroups = {'p','n'}; % peaks, not-peaks
    %     classModel.K = 4; % number of neighbors to classify a query complex (higher values gives more robust classifier but not necessarily a better predictor
    %     % to check the improvement in the prediction use the cross-validation loss)
    %     classModel.distanceMethod = 'correlation';
    %     doClass = 1;
    %     ind = 1;
    %     while(doClass)
    %         classModel.classMeas = [susPeaksQRS; susnPeaksQRS];
    %         classModel.model = fitcknn(classModel.classMeas, classModel.classGroups, 'NumNeighbors', classModel.K, 'Distance', classModel.distanceMethod);
    %
    %         rloss(ind) = resubLoss(classModel.model);
    %         cvmdl = crossval(classModel.model);
    %         kloss(ind) = kfoldLoss(cvmdl);
    %
    %         ind1 = 1;
    %         ind2 = 1;
    %         clear susPeaksQRS susnPeaksQRS;
    %         clear classResults;
    %
    %         for i = 1:length(peaksInd)
    %             currPeak = getQRSComplex(origSig, peaksInd(i), sum(peaksInd(i)==brdPeaks));
    %             classResults{i} = predict(classModel.model, currPeak);
    %             if(classResults{i}=='p')
    %                 susPeaksQRS(ind1,:) = currPeak;
    %                 ind1 = ind1+1;
    %             else
    %                 susnPeaksQRS(ind2,:) = currPeak;
    %                 ind2 = ind2+1;
    %             end
    %         end
    %
    %         doClass = 0;
    %     end
    %
    %     %
    %     peaksG =1;
    %
    %     % Classification using a knn classifier
    %     %     nNumOfPeaks = length(peaksTemp);
    %     %     for ind = 2:nNumOfPeaks
    %     %         peakPos = peaksTemp(ind);
    %     %         beatInterval = getBeatInterval(peaksTemp, ind);
    %     %         beatECG(ind,:) = getCurrBeatECG(origSig, peakPos, beatInterval, ind==1 || ind==nNumOfPeaks);
    %     %     end
    %     if(abs(diff(C))<0.2*C(peaksG))
    %         % the peaks values are very close
    %         return;
    %     else
    %         % peaks = (peaksInd(group==peaksG) - shift)';
    %         peaksInd = (peaksInd(group==peaksG))';
    %         peaksVals = (peaksVals(group==peaksG))';
    %     end
end
