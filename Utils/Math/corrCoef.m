function res = corrCoef(vec1, vec2)

% res = max(xcorr(vec1, vec2, 'coeff'));
res = xcorr_muha(vec1, vec2);

% 
% return;
% if(length(vec1)>=50000 && runPar(1, 3) && gpuDeviceCount())
%     vec1 = gpuArray(vec1);
%     vec2 = gpuArray(vec2);
%     isGPU = 1;
% end