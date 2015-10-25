function mTwave_struct = getMaternalTPos(detectorStruct, mQRS_struct) 
%#codegen

config.Order = 12;
config.Fc = detectorStruct.config.mTwave.filters.low.Fc/(detectorStruct.config.Fs/2);
tData = applyFilter('LOW_BUTTER', detectorStruct.signals, config);

detectorStruct.config.mTwave.Fs = detectorStruct.config.Fs;
susPos = [];
mTwave_struct.succ = 0;
mTwave_struct.pos = [];

pks = zeros(detectorStruct.config.nNumOfChs, length(mQRS_struct.pos));
[temp, siz] = getECGTemplate([], mQRS_struct.pos);
template = zeros(siz);
coder.varsize('template', [detectorStruct.config.nNumOfChs, max(siz)], [1 1]);

for i=1:detectorStruct.config.nNumOfChs
    pks(i, :) = refinePeaksPos(detectorStruct.signals(i,:), mQRS_struct.pos);
    tData(i, :) = tData(i,:)*sign(mean(detectorStruct.signals(i, pks(i,:))));
    template(i, :) = getECGTemplate(tData(i,:), pks(i,:));
    
    cl = clt_mex(template(i,:), detectorStruct.config.mTwave);
    inds = diff(cl>1*mean(cl(102:end)));
    starts = find(inds==1, 1); % -round(detectorStruct.config.mTwave.CLT.filter.winsize/2)
    ends = find(inds==-1, 1);
    
    if(isempty(starts) || isempty(ends))
        continue;
    end
    
    if (getSignalEnergy(template(i, ends(end):end))/getSignalEnergy(template(i, :))<0.1 && getSignalEnergy(template(i, ends(end):end))<0.15) % 10%
        continue;
    end
    
    CL = clt_mex(tData(i,:), detectorStruct.config.mTwave);
    inds = diff(CL>1*mean(CL(102:end)));
    starts = find(inds==1);
    ends = find(inds==-1);
    if(length(starts) ~= length(ends))
       if(starts(end)>ends(end))
           starts(end) = [];
       elseif(ends(1)<starts(1))
           ends(1) = [];
       else
           continue;
       end
    end
    intervals.onset = ends(1:end-1);
    intervals.offset = ends(1:end-1) + round((starts(2:end)-ends(1:end-1))/2);
    DIFF = intervals.offset - intervals.onset;
    inds = find(DIFF<(mean(DIFF)/2));
    intervals.onset(inds) = [];
    intervals.offset(inds) = [];
    
    inds = [intervals.onset;intervals.offset]' - round(detectorStruct.config.mTwave.CLT.filter.winsize/2);
    susPos = zeros(1, size(inds, 1));
    for ii=1:size(inds, 1)
        [val, ind] = max(tData(i, inds(ii,1):inds(ii,2)));
        susPos(ii) = ind + inds(ii,1);
    end

    mTwave_struct.succ = 1;
    break;
end

mTwave_struct.pos = susPos;