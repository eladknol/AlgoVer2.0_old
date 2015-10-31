function [RRestim,Score,BaseLine]=RRestimationAndCalcScore(varargin);
%  [RRestim,Score]=RRestimationAndCalcScore(RR,usevalidation);
%Inputs:
%RR - a vector of the RR time interval
%Varargin: in pairs: 
% RR - a vector of the RR time interval
%Locations - Locations of beats detected 
% 'usevalidation' true/false, 'DistFromBaseLine' true/false
%usevalidation - if to clean signal before calculating Hear Rate or use all
%RR samples.
%DistFromBaseLine - use this option to calc the score using the distance
%from the Baseline and not the from estimated RR on all signal
%
%Outputs:
%RRestim - the estimated Heart rate from the RR vector
%Score - a structure with score out put, fiels of structure are the
%components of the score and the total score in field Score.score
%'usevalidation',usevalid,'DistFromBaseLine',DistFromBase)

% OutliersThresh=0.15;
% HistBinNumForRRestim=200;
% MedWinLenForBaseLine=20;
SystemAudioParams; % load system parameters
if nargin<2
    
    error('Not enough inpout args')
else
    
    ParseArgs( varargin );
end

if ~exist('usevalidation','var')
    usevalidation=true;
end

if ~exist('DistFromBaseLine','var')
    DistFromBaseLine=true;
end

if ~exist('Fs')
    Fs=1000;
end

if ~exist('RR','var')
    if ~exist('Locations')
        error(' Must provide as input RR vector or Locations Vector')
    else
        RR=diff(Locations)/Fs;
    end
end       


if usevalidation
    valid=CleanSignalOutlieares(RR);
    RR=RR(valid);
    Score.NumOfOutliers=sum(~valid)/length(valid);
    
else
    
    Score.NumOfOutliers=NaN;
end


if isempty(RR)
    RRestim=[999];
    if nargout>1
        Score.MeanfromRR=[999];
        Score.STDfromRR=[999];
        Score.OverbyMoreThen15per=[999];
        Score.score=[999];
    end
else
    
%     if length(RR)>HistBinNumForRRestim*2;
%     [N,E]=histcounts(RR,HistBinNumForRRestim);
%     [mx,ind]=max(N);
%     RRestim=sum(E(ind:ind+1))/2;
%     else
%         [N,E]=histcounts(RR);
%     [mx,ind]=max(N);
%     RRestim=E(ind);
%     end
     [N,E] = histcounts(60./RR,'BinLimits',[60,180],'BinMethod','integers');
    [mx,ind]=max(medfilt1(N,7));
    RRestim=60/E(ind);
    
    if DistFromBaseLine
        BaseLine=medfilt1(RR,MedWinLenForBaseLine);
    elseif exist(RRestimIn,'var')
        BaseLine=RRestimIn;
    else
        BaseLine=RRestim;
    end
    
    MeanfromRR=mean(sqrt((RR-RRestim).^2));
    STDfromRR=std(abs(RR-RRestim));
    OverbyMoreThenNper=100*sum((abs(RR-BaseLine))>RRestim*OutliersThresh)/length(RR);
    
    if nargout>1
        Score.MeanfromRR=MeanfromRR;
        Score.STDfromRR=STDfromRR;
        Score.OverbyMoreThen15per=OverbyMoreThenNper;
        %         Score.score=sqrt(sum([MeanfromRR, STDfromRR, OverbyMoreThen15per/100].^2)/3);
        Score.score=rms([MeanfromRR, STDfromRR, OverbyMoreThenNper/100]);
        
        
    end
    Score.RR=RR;
end
end