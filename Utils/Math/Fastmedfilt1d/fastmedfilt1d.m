function m = fastmedfilt1d(x, W)
% Very fast implementation of the classical 1D running median filter of
% window size W (odd). Uses a quick selection method to obtain the median
% of each sliding window. 

% Input parameter case handling
x = x(:);

% Ensure that W is odd
W2 = floor(W/2);

% Call fast MEX core routine
if(coder.target('matlab'))
    
    xic = zeros(0, 1);
    coder.varsize('xic', [1000 1], [1 0]); % #CODER_VARSIZE
    xic = zeros(W2, 1);
    xfc = xic;
    
    xic = xic(:);
    xfc = xfc(:);
    m = fastmedfilt1d_core(x, xic, xfc, W2);
else
    % code replacement: openFolder(which ('fastmedfilt1d.m'))
    m = fastmedfilt1d_core_in_c(x, W2);
end
