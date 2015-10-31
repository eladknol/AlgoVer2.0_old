function PlotResultMulti(AlgOut,OutStruct,fignumStart)


N=length(AlgOut);

for k=1:N
    try
    PlotResult(AlgOut{k},OutStruct.resData(k).ECG_mQRSPos,0,fignumStart+k-1);
    catch
        PlotResult(AlgOut{k},[],0,fignumStart+k-1);
    end
end