function STFT = stft(sig, winLen, overlap, nfft, Fs, cutOffFreq, plotLen, func, plots)

% STFT = stft(sig, winLen, overlap, nfft, Fs, cutOffFreq)
% Short time Fourier transform
% Inputs:
%       sig: Time signal
%       winLen: length of the window (default: 128)
%       overlap: windows overlap in percent (default: 0.5 - for 50%)
%       nfft: Number of fft points (default: 1024)
%       Fs: Sampling requency of the input signal (default: 1000 Hz)
%       cutOffFreq: The upper limit of the frequencies (default: Fs/2 Hz)

% Written by MkM
% Last updated: 01/01/2015

%% Check
if(nargin<2), winLen     = 128 ; end
if(nargin<4), overlap    = 0.5 ; end
if(nargin<3), nfft       = 1024; end
if(nargin<5), Fs         = 1000; end
if(nargin<6), cutOffFreq = Fs/2; end
if(nargin<7), plotLen    = 2*Fs; end
if(nargin<8), func       = '';   end
if(nargin<9), plots      = 2;    end


if(isempty(winLen))     , winLen     = 128 ; end
if(isempty(nfft))       , nfft       = 1024; end
if(isempty(overlap))    , overlap    = 0.5 ; end
if(isempty(Fs))         , Fs         = 1000; end
if(isempty(cutOffFreq)) , cutOffFreq = Fs/2; end
if(isempty(plotLen))    , plotLen    = 2*Fs; end
if(isempty(func))       , func       = ''; end
if(isempty(plots))      , plots      = 2; end

%% Calc
overlapSamples = round(overlap.*winLen);
nNumOfWins = floor(length(sig)/overlapSamples);

inds = 1:winLen;
STFT(nNumOfWins, nfft/2) = 0;
for iWin=1:nNumOfWins-2*overlapSamples
    ft = fft(sig(inds), nfft);
    res = ft.*conj(ft);
    STFT(iWin, :) = res(1:nfft/2);
    inds = inds + overlapSamples;
end

freq = Fs/2*linspace(0, 1, nfft/2+1);
STFT = STFT(:, freq<cutOffFreq);

%% Plot
if(nargout)
    return;
end
f,
% Signal in time
ax(1) = subplot(plots,1,1);
inds = 1:plotLen;
plot( (1:length(inds))/Fs, sig(inds)); grid on
title('Time signal')
xlabel('Time [Sec]');

if(plots==1)
    return;
end
% STFT
ax(2) = subplot(plots,1,2);
STFT = [nan(floor(overlapSamples/2)-1, size(STFT,2)); STFT; nan(floor(overlapSamples/2), size(STFT,2))];
x = 1:round(plotLen/overlapSamples);
y = 1:size(STFT,2);
if(isempty(func))
    plotMat = STFT(x,:)';
else
    plotMat = eval([func '(STFT(x,:)'')' ';']);
end
imagesc(x, y, plotMat); hold on
title('STFT')
xlabel(['Window [' num2str(winLen) ', ' num2str(overlapSamples) ']']);
ylabel('Frequency [Hz]');

if(plots==2)
    return;
end
% Freq bands energy
ax(3) = subplot(plots,1,3);
freqWinLen = 10;
inds = 1:freqWinLen;
nn = size(STFT, 2)-freqWinLen;
inc = 1;
clear res;
for freqWin = 1:nn
    res(:, freqWin) = sum(plotMat(inds, :));
    inds = inds + inc;
end
imagesc(res(:,:)')
title('Freq bands energy')
xlabel(['Window [' num2str(winLen) ', ' num2str(overlapSamples) ']']);
ylabel(['Window [' num2str(freqWinLen) ', ' num2str(inc) ']']);

