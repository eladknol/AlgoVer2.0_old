function  filtSig = estimateNDRemovePwrlinNoise(signal, Config) %#codegen

% Remove powerline frequency by sustracting an estimation of the noise from the signal

% Calculate sin and cos arrays only once
Cos = zeros(Config.nNumOfHarmonics, Config.winSize);

Sin = Cos;
for h = 1:Config.nNumOfHarmonics
    ind = Config.Fc*h*(Config.winSize/Config.Fs);
    omega = 2*pi*ind/Config.winSize;
    w = 1:Config.winSize;
    Cos(h,w) = cos(omega*w);
    Sin(h,w) = sin(omega*w);
end

filtSig = signal;
w = 1:Config.winSize;
for i = 0:Config.winSize:length(filtSig)-Config.winSize
    for h = 1:Config.nNumOfHarmonics
        % Estimate the amplitude
        R = filtSig(w+i).*Cos(h,w);
        I = filtSig(w+i).*Sin(h,w);
        Rel = nansum(R);
        Img = nansum(I);
        % Remove powerline interferance
        filtSig(w+i) = filtSig(w+i) - (2/Config.winSize)*(Rel*Cos(h,w) + Img*Sin(h,w));
    end
end