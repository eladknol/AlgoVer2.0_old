function [pkMean, numPos, numNeg] = peak2mean(sig, len)
%#codegen

LEN = length(sig) - len;
pkMean = zeros(LEN, 1);
inds = 1:len;
numPos = 0;
numNeg = 0;
for i=1:LEN
    mxPos = max(sig(inds));
    mxNeg = -min(sig(inds));
    mxVal = max(mxPos, mxNeg);
    pkMean(i) = mxVal/(10+mean(sig(inds)));
    numPos = numPos + (mxVal==mxPos);
    numNeg = numNeg + (mxVal==mxNeg);
    inds = inds + 1;
end