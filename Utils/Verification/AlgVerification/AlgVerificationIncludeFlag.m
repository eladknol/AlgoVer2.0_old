function [ flag ] = AlgVerificationIncludeFlag(params,IndPerf,i_session,i_interval)
%AlgVerificationIncludeFlag.m returns a flag specifying if an interval
%(1 minute) should be verified manually or not, based on params.
%
%   Inputs: 'params' - struct containing inclusion paramters for classifying
%                    an interval as valid for verification (Detection
%                    module, detection score, etc.
%           'IndPerf' - alg results for each session (NGF file, containing at
%                     least one minute)
%           'i_session' - session number in subject
%           'i_interval' - interval (minute) number in session
%
%   Output: 'flag' - 0 or 1, if interval applies to inclusion parameters in
%           'params'

flag=1; % initial value for inclusion flag is set to true

%% Detection module
if ~isempty(params.Fetal_Detection_Module); % check if detection module is a criteria
    ECG_Score=Inf;Aud_Score=Inf;
    
    try  % get ECG and Audio scores for interval, if available
        ECG_Score=IndPerf.ECG_Interval_score_arr{i_session}(i_interval);
        Aud_Score=IndPerf.Audio_Interval_score_arr{i_session}(i_interval);
    end
    [m,I]=min([ECG_Score Aud_Score]);
    if m==Inf  % none of the scores were avaialble
        flag=0;
        return;
    else % one of the scores was available
        switch I % set flag to 0 if better module does not match criteria
            case 1
                if strcmp(strtrim(params.Fetal_Detection_Module),'Audio')
                    flag=0;
                    return;
                end
            case 2
                if strcmp(strtrim(params.Fetal_Detection_Module),'ECG')
                    flag=0;
                    return;
                end;
        end;
    end;
end   
%% Fetal detection score
%ECG
if ~isempty(params.Fetal_ECG_Detection_Score)&&~(any(isnan(params.Fetal_ECG_Detection_Score))) % check if ECG detection score is a criteria
    try  % get ECG score for interval, if available
        ECG_Score=IndPerf.ECG_Interval_score_arr{i_session}(i_interval);
    catch
        flag=0;
        return;
    end
    if  ~isequal(max([params.Fetal_ECG_Detection_Score(1) ECG_Score]),... % check if ECG score is not within criteria range
            min([ECG_Score params.Fetal_ECG_Detection_Score(2)]))
        flag=0;
        return;
    end
end

% Audio
if ~isempty(params.Fetal_Aud_Detection_Score)&&~(any(isnan(params.Fetal_Aud_Detection_Score))) % check if Audio detection score is a criteria
    try  % get Audio score for interval, if available
        Aud_Score=IndPerf.Audio_Interval_score_arr{i_session}(i_interval);
    catch
        flag=0;
        return;
    end
    if  ~isequal(max([params.Fetal_Aud_Detection_Score(1) Aud_Score]),... % check if ECG score is not within criteria range
            min([Aud_Score params.Fetal_Aud_Detection_Score(2)]))
        flag=0;
        return;
    end
end

%% Fetal HR
% ECG
try  % get ECG average HR for interval, if available
    ECG_HR=IndPerf.NGO_Data{i_session}.resData(i_interval).ECG_avgFHR;
    if ~isnan(ECG_HR);
        if ~isequal(max([params.Fetal_ECG_HR_AVG(1) ECG_HR]),... % check if ECG HR is not within criteria range
                min([ECG_HR params.Fetal_ECG_HR_AVG(2)]))
            flag=0;
            return;
        end
    end;
catch
end


%Audio
try  % get Audio average HR for interval, if available
    Aud_HR=IndPerf.NGO_Data{i_session}.resData(i_interval).Audio_avgFHR;
    if ~isnan(Aud_HR);
        if ~isequal(max([params.Fetal_Aud_HR_AVG(1) Aud_HR]),... % check if ECG HR is not within criteria range
                min([Aud_HR params.Fetal_Aud_HR_AVG(2)]))
            flag=0;
            return;
        end
    end;
catch
end

%% Overlapping
if ~isempty(params.Overlap); % check if overlapping of ECG and Audio detection (according to agreement criteria) is relevant
    try
        Overlap=IndPerf.Overlap_Interval_det_arr{i_session}(i_interval);
    catch
        flag=0;
        return
    end
    
    if Overlap~=params.Overlap;
        flag=0;
        return;
    end
end

%% Cross Correlation scores
% ECG
if ~isempty(params.f_E_m_E_xcorr)
    try  % get ECG score for interval, if available
        f_E_m_E_xcorr=IndPerf.NGO_Data{i_session}.resData(i_interval).f_E_m_E_max;
    catch
        flag=0;
        return;
    end
    if  ~isequal(max([params.f_E_m_E_xcorr(1) f_E_m_E_xcorr]),... % check if ECG score is not within criteria range
            min([f_E_m_E_xcorr params.f_E_m_E_xcorr(2)]))
        flag=0;
        return;
    end
end

%Audio
if~isempty(params.f_A_m_E_xcorr)
    try  % get Audio score for interval, if available
        f_A_m_E_xcorr=IndPerf.NGO_Data{i_session}.resData(i_interval).f_A_m_E_max;
    catch
        flag=0;
        return;
    end
    if  ~isequal(max([params.f_A_m_E_xcorr(1) f_A_m_E_xcorr]),... % check if Audio score is not within criteria range
            min([f_A_m_E_xcorr params.f_A_m_E_xcorr(2)]))
        flag=0;
        return;
    end
end
end

        



