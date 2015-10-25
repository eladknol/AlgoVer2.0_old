data = rand(10, 1);
% 
% tic;
% [g.matlab, c.matlab] = kMedoids(data, 3, 4, true(1));
% toc
% 
% tic
[g.mex, c.mex] = kMedoids_mex(data, 3, 4, false(1));
% toc



% for ii=1:length(tt)
%     g.mex(g.mex == tt(ii)) = ii;
% end





