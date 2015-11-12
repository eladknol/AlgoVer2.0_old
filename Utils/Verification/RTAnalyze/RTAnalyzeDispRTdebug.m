function RTAnalyzeDispRTdebug(folder)
% function displays RT debug folder's results

if isempty(folder);
    return;
end

% Get paths to files and sort file names
FilePathsStruct=dir(fullfile(folder,'*Out.mat'));
N_Files=length(FilePathsStruct);
FileNames=cell([N_Files 1]);
SubjectNames=cell([N_Files 1]);
OutAll=cell([N_Files 1]);


for i_file=1:N_Files;
    OutAll{i_file}=load(fullfile(folder,(FilePathsStruct(i_file).name)));
    FileNames{i_file}=OutAll{i_file}.resData.toolData.FileName;
    SubjectNames{i_file}=OutAll{i_file}.resData.toolData.SubjectName;
end

% get unique file names
[U_SubjectNames,iS]=unique(SubjectNames,'stable');
iS=[iS;N_Files+1];

for i_Subject=1:length(U_SubjectNames)
    % get file idx
    file_idx=iS(i_Subject):iS(i_Subject+1)-1;
    % get unique file names
    [U_FileNames,iF]=unique(FileNames(file_idx),'stable');
    
    % Find time stamps between files (acq)
    Sess_T=iF(2:end)-1;
    N_Sep=length(Sess_T);
    
    % generate inputs
    fHR_Nuvo_ECG=[];
    mHR_Nuvo_ECG=[];
    
    fHR_Nuvo_Aud=[];
    mHR_Nuvo_Aud=[];
    
    fHR_ECG_idx=[];
    fHR_Aud_idx=[];
    
    fHR_CTG=[];
    mHR_CTG=[];
    
    % load files and extract ECG and Audio results
    for i=1:length(file_idx);
        Out=OutAll{file_idx(i)};
        
        %Fetal
        if isfield(Out.resData,'fHRvec');
            %         disp(['File No ' num2str(i) ' ,mHR= ' num2str(Out.resData.mHRvec') ' ,fHR= ' num2str(Out.resData.fHRvec')]);
            switch Out.resData.Fetal_Final_Modality
                case 'ECG'
                    fHR_Nuvo_ECG=vertcat(fHR_Nuvo_ECG,Out.resData.fHRvec);
                    fHR_Nuvo_Aud=vertcat(fHR_Nuvo_Aud,nan([length(Out.resData.fHRvec) 1]));
                    
                case 'Audio'
                    fHR_Nuvo_ECG=vertcat(fHR_Nuvo_ECG,nan([length(Out.resData.fHRvec) 1]));
                    fHR_Nuvo_Aud=vertcat(fHR_Nuvo_Aud,Out.resData.fHRvec);
            end
            
        else
            fHR_Nuvo_ECG=vertcat(fHR_Nuvo_ECG,NaN([6 1]));
            fHR_Nuvo_Aud=vertcat(fHR_Nuvo_Aud,NaN([6 1]));
            %         disp(['File No ' num2str(i) ' No results!']);
        end
                        
        if isfield(Out.resData,'fHRCTG')&&~isempty(Out.resData.fHRCTG);
            fHR_CTG=vertcat(fHR_CTG,Out.resData.fHRCTG);
        else
            fHR_CTG=vertcat(fHR_CTG,NaN([240 1]));
        end
        
        % Maternal
         if isfield(Out.resData,'mHRvec');
            %         disp(['File No ' num2str(i) ' ,mHR= ' num2str(Out.resData.mHRvec') ' ,fHR= ' num2str(Out.resData.fHRvec')]);
            switch Out.resData.Maternal_Final_Modality
                case 'ECG'
                    mHR_Nuvo_ECG=vertcat(mHR_Nuvo_ECG,Out.resData.mHRvec);
                    mHR_Nuvo_Aud=vertcat(mHR_Nuvo_Aud,nan([length(Out.resData.mHRvec) 1]));
                    
                case 'Audio'
                    mHR_Nuvo_ECG=vertcat(mHR_Nuvo_ECG,nan([length(Out.resData.mHRvec) 1]));
                    mHR_Nuvo_Aud=vertcat(mHR_Nuvo_Aud,Out.resData.mHRvec);
            end
            
        else
            mHR_Nuvo_ECG=vertcat(mHR_Nuvo_ECG,NaN([6 1]));
            mHR_Nuvo_Aud=vertcat(mHR_Nuvo_Aud,NaN([6 1]));
            %         disp(['File No ' num2str(i) ' No results!']);
         end
        
        if isfield(Out.resData,'mHRCTG')&&~isempty(Out.resData.mHRCTG);
            mHR_CTG=vertcat(mHR_CTG,Out.resData.mHRCTG);
        else
            mHR_CTG=vertcat(mHR_CTG,NaN([240 1]));
        end

    end;
    
    % Combine ECG and Audio results into one
    % Fetal
    fHR_Nuvo=[];
    fHR_Nuvo(isnan(fHR_Nuvo_ECG)==0)=fHR_Nuvo_ECG(isnan(fHR_Nuvo_ECG)==0);
    fHR_Nuvo(isnan(fHR_Nuvo_Aud)==0)=fHR_Nuvo_Aud(isnan(fHR_Nuvo_Aud)==0);
    fHR_Nuvo(isnan(fHR_Nuvo_Aud)&isnan(fHR_Nuvo_ECG))=NaN;
    
      % calculate detection percentage
    fHR_Nuvo_ECG_rtn=100*sum((isnan(fHR_Nuvo_ECG)==0)&(fHR_Nuvo_ECG~=-1))/length(fHR_Nuvo);
    fHR_Nuvo_Aud_rtn=100*sum((isnan(fHR_Nuvo_Aud)==0)&(fHR_Nuvo_Aud~=-1))/length(fHR_Nuvo);
    fHR_Nuvo_rtn=fHR_Nuvo_ECG_rtn+fHR_Nuvo_Aud_rtn;
    
    % Maternal
    
    mHR_Nuvo=[];
    mHR_Nuvo(isnan(mHR_Nuvo_ECG)==0)=mHR_Nuvo_ECG(isnan(mHR_Nuvo_ECG)==0);
    mHR_Nuvo(isnan(mHR_Nuvo_Aud)==0)=mHR_Nuvo_Aud(isnan(mHR_Nuvo_Aud)==0);
    mHR_Nuvo(isnan(mHR_Nuvo_Aud)&isnan(mHR_Nuvo_ECG))=NaN;
    
    % calculate detection percentage
    mHR_Nuvo_ECG_rtn=100*sum((isnan(mHR_Nuvo_ECG)==0)&(mHR_Nuvo_ECG~=-1))/length(mHR_Nuvo);
    mHR_Nuvo_Aud_rtn=100*sum((isnan(mHR_Nuvo_Aud)==0)&(mHR_Nuvo_Aud~=-1))/length(mHR_Nuvo);
    mHR_Nuvo_rtn=mHR_Nuvo_ECG_rtn+mHR_Nuvo_Aud_rtn;
    
    
    % calculate time tags
    F_Nuvo=0.1; T_tag_Nuvo=(1:length(fHR_Nuvo_ECG))/(F_Nuvo*60);
    F_CTG=4; T_tag_CTG=(1:length(fHR_CTG))/(F_CTG*60);
    
    % plot results
    %Fetal
    h1=figure;set(h1,'WindowStyle','docked');
    set(h1,'Name',strrep(U_SubjectNames{i_Subject},'_',' '),'NumberTitle','off')
    y_lim=[-1 200];ax2=subplot(2,1,2);
    
    plot(T_tag_Nuvo,fHR_Nuvo,'b');hold on;grid on;
    % plot(T_tag_Nuvo,fHR_Nuvo_ECG,'b'); hold on; grid on;
    plot(T_tag_Nuvo,fHR_Nuvo_Aud,'g');
    plot(T_tag_CTG,fHR_CTG,'r');ylim(y_lim);
    FetalXlim=get(ax2,'XLim');
    plotshadedonaxes(ax2,FetalXlim,[repmat(110,1,length(FetalXlim));repmat(160,1,length(FetalXlim))],'g'); hold (ax2,'on');

    legend('ECG','Audio','CTG');
    
    % plot dashed lines between acq files
    plot(repmat(Sess_T,[1 2])',repmat(y_lim',[1 N_Sep]),'--k','LineWidth',1);
    for i=1:length(iF);
        text(iF(i)-1,0.95*y_lim(2),['\leftarrow' strrep(U_FileNames{i},'_',' ')],'FontSize',5);
    end
    xlabel('Time [min]');title(['ECG: ' num2str(round(fHR_Nuvo_ECG_rtn)) '[%], Audio: ' ...
        num2str(round(fHR_Nuvo_Aud_rtn)) '[%], Overall=' num2str(round(fHR_Nuvo_rtn)) '[%]' ]);
    
    %Maternal
    ax1=subplot(2,1,1);
    plot(T_tag_Nuvo,mHR_Nuvo,'b');hold on;grid on;
    % plot(T_tag_Nuvo,fHR_Nuvo_ECG,'b'); hold on; grid on;
    plot(T_tag_Nuvo,mHR_Nuvo_Aud,'g');
    plot(T_tag_CTG,mHR_CTG,'r');ylim(y_lim);
    legend('ECG','Audio','CTG');
    
    % plot dashed lines between acq files
    plot(repmat(Sess_T,[1 2])',repmat(y_lim',[1 N_Sep]),'--k','LineWidth',1);
    for i=1:length(iF);
        text(iF(i)-1,0.95*y_lim(2),['\leftarrow' strrep(U_FileNames{i},'_',' ')],'FontSize',5);
    end
    xlabel('Time [min]');title(['ECG: ' num2str(round(mHR_Nuvo_ECG_rtn)) '[%], Audio: ' ...
        num2str(round(mHR_Nuvo_Aud_rtn)) '[%], Overall=' num2str(round(mHR_Nuvo_rtn)) '[%]' ]);
    linkaxes([ax1 ax2],'x');
    
end
end




