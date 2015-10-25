function mxPos = maxWin(sig, len)
%#codegen

LEN = length(sig) - len;
pkMean = zeros(LEN, 1);
inds = 1:len;
numPos = 0;
numNeg = 0;
for i=1:LEN
    mxPos(i) = max(sig(inds));
    inds = inds + 1;
end