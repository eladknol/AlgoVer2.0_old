function writeBinaryFile(fileName, data)

% data is the data structure to write to the binary file
% data.hdr : header for the binary file
% data.ecg : ECG data
% fileName = 'aaa.ngf';
fid = fopen(fileName,'w+');

if(fid>0)
    [flds, types, lengths] = getBinaryFileStructure();
    lay1Flds = fields(flds);
    for i=1:numel(lay1Flds)
        if(iscell(flds.(lay1Flds{i})))
            for j=1:numel(lay1Flds{i})
                if(isfield(data.hdr.(lay1Flds{i}), flds.(lay1Flds{i}){j}))
                    val = data.hdr.(lay1Flds{i}).(flds.(lay1Flds{i}){j});
                else
                    dType = types.(lay1Flds{i}){j};
                    dLength = lengths.(lay1Flds{i}){j};
                    switch(dType)
                        case '*char',
                            tmpVal = 'a';
                        case 'int16',
                            tmpVal = 1;
                    end
                    val = repmat(tmpVal, 1, dLength);
                end
                
                dType = types.(lay1Flds{i}){j};
                fwrite(fid, val, dType);
            end
        else
            % chech this code block ...
            if(isfield(data.hdr, flds.(lay1Flds{i})))
                val = data.hdr.(flds.(lay1Flds{i}));
            else
                dType = types.(lay1Flds{i});
                dLength = lengths.(lay1Flds{i});
                switch(dType)
                    case '*char',
                        tmpVal = 'a';
                    case 'int16',
                        tmpVal = 1;
                end
                val = repmat(tmpVal, 1, dLength);
            end
            
            dType = types.(lay1Flds{i});
            fwrite(fid, val, dType);
        end
    end
else
    disp('Cannot open file for writing.');
end