function out=FineTuneSdetectionV1_1(Locations,Signal,SlowEnvelopeWinSize,FastEnvelopeWinSize,Fs)

%FineTuneSdetectionV1_1 uses the detection of the coarse peak detection and
%corrects the detection according to RR expected and if peaks are missing
%try and find them on a faster envelope signal.
%out=FineTuneSdetection(Locations,Signal,Frame,Fs)
%Get initial S detections, fine tune and improve detections
% Inputs:
%Locations- the initial S locations
%Signal - The signal before any processing - to be used in a later stage
%Frams - the signal frame on which the detection is perfromned.
%Fs - sampling rate, to be used in a later stage.

% PeakDiscardThresh=0.05;

%% params of function
ToCloseThresh=0.1;
LstMissingRRThresh=0.5;
minDist=50e-3;
minDistSamples=round(minDist*Fs);
SystemAudioParams; % load system params;
MinRRTime=round(MinRRTime*Fs);
SlowWin1=round(SlowEnvelopeWinSize*Fs);
SlowEnvelope=filtfilt(ones(1,SlowWin1)/(SlowWin1),1,abs(hilbert(Signal)));
out.SlowEnvelope=SlowEnvelope;
FastWin1=round(FastEnvelopeWinSize*Fs);
FastEnvelope=filtfilt(ones(1,FastWin1)/(FastWin1),1,abs(hilbert(Signal)));
out.FastEnvelope=FastEnvelope;


%%estimate avarege RR interval

RR=diff(Locations);


[N,E]=histcounts(RR,20);
[mx,ind]=max(N);
RRavg=sum(E(ind:ind+1))/2;

ValidRR=abs(RR-RRavg)<ToCloseThresh*RRavg;
if sum(ValidRR)<10 %if not enough valid RR take all RR and use RRavg calculated above
    ValidRR=true(size(ValidRR));
else
    RRavg=median(RR(ValidRR)); % update RRavg calc
end
%%  Start  updating  detections using the valid RRs

ValidRR(end)=true;
ValidLocations=Locations([true; ValidRR]);
RR=diff(ValidLocations);
RR=[RR; length(Signal)-ValidLocations(end)+minDistSamples];


AddedLocations=[];
for k=1:length(RR) %loop on all RRs 
    %% Estimate how many beats are missing
    MissingR=floor(RR(k)/RRavg)-1;
    if mod(RR(k),RRavg)>RRavg*(1-LstMissingRRThresh)
        MissingR=MissingR+1;
    end
    if MissingR>0
        if k<length(RR) % define the signal frame to work on
            StrtFrame=ValidLocations(k)+minDistSamples;
            EndFrame=ValidLocations(k+1)-minDistSamples;
        else
            StrtFrame=ValidLocations(k)+minDistSamples;
            EndFrame=length(SlowEnvelope);
        end
        
        tmpWin=FastEnvelope(StrtFrame:EndFrame); % Find peaks on the fast envelope signal
        if isempty(tmpWin)
           
            StrtFrame=ValidLocations(k);
            EndFrame=ValidLocations(k+1);
            tmpWin=FastEnvelope(StrtFrame:EndFrame);
        end
        try
        [pks,locs,w,p] = findpeaks(tmpWin);
        
        if ~isempty(p)
            indx=p/max(p)>PeakDiscardThresh;
            
            if sum(indx)<MissingR % if not enough kandidate peaks
                indx=p/max(p)>(PeakDiscardThresh/2);
            end
            if sum(indx)<MissingR % if still not enough peaks
                tmpWin=FastEnvelope(StrtFrame:EndFrame);
                [pks,locs,w,p] = findpeaks(tmpWin);
                indx=p/max(p)>PeakDiscardThresh;
            end
            
            if sum(indx)<MissingR % if still not enough peaks take those that are availble
                
                MissingR=length(indx);
            end
            pks=pks(indx);
            locs=locs(indx);
            w=w(indx);
            p=p(indx);
            
            StartLocation=ValidLocations(k);
            if k<length(RR)
                EndLocation=ValidLocations(k+1);
            else
                EndLocation=[];
            end
            %         locs=locs+ValidLocations(k)+minDist;
            tmpAddLoc=zeros(1,MissingR);
            lastLoc=0;
            %% try and add the missing PCG complexes locations.
            for n=1:MissingR 
                if ~isempty(locs)
              
                    
                    distLeft=abs(locs+minDistSamples-lastLoc-RRavg);
                    if ~isempty(EndLocation)
                        distRight=abs(EndLocation-(StartLocation+locs+minDistSamples)-RRavg*(MissingR+1-n));
                        dists=distLeft+distRight;
                    else
                        %                 dists=abs(locs-RRavg);
                        
                        dists=distLeft;
                    end
                    [mn,indx]=min(dists); % find the best candidate for a complex , min dist from expected
                    lastLoc=locs(indx);
                    tmpAddLoc(n)=locs(indx)+ StartLocation+minDistSamples;
                    %                 StartLocation=locs(indx)+StartLocation;
                    locs=locs(indx+1:end); % update  remaining candidate locations
                end
                
            end
            if length(tmpAddLoc)>1
                
                indx=[1, (diff(tmpAddLoc)~=0)];
                tmpAddLoc=tmpAddLoc(logical(indx));
            end
            
            tmpAddLoc=tmpAddLoc(tmpAddLoc>0);
            AddedLocations=[AddedLocations tmpAddLoc];% accumulate added locations
        end
        catch
            'Do Nothing'
        end
    end
end

%% Sort all detction and filter out non valid detections
newlocation=sort([ValidLocations ; AddedLocations'],'ascend');% Order location 
ind=find(diff(newlocation)>MinRRTime);% Take only location that are larger then MinRRTime
if ind(end)==length(newlocation)-1
    newlocation=[newlocation(ind); newlocation(end)];
else
    newlocation=newlocation(ind);
end


out.Locs=newlocation;
out.Pks=SlowEnvelope(out.Locs);

end
% out.RRavg=RRavg;
% RRestim=filter(ones(1,10)/10,1,diff(out.Locs));
% RRestim(1:9)=RRestim(10);
% RRestim=[RRestim(1); RRestim];
% out.RRestim=RRestim;




