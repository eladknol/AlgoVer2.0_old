function SNR = getSNR(signals, method, varargin)

% SNR = getSNR([],[], 'removeStruct', removeStruct, 'fQRS', fQRS)

% For ECG

nNumOfSigs = min(size(signals));

if(nNumOfSigs>1)
    for (iSig = 1:nNumOfSigs)
        snrEstimate(iSig) = getSNR(signals(iSig,:), method, varargin); %#ok<MFAMB>
    end
end

% Parse additional inputs
opts = struct;
if(~isempty(varargin))
    if(mod(size(varargin),2))
        error('ERR:ID', 'The additional inputs must be Name-Value pairs')
        return;
    end
    
    for i=1:2:numel(varargin)
        opts.(varargin{i}) = varargin{i+1};
    end
end

if(isempty(signals))
    matData = [];
    fetData = [];
    
    if(isfield(opts, 'removeStruct'))
        matData = opts.removeStruct.matData;
        if(isfield(opts.removeStruct, 'fetData'))
            fetData = opts.removeStruct.fetData;
        end
    else
        error('ERR:ID', 'Not supported yet');
    end
    
else
    error('ERR:ID', 'Not supported yet');
end

%% Estimate the maternal SNR
% Non maternal signals are noise (including the fetal signals)
if(isempty(matData) || isempty(fetData))
    return;
end

if(size(matData, 1)<size(matData, 2))
    matData = matData';
end
if(size(fetData, 1)<size(fetData, 2))
    fetData = fetData';
end

SNR.mat = 20*log10(rms(matData)./rms(fetData));

%% Estiamte the fetal SNR
% You need the fetal peaks in order to perform this estimation
fQRS = [];
if(isfield(opts, 'fQRS'))
    fQRS = opts.fQRS;
else
    error('ERR:ID', 'You need the fetal peaks in order to perform this estimation');
end

if(isempty(fQRS))
    return;
end

% Ok, 1st step is to apply maternal ECG elimination to the fetal data 
removeStruct_fetal = opts.removeStruct;
removeStruct_fetal.filtData = opts.removeStruct.fetData;
removeStruct_fetal.mQRS_struct.pos = fQRS.fQRS_struct.fQRS;
removeStruct_fetal = doRemove(removeStruct_fetal);

newFetData.data = removeStruct_fetal.matData;
newFetData.noise = removeStruct_fetal.fetData;

if(size(newFetData.data, 1)<size(newFetData.data, 2))
    newFetData.data = newFetData.data';
end
if(size(newFetData.noise, 1)<size(newFetData.noise, 2))
    newFetData.noise = newFetData.noise';
end

SNR.fet = 20*log10(rms(newFetData.data)./rms(newFetData.noise));