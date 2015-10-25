function pkMean = max2min(sig, len)
%#codegen

LEN = length(sig) - len;
pkMean = zeros(LEN, 1);
inds = 1:len;
for i=1:LEN
    pkMean(i) = max(sig(inds))/(10+min(sig(inds)));
    inds = inds + 1;
end