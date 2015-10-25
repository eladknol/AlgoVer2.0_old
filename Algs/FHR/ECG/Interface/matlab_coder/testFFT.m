
time = linspace(0,100,5000);
sig1 = sin(time) + rand(size(time));

% xcorr_muha(sig1, sig1)
compareFFT(sig1);
compareFFT_mex(sig1);
