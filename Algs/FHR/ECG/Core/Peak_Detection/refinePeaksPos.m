function pks = refinePeaksPos(signal, pks, mult)

if(nargin<3)
    mult = 1;
end
len = length(pks);

for i=[1, len]
    [qrs, loc] = getQRSComplex(signal, pks(i), 1, mult);
    pks(i) = loc;
end

for i=2:len-1
    [qrs, loc] = getQRSComplex(signal, pks(i), 0, mult);
    pks(i) = loc;
end