function [clusterID, clusterCenter] = kmedoids_ext(dataVec, nG, nReps)

% Use external methods for runnign the kmedoid clustering algo
% This function should be used for code generation only.
% If you with to use it, MEX it and then use it.

ifound = int32(0);
error = 0;
coder.varsize('clusterID', [1000, 1], [1 0]); % #CODER_VARSIZE
coder.varsize('clusterCenter', [20, 1], [1 0]); % #CODER_VARSIZE

clusterID = int32(0*(1:length(dataVec))');

% Call the external C code, This is not a library! it is a C code!!!
coder.ceval('kmedoids_wrapper', coder.ref(dataVec), int32(length(dataVec)), int32(nG), int32(nReps), 'e', coder.ref(ifound), coder.ref(error), coder.ref(clusterID));

% Get the centers
clusterCenter = zeros(nG, 1);

clusterID = clusterID + int32(1); % This is done due to the difference in MATLAB<->C indexing. In C, clusterID can hav a value of 0, 
% which in the generated code and since it is not an index is not traslated properly into proper indexing

inddd = 1;
for i=1:length(clusterID)    
    if(isempty(find(int32(clusterCenter) == clusterID(i), 1)))
        clusterCenter(inddd) = clusterID(i);
        inddd = inddd+1;
    end
    
    if(inddd==length(clusterCenter)+1)
        break;
    end
end

clusterIDSave = clusterID;
for i=1:length(clusterCenter)
    clusterID(clusterIDSave == clusterCenter(i)) = i;
end

% Some times this falls, needs to check why!
% happens when clusterCenter==0

clusterCenter = dataVec(clusterCenter); % #CODER_VALIDATE, #CODER_TEST

