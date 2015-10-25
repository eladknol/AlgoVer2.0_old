% CODER_PREPROCFETDATA_CODE_GENERATOR   Generate MEX-function
%  preProcFetalData_mex from preProcFetalData.
% 
% Script generated from project 'preProcFetalData.prj' on 09-Sep-2015.
% 
% See also CODER, CODER.CONFIG, CODER.TYPEOF, CODEGEN.

%% Create configuration object of class 'coder.MexCodeConfig'.
cfg = coder.config('mex');
cfg.CustomInclude = sprintf('"C:\\Users\\Admin\\Documents\\Visual Studio 2013\\Projects\\Project9\\Project9"\n');
cfg.CustomSource = sprintf('"C:\\Users\\Admin\\Documents\\Visual Studio 2013\\Projects\\Project9\\Project9\\fastmedfilt1d_core_coder.cpp"');
cfg.GenerateReport = true;

%% Define argument types for entry-point 'preProcFetalData'.
ARGS = cell(1,1);
ARGS{1} = cell(3,1);
ARGS{1}{1} = struct;
ARGS{1}{1}.filtData = coder.typeof(0,[6 180000],[1 1]);
ARGS{1}{1}.matData = coder.typeof(0,[6 180000],[1 1]);
ARGS{1}{1}.mQRS_struct = struct;
ARGS{1}{1}.mQRS_struct.bestLead = coder.typeof(0);
ARGS{1}{1}.mQRS_struct.bestLeadPeaks = coder.typeof(0);
ARGS{1}{1}.mQRS_struct.leadsInclude = coder.typeof(0,[6 1]);
ARGS{1}{1}.mQRS_struct.pos = coder.typeof(0,[1 5000],[0 1]);
ARGS{1}{1}.mQRS_struct.rel = coder.typeof(0);
ARGS{1}{1}.mQRS_struct = coder.typeof(ARGS{1}{1}.mQRS_struct);
ARGS{1}{1}.fetData = coder.typeof(0,[6 180000],[1 1]);
ARGS{1}{1}.relRemEng = coder.typeof(0,[6 1],[1 0]);
ARGS{1}{1}.noisyBeatFlag = coder.typeof(0,[6 5000],[1 1]);
ARGS{1}{1} = coder.typeof(ARGS{1}{1});
ARGS{1}{2} = coder.typeof('X',[1 20],[0 1]);
ARGS{1}{3} = struct;
ARGS{1}{3}.ICA = struct;
ARGS{1}{3}.ICA.nonLin = coder.typeof('X',[1 4]);
ARGS{1}{3}.ICA = coder.typeof(ARGS{1}{3}.ICA);
ARGS{1}{3}.Gen = struct;
ARGS{1}{3}.Gen.RMSWinLen = coder.typeof(0);
ARGS{1}{3}.Gen.maLength = coder.typeof(0);
ARGS{1}{3}.Gen = coder.typeof(ARGS{1}{3}.Gen);
ARGS{1}{3} = coder.typeof(ARGS{1}{3});

%% Invoke MATLAB Coder.
cd('C:\Users\Admin\Google_Drive\Rnd\Algorithms\Implementation\Cpp\src\MATLAB\fECG\Core\Fetal_Processing');
codegen -config cfg preProcFetalData -args ARGS{1}
