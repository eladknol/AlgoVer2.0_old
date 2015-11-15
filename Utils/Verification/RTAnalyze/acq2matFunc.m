function [count] = acq2matFunc(pwd)

%  ACQ2MATFunc:  This function will automatically convert all ACQ files to MAT
%  files in all specified folders. You can simply let it run overnight.
%  The reason to do so is because it could be very time consuming to load
%  ACQ files, and to load corresponding MAT files will be much quicker.
%
%  i.e. In your MATLAB code,
%	instead of using:  acq = load_acq('MyGSR.acq');
%	you can now use:   load('MyGSR.mat');
%
%  Usage:  Please update the acq_folder list below

acq_folder = {pwd};
count=0;

%%%%%%%  Please do not modify any code below   %%%%%%%

for i=1:length(acq_folder)
    fn_lst = dir(fullfile(acq_folder{i}, '*.acq'));
    
    for j=1:length(fn_lst)
        acq_fn = fullfile(acq_folder{i}, fn_lst(j).name);
        [p f] = fileparts(acq_fn);
        mat_fn = fullfile(acq_folder{i}, [f '.mat']);
        
        if ~exist(mat_fn,'file')
            try
            acq = load_acq(acq_fn);
            data=acq.data;
            isi_val=acq.hdr.graph.sample_time;
            catch
                data=[];
            end            
            if ~isempty(data)
                v7 = version;
                if str2num(v7(1))<7
                    count=count+1;
                    S=struct('data',data,'isi',isi_val,'isi_units','ms');
                    save(mat_fn,'-struct','S');
                else
                    count=count+1;
                    S=struct('data',data,'isi',isi_val,'isi_units','ms');
                    save(mat_fn, '-V6','-struct','S');
                end
            end
        end
    end
end
end

