function pkRMS = peak2rms_win(sig, len)
%#codegen

LEN = length(sig) - len;
pkRMS = zeros(LEN, 1);
inds = 1:len;
for i=1:LEN
    pkRMS(i) = peak2rms(sig(inds));
    inds = inds + 1;
end