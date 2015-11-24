function AlgVerificationWriteParams(DestFold,params)

filename=fullfile(DestFold,'AlgVVParams.txt');
ParamsBench=params.Bench;
ParamsVerf=params.Verf;

fid=fopen(filename, 'w');

fldnamesBench=fieldnames(params.Bench);

for i=1:length(fldnamesBench);
    fprintf(fid,'\n %10s %10d', fldnamesBench{i},params.Bench.(fldnamesBench{i}));
end

fldnamesVerf=fieldnames(params.Verf);

for i=1:length(fldnamesBench);
    fprintf(fid,'\n %4s %20d', fldnamesVerf{i},params.Verf.(fldnamesVerf{i})(:));
end

fclose(fid);