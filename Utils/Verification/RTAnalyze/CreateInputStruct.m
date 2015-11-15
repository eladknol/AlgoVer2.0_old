function [ InputStruct ] = CreateInputStruct()
% CreateInputStruct for 'DecisionFusionLogic.m' 

InputStruct.data=[];
InputStruct.meta=struct('Filename',[],'Samplerate',[],'ECGchannels',[1 2 3 4 5 6]...
   ,'MICchannels',[7 8 9 10],'SubjectID',{123456789},'BMIbeforepregnancy',99,'Age',99,'Weekofpregnancy',99);

InputStruct.meta.ChannelsTypes(10).value='MIC';
for i=1:6
    InputStruct.meta.ChannelsTypes(i).value='ECG';
end

for i=7:9
    InputStruct.meta.ChannelsTypes(i).value='MIC';
end;
end

