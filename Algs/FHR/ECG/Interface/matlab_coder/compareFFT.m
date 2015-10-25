function [FFT_matlab, FFT_dsp] = compareFFT(sig1)

coder.extrinsic('tic','toc','disp');

maxlag = length(sig1) - 1;
nextPow2 = 2^nextpow2(2*maxlag + 1);

sig1 = [sig1, zeros(1, nextPow2-length(sig1))];
t1 = zeros(1000,1);

for i=1:1000
    tic;
    FFT_matlab = fft(sig1, nextPow2);
    t1(i) = toc;
end

hfft = dsp.FFT('FFTLengthSource', 'Property',...
    'FFTLength', nextPow2, ...
    'FFTImplementation', 'FFTW'...
    );

t2 = zeros(1000,1);
for i=1:1000
    tic;
    FFT_dsp = step(hfft, sig1');
    t2(i) = toc;
end

disp([mean(t1) mean(t2)])
