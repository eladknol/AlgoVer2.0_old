function CompareSpec( s1,Fs1,s2,Fs2 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

ECG_chan=1:6;
Audio_chan=7:10;

[S1,NFFT1,f1]=getSpectrum( s1 ,Fs1 );
[S2,NFFT2,f2]=getSpectrum( s2 ,Fs2 );

figure;
ax1=subplot(2,2,1);
plot(f1,2*abs(S1(1:NFFT1/2+1,ECG_chan))) 
title('Single-Sided Amplitude Spectrum of ECG')
ylabel('|Y(f)|')

ax2=subplot(2,2,2);
plot(f1,2*abs(S1(1:NFFT1/2+1,Audio_chan))) 
title('Single-Sided Amplitude Spectrum of Audio')
ylabel('|Y(f)|')

ax3=subplot(2,2,3);
plot(f2,2*abs(S2(1:NFFT2/2+1,ECG_chan))) 
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

ax4=subplot(2,2,4);
plot(f2,2*abs(S2(1:NFFT2/2+1,Audio_chan))) 
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

linkaxes([ax1 ax2 ax3 ax4]);

end

