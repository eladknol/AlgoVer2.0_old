function res = winDiff(sig, template)

inds = 1:length(template);
for i=1:length(sig) - length(template)-1
    res(i) = norm(sig(inds) - template);
    inds = inds + 1;
end