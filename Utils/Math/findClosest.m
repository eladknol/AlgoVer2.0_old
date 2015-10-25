function [ind, closestVal, Diff] = findClosest(vec, val, num)

%[ind, closestVal, Diff] = <strong>findClosest</strong>(vec, val)
if(nargin<3)
    num = 1;
end

ind = ones(num, 1);
Diff = zeros(num, 1);
if(num==1)
    [Diff, ind] = min(abs(vec - val));
    closestVal = vec(ind);
else
    vecTemp = abs(vec - val);
    [vecSort, inds] = sort(vecTemp, 'ascend');
    
    ind = inds(1:num);
    closestVal = vec(ind);
    Diff = vecTemp(ind);
end