function [fHROut,mHROut] = RTAnalyzegetCTGData(handles)
%RTAnalyzegetCTGData gets CTG data for maternal and fetal HR from CTG log
%file
%   Input - 'handles' - handle to tool GUI
%   Output - fHROut,mHROut - Fetal and Maternal CTG results

% Grab inputs from handles
folder='C:\Users\Gali Cantor\Desktop\CTG'; %handles.folder; %folder where CTG log is written to.
acqLastT=handles.LastAnalysisT; %last T acq file was opened at.
T_out=handles.deltaT; %Time interval of CTG data to output in seconds.

% params
Fs=4; % sampling rate of CTG results
offset_TH=5; % maximal time offset allowed between CTG and acq samples

% Initialize outputs
fHRVec=[];
mHRVec=[];
T_StampVec=[];

fHROut=[];
mHROut=[];

% get last CTG log file path
LogName=dir(fullfile(folder,'*log*'));
if ~isempty(LogName)
    FilesNames={LogName(:).name}';    
   
    % sort files according to date
    [~,T_CTG]=sort([LogName(:).datenum]);
    FilesNames=FilesNames(T_CTG);
    LogPath=fullfile(folder,FilesNames{end});      
else
    return;
end

% open file if available
fid=fopen(LogPath,'r');
if fid==-1
    return;
end
if fid<3
    fclose(fid);
    return;
end

% load data
while 1
    tline = fgetl(fid);
    if ~ischar(tline)
        break;
    end
    
    fHR=zeros(1,Fs);
    mHR=zeros(1,Fs);
    % get time sample per line
    T_Start=strfind(tline,'Time:')+6;
   
    % get fetal and maternal HR per line
    fHR_Start=strfind(tline,'HR1')+5;
    mHR_Start=strfind(tline,'MHR')+5;
 
    % Check if line is valid, meaning all parameters were found
    if isempty(T_Start)||isempty(fHR_Start)||isempty(mHR_Start)
        continue;
    end
    
    T_End=T_Start+7;
    T_Stamp=tline(T_Start:T_End);
    fHR_End=fHR_Start+2;
    mHR_End=mHR_Start+2;
    
    
    % get fetal and maternal HR values from line
    for i_fHR=1:length(fHR_Start);
        fHR(i_fHR)=str2double(tline(fHR_Start(i_fHR) : fHR_End(i_fHR)));
    end
    for i_mHR=1:length(mHR_Start);
        mHR(i_mHR)=str2double(tline(mHR_Start(i_mHR) : mHR_End(i_mHR)));
    end
    
    % Concatante results
    fHRVec=vertcat(fHRVec,fHR');
    mHRVec=vertcat(mHRVec,mHR');
    T_StampVec=vertcat(T_StampVec,T_Stamp);
end

fclose(fid);


% Exit function if one of the outputs are empty
if isempty(T_StampVec)||isempty(fHRVec)||isempty(mHRVec)
    return;
end

% Find closest CTG sample's time tag to acq file's time tag
CTG_Ttags=datevec(T_StampVec(:,:));
nowT=clock;

% Update CTG time tags with today's date
N_CTG=size(CTG_Ttags,1);
for i=1:N_CTG;
    CTG_Ttags(i,1:3)=nowT(1:3);
end

% calculate time offset between acq time tag and CTG time tags
diff=abs(etime(repmat(acqLastT,[N_CTG 1]),CTG_Ttags));
[min_offset,T_CTG]=min(diff);

% In order to output result, minimal time offset should be smaller than threshold (offset_TH) and
% length of CTG data available longer then T_out

if min_offset<offset_TH && T_CTG>T_out;
    %get minute of CTG results closest to acqlastT
    fHROut=fHRVec(1+Fs*(T_CTG-T_out):T_CTG*Fs);
    mHROut=mHRVec(1+Fs*(T_CTG-T_out):T_CTG*Fs);
else
    return
end

