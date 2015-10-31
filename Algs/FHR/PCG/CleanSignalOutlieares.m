function valid=CleanSignalOutlieares(Signal)

SmoothFactor=10;
DivideThresh=30;

BaseSignal=filtfilt(ones(1,SmoothFactor)/SmoothFactor,1,Signal);

GMM=fitgmdist([Signal, Signal-BaseSignal],2, 'RegularizationValue',0.0001);

C=cluster(GMM,[Signal, Signal-BaseSignal]);
sigma1=sum(diag(GMM.Sigma(:,:,1)));
sigma2=sum(diag(GMM.Sigma(:,:,2)));
grp1=sum(C==1);
grp2=sum(C==2);
valid=true(size(Signal));
if grp1/grp2>10 || (sigma2/sigma1>DivideThresh && grp1>grp2)
    valid(C==2)=false;
elseif grp2/grp1>10 || (sigma1/sigma2>DivideThresh && grp2>grp1)
    valid(C==1)=false;
% else
%     outlayers=[];
end


