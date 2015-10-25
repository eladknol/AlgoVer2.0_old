function pkMean = winSum(sig, len)
%#codegen

LEN = length(sig) - len;
pkMean = zeros(LEN, 1);
inds = 1:len;
for i=1:LEN
    pkMean(i) = sum(sig(inds));
    inds = inds + 1;
end