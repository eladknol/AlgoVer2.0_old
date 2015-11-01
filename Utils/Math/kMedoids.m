function [groups, C] = kMedoids(vec, nG, nReps, builtin)

% This is a generic version of the kMedoids algorithm

% Batch for AWS 
global AWSFLAG;
if(isempty(AWSFLAG))
    AWSFLAG = false(1);
end
if(AWSFLAG)
    % Temp solution for the mex issues 
    builtin = true(1);
end

if(coder.target('matlab'))
    if(nargin<4)
        builtin = true(1); % use the built in matlab code in the statistics and machine learning toolbox
    end
    
    if(builtin) 
        % It is your responsibility to check whether the stats toolbox is available or not, this path assumes it does exist
        [groups, C] = kmedoids(vec, nG, 'Replicates', nReps); % Builtin matlab function
    else
        [groups, C] = kMedoids_mex(vec, nG, nReps, false(1));
    end
    
else
    %coder.ceval('free', coder.ref(nana));
    [groups, C] = kmedoids_ext(vec, int32(nG), int32(nReps));
end
