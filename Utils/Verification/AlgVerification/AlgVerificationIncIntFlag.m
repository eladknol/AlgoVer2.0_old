function [ flag ,IndPerf ] = AlgVerificationIncIntFlag(params,IndPerf,i_session,i_interval)
%AlgVerificationIncIntFlag.m returns a flag specifying if an interval
%(1 minute) should be included in test, based on params.
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
%           'IndPerf' - alg results for each session (NGF file, containing at
%                     least one minute)


% initial value for inclusion flag is set to true
E_flag=[];
A_flag=[];

%% Detection module
if ~isempty(params.Fetal_Detection_Module); % check if detection module is a criteria
    ECG_Score=Inf;Aud_Score=Inf;
    
    try  % get ECG and Audio scores for interval, if available
        ECG_Score=IndPerf.ECG_Interval_score_arr{i_session}(i_interval);
        Aud_Score=IndPerf.Audio_Interval_score_arr{i_session}(i_interval);
    end
    [m,I]=min([ECG_Score Aud_Score]);
    if m==Inf  % none of the scores were avaialble
        E_flag=vertcat(E_flag,0);
        A_flag=vertcat(A_flag,0);
 
    else % one of the scores was available
        switch I % set flag to 0 if better module does not match criteria
            case 1
                if strcmp(strtrim(params.Fetal_Detection_Module),'Audio')
                     E_flag=vertcat(E_flag,0);
                     A_flag=vertcat(A_flag,1);
                end
            case 2
                if strcmp(strtrim(params.Fetal_Detection_Module),'ECG')
                     E_flag=vertcat(E_flag,1);
                     A_flag=vertcat(A_flag,0);                   
                end;
        end;
    end;
end   
%% Fetal detection score
%ECG
try  % get ECG score for interval, if available
    ECG_Score=IndPerf.ECG_Interval_score_arr{i_session}(i_interval);
catch
    E_flag=vertcat(E_flag,0);
end
if  exist('ECG_Score','var')&&isequal(max([params.Fetal_ECG_Detection_Score(1) ECG_Score]),... % check if ECG score is within criteria range
        min([ECG_Score params.Fetal_ECG_Detection_Score(2)]))
    E_flag=vertcat(E_flag,1);
else
    E_flag=vertcat(E_flag,0);
end

% Audio

try  % get Audio score for interval, if available
    Aud_Score=IndPerf.Audio_Interval_score_arr{i_session}(i_interval);
catch
    A_flag=vertcat(A_flag,0);
end
if  exist('Aud_Score','var')&&isequal(max([params.Fetal_Aud_Detection_Score(1) Aud_Score]),... % check if Audio score is within criteria range
        min([Aud_Score params.Fetal_Aud_Detection_Score(2)]))
    A_flag=vertcat(A_flag,1);
else
    A_flag=vertcat(A_flag,0);
end

%% Fetal HR
% ECG
try  % get ECG average HR for interval, if available
    ECG_HR=IndPerf.NGO_Data{i_session}.resData(i_interval).ECG_avgFHR;
    if ~isnan(ECG_HR) && ~isequal(max([params.Fetal_ECG_HR_AVG(1) ECG_HR]),... % check if ECG HR is not within criteria range
            min([ECG_HR params.Fetal_ECG_HR_AVG(2)]));
        E_flag=vertcat(E_flag,0);
    else
        E_flag=vertcat(E_flag,1);
    end
catch
        E_flag=vertcat(E_flag,0);
end


%Audio
try  % get Audio average HR for interval, if available
    Aud_HR=IndPerf.NGO_Data{i_session}.resData(i_interval).Audio_avgFHR;
    if ~isnan(Aud_HR) && ~isequal(max([params.Fetal_Aud_HR_AVG(1) Aud_HR]),... % check if ECG HR is not within criteria range
            min([Aud_HR params.Fetal_Aud_HR_AVG(2)]));
        A_flag=vertcat(A_flag,0);
    else
        A_flag=vertcat(A_flag,1);
    end
catch
        A_flag=vertcat(A_flag,0);
end

%% Overlapping
if ~isempty(params.Overlap); % check if overlapping of ECG and Audio detection (according to agreement criteria) is relevant
    try
        Overlap=IndPerf.Overlap_Interval_det_arr{i_session}(i_interval);
    catch
        A_flag=vertcat(A_flag,0);
        E_flag=vertcat(E_flag,0);
    end
    
    if Overlap~=params.Overlap;
        A_flag=vertcat(A_flag,0);
        E_flag=vertcat(E_flag,0);    
    end
end

%% Cross Correlation scores
% ECG
if ~isempty(params.f_E_m_E_xcorr)
    try  % get ECG score for interval, if available
        f_E_m_E_xcorr=IndPerf.NGO_Data{i_session}.resData(i_interval).f_E_m_E_max;
    catch
        E_flag=vertcat(E_flag,0);    
    end
    if  ~isempty(f_E_m_E_xcorr) && ~isequal(max([params.f_E_m_E_xcorr(1) f_E_m_E_xcorr]),... % check if ECG correlation score is not within criteria range
            min([f_E_m_E_xcorr params.f_E_m_E_xcorr(2)]))
        E_flag=vertcat(E_flag,0);    
    else
        E_flag=vertcat(E_flag,1);    
    end
end

%Audio
if~isempty(params.f_A_m_E_xcorr)
    try  % get Audio score for interval, if available
        f_A_m_E_xcorr=IndPerf.NGO_Data{i_session}.resData(i_interval).f_A_m_E_max;
    catch
        A_flag=vertcat(A_flag,0);    
    end
    if   ~isempty(f_A_m_E_xcorr) &&~isequal(max([params.f_A_m_E_xcorr(1) f_A_m_E_xcorr]),... % check if Audio score is not within criteria range
            min([f_A_m_E_xcorr params.f_A_m_E_xcorr(2)]))
        A_flag=vertcat(A_flag,0);    
    else
        A_flag=vertcat(A_flag,1);    
    end
end

%% Update interval detection as 1 if all parameters are met, 0 if o.w
%ECG
switch all(E_flag)
    case 0
        IndPerf.ECG_Interval_det_arr{i_session}(i_interval)=0;
    case 1
        IndPerf.ECG_Interval_det_arr{i_session}(i_interval)=1;
end
 
%Audio
switch all(A_flag)
    case 0
        IndPerf.Audio_Interval_det_arr{i_session}(i_interval)=0;
    case 1
        IndPerf.Audio_Interval_det_arr{i_session}(i_interval)=1;
end

% flag is true if either ECG or Audio met all parameters, false o.w
flag=all(E_flag) | all(A_flag);
end

        



