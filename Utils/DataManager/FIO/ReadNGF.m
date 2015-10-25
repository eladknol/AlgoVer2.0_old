function [NGFhdr, data, ctg] = ReadNGF(filename, DataReadFormat)

% 
% READNGF This function reads the header of an NGF file, both versions and
% returns the header, data, and CTG data if availbe
% [NGFhdr, data] = ReadNGF(filename)
% Inputs:
%   filename: a string of the file name
%   DataReadFormat: if to reshape the data into channels (default): DataReadFormat='Reshape' or read
%   data as one vector: DataReadFormat='OneVector'
% Outputs:
%   NGFhdr: a structure containing all the information in the header
%   data: a matrix containing all the data (LxN)

%% Dedfine the fields read from the header
% InfoFields={'Date:','Test place:','Recorded by:','Subject ID:','Age:',...
%             'BMI before pregnancy:','Weight gain during pregnancy:','Week of pregnancy:',...
%             'Sex:','Blood pressure:','Placenta location:','Fetus orientation:','Device ID:',...
%             'Sample rate:','Bits:','Biopac ECG HP:','Biopac ECG LP:','Biopac MIC HP:','Biopac MIC LP:',...
%             'Data format:','Sensor type CH1:','Sensor location CH1:','Gain CH1:','Sensor type CH2:',...
%             'Sensor location CH2:','Gain CH2:','Sensor type CH3:','Sensor location CH3:',...
%             'Gain CH3:','Sensor type CH4:','Sensor location CH4:','Gain CH4:',...
%             'Sensor type CH5:','Sensor location CH5:','Gain CH5:','Sensor type CH6:','Sensor location CH6:','Gain CH6:',...
%             'Sensor type CH7:','Sensor location CH7:','Gain CH7:','Sensor type CH8:','Sensor location CH8:','Gain CH8:'};

%%
if nargin<2
    DataReadFormat='Reshape';
end
FileFormat='OldFileFormat';
[fid, msg] = fopen(filename,'r');

% Proceed if file is valid
if fid<0
    % file id is not valid
    %     error(msg);
    data = NaN;
    NGFhdr = NaN;
    return;
end

try % I've added this try-catch
    channelsNo=0;
    ECGchannels=[];
    MICchannels=[];

    ChannelsTypes=[];
    while 1
        KHz=false;
        tline=fgetl(fid);
        
        
        if ~ischar(tline);
            break;
        end
        tmp=strfind(tline,'{');
        if ~isempty(tmp)
            FileFormat='NewFileFormat';
            break;
        end
        
        [tok,rem]=strtok(tline,':');
        if strcmp(tok,'DATA')
            break;
        else
            if ~isempty(rem)
                str=strtrim(rem(2:end));
                
                p=strfind(tok,'Sensor type');
                if ~isempty(p)
                    channelsNo=channelsNo+1;
                    if ~isempty(strfind(str,'ECG'));
                        ECGchannels=[ECGchannels, sscanf(tok,'%*s %*s CH%i')];
                        %                         ChannelsTypes=[ChannelsTypes, {'ECG'}];
                        tmp.value='ECG';
                        ChannelsTypes=[ChannelsTypes, tmp];
                    end
                    if ~isempty(strfind(str,'MIC'));
                        %                     MICchannels=[MICchannels, str2num(tok(15))];
                        MICchannels=[MICchannels, sscanf(tok,'%*s %*s CH%i')];
                        %                         ChannelsTypes=[ChannelsTypes, {'MIC'}];
                        tmp.value='MIC';
                        ChannelsTypes=[ChannelsTypes, tmp];
                    end
                end;
                p1=strfind(str,'KHz');
                p2=strfind(str,'Hz');
                if ~isempty(p1)
                    str=str(1:p1-1);
                    KHz=true;
                elseif ~isempty(p2)
                    str=str(1:p2-1);
                end
                
                num=str2num(str);
                
                if isempty(num)|| ~isempty(strfind(tok,'Date'))
                    NGFhdr.(regexprep(tok,'\W',''))=str;
                elseif KHz
                    NGFhdr.(regexprep(tok,'\W',''))=num*1000;
                else
                    NGFhdr.(regexprep(tok,'\W',''))=num;
                end
            end
        end
    end
    if ~strcmp('NewFileFormat',FileFormat)
        NGFhdr.ECGchannels=ECGchannels;
        NGFhdr.MICchannels=MICchannels;
        NGFhdr.ChannelsTypes=ChannelsTypes;
        
        if(nargout>1)
            FIDlocation=ftell(fid);
            data = fread(fid,'double');
            switch DataReadFormat  % in swithc format so we can add differnt formats of reshape in future
                case 'Reshape'
                    data = reshape(data,[round(size(data,1)/channelsNo),channelsNo]);
            end
        end
        if nargout>2
            ctg=[];
        end
        fclose(fid);
        
    else
        fclose(fid);
        %         [NGFhdr,data,ctg] = ReadNGFnew(filename);
        if(nargout==1)
            NGFhdr = ReadNGFnew(filename);
        elseif(nargout==2)
            [NGFhdr, data] = ReadNGFnew(filename);
        else
            [NGFhdr, data, ctg] = ReadNGFnew(filename);
        end
        
    end
    
    
catch mexcp
    fclose(fid);
    mexcp.rethrow(); % this must be changed, but will work for now
end


