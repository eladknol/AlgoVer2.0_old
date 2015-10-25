function res_res = scanAndDetect(sig, pks)

error('TBU');

if(median(sig(pks))<0)
    sig = -sig;
end
config.medLen = floor(length(pks)/5);
config.maLength = 13;
RRC = diff(pks);
tempRRC = medfilt1([RRC RRC RRC], config.medLen);
tempRRC = applyFilter('ma', tempRRC, config);
tempRRC = round(tempRRC(length(RRC):2*length(RRC)-1));
cumPks = cumsum([pks(1) tempRRC]);
meanRR = mean(tempRRC);

winSize = 5*1000; % 5 secs
inds = 1:winSize;
newPeaks = [];
thePeaks = [];
for iWin = 1:length(sig)/winSize
    startInd = inds(1);
    endInd = inds(end);
    
    currSig = sig(inds);
    currSig = currSig./max(abs(currSig));
    
    currMeanRR = mean(diff(cumPks( cumPks<inds(end) & cumPks>inds(1))));
    predNumOfPeaks = floor(winSize/currMeanRR);
    
    [vvs, currLocs] = findpeaks(currSig, 'MinPeakHeight', 0.1, 'MinPeakDistance', floor(0.3*currMeanRR));
    
    
    distMat = abs(bsxfun(@minus, currLocs', currLocs));
    mults = mod(distMat, currMeanRR);
    mults(mults>0.5*currMeanRR) = currMeanRR - mults(mults>0.5*currMeanRR);
    thr = 0.25*currMeanRR;
    bin = mults<thr;
    clear SCORE
    for jPeak=1:length(currLocs)
        susPeaks = currLocs(bin(jPeak,:));
        score = 0;
        for ii=1:length(susPeaks)
            [a, b, df] = findClosest(pks, startInd + susPeaks(ii));
            score = score + df;
        end
        SCORE(jPeak) = score;
        %         score1(jPeak) = abs(sum(bin(jPeak,:))-predNumOfPeaks);
        %         score2(jPeak) = mean(mults(bin(jPeak,:)));
    end
    [scr, ind] = sort(SCORE, 'ascend');
    %newPeaks = [newPeaks startInd+currLocs(round(median(double(bin(ind(1:5),:))))>0)];
    %     res_res = newPeaks;
    newPeaks = currLocs(round(median(double(bin(ind(1:5),:))))>0);
    if(1)
        vvs = currSig(newPeaks);
        currLocs = newPeaks;
        vecTemp = vvs(1) * ones(1, currLocs(1)-1);
        vec = [];
        for i=1:length(currLocs)-1
            temp = linspace(vvs(i), vvs(i+1), currLocs(i+1)-currLocs(i)+1);
            vec = [vec temp];
        end
        vec(diff(vec)==0) = [];
        vec = [vecTemp vec];
        
        df = medfilt1(1000*diff(vec), round(currMeanRR));
        binPeaks = find(abs(diff(df))>1e-6);
        binPeaks(diff(binPeaks)<=1)=[];
        counter = 0;
        
        binPeaks = [thePeaks startInd+binPeaks];
        while(counter<predNumOfPeaks)
            df = diff(binPeaks);
            reCorrect = df>1.2*currMeanRR;
            if(~any(reCorrect))
                break;
            end
            len = length(df);
            for ii = find(reCorrect)
                recorr_ind = 0;
                if(ii>1 && df(ii-1)<0.8*currMeanRR)
                    recorr_ind = ii-1;
                elseif(ii<len && df(ii+1)<0.8*currMeanRR)
                    recorr_ind = ii+1;
                else
                    if((mod(df(ii),currMeanRR)/currMeanRR)<.1)
                        % missing beat!
                        
                        addPeaks = round(binPeaks(ii):currMeanRR:binPeaks(ii+1));
                        if(length(addPeaks)<=2)
                            break;
                        end
                        addPeaks(1) = [];
                        addPeaks(end) = [];
                        binPeaks = sort([binPeaks addPeaks]);
                    end
                end
                if(recorr_ind~=0)
                    binPeaks(recorr_ind) = round(mean(binPeaks(recorr_ind + [-1 +1])));
                end
            end
            counter = counter+1;
        end
        thePeaks = binPeaks;
        %     plotWithPeaks(currSig, currLocs,1)
        %     hold on;
        %     plot(currLocs, vvs, '-.r');
    end
    inds = inds + winSize;
    res_res = thePeaks;
end
