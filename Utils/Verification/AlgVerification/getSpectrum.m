function [S,NFFT,f]=getSpectrum(s,Fs)

L=length(s);
NFFT = 2^nextpow2(L); 
S = fft(s,NFFT)/L;
% S=periodogram(s,[],NFFT);
f = Fs/2*linspace(0,1,NFFT/2+1);

end

