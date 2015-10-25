function [mQRSPos, rel] = examineMaternalPeaks(pks, signals, bestLead, bestLeadPeaks, leadsInclude)
%#codegen

% if(numel(pks)==1)
%     mQRSPos = pks{1};
% end

mQRSPos = pks;

% IMPORTANT: the global peaks are fine-detected using the best lead
[mQRSPos, rel] = getGlobalPeaks(mQRSPos, signals, bestLead, bestLeadPeaks, leadsInclude);
