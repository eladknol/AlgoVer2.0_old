function resPeaks = buildFetalTimeSeries(fetSignal, pks, inConfig, correctionStage)

% #pragmas
% #codegen

%% Coder directives
coder.extrinsic('warning');

if(length(pks) == 1 || pks(1) == -1)
    resPeaks = -1;
    return;
end


if(nargin<4)
    correctionStage = 17; % bananas
end

pks = refinePeaksPos(fetSignal, pks);
pks = pks(:)';
config = inConfig;
maxPredHR = inConfig.maxPredFetalHR;
predFetHR = (inConfig.maxPredFetalHR + inConfig.minPredFetalHR)/2;
maxLen = length(fetSignal);
config.medLen = floor(length(pks)/5);
config.maLength = inConfig.peakExamination.timeSeries.maLength;
RRC = diff(pks);
% tempRRC = medfilt1([RRC RRC RRC], config.medLen); % medfilt1 is not supported by the coder
tempRRC = fastmedfilt1d([RRC RRC RRC], config.medLen)';


[sts, tempRRC] = applyFilter('ma', tempRRC, config);
tempRRC = tempRRC(length(RRC):2*length(RRC)-1);
% tempHRC: is the HRC trendline!
% acourding to the tempHRC, start building a time series

%% Find a charasteristic RR interval
winSize = inConfig.peakExamination.goodSegPeaks; % 5 peaks are needed to flag a good segment

df = RRC - tempRRC;% find the segment with the minimu error

err = zeros(length(df)-winSize+1, 1);
for iWin = 1:length(df) - winSize
    err(iWin) = norm(df(iWin:iWin+winSize));
end

errThrsh = 10; % help me
countExt = 1; 
maxCont = winSize;
minLen = winSize;% Don't ask why
inds = [];

while(countExt<maxCont) % Loop until you die
    bin = diff(err<errThrsh);
    raiseInd = find(bin==1);
    fallInd = find(bin==-1);
    
    % Update the threshold (increase it)
    errThrsh = errThrsh*2;
    countExt = countExt + 1;
    
    if(isempty(raiseInd) || isempty(fallInd))
        continue;
    end
    
    if(length(raiseInd) ~= length(fallInd))
        firstRaise = raiseInd(1);
        if(raiseInd(1) > fallInd(1))
            raiseInd = [1; raiseInd];
        else
            fallInd = [fallInd; length(bin)];
        end
    end
    if(fallInd(1)<raiseInd(1))
        raiseInd = [1; raiseInd];
        raiseInd(end) = [];
    end
    [y, i] = max(fallInd - raiseInd);
    inds = (raiseInd(i)+1):fallInd(i);
    
    if(length(inds)>=minLen)
        break;
    end
    
end

bestPeaks = pks(inds);

meanRR = floor(mean(diff(bestPeaks)));
stdRR = std(diff(bestPeaks));
mult = 2;
if(60*config.Fs/meanRR>maxPredHR)
    % not acc results, you dumpass
    meanRR = config.Fs/(predFetHR/60);
end
goodPeaks = bestPeaks;

if(isempty(goodPeaks))
    resPeaks = -1;
    return;
end
%% 1st, Use the created time machine go back in time
susInd = bestPeaks(1);

maxCount = 10*maxPredHR;
counter=1;
while(true)
    susInd = susInd - meanRR;
    if(all(susInd<pks(1)) || counter>=maxCount)
        break;
    end
    currPeaks = 1:(find(pks == goodPeaks(1), 1, 'first')-1);
    [ind, closestVal, Diff] = findClosest(pks(currPeaks), susInd);
    if(all(Diff<(mult*stdRR + abs(susInd - closestVal))))
        if(goodPeaks(1) ~= closestVal)
            goodPeaks = [closestVal goodPeaks];
            meanRR = floor(mean(diff(goodPeaks)));
            stdRR = std(diff(goodPeaks));
        end
    end
    susInd = goodPeaks(1);
    counter = counter + 1;
end

%% 2nd, go forward in time, if possible, take some monkeys with you
susInd = bestPeaks(end);
counter=1;
while(true)
    susInd = susInd + meanRR;
    if(all(susInd>pks(end)) || counter>=maxCount)
        break;
    end
    currPeaks = (find(pks == goodPeaks(end), 1, 'first')+1):length(pks);
    [ind, closestVal, Diff] = findClosest(pks(currPeaks), susInd);
    if(all(Diff<(mult*stdRR + abs(susInd - closestVal))))
        goodPeaks = [goodPeaks closestVal];
        meanRR = floor(mean(diff(goodPeaks)));
        stdRR = std(diff(goodPeaks));
    end
    susInd = closestVal;
    counter = counter + 1;
end

if(correctionStage==1)
    
    %% Start with finding false negatives, I know you, you're always looking for the bad side
    ind=1;
    addPeaks = [];
    remPeaks = [];
    coder.varsize('addPeaks', [5000 1], [1 0]); % #CODER_VARSIZE
    coder.varsize('remPeaks', [5000 1], [1 0]); % #CODER_VARSIZE
    coder.varsize('tempAddPeaks', [1 1000], [0 1]); % #CODER_VARSIZE
    
    Diff1 = diff(goodPeaks);
    Diff2 = diff(Diff1);
    [vv, tmpPks] = findpeaks(abs(Diff1));
    STDV = 0.2;
    mult_loc = 1 + STDV;
    for i=1:length(tmpPks)
        if(all((Diff1(tmpPks(i)))>mult_loc*meanRR))
            tInds_1 = (tmpPks(i)-2):(tmpPks(i)+2);
            tInds = tInds_1(tInds_1>0 & tInds_1<length(Diff1));
            if(~any(Diff1(tInds)<(meanRR - stdRR)))
                surrPeaks = goodPeaks(tmpPks(i)-1:tmpPks(i)+1);
                susPoses = surrPeaks(1) + [1 2]*(surrPeaks(3) - surrPeaks(1))/3;
                [ii, closestVal, df] = findClosest(susPoses, goodPeaks(tmpPks(i)));
                %susPoses(ii) = [];
                tempAddPeaks = floor(susPoses(ii ~= [1 2]));
                remAddPeak = [];
                for ijk = 1:length(tempAddPeaks)
                    [iii, closestVal, df] = findClosest(goodPeaks, tempAddPeaks(ijk), 2);
                    strtI = max(1, iii(1) - 3);
                    endI = min(length(Diff1), iii(2) + 3);
                    localRR = median(Diff1(strtI:endI));
                    temp_here_12 = abs(1-(diff(closestVal))/localRR)<0.1;
                    if(all(temp_here_12(:)))
                        remAddPeak = [remAddPeak ijk];
                    end
                end
                tempAddPeaks(remAddPeak) = [];
                addPeaks = [addPeaks; tempAddPeaks(:)];
                ind = ind+1;
            end
        end
    end
    goodPeaks = sort([goodPeaks addPeaks']);
    
    %% Find ZigZags (false positive and flase negative): one false positive creates zigzags: it is close to one peak and hince a true is removed hence it is far from the next peak
    ind = 1;
    %clear addPeaks remPeaks
    addPeaks = [];
    remPeaks = [];
    Diff1 = diff(goodPeaks);
    [vv, tmpPks] = findpeaks(abs(diff(Diff1)));
    tmpPks = tmpPks+1;
    
    for i=1:length(tmpPks)
        
        if(all(abs(Diff1(tmpPks(i)-1)-Diff1(tmpPks(i)))>mult*stdRR) && all(abs(Diff1(tmpPks(i)+1)-Diff1(tmpPks(i)))>mult*stdRR))
            % BINGO, kill it now
            currPeak = goodPeaks(tmpPks(i));
            %remPeaks(ind) = currPeak;
            remPeaks = [remPeaks currPeak];
            surrPeaks = goodPeaks(goodPeaks~=currPeak);
            prevPeak = goodPeaks(tmpPks(i)-1);
            nextPeak = goodPeaks(tmpPks(i)+1);
            p = polyfit(1:length(surrPeaks), surrPeaks, 3);
            susPos = floor(polyval(p, tmpPks(i)-1));
            tmp = prevPeak + floor((nextPeak - prevPeak)/2);
            
            if(all(abs(tmp - susPos) < mult*stdRR))
                pos = tmp;
            else
                pos = tmp; % it looks like I changed it for some reason, it works, don't touch it!
                %             pos = susPos;
            end
            
            [qrs, maxInd] = getQRSComplex(fetSignal, pos, 0, 1);
            %addPeaks(ind) = maxInd;
            addPeaks = [addPeaks; maxInd];
            
            ind = ind+1;
        end
    end
    
    for i=ind-1:-1:1 % don't change it!
        goodPeaks(goodPeaks==remPeaks(i)) = [];
    end
    goodPeaks = sort([goodPeaks addPeaks']);
    
    
    %% Find mispositioning
    Diff1 = diff(goodPeaks);
    Diff2 = diff(Diff1);
    [vv, tmpPks] = findpeaks(abs(Diff2));
    tmpPks = tmpPks+1;
    MIN_CORR_COEFF = 0.8;
    shortTemp = getTemplate(fetSignal, goodPeaks, getQRSTemplateSize(1));
    [val, maxTempInd] = max(abs(shortTemp));
    bin = diff(abs(shortTemp)>0.3*val);
    raiseInd = find(bin==1);
    fallInd = find(bin==-1);
    [ind_raise, closestVal_raise, Diff] = findClosest(raiseInd, maxTempInd);
    [ind_fall, closestVal_fall, Diff] = findClosest(fallInd, maxTempInd);
    if(ind_raise==ind_fall)
        wid = 2*abs(raiseInd(ind_raise) - fallInd(ind_fall))+1;
        winStrt = maxTempInd-floor(wid/2);
        if(winStrt<1)
            winStrt = 1;
        end
        winEnd = maxTempInd+floor(wid/2);
    else
        wid = 25;
        winStrt = maxTempInd-floor(wid/2);
        if(winStrt<1)
            winStrt = 1;
        end
        winEnd = maxTempInd+floor(wid/2);
    end
    ind=1;
    % coder
    %clear addPeaks remPeaks
    addPeaks = [];
    remPeaks = [];
%     for ii=1:10
%     remPeaks = [remPeaks ii];
%     end
    for i=1:length(tmpPks)
        temp_here_13 = abs(Diff1(tmpPks(i)-1)-Diff1(tmpPks(i)))>mult*stdRR;
        if(all(temp_here_13(:)))
            if(Diff2(tmpPks(i)-1)<0)
                % the one before is higher, this means that peak is close to the next peak
                prevPeak = goodPeaks(tmpPks(i)-1);
                nextPeak = goodPeaks(tmpPks(i)+1);
                susPeakPos = prevPeak + floor((nextPeak - prevPeak)/2);
                [qrs, maxInd] = getQRSComplex(fetSignal, susPeakPos, 0, 1);
                [cor, lag] = xcorr(shortTemp(winStrt:winEnd), qrs(winStrt:winEnd), 'coeff');
                corCoef = max(cor);
                corLag = lag(round(end/2));
                if(corCoef>MIN_CORR_COEFF)
                    susPeakPos = susPeakPos - corLag;
                    
                    remPeaks = [remPeaks; goodPeaks(tmpPks(i))];
                    addPeaks = [addPeaks; susPeakPos];
                    %remPeaks(ind) = goodPeaks(tmpPks(i));
                    %addPeaks(ind) = susPeakPos;
                    
                    ind = ind+1;
                end
            else
                prevPeak = goodPeaks(tmpPks(i)-1);
                nextPeak = goodPeaks(tmpPks(i)+1);
                susPeakPos = prevPeak + floor((nextPeak - prevPeak)/2);
                [qrs, maxInd] = getQRSComplex(fetSignal, susPeakPos, 0, 1);
                [cor, lag] = xcorr(shortTemp(winStrt:winEnd), qrs(winStrt:winEnd), 'coeff');
                [corCoef, ii] = max(cor);
                corLag = lag(ii);
                if(corCoef>MIN_CORR_COEFF)
                    susPeakPos = susPeakPos - corLag;
                    remPeaks = [remPeaks; goodPeaks(tmpPks(i))];
                    addPeaks = [addPeaks; susPeakPos];
                    
                    %remPeaks(ind) = goodPeaks(tmpPks(i));
                    %addPeaks(ind) = susPeakPos;
                    ind = ind+1;
                end
                % the one before is lower, this means that peak is close to the prev peak
            end
        end
    end
    
    for i=ind-1:-1:1 % don't change it!
        goodPeaks(goodPeaks==remPeaks(i)) = [];
    end
    goodPeaks = sort([goodPeaks addPeaks']);
    resPeaks = goodPeaks;
    
else
    %% Alright, now lets find bursts!
    % here scan each peak and ask it how it is going?
    counter = 1;
    maxCount = length(goodPeaks);
    globSign = sign(median(fetSignal(goodPeaks)));
    
    startInd = 1;
    while(counter<maxCount)
        % Pre-calcs
        RRC = diff(goodPeaks);
        nNumOfPeaks = length(goodPeaks);
        %spikes = RRC - medfilt1(RRC, 3);
        spikes = RRC - fastmedfilt1d(RRC, 3)';
        inds = find(abs(spikes)>0.08*meanRR, 1);
        
        if(isempty(inds) || startInd>=length(goodPeaks))
            % Fantastic, a banana is saved
            break; % Upper while loop
        end
        
        % Peaks scanner
        for iPeak = startInd:length(goodPeaks)-1
            if(all(abs(spikes(iPeak))<0.1*meanRR))
                % Cool, do nothing. (Seems as you...)
            else
                if(spikes(iPeak)<0)
                    if(iPeak==1)
                        if((iPeak+1<=length(spikes)) && all(abs(spikes(iPeak+1))<0.05*meanRR))
                            currPeak = goodPeaks(iPeak+1) - meanRR;
                            if(all(currPeak>1))
                                goodPeaks(iPeak) = refinePeaksPos(fetSignal, currPeak, .5);
                            else
                                goodPeaks(iPeak) = [];
                            end
                        else
                            startInd = startInd + 1;
                            break;
                        end
                    elseif(iPeak<nNumOfPeaks-1)
                        % Find wosh wosh areas (very noisy areas, couldn't find a better name for it)
                        strtI = max(iPeak-1, 1);
                        endI = min(iPeak+5, nNumOfPeaks-1);
                        localSpikes = spikes(strtI:endI);
                        if(~isempty(localSpikes))
                            if(sum(abs(localSpikes)>0.1*meanRR) / length(localSpikes)>0.3);
                                startInd = iPeak + 1;
                                break; % lower for loop
                            end
                        end
                        
                        if((iPeak+1<=length(spikes)) && all(spikes(iPeak+1)>0.1*meanRR))
                            % zig-zag
                            % Dingo, the before peaks are perfect, Don't touch them!
                            % Update the goodPeaks array and break the current for loop
                            beforeRR = RRC(iPeak-1);
                            temp_here_1 = abs(spikes(iPeak+2))<0.025*meanRR;
                            if(iPeak<nNumOfPeaks-3 && all(temp_here_1))
                                afterRR = RRC(iPeak+2);
                            else
                                afterRR = meanRR;
                            end
                            currRR = round((beforeRR + afterRR)/2);
                            goodPeaks(iPeak+1) = refinePeaksPos(fetSignal, goodPeaks(iPeak) + currRR, .5);
                            
                        else
                            % The next peak is either good or as pad as this peak, use a polygraph!
                            % Check the next-next peak
                            onlyThis = 0;
                            if(iPeak<nNumOfPeaks-3)
                                if((iPeak+2<=length(spikes)) && all(spikes(iPeak+2)>0.1*meanRR))
                                    % Two bads, correct both, (you can kill them, no one will know)
                                    beforeRR = RRC(iPeak-1);
                                    temp_here_2 = abs(spikes(iPeak+3))<0.025*meanRR;
                                    if(iPeak<nNumOfPeaks-4 && all(temp_here_2))
                                        afterRR = RRC(iPeak+3);
                                    else
                                        afterRR = meanRR;
                                    end
                                    
                                    currRR = round((beforeRR + afterRR)/2);
                                    goodPeaks(iPeak+1) = refinePeaksPos(fetSignal, goodPeaks(iPeak) + currRR, .5);
                                    goodPeaks(iPeak+2) = refinePeaksPos(fetSignal, goodPeaks(iPeak) + 2*currRR, .5);
                                else
                                    onlyThis = 1;
                                end
                            else
                                onlyThis = 1;
                            end
                            % Change only this peak, it looks like a false positive
                            if(onlyThis)
                                if(iPeak-1>0)
                                    beforeRR = RRC(iPeak-1);
                                else
                                    beforeRR = RRC(iPeak);
                                end
                                
                                afterRR = meanRR;
                                currRR = round((beforeRR + afterRR)/2);
                                goodPeaks(iPeak+1) = refinePeaksPos(fetSignal, goodPeaks(iPeak) + currRR, .5);
                            end
                        end
                    else
                        % The last peak
                        warning('TBU'); % just ignore it for now,...
                        startInd = startInd + 1;
                        break;
                    end
                elseif(spikes(iPeak)>0)
                    if(iPeak==1)
                        if((iPeak+1<=length(spikes)) && all(abs(spikes(iPeak+1))<0.05*meanRR))
                            currPeak = goodPeaks(iPeak+1) - meanRR;
                            if(all(currPeak>1))
                                goodPeaks(iPeak) = refinePeaksPos(fetSignal, currPeak, .5);
                            else
                                goodPeaks(iPeak) = [];
                            end
                        else
                            startInd = startInd + 1;
                            break;
                        end
                    elseif(iPeak<nNumOfPeaks-1)
                        % Find wosh wosh areas (very noisy areas)
                        strtI = max(iPeak-5, 1);
                        endI = min(iPeak+5, nNumOfPeaks-1);
                        localSpikes = spikes(strtI:endI);
                        if(~isempty(localSpikes))
                            if(sum(abs(localSpikes)>0.1*meanRR) / length(localSpikes)>0.3);
                                startInd = iPeak + 1;
                                break; % lower for loop
                            end
                        end
                        if((iPeak+1<=length(spikes)) && all(spikes(iPeak+1)<-0.1*meanRR))
                            % zig-zag
                            % Dingo, the before peaks are perfect, Don't touch them!
                            % Update the goodPeaks array and break the current for loop
                            beforeRR = RRC(iPeak-1);
                            if(iPeak<nNumOfPeaks-3 && all(abs(spikes(iPeak+2))<0.025*meanRR))
                                afterRR = RRC(iPeak+2);
                            else
                                afterRR = meanRR;
                            end
                            currRR = round((beforeRR + afterRR)/2);
                            goodPeaks(iPeak+1) = refinePeaksPos(fetSignal, goodPeaks(iPeak) + currRR, .5);
                            
                        else
                            % The next peak is either good or as pad as this peak
                            % Check the next-next peak
                            onlyThis = 0;
                            if(iPeak<nNumOfPeaks-3)
                                if(all(spikes(iPeak+2)<-0.1*meanRR))
                                    % Two bads, correct both
                                    beforeRR = RRC(iPeak-1);
                                    temp_here_5 = abs(spikes(iPeak+3))<0.025*meanRR;
                                    if(iPeak<nNumOfPeaks-4 && all(temp_here_5))
                                        afterRR = RRC(iPeak+3);
                                    else
                                        afterRR = meanRR;
                                    end
                                    
                                    currRR = round((beforeRR + afterRR)/2);
                                    goodPeaks(iPeak+1) = refinePeaksPos(fetSignal, goodPeaks(iPeak) + currRR, .5);
                                    goodPeaks(iPeak+2) = refinePeaksPos(fetSignal, goodPeaks(iPeak) + 2*currRR, .5);
                                else
                                    onlyThis = 1;
                                end
                            else
                                onlyThis = 1;
                            end
                            % Change only this peak, it looks like a false positive
                            if(onlyThis)
                                if(iPeak-1>0)
                                    beforeRR = RRC(iPeak-1);
                                else
                                    beforeRR = RRC(iPeak);
                                end
                                afterRR = meanRR;
                                currRR = round((beforeRR + afterRR)/2);
                                goodPeaks(iPeak+1) = refinePeaksPos(fetSignal, goodPeaks(iPeak) + currRR, .5);
                            end
                        end
                    else
                        % The last peak
                        warning('TBU');
                        startInd = startInd + 1;
                        break;
                    end
                else
                    % Dead end, increment startInd
                    startInd = startInd + 1;
                    break; % lower for loop
                end
                if(iPeak>1)
                    startInd = iPeak-1; % No need to scan from the start,
                else
                    startInd = 1;
                end
                break;
            end
        end
        counter = counter + 1;
    end
    resPeaks = goodPeaks;
end
if(length(resPeaks) == 1)
    resPeaks = -1;
end

return;

% Ok, now some self check
before = diff(goodPeaks_save);
after = diff(goodPeaks);
err_before = norm(before - medfilt1(before, 3));
err_after = norm(after- medfilt1(after, 3));
if(err_after<err_before) % the enegry of the spikes should decrease..
    resPeaks = goodPeaks;
else
    resPeaks = goodPeaks_save;
end
