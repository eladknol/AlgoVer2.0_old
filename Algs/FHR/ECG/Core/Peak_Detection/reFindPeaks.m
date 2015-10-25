function newPeaks = reFindPeaks(signal, predPeaksInds, theoNumOfPeaks, newSegInds) %#codegen
% theoNumOfPeaks: the theoritical number of peaks depending on the getation week and time frame
% Used for fetal detection!
% Semi-supervised learner 

if(0.3*mean(signal(predPeaksInds))<0)
    signal = -signal;
end
%% Create a model from the original peaks 
% use kmeans clustering
clear qrs;
mult = 1;
for iPeak = 1:length(predPeaksInds)
    qrs(iPeak,:) = getQRSComplex(signal, predPeaksInds(iPeak), 0, mult);
end
nG = 5;

% clust = clusterdata(qrs,'MAXCLUST', nG); % more stable than kmeans!!
reClust = 0;
count = 0;
while(true)
    reClust = 0;
    [clust, C] = kmeans(qrs, nG, 'Replicates', 5); % kmeans can be non-repreducable hence use 5 reps
    for i=1:nG
        if(sum(clust==i)==1)
            % A cluster contains only one member, it is probably noise!
            qrs(clust==i, :) = [];
            predPeaksInds(clust==i) = [];
            reClust = 1;
        end
    end
    
    if(~reClust || count>3)
        break;
    end
    count = count+1;
end
nG = 3;
[clust, C] = kmeans(qrs, nG, 'Replicates', 5); % kmeans can be non-repreducable hence use 5 reps
    
for i=1:nG
    cluster(i).nNumOfPeaks = sum(clust==i);
    if(cluster(i).nNumOfPeaks==1)
        cluster(i).template = C(i,:);%qrs((clust==i), :);
    else
        cluster(i).template = C(i,:);%mean(qrs((clust==i), :));
    end
end
comps = [1 2; 1 3; 2 3];
for i=1:nG
    NORM(i) = norm([cluster(i).template]);
end

for i=1:nG
    temp = abs(cluster(i).template);
    [y, maxInd] = max(temp); % norm(cluster(i).template, inf);
    [vls, inds] = findpeaks(-temp);
    [ind, closestVal, Diff] = findClosest(inds, maxInd, 2);
    tempProps(i).width = abs(diff(closestVal));
    err(i) = (norm(cluster(comps(i,1)).template - cluster(comps(i,2)).template, 2))/mean(NORM(comps(i,:)));
end
bin = err<1;
if(sum(bin)==1)
    goodGroups = comps(bin==1,:);
    goodPeaks = predPeaksInds(clust==goodGroups(1) | clust==goodGroups(2));
    pksGrp = qrs(clust==goodGroups(1) | clust==goodGroups(2), :);
    notPksGrp = qrs(clust~=goodGroups(1) & clust~=goodGroups(2), :);
    
else
    d = abs([cluster.nNumOfPeaks] - theoNumOfPeaks);
    
    ind = [1 2; 1 3; 2 3];
    D = abs(diff(d(ind)'));
    bin = D<(0.3*mean(d)); % close groups
    if(any(bin))
        for i=1:nG
            res = corr(qrs(clust==i,:)');
            res(res==1) = nan;
            grpMeanCorr(i) = nanmean(res);
        end
        
        if(sum(bin)==1)
            [yy, ii] = max(grpMeanCorr(ind(bin,:)));
            goodGroup = ind(bin,ii);
        else
            [yy, ii] = max(grpMeanCorr);
            goodGroup = ii;
        end
    else
        [val, goodGroup] = min(d);
    end
    pksGrp = qrs(clust==goodGroup, :);
    notPksGrp = qrs(clust~=goodGroup, :);
end
model.train.obs = [pksGrp; notPksGrp];
model.train.cls = [ones(size(pksGrp,1), 1); zeros(size(notPksGrp,1), 1)]; % Peak, not-peak

%% Train an SVM classy
SVMModel = fitcsvm(model.train.obs, model.train.cls,'KernelFunction','linear','Standardize',true, 'ClassNames',[1, 0], 'verbose', 0);
% CVSVMModel = crossval(SVMModel);
% classLoss = kfoldLoss(CVSVMModel);

%% Now lets classy

[allPeaks.Vals, allPeaks.Inds] = findpeaks(signal, 'MinPeakHeight', 0.7*median(signal(predPeaksInds)));

allPeaks.Inds(allPeaks.Inds<newSegInds(1)) = [];
allPeaks.Inds = sort([allPeaks.Inds predPeaksInds(predPeaksInds<newSegInds(1))]);

remFlag = [];
clear newQRS;
for iPeak = 1:length(allPeaks.Inds)
    tmp_1 = getQRSComplex(signal, allPeaks.Inds(iPeak), 0, mult);
    if(length(tmp_1)<=10)% TBC
        remFlag = [remFlag iPeak];
    else
        newQRS(iPeak,:) = tmp_1;
    end
end
allPeaks.Inds(remFlag) = [];
[label, score] = predict(SVMModel, newQRS);

pks = allPeaks.Inds(label==1);

newPeaks = pks(pks>newSegInds(1));
oldPeaks = pks(pks<=newSegInds(1));
if(~isempty(oldPeaks))
    newPeaks = [oldPeaks(end) newPeaks];
    oldPeaks(end) = [];
end

%%
len = length(newPeaks);
df = diff(newPeaks);
nG = 3;
[clust, C] = kmedoids(df', nG);

add(1) = sum((abs((C(1) - C(3))./C(1))<0.5))>=1; % 1_3
add(2) = sum((abs((C(1) - C(2))./C(1))<0.5))>=1; % 1_2
add(3) = sum((abs((C(2) - C(3))./C(2))<0.5))>=1; % 2_3

switch(sum(add))
    case 0,
        % There are no 2 groups that are close
        for i=1:nG
            N(i) = sum(clust==i);
            RMS(i) = rms(df(clust==i) - C(i));
        end
        RMS(RMS<1e-4) = inf;
        meas = N./RMS;
        if(peak2rms(meas)>1)
            [y, goodGrp] = max(meas);
            validPeaks = newPeaks([1>0; clust==goodGrp]);
        else
            validPeaks = newPeaks;
        end
    case 1,
        % There are 2 groups that are close
        nG = nG-1;
        [clust, C] = kmedoids(df', nG);
        if(abs(C(1) - C(2))/max(C)>0.3) % very far groups, keep the one with the max number of members
            if(sum(clust==1)>sum(clust==2))
                % keep grp 1
                validPeaks = newPeaks([1>0; clust==1]);
                %newPeaks([0>1; clust==2]) = [];
            else
                % keep grp 2
                validPeaks = newPeaks([1>0; clust==2]);
                %newPeaks([0>1; clust==1]) = [];
            end
        end
    case 2,
        % Not an option
    case 3,
        % There are 3 groups that are close
        % Ok, do nothing!
        validPeaks = newPeaks;
end

tmpPeaks = validPeaks;
for i = 1:length(newPeaks)
    if(~any(tmpPeaks==newPeaks(i)))
        rel = rms(diff(sort([validPeaks newPeaks(i)]), 2))/rms(diff(sort(validPeaks), 2));
        if(rel<0.9)
            % mmm, looks like a good peak add it
            tmpPeaks = [tmpPeaks newPeaks(i)];
        end
    end
end

tmpPeaks = sort(tmpPeaks);

newPeaks = [oldPeaks tmpPeaks];

%%
return;
%%
% allPeaks.Vals = allPeaks.Vals + 0.0000001*rand(size(allPeaks.Vals));
nNumOfPredPeaks = length(predPeaksInds);
cont = 0;
for i = 1:nNumOfPredPeaks
    fnd = find(allPeaks.Inds==predPeaksInds(i));
    if(~isempty(fnd))
        predPeaks.predInd(i) = fnd;
        cont = 1;
    end
end
if(~cont)
    newPeaks = -1;
    return;
end

if(length(predPeaks.predInd)< 0.6*length(predPeaksInds))
    newPeaks = -1;
    return;
end
predPeaks.predInd(predPeaks.predInd==0)=[];
predPeaks.Vals = allPeaks.Vals(predPeaks.predInd);
predPeaks.Width = allPeaks.Width(predPeaks.predInd);
predPeaks.Prom = allPeaks.Prom(predPeaks.predInd);

[allPeaks.Vals, allPeaks.Inds, allPeaks.Width, allPeaks.Prom] = findpeaks(signal, 'MinPeakHeight', 0.3*median(predPeaks.Vals));

vec = [allPeaks.Vals; allPeaks.Prom];

nG = 3;
[clust, C] = kmeans(vec', nG);
add(1) = sum((abs((C(1,:) - C(3,:))./C(1,:))<0.3))>=1; % 1_3
add(2) = sum((abs((C(1,:) - C(2,:))./C(1,:))<0.3))>=1; % 1_2
add(3) = sum((abs((C(2,:) - C(3,:))./C(2,:))<0.3))>=1; % 2_3

if(sum(add) > 0 && sum(add) < 3) % two or more groups are close add them
    nG = 2;
    [clust, C] = kmeans(vec', nG);
end

predPeaks.Cents(1) = mean(predPeaks.Vals);
predPeaks.Cents(2) = mean(predPeaks.Prom);
% predPeaks.Cents(3) = mean(predPeaks.Width);% 3 params

for i=1:nG
    d(i) = sum(abs(C(i,:)-predPeaks.Cents));
end

for i=1:nG
    nNumOfPeaks(i) = sum(clust==i);
end

d = abs(nNumOfPeaks - theoNumOfPeaks);

[val, goodGroup] = min(d);
% maybe you need to deal with outliers



%%

notPeaksGroupFeats = vec(:,clust~=goodGroup);
maybePeaksGroupFeats = vec(:,clust==goodGroup);
yesPeaksGroupFeats = [predPeaks.Vals; predPeaks.Prom];


% classy
X = [yesPeaksGroupFeats, notPeaksGroupFeats]';
Y = [ones(length(yesPeaksGroupFeats), 1); zeros(length(notPeaksGroupFeats), 1)];
SVMModel = fitcsvm(X,Y,'KernelFunction','linear','Standardize',true, 'ClassNames',[1, 0], 'verbose', 1);
CVSVMModel = crossval(SVMModel);
classLoss = kfoldLoss(CVSVMModel)
newX = maybePeaksGroupFeats';
[label,score] = predict(SVMModel, newX);

f,
plot(notPeaksGroupFeats(1,:), notPeaksGroupFeats(2,:), '*r')
hold on;
plot(yesPeaksGroupFeats(1,:), yesPeaksGroupFeats(2,:), 'ob')
plot(maybePeaksGroupFeats(1,:), maybePeaksGroupFeats(2,:), '.k')
plot(maybePeaksGroupFeats(1,label==1), maybePeaksGroupFeats(2,label==1), 'vm')
sv = X(SVMModel.IsSupportVector, :);
plot(sv(:,1), sv(:,2), 'og')

newPeaks = predPeaksInds;
tmpo = [];
vec1 = vec(1,:)';
for i=1:length(vec1)
    if(clust(i)==goodGroup && isempty(find(predPeaksInds == allPeaks.Inds(i), 1)))
        if(label(maybePeaksGroupFeats(1,:) == vec1(i)))
            newPeaks = [newPeaks allPeaks.Inds(i)];
        end
    else
        % check the support vectors
        templateSize.onset = -100;
        templateSize.offset = +100;
        template = getTemplate(signal, predPeaksInds, templateSize);
        if(~isempty(find(sv(:,1) == vec1(i), 1)))
            disp('bingo')
            tmpo = [tmpo allPeaks.Inds(i)];
            qrs = getQRSComplex(signal, allPeaks.Inds(i), 0, 2);
            if(max(xcorr(template, qrs, 'coeff'))>0.7)
                newPeaks = [newPeaks allPeaks.Inds(i)];
            end
        end
    end
end

newPeaks = sort(newPeaks);
df = diff(newPeaks);
newPeaks(df==0) = []; % remove repeating peaks