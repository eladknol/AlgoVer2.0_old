function  varargout = ReadNGFnew(filename, DataReadFormat)

% [hdr,data,CTGdata]=ReadNGFnew(filename, DataReadFormat)

% warning('off','MATLAB:iofun:UnsupportedEncoding')

if nargin<2
    DataReadFormat='Reshape';
end
[fid, msg] = fopen(filename,'r');

% Proceed if file is valid
if fid<0
    % file id is not valid
    %     error(msg);
    data = NaN;
    NGFhdr = NaN;
    return;
end
hdr=struct;
ReadStatus=1;
type.Ver=1.0;
while 1
    if ReadStatus==2
        break;
    end
    % read line
    [a,position]=textscan(fid,'%s',1,'Delimiter',{'{','}'},'whitespace','','endofline','');
    str= regexp(a{1}{1},'\w*','match');
    if ~isempty(str)
        if strcmp(str{1},'Version')
            str{1}=str{4};
            
            FlagVer=true;
            type.Ver=str2num([str{2},'.',str{3}]);
            
        else
            FlagVer=false;
            
            
        end
        switch str{1}
            case 'Varies_User_Data'
                a=textscan(fid,'%s',1,'Delimiter',{'{','}'},'whitespace','','endofline','');
                str=a{1}{1};
                str=strtrim(str);
                tmphdr=ParseRegData(str);
                if FlagVer
                    type.ECG=1;
                    type.MIC=2;
                else
                    type.ECG=0;
                    type.MIC=1;
                end
            case 'Fixed_User_Data'
                a=textscan(fid,'%s',1,'Delimiter',{'{','}'},'whitespace','','endofline','');
                str=a{1}{1};
                str=strtrim(str);
                tmphdr=ParseRegData(str);
            case 'Raw_File_Info'
                a=textscan(fid,'%s',1,'Delimiter',{'{','}'},'whitespace','','endofline','');
                str=a{1}{1};
                str=strtrim(str);
                tmphdr=ParseRegData(str);
            case 'Fetus_Data'
                a=textscan(fid,'%s',1,'Delimiter',{'{','}'},'whitespace','','endofline','');
                str=a{1}{1};
                str=strtrim(str);
                tmphdr=ParseRegData(str);
            case 'Device_ID_Data'
                a=textscan(fid,'%s',1,'Delimiter',{'{','}'},'whitespace','','endofline','');
                str=a{1}{1};
                str=strtrim(str);
                tmphdr=ParseRegData(str);
            case 'Device_ID_Data'
                a=textscan(fid,'%s',1,'Delimiter',{'{','}'},'whitespace','','endofline','');
                str=a{1}{1};
                str=strtrim(str);
                tmphdr=ParseRegData(str);
            case 'ECG_Distances'
                a=textscan(fid,'%s',1,'Delimiter',{'[',']'},'whitespace','','endofline','');
                str=a{1}{1};
                str=strtrim(str);
                FieldName=str(2:end-2);
                a=textscan(fid,'%s',1,'Delimiter',{'[',']'},'whitespace','','endofline','');
                str=a{1}{1}(2:end);
                str=strtrim(str);
                while 1
                    [b,pos]=textscan(str,'%s',1,'Delimiter',{'}'},'whitespace','','endofline','');
                    str2=b{1}{1};
                    str2=strtrim(str2(2:end));
                    distHdr=ParseRegData(str2);
                    tmphdr.(FieldName).(distHdr.Name)=distHdr.Value;
                    str=strtrim(str(pos+2:end));
                    if isempty(str)
                        break
                    end
                    
                    
                    
                    
                end
            case 'Channel_Settings'
                a=textscan(fid,'%s',1,'Delimiter',{'[',']'},'whitespace','','endofline','');
                str=a{1}{1};
                str=strtrim(str);
                FieldName=str(2:end-2);
                a=textscan(fid,'%s',1,'Delimiter',{']\r\n'},'whitespace','','endofline','');
                str=a{1}{1}(2:end);
                str=strtrim(str);
                while 1
                    [b,pos]=textscan(str,'%s',1,'Delimiter',{'}'},'whitespace','','endofline','');
                    str2=b{1}{1};
                    str2=strtrim(str2(2:end));
                    distHdr=ParseRegData(str2);
                    tmphdr.(FieldName)(distHdr.Channel_Number)=distHdr;
                    str=strtrim(str(pos+2:end));
                    if isempty(str)
                        break
                    end
                    
                    
                    
                    
                end
                ReadStatus=2;
                
        end
        hdr=structCopy(hdr,tmphdr);
        
    end
end
hdr.ChannelsNum=max(size(hdr.Channels));
hdr=AdjustHdr2Old(hdr,filename,type);
varargout{1} = hdr;
if(nargout==1)
    return; % I've added this since reading the CTG data takes sooooo long and it is not needed always
end

[a1,position1]=textscan(fid,'%s',1,'Delimiter',{'Data: \r\n'},'whitespace','','endofline','');
[a2,position2]=textscan(fid,'%s',1,'Delimiter',{'CTG:\r\n'},'whitespace','','endofline','');
fseek(fid,position1,'bof');
if strcmp(hdr.HasCTG, 'true')
    datasize=(position2-position1-1)/8;
    D=fread(fid,datasize,hdr.Data_Format);
    data=reshape(D,[hdr.ChannelsNum,round(size(D,1)/hdr.ChannelsNum)]);
    data=data';
    % if strcmp(hdr.HasCTG, 'true')
    
    raw = textscan(fid, '%s');
    
    CTGdata=ParseCTGdata(raw);
else
    datasize=(position2-position1)/8;
    D=fread(fid,datasize,hdr.Data_Format);
    data=reshape(D,[hdr.ChannelsNum,round(size(D,1)/hdr.ChannelsNum)]);
    data=data';
    CTGdata=[];
end
% hdr=AdjustHdr2Old(hdr,filename,type);
varargout{1} = hdr;
varargout{2} = data;
varargout{3} = CTGdata;
fclose(fid);
end


function tmphdr=ParseRegData(str);


while 1
    [ss,rem]=strtok(str,':');
    ss=ss(2:end-1);
    switch ss
        case 'Channel_Locations'
            loc=strfind(rem,'],');
            ss2=rem(1:loc);
            ss2=regexprep(ss2,'\s','');
            rem=rem(loc+1:end);
        otherwise
            
            [ss2,rem]=strtok(rem,',');
            
    end
    
    ind=strfind(ss2,'"');
    if isempty(ind)
        ss2=strtrim(ss2(2:end));
    else
        ss2=ss2(ind(1)+1:ind(2)-1);
    end
    %      ss2=regexp(ss2,'\w*','match')
    var=str2double(ss2);
    if isnan(var)
        tmphdr.(ss)=ss2;
    else
        tmphdr.(ss)=var;
    end
    
    str=strtrim(rem(2:end));
    if isempty(str)
        break;
    end
end

end



function  resData=ParseCTGdata(raw);
raw = raw{1};

fHR = [];
fHRconf=[];
mHR = [];
mHRconf=[];
TOCO = [];
TOCOconf=[];
for i=1:numel(raw)
    switch(lower(raw{i}))
        case 'time:',
            Time=raw{i+1};
        case 'hr1:',
            C=strsplit(raw{i+1},'-');
            fHR = [fHR str2double(C{1})];
            fHRconf=[fHRconf, Color2Num(C{2}(1:end-1))];
            
            
        case 'mhr:',
            C=strsplit(raw{i+1},'-');
            mHR = [mHR str2double(C{1})];
            mHRconf=[mHRconf, Color2Num(C{2}(1:end-1))];
            
        case 'toco:',
            C=strsplit(raw{i+1},'-');
            TOCO = [TOCO str2double(C{1})];
            TOCOconf=[TOCOconf, Color2Num(C{2}(1:end))];
            
    end
end
resData.Time=Time;
resData.fHRC = fHR;
resData.mHRC = mHR;
resData.TOCO = TOCO;
resData.fHRCconf = fHRconf;
resData.mHRCconf = mHRconf;
resData.TOCOconf = TOCOconf;

end
function Num=Color2Num(str)
switch lower(str)
    case 'green'
        Num=2;
    case 'yellow'
        Num=1;
    case 'red'
        Num=0;
    otherwise
        Num=0;
        
end
end

function hdr=AdjustHdr2Old(hdr,filename,type)
sensTypes=[hdr.Channels.Channel_Type];
[~,name,ext] = fileparts(filename);
hdr.Filename=[name,ext];
if type.Ver==1.1 | type.Ver==1
    sensTypes=[hdr.Channels.Channel_Type];
    hdr.ECGchannels=find(sensTypes==type.ECG);
    hdr.MICchannels=find(sensTypes==type.MIC);
elseif type.Ver==1.2
    sensTypes={hdr.Channels.Channel_Type};
    hdr.ECGchannels=find(strcmp(sensTypes,'ECG'));
    hdr.MICchannels=find(strcmp(sensTypes,'MIC'));
end
hdr.Samplerate=hdr.Sample_Rate;
hdr.SubjectID=hdr.User_ID;
hdr.BMIbeforepregnancy=hdr.BMI;
hdr.Weekofpregnancy=hdr.Week_Of_Pregnancy;
if isnumeric(hdr.Device_ID)
    if hdr.Device_ID==0
        hdr.DeviceID='BIOPAC';
    elseif hdr.Device_ID==1
        hdr.DeviceID='microchip';
    end
else
    hdr.DeviceID=hdr.Device_ID;
end
hdr=rmfield(hdr,'User_ID');
hdr=rmfield(hdr,'Sample_Rate');
hdr=rmfield(hdr,'BMI');
hdr=rmfield(hdr,'Week_Of_Pregnancy');
hdr=rmfield(hdr,'Device_ID');


for k=1:length(hdr.ECGchannels)
    %hdr.ChannelsTypes(hdr.ECGchannels(k), :)='ECG';
    hdr.ChannelsTypes(hdr.ECGchannels(k)).value='ECG';
end
for k=1:length(hdr.MICchannels)
    %hdr.ChannelsTypes(hdr.MICchannels(k), :)='MIC';
    hdr.ChannelsTypes(hdr.MICchannels(k)).value='MIC';
end
end

%  fieldNames=regexp(str,'"\w*":','match');
%  for k=1:length(fieldNames)

