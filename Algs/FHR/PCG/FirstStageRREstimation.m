function candid=FirstStageRREstimation(SignalEnrgEnv,Fs)


SystemAudioParams;



%% Find Peaks in the energy signals candidates for S signals
[pks,locs,w,p] = findpeaks(SignalEnrgEnv);
indx=p/median(p) > PeakDiscardThresh; %Discard small peaks
pks=pks(indx);
locs=locs(indx);
w=w(indx);
p=p(indx);

GMModel = fitgmdist([w/max(w),(pks./p)/max(pks./p)],2, 'RegularizationValue',0.0001); % Cluster all peaks into two gaussians, using the hight and width of the peaks
idx=cluster(GMModel,[w/max(w),(pks./p)/max(pks./p)]);
pks1=pks(idx==1);
pks2=pks(idx==2);
locs1=locs(idx==1);
locs2=locs(idx==2);
dist=KLdistanceNormal(GMModel); % calcuate distance between the two gaussians
if dist>MinDistanceBetweenGroups && (sum(idx==1)>MinNumForGroup && sum(idx==2)>MinNumForGroup)
%    gaussians are far appart and have enough points in each group select
%    the most appropriate  group as the S peaks candidates else use all
    if prod(diag(GMModel.Sigma(:,:,1)))<prod(diag(GMModel.Sigma(:,:,2)))
        % Select the group that has a narrower distribution
        candid.Pks=pks1;
        candid.Locs=locs(idx==1);
        candid.p=p(idx==1);
        candid.w=w(idx==1);
    else
        candid.Pks=pks2;
        candid.Locs=locs(idx==2);
        candid.p=p(idx==2);
        candid.w=w(idx==2);
    end
else
    candid.Pks=pks;
    candid.Locs=locs;
    candid.p=p;
    candid.w=w;
end
NumOfDetections=length(candid.Locs);

if 60*Fs*NumOfDetections/length(SignalEnrgEnv)<minDetPerSec % if detection rate is smaller then minDetPerSec select the larger group
    
    if length(pks1)>length(pks2)
        candid.Pks=pks1;
        candid.Locs=locs(idx==1);
        candid.p=p(idx==1);
        candid.w=w(idx==1);
    else
        candid.Pks=pks2;
        candid.Locs=locs(idx==2);
        candid.p=p(idx==2);
        candid.w=w(idx==2);
    end
end
