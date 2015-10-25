function peaks = getPeaks(signal, method, predPeaks, theoNumOfPeaks, newSegInds, config)

%  Find peaks in signal
% method can be:
%             1. 'deriv' for using the 1st and 2nd derivatives
% mod: use matlab biult in function and kmeans
%             2. 'corr' for using the template correlation

% predPeaks is the predicted positions of the peaks.
% this parameter is used to build the template to be used in the
% template-correlation method

if(nargin<2)
    method = 'deriv';
end

if(strcmpi(method,'corr'))
    if(nargin<3)
        error('not_enough_inputs:noPredPeaks','I need the predPeaks positions to build a template...');
    end
end

switch(method)
%     case 'direc'
%         peaks = direcPeaks(signal); % local function
    case 'corr'
        peaks = corrPeaks(signal, predPeaks); % local function
%     case 'class'
%         peaks = classPeaks(signal, predPeaks); % local function
%     case 'refind'
%         peaks = reFindPeaks(signal, predPeaks, theoNumOfPeaks, newSegInds); % local function
end
