function [max_r,r,lag_diff_4_max_r] = CalcDetectionXcorr(comb_1,comb_2,max_lag,debug)
%CalcFetMatXcorr calculates the cross-coreelation between fetal and
%maternal S or QRS detections
%   Inputs: comb_1 - vector of fetal QRS (ECG) or S (Audio) detection.
%           comb_2 - vector of maternal QRS (ECG) or S (Audio) detection.
%           debug - flag (true or false) for plotting results
%   Output: max_r - value of maximum correlation
%           r - cross correlation result
%           lag_diff_4_max_r - shift where max value of cross correlation
%                              is

% return if one of the input vectors is empty
if all(~comb_1)|| all(~comb_2)
    max_r=[];
    r=[];
    lag_diff_4_max_r=[];
    return;
end

% calculate cross correlation between 2 vectors
[r,lags] = xcorr(comb_1,comb_2,max_lag);
r=r/sum(comb_1);

% get max and min xcorr value and offset
[max_r,i_max_r] = max(r);
[min_r,~] = min(r);
max_r=max_r-min_r;
lag_diff_4_max_r= lags(i_max_r);

% plot
if debug  
    figure;plot(lags,r);xlabel('Shift [samples]');
    title('Normalized cross correlation result');
end


