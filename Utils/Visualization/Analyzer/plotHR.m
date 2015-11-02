function plotHR(pks, Fs)

if(nargin<2)
    Fs = 1e3;
end
plotf(60./diff(pks)*Fs);

