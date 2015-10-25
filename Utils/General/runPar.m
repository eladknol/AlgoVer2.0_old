function res = runPar(reqWorkers, procLevel)

res = getInsTBXs('parallel');

if(~nargin)
    return;
end
if(nargin<2)
    procLevel = 0;
end


% Check how many workers are needed

if(reqWorkers==1 && procLevel<3)
    % Using parallel for loops using one worker is not efficient,
    % do not use parallel if only one worker is needed,
    % use the main matlab process instead and leave the parallel workers for other jobs
    
    res = 0;
end



%% procLevels:
%   0: ignore it
%   1: File level - Run multible files in parallel
%   2: Alg Step level - Run an algorithm step in parallel (not the different steps!!) (mECG removal for the different channels for example)
%   3: inStep level - let in step procedures/functions run in parallel (kmeans for example)

% The most effecient way to to use the parallel is to run in level 1 (if applicable)
% Try to avoid inStep parallelization due to overhead 