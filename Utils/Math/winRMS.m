function RMS = winRMS(signal, len, ovrlap)
%ovrlap =1
%#codegen

inds = 1:len;
if(nargin<3)
    ovrlap = 0;
end

coder.varsize('RMS', [6, 120000], [1 1]); % #CODER_VARSIZE

signal = signal';
if(~ovrlap)
    steps = 1:floor(size(signal,1)/len);
    
    RMS = zeros(min(size(signal)), length(steps));
    for i = 1:floor(size(signal,1)/len)
        RMS(:,i) = rms(signal(inds,:));
        inds = inds + len;
    end
else
    inds = 1:len;
    if(ovrlap==1)
        inc = 1;
    else
        inc = floor((1-ovrlap)*len);
    end
    signal = signal';
    if(any(isnan(signal)))
        RMS = rms_win(signal, len, inc);
    else
        if(coder.target('matlab'))
            RMS = rms_win_mex(signal, len, inc);
        else
            RMS = rms_win(signal, len, inc);
        end
    end
end
