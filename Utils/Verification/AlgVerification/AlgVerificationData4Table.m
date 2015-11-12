function [ rowData] = AlgVerificationData4Table(IndPerf,handles,i_Session,i_Interval,idx)
% AlgVerificationData4Table.m Returns interval data for table in GUI
% Inputs: IndPerf - individual performance data,
%         handles - handle to GUI
%         i_Session - Session number for subject
%         i_interval - Interval (minute) number in session
%         idx - index of row in table
% Output: rowData - single row data for table, according to selected columns

TableColumns=handles.TableColumns;
N_Cols=length(TableColumns);

rowData=[];

for i_Col=1:N_Cols
    ColName=strtrim(TableColumns{i_Col});
    
    switch ColName
        case 'Subject Path'
            try
                rowData{1,i_Col}=IndPerf.Subject_Path;
            catch
                rowData{1,i_Col}=[];
            end
        case 'File Name'
            try
                [~,rowData{1,i_Col},~]=fileparts(IndPerf.NGF_Paths{i_Session});
            catch
                rowData{1,i_Col}=[];
            end
        case 'Gestation Age'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.gestAge;
            catch
                rowData{1,i_Col}=[];
            end
        case 'BMI'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.bmi;
            catch
                rowData{1,i_Col}=[];
            end
        case 'Age'
            try
                rowData{1,i_Col}=IndPerf.hdr{i_Session}.Age;
            catch
                rowData{1,i_Col}=[];
            end
        case 'Has CTG'
            try
                rowData{1,i_Col}=IndPerf.hdr{i_Session}.HasCTG;
            catch
                rowData{1,i_Col}=[];
            end
        case 'Detection Module'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).Fetal_Final_Modality;
            catch
                rowData{1,i_Col}=[];
            end
        case 'ECG Score'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).Fetal_ECG_Score;
            catch
                rowData{1,i_Col}=[];
            end
        case 'Audio Score'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).Fetal_Audio_Score;
            catch
                rowData{1,i_Col}=[];
            end
        case 'M ECG Score'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).Maternal_ECG_Score;
            catch
                rowData{1,i_Col}=[];
            end
        case 'M Audio Score'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).Maternal_Audio_Score;
            catch
                rowData{1,i_Col}=[];
            end
        case 'ECG HR'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).ECG_avgFHR;
            catch
                rowData{1,i_Col}=[];
            end
        case 'Audio HR'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).Audio_avgFHR;
            catch
                rowData{1,i_Col}=[];
            end
        case 'Overlap'
            try
                if IndPerf.Overlap_Interval_det_arr{1,i_Session}(i_Interval);
                    rowData{1,i_Col}='true';
                else
                    rowData{1,i_Col}='false';
                end
            catch
                rowData{1,i_Col}=[];
            end
        case 'Index'
            try
                rowData{1,i_Col}=idx;
            catch
                rowData{1,i_Col}=[];
            end
        case 'Session'
            try
                rowData{1,i_Col}=i_Session;
            catch
                rowData{1,i_Col}=[];
            end
        case 'Interval'
            try
                rowData{1,i_Col}=i_Interval;
            catch
                rowData{1,i_Col}=[];
            end
        case 'NGF Path'
            try
                rowData{1,i_Col}=IndPerf.NGF_Paths{i_Session};
            catch
                rowData{1,i_Col}=[];
            end
        case 'ECG VV Status'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).ECG_VV_Status;
            catch
                rowData{1,i_Col}=[];
            end
        case 'ECG VV Comments'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).ECG_VV_Comments;
            catch
                rowData{1,i_Col}='';
            end
            
        case 'Audio VV Status'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).Audio_VV_Status;
            catch
                rowData{1,i_Col}=[];
            end
        case 'Audio VV Comments'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).Audio_VV_Comments;
            catch
                rowData{1,i_Col}='';
            end
        case 'GT Source'
            try
                [~,GT_file_path]=getMatchingNGOFilePath(handles.GT_Folder_Path,IndPerf.NGF_Paths{i_Session});
                [~,NGO_Data]=readNGO(GT_file_path);
                rowData{1,i_Col}=NGO_Data.resData(i_Interval).GT_Source;
            catch
                rowData{1,i_Col}='';
            end
        case 'GT Median window size'
            try
                [~,GT_file_path]=getMatchingNGOFilePath(handles.GT_Folder_Path,IndPerf.NGF_Paths{i_Session});
                [~,NGO_Data]=readNGO(GT_file_path);
                rowData{1,i_Col}=NGO_Data.resData(i_Interval).med_win_size;
            catch
                rowData{1,i_Col}=[];
            end
        case 'f_E_m_E_max_xcorr'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).f_E_m_E_max;
            catch
                rowData{1,i_Col}=[];
            end
        case 'f_E_m_A_max_xcorr'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).f_E_m_A_max;
            catch
                rowData{1,i_Col}=[];
            end
        case 'f_A_m_E_max_xcorr'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).f_A_m_E_max;
            catch
                rowData{1,i_Col}=[];
            end
        case 'f_A_m_A_max_xcorr'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).f_A_m_A_max;
            catch
                rowData{1,i_Col}=[];
            end
        case 'm_E_m_A_max_xcorr'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).m_E_m_A_max;
            catch
                rowData{1,i_Col}=[];
            end
        case 'f_E_f_A_max_xcorr'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).f_E_f_A_max;
            catch
                rowData{1,i_Col}=[];
            end
        case 'f_E_m_E_lag'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).f_E_m_E_lag;
            catch
                rowData{1,i_Col}=[];
            end
        case 'f_E_m_A_lag'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).f_E_m_A_lag;
            catch
                rowData{1,i_Col}=[];
            end
        case 'f_A_m_E_lag'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).f_A_m_E_lag;
            catch
                rowData{1,i_Col}=[];
            end
        case 'f_A_m_A_lag'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).f_A_m_A_lag;
            catch
                rowData{1,i_Col}=[];
            end
        case 'm_E_m_A_lag'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).m_E_m_A_lag;
            catch
                rowData{1,i_Col}=[];
            end
        case 'f_E_f_A_lag'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).f_E_f_A_lag;
            catch
                rowData{1,i_Col}=[];
            end
        case 'ECG Score by ECG'
            try
                rowData{1,i_Col}=IndPerf.NGO_Data{i_Session}.resData(i_Interval).ECG_globalScore;
            catch
                rowData{1,i_Col}=[];
            end
        case 'Audio Channel'
            try
                rowData{1,i_Col}=IndPerf.mat_data{i_Session,1}.Audio{i_Interval}.Fetal.Signal(2);
            catch
                rowData{1,i_Col}=[];
            end
            
        case 'Audio Filter'
            try
                rowData{1,i_Col}=IndPerf.mat_data{i_Session,1}.Audio{i_Interval}.Fetal.Signal(1);
            catch
                rowData{1,i_Col}=[];
            end
    end
end

