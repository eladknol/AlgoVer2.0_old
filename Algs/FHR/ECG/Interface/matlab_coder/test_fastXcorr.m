

sig1 = rand(10000, 1);
sig2 = rand(10000, 1);

[corrVal.matlab, lag.matlab] = xcorr_muha_lag(sig1, sig2);

%% Benchit
time.matlab(1:10)=0;
time.mex(1:10)=0;
for i=1:10
    tic;
    [corrVal.matlab, lag.matlab] = xcorr_muha_lag(sig1, sig2);
    time.matlab(i) = toc;
    tic;
    [corrVal.mex, lag.mex] = fastXcorr_mex(sig1, sig2);
%     [corrVal.mex, lag.mex] = xcorr_muha_lag_mex(sig1, sig2);
    time.mex(i) = toc;
end

disp([mean(time.mex) mean(time.matlab)]);
