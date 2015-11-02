function plotTimeSig(sig, Fs, timeProps, figHandle)

if(nargin<4)
    figure;
else
    figure(figHandle);
end

if(nargin<3)
    timeProps.start = 0;
    timeProps.end = length(sig)/Fs;
end

if(isempty(timeProps))
    timeProps.start = 0;
    timeProps.end = length(sig)/Fs;
end

timeSer = linspace(timeProps.start, timeProps.end, length(sig));

plot(timeSer, sig);
grid on;

xlabel('Time [Sec]');
ylabel('Amp [V]');

% ylim(1.5*[min(sig) max(sig)])
xlim([timeProps.start, timeProps.end*1.1])