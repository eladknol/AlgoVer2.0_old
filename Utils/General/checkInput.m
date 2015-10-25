function res = checkInput(inStruct, inputRef)

flds = fieldnames(inputRef);
res1 = [];
res2 = [];
for i=1:length(flds)
    if(isfield(inStruct, flds{i}))
        if(isa(inStruct.(flds{i}), class(inputRef.(flds{i}))))
            
        else
            res2 = [res2 flds{i} ':' class(inputRef.(flds{i})) ', '];
        end
    else
        res1 = [res1 flds{i} ', '];
    end
end

if(~isempty(res1))
    res1 = ['Missing inputs::' res1(1:end-2)];
end
if(~isempty(res2))
    res2 = ['Data types not correct::' res2(1:end-2)];
end

if(isempty([res1 res2]))
    res = 1;
else
    res = [res1 res2];
end