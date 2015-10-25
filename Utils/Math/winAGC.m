function sigAGC = winAGC(signal, config, nNumOfPredPeaks)

% perform windowed AGC on a signal
ENG = zeros(0,1);
coder.varsize('ENG',[10000 1],[1 0]);
noiseThresh = 0;
startInd = 1;
endInd = 1;

if(nargin>2)
    winSize = 50;
    for win = 1:length(signal)/winSize
        startInd = 1 + (win-1)*winSize;
        endInd = win * winSize;
        eng = signal.^2;
        ENG(win) = sum(eng(startInd:endInd));
    end
    ENG = sort(10*log10(ENG), 'descend');
    ENG = ENG(1:min(floor(nNumOfPredPeaks*2), length(ENG)));
    noiseThresh = ENG(end);
    winSize = 50;
    
    % For coder
    sigAGC = zeros(length(startInd:endInd)+1, 1);
    
    for win = 1:length(signal)/winSize
        startInd = 1 + (win-1)*winSize;
        endInd = win * winSize;
        eng = signal.^2;
        sigAGC(startInd:endInd) = autoGC(signal(startInd:endInd), 1, winSize, noiseThresh);
    end
else
    winSize = 50;
    if(nargin==2)
        if(isfield(config,'winSize'))
            winSize = config.winSize;
        end
    end
    % For coder
    win =1;
    startInd = 1 + (win-1)*winSize;
    endInd = win * winSize;
    sigAGC = zeros(length(startInd:endInd)+1, 1);
    
    for win = 1:length(signal)/winSize
        startInd = 1 + (win-1)*winSize;
        endInd = win * winSize;
        eng = signal.^2;
        sigAGC(startInd:endInd) = autoGC(signal(startInd:endInd), 1, winSize);
    end
end

if(nargin==2)
    if(isfield(config,'isNorm'))
        if(config.isNorm)
            sigAGC = sigAGC/max(abs(sigAGC));
        end
    end
end
