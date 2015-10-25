function config = getAlgConfig(varargin)

config = struct();
for i=1:2:nargin-1
    inStruct.(varargin{i}) = varargin{i+1};
end

% Detect which parameters to use, 'default' or 'user'
fld = 'type';
dVal = 'default';
if(~isfield(inStruct, fld))
    inStruct.(fld) = dVal;
end

% Detect which part of the alg
fld = 'algPart';
dVal = 'all';
if(~isfield(inStruct, fld))
    inStruct.(fld) = dVal;
end


switch(inStruct.type)
    case 'default',
        str = inStruct.('algPart');
        if(ischar(inStruct.('opts')))
            opts  = ['''' inStruct.('opts') ''''];
        else
            opts = inStruct.('opts');
        end
        eval(['resConfig = get' upper(str(1)) str(2:end) 'Config(' opts ');']);
        if(exist('resConfig', 'var'))
            config = structCopy(resConfig, config);
        else
            config = -1;
        end
    case 'user',
        
    otherwise,
        config = -1;
end

config.procType = inStruct.('opts');