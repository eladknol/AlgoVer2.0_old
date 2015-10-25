function TBX = getInsTBXs(checkTBX)

tbx = ver();
for i=1:length(tbx)
    str = lower(tbx(i).Name);
    str(str == ' ' | str == '.' | str == '-' ) = '_';
    TBX.(str) = 1;
end

if(nargin)
    flds = fields(TBX);
    inc = 0;
    for i=1:length(flds)
        fld = flds{i};
        fld(strfind(fld, 'toolbox'):strfind(fld, 'toolbox')+length('toolbox')-1)=[];
        if(strfind(fld, checkTBX))
            inc = 1;
            break;
        end
    end
    TBX = inc;
else
    return;
end


% Batch for parallel toolbox
if(any(strfind(checkTBX, 'parallel')) || any(strfind(checkTBX, 'par')))
    try
        gcp('nocreate');
        TBX = TBX;
    catch
        TBX = 0;
    end
end
