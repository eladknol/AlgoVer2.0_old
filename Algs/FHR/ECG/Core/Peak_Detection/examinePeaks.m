function peaks = examinePeaks(pks, signal)
%#codegen

MAX_ACC_PEAK_SHIFT = ceil(0.1*nanmean(diff(pks{1})));
ind = 1;
if(numel(pks)==1)
    len = length(pks{1});
    for i=1:len
        [QRS, maxInd] = getQRSComplex(signal, pks{1}(i), i==1 || i==len);
        pks{1}(i) = maxInd;
    end
    peaks = pks{1};
    
elseif(numel(pks)==2)
    for i=1:length(pks{1})
        temp = abs(pks{2}-pks{1}(i))<MAX_ACC_PEAK_SHIFT;
        fInd = find(temp,1);
        if(~isempty(fInd))
            if(abs(signal(pks{1}(i)))>abs(signal(pks{2}(fInd))))
                peaks(ind) = pks{1}(i);
            else
                peaks(ind) = pks{2}(fInd);
            end
            ind = ind+1;
        end
    end
elseif(numel(pks)==3)
    for i=1:length(pks{1})
        temp2 = abs(pks{2}-pks{1}(i))<MAX_ACC_PEAK_SHIFT;
        temp3 = abs(pks{3}-pks{1}(i))<MAX_ACC_PEAK_SHIFT;
        fInd2 = find(temp2,1);
        fInd3 = find(temp3,1);
        if(~isempty(fInd2)) % >=2
            if(abs(signal(pks{1}(i)))>abs(signal(pks{2}(fInd2))))
                peaks(ind) = pks{1}(i);
            else
                peaks(ind) = pks{2}(fInd2);
            end
            if(~isempty(fInd3))
                if(abs(signal(peaks(ind)))>abs(signal(pks{3}(fInd3))))
                    peaks(ind) = pks{1}(i);
                else
                    peaks(ind) = pks{3}(fInd3);
                end
            end
            ind = ind+1;
        end
    end
    
end

peaks(peaks<0)=[];
peaks(peaks>length(signal))=[];