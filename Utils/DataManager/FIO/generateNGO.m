function succ = generateNGO(mQRS_struct, mECG, fQRS_struct, ngoFileName)

resStruct = getECGStruct4NGO(mQRS_struct, mECG, fQRS_struct);

if(isempty(resStruct))
    succ = 0;
    return;
end

if(exist(ngoFileName, 'file'))
    % Read and append
    [succ, outStruct] = readNGO(ngoFileName);
    if(succ)
        resStruct = structCopy(resStruct, outStruct);
    else
        warning('Cannot append NGO file'); % should be removed 
    end
end

[succ, outFileName] = writeNGO(ngoFileName, resStruct);
