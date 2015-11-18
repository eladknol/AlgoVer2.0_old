function [ flag , Exclusion_Reason ] = AlgVerificationIncSessFlag(params,hdr)
% AlgVerificationIncSessFlag returnes if a session should be included in
% benchmark/ verification
% run according to set parameters
%   Inputs  : params - set of parameters (such as gestation age, has ctg or
%                    not, BMI etc.
%           hdr - individual session NGF header
%
%   Outputs : flag = True or false
%             Exclusion_Reason = Reasons for exclusion
%

flag=1;
Exclusion_Reason=[];

ex_count=0;

%% week of pregnancy
% min
if ~isempty(params.Min_Gest_Age) % check only if parameter is relevant
    if isempty(hdr.Weekofpregnancy) % exclude if values is N/A from header
        ex_count=ex_count+1;
        flag=0;
        Exclusion_Reason{1,ex_count}={'Week of pregnancy is N/A'};
    else if hdr.Weekofpregnancy<params.Min_Gest_Age % exclude if value does not meet criteria
            ex_count=ex_count+1;
            flag=0;
            Exclusion_Reason{1,ex_count}={'Week of pregnancy is too early'};
        end;
    end
end

% max
if ~isempty(params.Max_Gest_Age) % check only if parameter is relevant
    if isempty(hdr.Weekofpregnancy) % exclude if values is N/A from header
        ex_count=ex_count+1;
        flag=0;
        Exclusion_Reason{1,ex_count}={'Week of pregnancy is N/A'};
    else if hdr.Weekofpregnancy>params.Max_Gest_Age % exclude if value does not meet criteria
            ex_count=ex_count+1;
            flag=0;
            Exclusion_Reason{1,ex_count}={'Week of pregnancy is too late'};
        end;
    end
end

%% CTG data
if ~isempty(params.Has_CTG)
    if params.Has_CTG
        if ~isfield(hdr,'HasCTG') || strcmp(hdr.HasCTG,'false')
            ex_count=ex_count+1;
            flag=0;
            Exclusion_Reason{1,ex_count}={'Session does not contain CTG data'};
        end
    else if ~params.Has_CTG
            if isfield(hdr,'HasCTG') && strcmp(hdr.HasCTG,'true')
                ex_count=ex_count+1;
                flag=0;
                Exclusion_Reason{1,ex_count}={'Session contains CTG data'};
            end
        end
    end
end

%% Patient age 
%min 
if ~isempty(params.Min_Age) % check only if parameter is relevant
    if isempty(hdr.Age) % exclude if values is N/A from header
        ex_count=ex_count+1;
        flag=0;
        Exclusion_Reason{1,ex_count}={'Age is N/A'};
    else if hdr.Age<params.Min_Age % exclude if value does not meet criteria
            ex_count=ex_count+1;
            flag=0;
            Exclusion_Reason{1,ex_count}={'Patient is too young'};
        end;
    end
end

%max 
if ~isempty(params.Max_Age) % check only if parameter is relevant
    if isempty(hdr.Age) % exclude if values is N/A from header
        ex_count=ex_count+1;
        flag=0;
        Exclusion_Reason{1,ex_count}={'Age is N/A'};
    else if hdr.Age>params.Max_Age % exclude if value does not meet criteria
            ex_count=ex_count+1;
            flag=0;
            Exclusion_Reason{1,ex_count}={'Patient is too old'};
        end;
    end
end

%% BMI
% min
if ~isempty(params.Min_BMI) % check only if parameter is relevant
    if isempty(hdr.BMIbeforepregnancy) % exclude if values is N/A from header
        ex_count=ex_count+1;
        flag=0;
        Exclusion_Reason{1,ex_count}={'BMI is N/A'};
    else if hdr.BMIbeforepregnancy<params.Min_BMI % exclude if value does not meet criteria
            ex_count=ex_count+1;
            flag=0;
            Exclusion_Reason{1,ex_count}={'BMI is too low'};
        end;
    end
end

%max 
if ~isempty(params.Max_BMI) % check only if parameter is relevant
    if isempty(hdr.BMIbeforepregnancy) % exclude if values is N/A from header
        ex_count=ex_count+1;
        flag=0;
        Exclusion_Reason{1,ex_count}={'BMI is N/A'};
    else if hdr.BMIbeforepregnancy>params.Max_BMI % exclude if value does not meet criteria
            ex_count=ex_count+1;
            flag=0;
            Exclusion_Reason{1,ex_count}={'BMI is too high'};
        end;
    end
end
end

