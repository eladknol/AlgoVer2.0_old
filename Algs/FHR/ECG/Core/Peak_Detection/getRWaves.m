function [R_Waves, RelValidSigs, bestLead, bestLeadPeaks, leadsInclude] = getRWaves(signals, method, config, procSig)
% find R-waves in the signal using a specified method

RelValidSigs = 0;
switch(method)
%     case 'direct',
%         R_Waves = findRWavesDirect(signals, config);
%     case 'wavelet',
%         R_Waves = findRWavesWavelet(signals);
%     case {'PCA','ICA'},
%         [R_Waves, RelValidSigs, bestLead, bestLeadPeaks] = findRWavesPCA(signals, config);
    case {'final'},
        [R_Waves, RelValidSigs, bestLead, bestLeadPeaks, leadsInclude] = findRWaves(signals, config);
    case {'2nd'}
        [R_Waves, RelValidSigs, bestLead, bestLeadPeaks, leadsInclude] = findRWaves(signals, config, procSig);
    otherwise
        error('Method is not supported.');
end
