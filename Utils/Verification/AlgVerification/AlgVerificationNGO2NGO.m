% This script updates new NGO files with old verification comments and
% status from old run

crosscorr=1; % flag for calculating crosscorrelation
copyVVres=0; % flag for copying verification results and comments

PrevFolder='C:\Users\Elad\Google Drive\Nuvo Algorithm team\Verification\ICA\Run191115_FIR100_ICA=4';
CurrFolder='C:\Users\Elad\Google Drive\Nuvo Algorithm team\Verification\ICA\Run191115_FIR100_ICA=4';

FoldersList_1=folderSubFolders(PrevFolder,1,0,'',0); % up to depth 1 folders
FoldersList_2=folderSubFolders(PrevFolder,2,0,'',0); % uo tp depth 2 folders

folderPaths=setdiff(FoldersList_2,FoldersList_1);

P_count=0;
for i_folder=1:length(folderPaths);
    Prev_NGO_file_names=dir(fullfile(folderPaths{i_folder},'*ngo'));
    for i_file=1:length(Prev_NGO_file_names);
        Prev_NGO_file_path=fullfile(folderPaths{i_folder},Prev_NGO_file_names(i_file).name);
        Curr_NGO_file_path=strrep(Prev_NGO_file_path,PrevFolder,CurrFolder);
        
        try
        [Read_Status_Prev,Prev_NGO_data]=readNGO(Prev_NGO_file_path);
        catch
            continue;
        end
        
        if exist(Curr_NGO_file_path,'file')==2
            try
            [Read_Status_Curr,Curr_NGO_data]=readNGO(Curr_NGO_file_path);
            catch
                continue;
            end
        else
            continue;
        end
        
        if Read_Status_Curr && Read_Status_Prev && isfield(Prev_NGO_data,'resData') && isfield(Curr_NGO_data,'resData')
            if copyVVres % Copy verification results
                [Curr_NGO_data.resData.ECG_VV_Comments]=deal('');
                [Curr_NGO_data.resData.Audio_VV_Comments]=deal('');
            end
            for i_int=1:length(Prev_NGO_data.resData)
                if copyVVres % Copy verification results
                    % ECG
                    if isfield(Prev_NGO_data.resData(i_int),'ECG_VV_Comments')
                        Curr_NGO_data.resData(i_int).ECG_VV_Comments=Prev_NGO_data.resData(i_int).ECG_VV_Comments;
                    end
                    if isfield(Prev_NGO_data.resData(i_int),'ECG_VV_Status')
                        Curr_NGO_data.resData(i_int).ECG_VV_Status=Prev_NGO_data.resData(i_int).ECG_VV_Status;
                    end
                    
                    % Audio
                    if isfield(Prev_NGO_data.resData(i_int),'Audio_VV_Comments')
                        Curr_NGO_data.resData(i_int).Audio_VV_Comments=Prev_NGO_data.resData(i_int).Audio_VV_Comments;
                    end
                    if isfield(Prev_NGO_data.resData(i_int),'Audio_VV_Status')
                        Curr_NGO_data.resData(i_int).Audio_VV_Status=Prev_NGO_data.resData(i_int).Audio_VV_Status;
                    end
                end
                
                if crosscorr
                    try
                        FetMatXcorr=CalcFetMatXCorr(Curr_NGO_data.resData(i_int),Curr_NGO_data.Fs,0);
                        % Copy cross correlation results to NGO file
                        fldnames=fieldnames(FetMatXcorr);
                        for i_fld=1:length(fldnames)
                            Curr_NGO_data.resData(i_int).(fldnames{i_fld})=FetMatXcorr.(fldnames{i_fld});
                        end
                    catch ME
                        disp('fdsfd');
                    end
                end
            end
            
            [write_status,~]=writeNGO(Curr_NGO_file_path,Curr_NGO_data);
            if write_status
                disp(['+ Succeeded to save: ' Curr_NGO_file_path]);
                P_count=P_count+1;
            else
                disp(['-- Failed to save: ' Curr_NGO_file_path]);
            end
        else
            disp(['-- Failed to load: ' Prev_NGO_file_path '=' num2str(Read_Status_Prev) ', ' Curr_NGO_file_path '=' num2str(Read_Status_Curr)]);
        end
    end
end





