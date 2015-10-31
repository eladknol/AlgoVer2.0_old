function SignalStruct = PlotSignalChannels(inputStruct,OutStruct,Sno,ch)

Signal=inputStruct.data(OutStruct.resData(Sno).StartSample:OutStruct.resData(Sno).EndSample,inputStruct.meta.MICchannels);
N1=20001;
N2=30000;


figure
SubPlt=1;

Fs=OutStruct.Fs;

[SignalStruct]=Signal2BPsignals(Signal,Fs);
N=length(SignalStruct);

L=length(SignalStruct(1).filtsignal);
t=(0:L-1)/Fs;
for k=1:N
    h(k)=subplot(4,1,SubPlt);
    plot(t(N1:N2),SignalStruct(k).filtsignal((N1:N2),ch));axis tight;
    title(['Freqs: ' ,num2str(SignalStruct(k).BandPass(1)),' - ',num2str(SignalStruct(k).BandPass(2)),'Hz']);
    if SubPlt<4
        SubPlt=SubPlt+1;
    else
       
        if k<N
        figure;
        SubPlt=1;
        end
    end
end
 linkaxes(h,'x');        
        
    
