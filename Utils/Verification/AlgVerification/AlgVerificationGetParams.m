function [ handles ] = AlgVerificationGetParams(handles)
%AlgVerificationGetParams updates GUI handles with user set parameters for
%verification /benchmarking
%   Input - handles.params - empty struct with parameters 
%   Output - handles.params - struct with extracted parameters

%% Gestation Age
% Min
Min_Gest_Age=get(handles.edit5,'String');
    if isempty(Min_Gest_Age)||strcmp(Min_Gest_Age,'min');
        handles.params.Bench.Min_Gest_Age=0;
    else
        handles.params.Bench.Min_Gest_Age=str2double(Min_Gest_Age);
    end
    
% Max
Max_Gest_Age=get(handles.edit6,'String');
    if isempty(Max_Gest_Age)||strcmp(Max_Gest_Age,'max');
        handles.params.Bench.Max_Gest_Age=Inf;
    else
        handles.params.Bench.Max_Gest_Age=str2double(Max_Gest_Age);
    end

%% Age
% Min
Min_Age=get(handles.edit3,'String');
    if isempty(Min_Age)||strcmp(Min_Age,'min');
        handles.params.Bench.Min_Age=0;
    else
        handles.params.Bench.Min_Age=str2double(Min_Age);
    end
    
% Max
Max_Age=get(handles.edit4,'String');
    if isempty(Max_Age)||strcmp(Max_Age,'max');
        handles.params.Bench.Max_Age=Inf;
    else
        handles.params.Bench.Max_Age=str2double(Max_Age);
    end

%% BMI
% Min
Min_BMI=get(handles.edit7,'String');
    if isempty(Min_BMI)||strcmp(Min_BMI,'min');
        handles.params.Bench.Min_BMI=0;
    else
        handles.params.Bench.Min_BMI=str2double(Min_BMI);
    end
    
% Max
Max_BMI=get(handles.edit8,'String');
    if isempty(Max_BMI)||strcmp(Max_BMI,'max');
        handles.params.Bench.Max_BMI=Inf;
    else
        handles.params.Bench.Max_BMI=str2double(Max_BMI);
    end

%% CTG 
Has_CTG=cellstr(get(handles.popupmenu2,'String'));
Has_CTG=strtrim(Has_CTG{get(handles.popupmenu2,'Value')});

switch Has_CTG
    case 'Yes'
        handles.params.Bench.Has_CTG=1;
    case 'No'
        handles.params.Bench.Has_CTG=0;
    case 'Irrelevant'
        handles.params.Bench.Has_CTG=[];
end   

%% Fetal Detection Module
Fetal_Detection_Module=cellstr(get(handles.popupmenu3,'String'));
handles.params.Verf.Fetal_Detection_Module=strtrim(Fetal_Detection_Module{get(handles.popupmenu3,'Value')});

if strcmp(handles.params.Verf.Fetal_Detection_Module,'Irrelevant')
    handles.params.Verf.Fetal_Detection_Module=[];
end

%% ECG Detection Score
% Min
Min_ECG_TH=get(handles.edit9,'String');
if isempty(Min_ECG_TH)||strcmp(Min_ECG_TH,'min');
    handles.params.Verf.Fetal_ECG_Detection_Score(1)=0;
else
    handles.params.Verf.Fetal_ECG_Detection_Score(1)=str2double(Min_ECG_TH);
end

% Max
Max_ECG_TH=get(handles.edit10,'String');
if isempty(Max_ECG_TH)||strcmp(Max_ECG_TH,'max');
    handles.params.Verf.Fetal_ECG_Detection_Score(2)=Inf;
else
    handles.params.Verf.Fetal_ECG_Detection_Score(2)=str2double(Max_ECG_TH);
end

%% Audio Detection Score
% Min
Min_Aud_TH=get(handles.edit11,'String');
if isempty(Min_Aud_TH)||strcmp(Min_Aud_TH,'min');
    handles.params.Verf.Fetal_Aud_Detection_Score(1)=0;
else
    handles.params.Verf.Fetal_Aud_Detection_Score(1)=str2double(Min_Aud_TH);
end

% Max
Max_Aud_TH=get(handles.edit12,'String');
if isempty(Max_Aud_TH)||strcmp(Max_Aud_TH,'max');
    handles.params.Verf.Fetal_Aud_Detection_Score(2)=Inf;
else
    handles.params.Verf.Fetal_Aud_Detection_Score(2)=str2double(Max_Aud_TH);
end

%% ECG HR
% Min
Min_ECG_HR=get(handles.edit13,'String');
if isempty(Min_ECG_HR)||strcmp(Min_ECG_HR,'min');
    handles.params.Verf.Fetal_ECG_HR_AVG(1)=0;
else
    handles.params.Verf.Fetal_ECG_HR_AVG(1)=str2double(Min_ECG_HR);
end

% Max
Max_ECG_HR=get(handles.edit14,'String');
if isempty(Max_ECG_HR)||strcmp(Max_ECG_HR,'max');
    handles.params.Verf.Fetal_ECG_HR_AVG(2)=Inf;
else
    handles.params.Verf.Fetal_ECG_HR_AVG(2)=str2double(Max_ECG_HR);
end

%% Audio HR
% Min
Min_Aud_HR=get(handles.edit15,'String');
if isempty(Min_Aud_HR)||strcmp(Min_Aud_HR,'min');
    handles.params.Verf.Fetal_Aud_HR_AVG(1)=0;
else
    handles.params.Verf.Fetal_Aud_HR_AVG(1)=str2double(Min_Aud_HR);
end

% Max
Max_Aud_HR=get(handles.edit16,'String');
if isempty(Max_Aud_HR)||strcmp(Max_Aud_HR,'max');
    handles.params.Verf.Fetal_Aud_HR_AVG(2)=Inf;
else
    handles.params.Verf.Fetal_Aud_HR_AVG(2)=str2double(Max_Aud_HR);
end

%% Overlapping
Overlap=cellstr(get(handles.popupmenu4,'String'));
Overlap=strtrim(Overlap{get(handles.popupmenu4,'Value')});

switch Overlap
    case 'Yes'
        handles.params.Verf.Overlap=1;
    case 'No'
        handles.params.Verf.Overlap=0;
    case 'Irrelevant'
        handles.params.Verf.Overlap=[];
end 

%% ECG cross correlation Score
% Min
Min_f_E_m_E_xcorr=get(handles.edit21,'String');
if isempty(Min_f_E_m_E_xcorr)||strcmp(Min_f_E_m_E_xcorr,'min');
    handles.params.Verf.f_E_m_E_xcorr(1)=0;
else
    handles.params.Verf.f_E_m_E_xcorr(1)=str2double(Min_f_E_m_E_xcorr);
end

% Max
Max_f_E_m_E_xcorr=get(handles.edit22,'String');
if isempty(Max_f_E_m_E_xcorr)||strcmp(Max_f_E_m_E_xcorr,'max');
    handles.params.Verf.f_E_m_E_xcorr(2)=Inf;
else
    handles.params.Verf.f_E_m_E_xcorr(2)=str2double(Max_f_E_m_E_xcorr);
end

%% Audio cross correlation Score
% Min
Min_f_A_m_E_xcorr=get(handles.edit23,'String');
if isempty(Min_f_A_m_E_xcorr)||strcmp(Min_f_A_m_E_xcorr,'min');
    handles.params.Verf.f_A_m_E_xcorr(1)=0;
else
    handles.params.Verf.f_A_m_E_xcorr(1)=str2double(Min_f_A_m_E_xcorr);
end

% Max
Max_f_A_m_E_xcorr=get(handles.edit24,'String');
if isempty(Max_f_A_m_E_xcorr)||strcmp(Max_f_A_m_E_xcorr,'max');
    handles.params.Verf.f_A_m_E_xcorr(2)=Inf;
else
    handles.params.Verf.f_A_m_E_xcorr(2)=str2double(Max_f_A_m_E_xcorr);
end
end

