function strct_dst = structCopy(strct_src, strct_dst)

if(isstruct(strct_src) && isstruct(strct_dst))
    flds = fields(strct_src);    
    for i = 1:length(flds)
        strct_dst.(flds{i}) = strct_src.(flds{i});
    end
else
    strct_dst = struct();
end