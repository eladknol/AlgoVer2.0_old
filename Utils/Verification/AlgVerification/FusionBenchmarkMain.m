%% Fusion benchmark
function [handles] = FusionBenchmarkMain(handles,RunType)
params=handles.params;
% script analyzes algorithm preformance
% Inputs - 'params' - parameter struct with criteria for benchmark and
%                   verification
%          'RunType' - RunType : 0 - Benchmark, 1 - Verification

%% Initizliaztion
% generate inclusion parameters and create out file description string
% based on parameters

if RunType==0  % not running verification, just benchmark.
    % %     Patient related - set parameters to [] if they are not a relevant criteria
    %     params.Min_Gest_Age=[]; params.Max_Gest_Age=[];  % Gestation week
    %     params.Has_CTG=0;                               % CTG presence
    %     params.Min_Age=[]; params.Max_Age=[];            % Age
    %     params.Min_BMI=20; params.Max_BMI=26;            % BMI
    %
    % %     create string to describe files produced according to the above params
    
    params_Names=fieldnames(params.Bench);
    Out_File_Str=[];
    
    for i_params=1:length(params_Names);
        val=getfield(params.Bench,params_Names{i_params});
        if ~isempty(val)
            Out_File_Str=strcat(Out_File_Str,'_',params_Names{i_params},'=',num2str(val));
        end
    end
end

% Check for input of matching folder for benchmark comparisson
if ~isempty(handles.NGO_Folder_Path_4_Match);
    Compare2PrevDBFlag=1;
else
    Compare2PrevDBFlag=0;
end

% Alg. related - set parameters to [] if they are not a relevant criteria
% if RunType
%     params.Fetal_Detection_Module=[];  % final detection module. 'ECG' or 'Audio' or [];
%     params.Fetal_ECG_Detection_Score=[]; % min and max ECG detection scores per minute
%     params.Fetal_Aud_Detection_Score=[]; % min and max audio detection scores per minute
%     params.Fetal_ECG_HR_AVG=[]; % min and max ECG fetal HR avg per interval
%     params.Fetal_Aud_HR_AVG=[]; % min and max audio fetal HR avg per interval
%     params.Overlap=1; % parameters for including segments with ECG and Audio result agreement
% end


% Get file paths using NGF and NGO folder paths
handles.NGF_Folder_Path='C:\Users\Elad\Google Drive\Nuvo Algorithm team\Database';
handles.GT_Folder_Path='C:\Users\Elad\Google Drive\Nuvo Algorithm team\Verification\GroundTruth';

subFoldersList_1=folderSubFolders(handles.NGO_Folder_Path,1,0,'',0); % up to 0 folders deep
subFoldersList_2=folderSubFolders(handles.NGO_Folder_Path,2,0,'',0); % up to 1 folders deep
SubjectFolderPaths=setdiff(subFoldersList_2,subFoldersList_1);

% Threshold for approved HR detection score per minute
ECG_Score_TH=0.2;
Audio_Score_TH=0.2;

N_Subjects=length(SubjectFolderPaths); %  #of subject folders

% generate struct for total performance evaluation
res=FusionBenchmarkGenStruct(N_Subjects,ECG_Score_TH,Audio_Score_TH);

%% Loop through data -> Initial inputs for each subject
% Generate waitbar
switch RunType
    case 0
        hwbar=waitbar(0,'Processing Benchmark...');
    case 1
        hwbar=waitbar(0,'Processing Verification...');
end

for i_Subject=1:N_Subjects
    waitbar(i_Subject/N_Subjects);
    % get NGO session paths and # of sessions
    res.IndPerf(i_Subject).Subject_Path=SubjectFolderPaths{i_Subject};
    NGOFileNames=dir(fullfile(SubjectFolderPaths{i_Subject},'*.ngo'));
    % build path for NGO files
    res.IndPerf(i_Subject).NGO_Paths=fullfile(SubjectFolderPaths{i_Subject},{NGOFileNames.name}');
    N_Sessions=length(res.IndPerf(i_Subject).NGO_Paths);
    
    % set initial values for individual performance
    res.IndPerf(i_Subject).ECG_Session_det_vec=zeros(1,N_Sessions);
    res.IndPerf(i_Subject).Audio_Session_det_vec=zeros(1,N_Sessions);
    res.IndPerf(i_Subject).Fusion_Session_det_vec=zeros(1,N_Sessions);
    res.IndPerf(i_Subject).Sessions=N_Sessions;
    res.IndPerf(i_Subject).ECG_Session_score_vec=zeros(1,N_Sessions);
    res.IndPerf(i_Subject).Audio_Session_score_vec=zeros(1,N_Sessions);
    res.IndPerf(i_Subject).Included=zeros(1,N_Sessions);
    
    %% Loop through data ->  Check data, header and if session should be included
    
    % load NGO data
    for i_Session=1:N_Sessions
        [~,res.IndPerf(i_Subject).NGO_Data{i_Session,1}]=readNGO(res.IndPerf(i_Subject).NGO_Paths{i_Session});

        % check wheter resData exists
        if isfield(res.IndPerf(i_Subject).NGO_Data{i_Session,1},'resData')==1
            % get number of intervals per session
            N_Intervals=length(res.IndPerf(i_Subject).NGO_Data{i_Session,1}.resData);
            res.IndPerf(i_Subject).Intervals=res.IndPerf(i_Subject).Intervals+N_Intervals;
            
            % get path for NGF file
            [~,res.IndPerf(i_Subject).NGF_Paths{i_Session,1}]=getMatchingNGFFilePath(handles.NGF_Folder_Path,res.IndPerf(i_Subject).NGO_Paths{i_Session});
            
            % try reading NGF data and extracting header
            try
                [res.IndPerf(i_Subject).hdr{i_Session,1},~,~]=ReadNGF(res.IndPerf(i_Subject).NGF_Paths{i_Session,1},'Reshape');
            catch ME1
                disp(['Cannot read NGF:' res.IndPerf(i_Subject).NGF_Paths{i_Session,1}]);
                res.IndPerf(i_Subject).Included(i_Session)=0;
                res.IndPerf(i_Subject).Exclusion_Reason{i_Session,1}={'NGF Data could not be read'};
                res.IndPerf(i_Subject).Excluded_Sessions=res.IndPerf(i_Subject).Excluded_Sessions+1;
                res.IndPerf(i_Subject).Excluded_Intervals=res.IndPerf(i_Subject).Excluded_Intervals+N_Intervals;
                continue;
            end
            
            % update hdr with CTG indication if 'CTG' string exists in file
            % name
            if ~isempty(strfind(res.IndPerf(i_Subject).NGF_Paths{i_Session,1},'CTG'));
                res.IndPerf(i_Subject).hdr{i_Session,1}.HasCTG='true';
            else
                res.IndPerf(i_Subject).hdr{i_Session,1}.HasCTG='false';
            end
            
            % Find out if session should be included in test or not
            [res.IndPerf(i_Subject).Included(i_Session),res.IndPerf(i_Subject).Exclusion_Reason{i_Session,1}]=FusionBenchmarkIncludeFlag(params.Bench,res.IndPerf(i_Subject).hdr{i_Session,1});
            
            % Find out if the session has a matching session result in a different run
            if Compare2PrevDBFlag
                [succ_get_path,NGO_File_Path_4_Match]=getMatchingNGOFilePath(handles.NGO_Folder_Path_4_Match,res.IndPerf(i_Subject).NGO_Paths{i_Session});
                if ~(succ_get_path && (exist(NGO_File_Path_4_Match,'file')==2))
                    res.IndPerf(i_Subject).Excluded_Sessions=res.IndPerf(i_Subject).Excluded_Sessions+1;
                    res.IndPerf(i_Subject).Included(1,i_Session)=0;
                    res.IndPerf(i_Subject).Exclusion_Reason{i_Session,1}={'matching file in prev db does not exist'};
                    res.IndPerf(i_Subject).Excluded_Intervals=res.IndPerf(i_Subject).Excluded_Intervals+N_Intervals;
                    disp(['Missing from matching DB: Subject' num2str(i_Subject) ' path:' res.IndPerf(i_Subject).NGO_Paths{i_Session}]);
                    continue;
                end
                % check wheter resData exists
                [succ_read,NGO_Data_4_Match]=readNGO(NGO_File_Path_4_Match);
                if ~(succ_read && isfield(NGO_Data_4_Match,'resData')==1);
                    res.IndPerf(i_Subject).Excluded_Sessions=res.IndPerf(i_Subject).Excluded_Sessions+1;
                    res.IndPerf(i_Subject).Included(1,i_Session)=0;
                    res.IndPerf(i_Subject).Exclusion_Reason{i_Session,1}={'resData in matching file in prev db is empty'};
                    res.IndPerf(i_Subject).Excluded_Intervals=res.IndPerf(i_Subject).Excluded_Intervals+N_Intervals;
                    disp(['No resData in matching DB: Subject' num2str(i_Subject) ' path:' res.IndPerf(i_Subject).NGO_Paths{i_Session}]);
                    continue;
                end
                
                % check if number of minutes in resData do not match
                if length(NGO_Data_4_Match.resData)~=length(res.IndPerf(i_Subject).NGO_Data{i_Session,1}.resData)
                    disp(['Mismatch in interval numbers: Subject' num2str(i_Subject) ' path:' res.IndPerf(i_Subject).NGO_Paths{i_Session}]);
                end
            end
            
            % check if session is included in test set
            if res.IndPerf(i_Subject).Included(1,i_Session)
                %% Loop through data -> Calculating scores
                % load mat data
                try
                    res.IndPerf(i_Subject).mat_data{i_Session,1}=load(strcat(res.IndPerf(i_Subject).NGO_Paths{i_Session}(1:end-4),'.mat'));
                catch
                    res.IndPerf(i_Subject).mat_data{i_Session,1}=[];
                end
                        
                % extracting gestation age
                res.IndPerf(i_Subject).Gest_Age=res.IndPerf(i_Subject).hdr{i_Session}.Weekofpregnancy;
                % get interval score
                res.IndPerf(i_Subject).ECG_Interval_score_arr{1,i_Session}=[res.IndPerf(i_Subject).NGO_Data{i_Session}.resData(1:N_Intervals).Fetal_ECG_Score]';
                res.IndPerf(i_Subject).Audio_Interval_score_arr{1,i_Session}=[res.IndPerf(i_Subject).NGO_Data{i_Session}.resData(1:N_Intervals).Fetal_Audio_Score]';
                
                % get minimum interval score in session
                res.IndPerf(i_Subject).ECG_Session_score_vec(i_Session)=min(res.IndPerf(i_Subject).ECG_Interval_score_arr{1,i_Session});
                res.IndPerf(i_Subject).Audio_Session_score_vec(i_Session)=min(res.IndPerf(i_Subject).Audio_Interval_score_arr{1,i_Session});
                res.IndPerf(i_Subject).Fusion_Session_score_vec(i_Session)=min(res.IndPerf(i_Subject).ECG_Session_score_vec(i_Session),res.IndPerf(i_Subject).Audio_Session_score_vec(i_Session));
                
                % get interval detection according to score thresholds
                res.IndPerf(i_Subject).ECG_Interval_det_arr{1,i_Session}=res.IndPerf(i_Subject).ECG_Interval_score_arr{1,i_Session}<ECG_Score_TH;
                res.IndPerf(i_Subject).Audio_Interval_det_arr{1,i_Session}=res.IndPerf(i_Subject).Audio_Interval_score_arr{1,i_Session}<Audio_Score_TH;
                res.IndPerf(i_Subject).Fusion_Interval_det_arr{1,i_Session}=(res.IndPerf(i_Subject).ECG_Interval_det_arr{1,i_Session} |  res.IndPerf(i_Subject).Audio_Interval_det_arr{1,i_Session});
                res.IndPerf(i_Subject).Overlap_Interval_det_arr{1,i_Session}=(res.IndPerf(i_Subject).ECG_Interval_det_arr{1,i_Session} &  res.IndPerf(i_Subject).Audio_Interval_det_arr{1,i_Session});
                
                % update total number of intervals with HR detected for each
                % module, per subject
                res.IndPerf(i_Subject).ECG_Interval_det=res.IndPerf(i_Subject).ECG_Interval_det+...
                    sum([res.IndPerf(i_Subject).ECG_Interval_det_arr{i_Session}]);
                res.IndPerf(i_Subject).Audio_Interval_det=res.IndPerf(i_Subject).Audio_Interval_det+...
                    sum([res.IndPerf(i_Subject).Audio_Interval_det_arr{i_Session}]);
                res.IndPerf(i_Subject).Fusion_Interval_det=res.IndPerf(i_Subject).Fusion_Interval_det+...
                    sum([res.IndPerf(i_Subject).Fusion_Interval_det_arr{i_Session}]);
                res.IndPerf(i_Subject).Overlap_Interval_det=res.IndPerf(i_Subject).Overlap_Interval_det+...
                    sum([res.IndPerf(i_Subject).Overlap_Interval_det_arr{i_Session}]);
                
                %% classify session as 'HR detected'  if at least one interval has a HR detection
                if sum(res.IndPerf(i_Subject).ECG_Interval_det_arr{1,i_Session})>0
                    res.IndPerf(i_Subject).ECG_Session_det_vec(i_Session)=1;
                end
                
                if sum(res.IndPerf(i_Subject).Audio_Interval_det_arr{1,i_Session})>0
                    res.IndPerf(i_Subject).Audio_Session_det_vec(i_Session)=1;
                end
                
                if sum(res.IndPerf(i_Subject).Fusion_Interval_det_arr{1,i_Session})>0
                    res.IndPerf(i_Subject).Fusion_Session_det_vec(i_Session)=1;
                end
                
                if (res.IndPerf(i_Subject).Audio_Session_det_vec(i_Session)==1)&&(res.IndPerf(i_Subject).ECG_Session_det_vec(i_Session)==1)
                    res.IndPerf(i_Subject).Overlap_Session_det_vec(i_Session)=1;
                end
                
                
                %% get interval HR vector for ECG and Audio
                for i_Interval=1:N_Intervals
                    % check if both modules returned fetal QRS location
                    % vectors
                 if 0   
                    if ~isempty(res.IndPerf(i_Subject).NGO_Data{i_Session}.resData(i_Interval).ECG_fQRSPos) &&...
                            ~isempty(res.IndPerf(i_Subject).NGO_Data{i_Session}.resData(i_Interval).Audio_fSPos);
                        % Get HR vector for an interval
                        outECG=ScoreGraph(res.IndPerf(i_Subject).NGO_Data{i_Session}.resData(i_Interval).ECG_fQRSPos);
                        % if length of HR vector is smaller than 6,
                        % populate last element up to size of 6
                        if length(outECG.HRvec)<6;
                            outECG.HRvec=vertcat(outECG.HRvec,repmat(outECG.HRvec(end),[6-length(outECG.HRvec) 1]));
                        end;
                        res.IndPerf(i_Subject).ECG_f_HRvec{i_Session}(:,i_Interval)=outECG.HRvec;
                        outAudio=ScoreGraph(res.IndPerf(i_Subject).NGO_Data{i_Session}.resData(i_Interval).Audio_fSPos);
                        
                        % if length of HR vector is smaller than 6,
                        % populate last element up to size of 6
                        if length(outAudio.HRvec)<6;
                            outAudio.HRvec=vertcat(outAudio.HRvec,repmat(outAudio.HRvec(end),[6-length(outAudio.HRvec) 1]));
                        end;
                        res.IndPerf(i_Subject).Audio_f_HRvec{i_Session}(:,i_Interval,:)=outAudio.HRvec;
                        
                        % Calculate mean of abs diff between HR vectors of two
                        % modules for an interval if both are not [-1 -1 -1 -1 -1 -1]
                        
                        if ~((all(outECG.HRvec(:)==-1) || (all(outAudio.HRvec(:)==-1))))
                            res.IndPerf(i_Subject).diff_f_HRvec{i_Session}(i_Interval,1)=100*(mean(abs(outAudio.HRvec-outECG.HRvec))/mean([ mean(outAudio.HRvec) mean(outECG.HRvec)]));
                        else
                            res.IndPerf(i_Subject).diff_f_HRvec{i_Session}(i_Interval,1)=-1;
                        end
                    else
                        res.IndPerf(i_Subject).diff_f_HRvec{i_Session}(i_Interval,1)=-999;
                    end
                 end   
                    
                    %%  For Verification only - Check if interval's characteristics agree with verification parameters
                    if RunType==1
                        flag=AlgVerificationIncludeFlag(params.Verf,res.IndPerf(i_Subject),i_Session,i_Interval);
                        if flag
                            idx=size(handles.TableData,1)+1;
                            handles.TableData=vertcat(handles.TableData,AlgVerificationData4Table(res.IndPerf(i_Subject),handles,i_Session,i_Interval,idx));
                        end
                    end
                    %%
                end
                
                %% Update excluded session and interval data
            else
                res.IndPerf(i_Subject).Excluded_Sessions=res.IndPerf(i_Subject).Excluded_Sessions+1;
                res.IndPerf(i_Subject).Excluded_Intervals=res.IndPerf(i_Subject).Excluded_Intervals+N_Intervals;
            end
        else
            disp(['No res Data: Subject' num2str(i_Subject) ' path:' res.IndPerf(i_Subject).NGO_Paths{i_Session}]);
            res.IndPerf(i_Subject).Excluded_Sessions=res.IndPerf(i_Subject).Excluded_Sessions+1;
            res.IndPerf(i_Subject).Included(1,i_Session)=0;
            res.IndPerf(i_Subject).Exclusion_Reason{i_Session,1}={'resData is empty'};
            continue;
        end;
    end
    
    res.IndPerf(i_Subject).Included_Sessions=res.IndPerf(i_Subject).Sessions-res.IndPerf(i_Subject).Excluded_Sessions;
    res.IndPerf(i_Subject).Included_Intervals=res.IndPerf(i_Subject).Intervals-res.IndPerf(i_Subject).Excluded_Intervals;
    
    % calculate session detection per subject
    res.IndPerf(i_Subject).ECG_Session_det=sum(res.IndPerf(i_Subject).ECG_Session_det_vec);
    res.IndPerf(i_Subject).Audio_Session_det=sum(res.IndPerf(i_Subject).Audio_Session_det_vec);
    res.IndPerf(i_Subject).Fusion_Session_det=sum(res.IndPerf(i_Subject).Fusion_Session_det_vec);
    res.IndPerf(i_Subject).Overlap_Session_det=sum(res.IndPerf(i_Subject).Overlap_Session_det_vec);
    
    % calculate interval and session success per subject
    res.IndPerf(i_Subject).ECG_Interval_Suc=res.IndPerf(i_Subject).ECG_Interval_det/res.IndPerf(i_Subject).Included_Intervals;
    res.IndPerf(i_Subject).Audio_Interval_Suc=res.IndPerf(i_Subject).Audio_Interval_det/res.IndPerf(i_Subject).Included_Intervals;
    res.IndPerf(i_Subject).Fusion_Interval_Suc=res.IndPerf(i_Subject).Fusion_Interval_det/res.IndPerf(i_Subject).Included_Intervals;
    res.IndPerf(i_Subject).Overlap_Interval_Suc=res.IndPerf(i_Subject).Overlap_Interval_det/res.IndPerf(i_Subject).Included_Intervals;
    
    res.IndPerf(i_Subject).ECG_Session_Suc=res.IndPerf(i_Subject).ECG_Session_det/res.IndPerf(i_Subject).Included_Sessions;
    res.IndPerf(i_Subject).Audio_Session_Suc=res.IndPerf(i_Subject).Audio_Session_det/res.IndPerf(i_Subject).Included_Sessions;
    res.IndPerf(i_Subject).Fusion_Session_Suc=res.IndPerf(i_Subject).Fusion_Session_det/res.IndPerf(i_Subject).Included_Sessions;
    res.IndPerf(i_Subject).Overlap_Session_Suc=res.IndPerf(i_Subject).Overlap_Session_det/res.IndPerf(i_Subject).Included_Sessions;
    
    % update individual performance data into total performance data
    % per interval
    res.TotalPerf.Intervals=res.TotalPerf.Intervals+res.IndPerf(i_Subject).Intervals;
    res.TotalPerf.Included_Intervals=res.TotalPerf.Included_Intervals+res.IndPerf(i_Subject).Included_Intervals;
    res.TotalPerf.Excluded_Intervals=res.TotalPerf.Excluded_Intervals+res.IndPerf(i_Subject).Excluded_Intervals;
    
    
    res.TotalPerf.ECG_Interval_det=res.TotalPerf.ECG_Interval_det+res.IndPerf(i_Subject).ECG_Interval_det;
    res.TotalPerf.Audio_Interval_det=res.TotalPerf.Audio_Interval_det+res.IndPerf(i_Subject).Audio_Interval_det;
    res.TotalPerf.Fusion_Interval_det=res.TotalPerf.Fusion_Interval_det+res.IndPerf(i_Subject).Fusion_Interval_det;
    res.TotalPerf.Overlap_Interval_det=res.TotalPerf.Overlap_Interval_det+res.IndPerf(i_Subject).Overlap_Interval_det;
    
    %per session
    res.TotalPerf.Sessions=res.TotalPerf.Sessions+res.IndPerf(i_Subject).Sessions;
    res.TotalPerf.Included_Sessions=res.TotalPerf.Included_Sessions+res.IndPerf(i_Subject).Included_Sessions;
    res.TotalPerf.Excluded_Sessions=res.TotalPerf.Excluded_Sessions+res.IndPerf(i_Subject).Excluded_Sessions;
    
    res.TotalPerf.ECG_Session_det=res.TotalPerf.ECG_Session_det+sum(res.IndPerf(i_Subject).ECG_Session_det_vec);
    res.TotalPerf.Audio_Session_det=res.TotalPerf.Audio_Session_det+sum(res.IndPerf(i_Subject).Audio_Session_det_vec);
    res.TotalPerf.Fusion_Session_det=res.TotalPerf.Fusion_Session_det+sum(res.IndPerf(i_Subject).Fusion_Session_det_vec);
    res.TotalPerf.Overlap_Session_det=res.TotalPerf.Overlap_Session_det+sum(res.IndPerf(i_Subject).Overlap_Session_det_vec);
    
end;
close(hwbar);
%% Updating Total Performance using individual performance

res.TotalPerf.ECG_Interval_Suc=100*res.TotalPerf.ECG_Interval_det/res.TotalPerf.Included_Intervals;
res.TotalPerf.ECG_Session_Suc=100*res.TotalPerf.ECG_Session_det/res.TotalPerf.Included_Sessions;

res.TotalPerf.Audio_Interval_Suc=100*res.TotalPerf.Audio_Interval_det/res.TotalPerf.Included_Intervals;
res.TotalPerf.Audio_Session_Suc=100*res.TotalPerf.Audio_Session_det/res.TotalPerf.Included_Sessions;

res.TotalPerf.Fusion_Interval_Suc=100*res.TotalPerf.Fusion_Interval_det/res.TotalPerf.Included_Intervals;
res.TotalPerf.Fusion_Session_Suc=100*res.TotalPerf.Fusion_Session_det/res.TotalPerf.Included_Sessions;

res.TotalPerf.Overlap_Interval_Suc=100*res.TotalPerf.Overlap_Interval_det/res.TotalPerf.Included_Intervals;
res.TotalPerf.Overlap_Session_Suc=100*res.TotalPerf.Overlap_Session_det/res.TotalPerf.Included_Sessions;

% Display results in command window

disp(['Number of subjects = ' num2str(N_Subjects)]);
%Intervals
disp(['Total Intervals=' num2str(res.TotalPerf.Intervals) ', Excluded Intervals=' num2str(res.TotalPerf.Excluded_Intervals)]);

disp(['Intervals, ECG : ' num2str(res.TotalPerf.ECG_Interval_det) '/' num2str(res.TotalPerf.Included_Intervals)...
    ' , ' num2str(res.TotalPerf.ECG_Interval_Suc,'%.1f') '%']);
disp(['Intervals, Audio : ' num2str(res.TotalPerf.Audio_Interval_det) '/' num2str(res.TotalPerf.Included_Intervals)...
    ' , ' num2str(res.TotalPerf.Audio_Interval_Suc,'%.1f') '%']);
disp(['Intervals, Fusion : ' num2str(res.TotalPerf.Fusion_Interval_det) '/' num2str(res.TotalPerf.Included_Intervals)...
    ' , ' num2str(res.TotalPerf.Fusion_Interval_Suc,'%.1f') '%']);
disp(['Intervals, Overlap : ' num2str(res.TotalPerf.Overlap_Interval_det) '/' num2str(res.TotalPerf.Included_Intervals)...
    ' , ' num2str(res.TotalPerf.Overlap_Interval_Suc,'%.1f') '%']);


%Sessions
disp(['Total Sessions=' num2str(res.TotalPerf.Sessions) ', Excluded Sessions=' num2str(res.TotalPerf.Excluded_Sessions)]);

disp(['Sessions, ECG : ' num2str(res.TotalPerf.ECG_Session_det) '/' num2str(res.TotalPerf.Included_Sessions)...
    ' , ' num2str(res.TotalPerf.ECG_Session_Suc,'%.1f') '%']);
disp(['Sessions, Audio : ' num2str(res.TotalPerf.Audio_Session_det) '/' num2str(res.TotalPerf.Included_Sessions)...
    ' , ' num2str(res.TotalPerf.Audio_Session_Suc,'%.1f') '%']);
disp(['Sessions, Fusion: ' num2str(res.TotalPerf.Fusion_Session_det) '/' num2str(res.TotalPerf.Included_Sessions)...
    ' , ' num2str(res.TotalPerf.Fusion_Session_Suc,'%.1f') '%']);
disp(['Sessions, Overlap: ' num2str(res.TotalPerf.Overlap_Session_det) '/' num2str(res.TotalPerf.Included_Sessions)...
    ' , ' num2str(res.TotalPerf.Overlap_Session_Suc,'%.1f') '%']);

%% Generate plots and statistics
% calculate session success by gestation age
Included_Idx=find([res.IndPerf(:).Included_Sessions])';

% Run plot generating functions for session and interval analysis
if RunType==0;
    FusionBenchmarkGenStats(res.IndPerf(Included_Idx),handles.NGO_Folder_Path,Out_File_Str,'Sessions');
    FusionBenchmarkGenStats(res.IndPerf(Included_Idx),handles.NGO_Folder_Path,Out_File_Str,'Intervals');
    FusionBenchmarkCalcAgmt(res.IndPerf(Included_Idx),handles.NGO_Folder_Path,Out_File_Str,'Intervals');
end
%

%% Calculate number of sessions within a specific range

% Min_TH=0.1;
% Max_TH=0.25;
%
%
% ECG_Score_Vec=[res.IndPerf(:).ECG_Session_score_vec];
% ECG_Idx_In_Range=(ECG_Score_Vec>=Min_TH) & (ECG_Score_Vec<=Max_TH);
% ECG_In_Range_Tot=sum(double(ECG_Idx_In_Range));
%
% Audio_Score_Vec=[res.IndPerf(:).Audio_Session_score_vec];
% Audio_Idx_In_Range=(Audio_Score_Vec>=Min_TH) & (Audio_Score_Vec<=Max_TH);
% Audio_In_Range_Tot=sum(double(Audio_Idx_In_Range));
%
% Fusion_In_Range_Tot=sum(double(ECG_Idx_In_Range | Audio_Idx_In_Range));
%
%

end









