function res = winDiv(sig, template)

inds = 1:length(template);
for i=1:length(sig) - length(template)-1
    res(i) = sum(sig(inds)./template);
    inds = inds + 1;
end