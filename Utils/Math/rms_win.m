function RMS = rms_win(signal, len, inc)
%#codegen 

LEN = length(signal) - len;
RMS = zeros(LEN, 1);
inds = 1:len;

for i=1:LEN
    RMS(i) = nanrms(signal(inds));
    %RMS(i) = rms_real(signal(inds));
    inds = inds + inc;
end
