function FusionBenchmarkCalcAgmt( IndPerf ,NGO_Folder_Path,Out_File_Str,FileType)
%FusionBenchmarkCalcAgmt calculates and plots agreement between 2 modules
%   Inputs : IndPerf  = data for all Included sessions
%            NGO_Folder_Path - path for outputs
%            Out_File_Str - string for describing plots and excel

data=[];
N_Subjects=length(IndPerf);
for i_Subject=1:N_Subjects
    tmp_Agmt=cell2mat([IndPerf(i_Subject).diff_f_HRvec']); 
    tmp_Gest_Age=repmat(IndPerf(i_Subject).Gest_Age,[length(tmp_Agmt) 1]);
    data=vertcat(data,[tmp_Gest_Age tmp_Agmt]);  
end

% Get number of intervals per gestation age
Intervals_Per_Gest=[[IndPerf(:).Gest_Age]' [IndPerf(:).Included_Intervals]'];
   
% remove invalid agreement scores (-1 or -999)
Total_Int=size(data(:,2),1);  % total number of intervals 
Invalid_No_Res_Int=sum(data(:,2)==-1); % number of intervals with one of the modules returning -1 as HR vector
Invalid_No_QRS_Pos_Int=sum(data(:,2)==-999); % number of intervals with one of the modules not returning fetal QRS location vector
Valid_Int=sum(data(:,2)>0); % number of intervals with valid HR vector result from both modules

data=data(data(:,2)>0,:);
[~,I]=sort(data);
dataSorted=data(I(:,1),:);


% create histogram data
[N,edges,ic] = histcounts(data(:,1),'BinMethod','integers');
centers=(edges(1:end-1)+edges(2:end))/2;
data4Plot_Tot=zeros(length(centers)+1,2);
data4Plot_Tot(1:end-1,1)=centers';

 % sum of included intervals per gestation age
for i=1:length(N);
    data4Plot_Tot(i,2)=sum(Intervals_Per_Gest(Intervals_Per_Gest(:,1)==data4Plot_Tot(i,1),2));
end
    
Agmt_Perc_Vec=[5:10:95];
data4Plot_Tot=[data4Plot_Tot zeros(size(data4Plot_Tot,1),length(Agmt_Perc_Vec))]; % create big table
data4Plot_Perc=zeros(size(data4Plot_Tot));
data4Plot_Perc(:,1:2)=data4Plot_Tot(:,1:2);


header=cell(1,length(Agmt_Perc_Vec));
% count number of intervals below percentage for each gestation week
for i_APV=1:length(Agmt_Perc_Vec);
    data4Plot_Tot(1:end-1,i_APV+2)=histcounts(dataSorted(find(dataSorted(:,2)<Agmt_Perc_Vec(i_APV)),1),edges)';
    data4Plot_Perc(1:end-1,i_APV+2)=100*(data4Plot_Tot(1:end-1,i_APV+2)./data4Plot_Tot(1:end-1,2));
    header{i_APV}=['TH_' num2str(Agmt_Perc_Vec(i_APV))];
end 


Marker_Sizes=data4Plot_Tot(1:end-1,2);   % marker size for plot
header=['Gestation_Age' 'Valid_Sessions' header];
T=array2table(data4Plot_Perc,'VariableNames', header );

h=figure;
Plot_Perc_TH=35;
for i=1:find(Agmt_Perc_Vec==Plot_Perc_TH);
    plot(data4Plot_Perc(1:end-1,1),data4Plot_Perc(1:end-1,i+2),'--','DisplayName',[' <' num2str(Agmt_Perc_Vec(i)) '%']);hold on;
end

cmap=get(gca,'ColorOrder');
title(['Intervals with module agreement, ' num2str(Valid_Int) ' out of ' num2str(Total_Int)]);
set(gca,'XTick',centers,'XTickLabel',{centers(:)});xlabel('Gestation age [week]');ylabel('%');
legend('-DynamicLegend');grid on;

for i=1:find(Agmt_Perc_Vec==Plot_Perc_TH);
    scatter(centers,data4Plot_Perc(1:end-1,i+2),Marker_Sizes,cmap(i,:),'f');hold on;
end
saveas(h,[NGO_Folder_Path '\' FileType '_Module_Agreement' Out_File_Str '.bmp']);
saveas(h,[NGO_Folder_Path '\' FileType '_Module_Agreement' Out_File_Str '.fig']);















