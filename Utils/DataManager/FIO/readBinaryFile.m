function readBinaryFile()

fid = fopen(fileName,'r+');


if(fid>0)
    flds = getBinaryFileStructure();
    lay1Flds = fields(flds);
    for i=1:numel(lay1Flds)
        if(isstruct(lay1Flds{i}))
            lay2Flds = fields(lay1Flds{i});
            for j=1:numel(lay2Flds)
                hdr.(lay1Flds{i}).(lay2Flds{j}) = fread(fid,dSize,dType);
            end
        else
            
        end
        
    end
else
    disp('Cannot open file for writing.');
end