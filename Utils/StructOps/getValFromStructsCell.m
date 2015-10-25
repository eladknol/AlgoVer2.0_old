function val = getValFromStructsCell(cellArrayOfStructs, fld, maxInd)

% Get value from a cell array of structs

if(~iscell(cellArrayOfStructs))
    val = [];
    warning('First input must be a cell array of structures');
    return;
end

if(nargin<3)
    maxInd = length(cellArrayOfStructs);
end

val(1:1) = 0;
for i = 1:maxInd
    switch(class(cellArrayOfStructs{1}.(fld))) 
        case 'double',
            val(i) = cellArrayOfStructs{i}.(fld);
        case 'struct',
            val{i} = cellArrayOfStructs{i}.(fld);
        otherwise,
            val(i) = cellArrayOfStructs{i}.(fld);
    end 
end