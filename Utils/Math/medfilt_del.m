function res = medfilt_del(signal, winLen)

len = length(signal)-winLen;
res = zeros(size(signal));
for i=1:len
    res(i) = median(signal(i:i+99));
end