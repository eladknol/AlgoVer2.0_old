function FusionBenchmarkGenStats(IndPerf,NGO_Folder_Path,Out_File_Str,FileType)
% Plot accuracy plots for ECG, Audio and Fusion results
%   Input - IndPerf  = data for all Included sessions
%           NGO_Folder_Path - path for outputs
%           Out_File_Str - string for describing plots and excel
%           FileType - 'Intervals' or 'Sessions'

if strcmp(FileType,'Sessions');
    data=horzcat([IndPerf.Gest_Age]',[IndPerf.Included_Sessions]',[IndPerf.Fusion_Session_det]',[IndPerf.ECG_Session_det]',[IndPerf.Audio_Session_det]',[IndPerf.Overlap_Session_det]');
else if strcmp(FileType,'Intervals');
            data=horzcat([IndPerf.Gest_Age]',[IndPerf.Included_Intervals]',[IndPerf.Fusion_Interval_det]',[IndPerf.ECG_Interval_det]',[IndPerf.Audio_Interval_det]',[IndPerf.Overlap_Interval_det]');
    else
        disp('Wrong input of File Type');
        return;
    end
end        

% Sort data according to 1st column
[~,I]=sort(data);
dataSorted=data(I(:,1),:);

% bin data according to 1st column variable (gestation age for example)
[N,edges,ic] = histcounts(dataSorted(:,1),'BinMethod','integers');
centers=(edges(1:end-1)+edges(2:end))/2;
data4Plot=zeros(length(centers)+1,10);
data4Plot(1:end-1,1)=centers';

for i=1:length(N);
    % sum counts according to parameter
    data4Plot(i,2)=sum(dataSorted((ic==i),2)); %Sessions / Intervals
    data4Plot(i,3)=sum(dataSorted((ic==i),3)); %Fusion
    data4Plot(i,4)=sum(dataSorted((ic==i),4));  % ECG
    data4Plot(i,5)=sum(dataSorted((ic==i),5)); % Audio
    data4Plot(i,6)=sum(dataSorted((ic==i),6)); % Overlap
    
    % accuracy per gestatiom age (1st column variable)
    data4Plot(i,7)=100*data4Plot(i,3)/data4Plot(i,2);
    data4Plot(i,8)=100*data4Plot(i,4)/data4Plot(i,2);
    data4Plot(i,9)=100*data4Plot(i,5)/data4Plot(i,2);
    data4Plot(i,10)=100*data4Plot(i,6)/data4Plot(i,2);
end;

% Calculate data for excel (totals and accuracy)
data4Plot(end,2)=sum(data4Plot(1:end-1,2));
data4Plot(end,3)=sum(data4Plot(1:end-1,3));
data4Plot(end,4)=sum(data4Plot(1:end-1,4));
data4Plot(end,5)=sum(data4Plot(1:end-1,5));
data4Plot(end,6)=sum(data4Plot(1:end-1,6));
data4Plot(end,7)=100*data4Plot(end,3)/data4Plot(i+1,2);
data4Plot(end,8)=100*data4Plot(end,4)/data4Plot(i+1,2);
data4Plot(end,9)=100*data4Plot(end,5)/data4Plot(i+1,2);
data4Plot(end,10)=100*data4Plot(end,6)/data4Plot(i+1,2);


Total_Valid_Sessions=data4Plot(end,2); 
Marker_Sizes=data4Plot(1:end-1,2);   % marker size for plot

% Bar plot
h1=figure;h_bar=bar(centers,data4Plot(1:end-1,2:6));legend('Sessions','Fusion','ECG','Audio','Overlap');
h1.Position=[300 300 1200 300];
h_bar(1).FaceColor='k'; h_bar(2).FaceColor='m'; h_bar(3).FaceColor='r'; h_bar(4).FaceColor='b';h_bar(5).FaceColor='g';
xlabel('Gestation age [week]');ylabel('# of sessions');
title(['Fetus HR detection, ' num2str(Total_Valid_Sessions) ' ' FileType]);
set(gca,'XTick',centers,'XTickLabel',{centers(:)});
saveas(h1,[NGO_Folder_Path '\' FileType '_BarPlot_' Out_File_Str '.bmp']);
saveas(h1,[NGO_Folder_Path '\' FileType '_BarPlot_' Out_File_Str '.fig']);

% Line and scatter
h2=figure;plot(centers,data4Plot(1:end-1,7),'--m',centers,data4Plot(1:end-1,8),'--r',centers,data4Plot(1:end-1,9),'--b',centers,data4Plot(1:end-1,10),'--g');hold on;
h2.Position=[300 300 1200 300];
legend('Fusion','ECG','Audio','Overlap','Location','Best');
set(gca,'XTick',centers,'XTickLabel',{centers(:)});
xlabel('Gestation age [week]');ylabel('detection [%]');
scatter(centers,data4Plot(1:end-1,7),Marker_Sizes,'m','f','s');hold on;
scatter(centers,data4Plot(1:end-1,8),Marker_Sizes,'r','f','d');hold on;
scatter(centers,data4Plot(1:end-1,9),Marker_Sizes,'b','f');grid on;
scatter(centers,data4Plot(1:end-1,10),Marker_Sizes,'g','f','h');grid on;

title(['Fetus HR detection, ' num2str(Total_Valid_Sessions) ' ' FileType]);
saveas(h2,[NGO_Folder_Path '\' FileType '_Accuracy_' Out_File_Str '.bmp']);
saveas(h2,[NGO_Folder_Path '\' FileType '_Accuracy_' Out_File_Str '.fig']);

% Create data table
dataTable=array2table(data4Plot,'VariableNames',{'Gestation_Age' 'Valid_Sessions' 'Fusion_detection' 'ECG_detection' 'Audio_detection' 'Overlap_detection' 'Fusion_Perc'	'ECG_Perc' 'Audio_Perc' 'Overlap_Perc'});

% save data table to excel file
XlsFileName=[NGO_Folder_Path '\' FileType '_results' Out_File_Str '.xlsx'];
writetable(dataTable,XlsFileName);
winopen(XlsFileName);
end

