function res = reDetectPeaks(pks, fetSignal, inConfig)
%#codegen

dff = diff(pks);
pks(dff==0) = [];

pks = refinePeaksPos(fetSignal, pks);
pks = pks(:)';
maxPredHR = 200;
maxLen = length(fetSignal);
config = inConfig;
config.medLen = floor(length(pks)/5);
config.maLength = 13;
RRC = diff(pks');
% tempRRC = medfilt1([RRC RRC RRC], config.medLen);
tempRRC = fastmedfilt1d([RRC RRC RRC], config.medLen);
[sts, tempRRC] = applyFilter('ma', tempRRC, config);
tempRRC = tempRRC(length(RRC):2*length(RRC)-1);

meanRR = mean(tempRRC);

theoNumOfPeaks = length(fetSignal)/meanRR;

if(coder.target('matlab'))
    
    nG = 3;
    gmModel = fitgmdist(RRC, nG);
    clust = cluster(gmModel, RRC);
    
    % isPlot = 0;
    % if(isPlot)
    %     plotf(tempRRC); hold on;
    %     plot(RRC, 'ok');
    %     opts = 'rgb';
    %     for i=1:nG
    %         inds = find(clust==i);
    %         plot(inds, RRC(clust==i), ['*' opts(i)]);
    %     end
    % end
    
    Diff = tempRRC - RRC;
    df = zeros(nG, 1);
    for i=1:nG
        %inds = find(clust==i);
        df(i) = norm(Diff(clust==i));
    end
    [y, goodGroup] = min(df);
    inds = find(clust==goodGroup);
    
    % if(isPlot)
    %     plot(inds, RRC(inds), '^m');
    % end
    
    %
    susPeaksPos = [];
    goodPeaks = pks(inds+1);
    Diff = diff(goodPeaks);
    bin = Diff>1.2*meanRR | Diff<0.8*meanRR;
    for i=1:length(bin)
        if(bin(i))
            nPeaks = round(Diff(i)/meanRR);
            susPeaksPos = [susPeaksPos linspace(goodPeaks(i), goodPeaks(i+1), nPeaks+1)];
        end
    end
    goodPeaks = sort([floor(susPeaksPos) goodPeaks]);
    goodPeaks(diff(goodPeaks)==0)=[];
    goodPeaks = refinePeaksPos(fetSignal, goodPeaks);
    
    res = goodPeaks;
    
    % CODER_REMOVE
    % return;
    %
    % %% Kalman
    % % Parameters:
    % % 1 (Dist) -> next position of the fetal (R) peak
    % % 2 (Speed)-> derived from (1): Heart rate
    % % 3 (Accel)-> derived from (2): Changes in the heart rate
    % % The 3 parameters above are equivalent to the RR intervals
    %
    % RR = diff(goodPeaks);
    % meanRR = mean(RR);
    % R = cov(RR)/10;
    % PR = R/100;
    %
    % hKalman = dsp.KalmanFilter('ProcessNoiseCovariance', PR,...
    %     'MeasurementNoiseCovariance', R,...
    %     'InitialStateEstimate', meanRR,...
    %     'InitialErrorCovarianceEstimate', 1,...
    %     'ControlInputPort',false); %Create Kalman filter
    %
    % for ii=1:length(RR)
    %     noisyVal = RR(ii);
    %     estVal(ii) = step(hKalman, noisyVal);
    % end
    %
    % config.medLen = 5;
    % tempRRC = medfilt1([estVal estVal estVal], config.medLen);
    % tempRRC = applyFilter('ma', tempRRC, config);
    % tempRRC = tempRRC(length(estVal):2*length(estVal)-1);
    % %%
    %
    % peaks = getPeaks(fetSignal, 'refind', goodPeaks, theoNumOfPeaks, 0);
    % % res = -triu(bsxfun(@minus, pks', pks), 1);
    % distMat = abs(bsxfun(@minus, pks', pks));
    %
    % res = mod(distMat, meanRR);
    %
    % len = length(res);
    % nG = 5;
    % for ii=1:len
    % %     bin(ii,:) = res(ii,:)<0.3*meanRR | res(ii,:)>0.7*meanRR;
    %     [clust(ii,:), C(ii,:)] = kmeans(res(ii,:)', nG);
    %     bin = C(ii,:)<50 | C(ii,:)>350;
    %     inds = find(bin);
    %     frnds{ii} = [];
    %     for i=1:length(inds)
    %         frnds{ii} = [frnds{ii} find(clust(ii,:) == inds(i))];
    %     end
    % end
    %
    %
    % for ii=1:10:300;
    %     plotcfg = ['r', 'g', 'b', 'k', 'm'];
    %     f,
    %     for grp = 1:5
    %         hold on;
    %         plot(res(ii,clust(ii,:)==grp), ['o' plotcfg(grp)]);
    %     end
    %     waitfor(gcf);
    % end
else
    % #CODER_UPDATE
    res = pks;
end
