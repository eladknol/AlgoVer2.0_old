% CODER_DODETECT_FETAL_CODE_GENERATOR   Generate static library doDetectFetal
%  from doDetectFetal.
% 
% Script generated from project 'doDetectFetal.prj' on 13-Oct-2015.
% 
% See also CODER, CODER.CONFIG, CODER.TYPEOF, CODEGEN.

%% Create configuration object of class 'coder.CodeConfig'.
cfg = coder.config('lib','ecoder',false);
cfg.GenerateReport = true;
cfg.GenCodeOnly = true;

%% Define argument types for entry-point 'doDetectFetal'.
ARGS = cell(1,1);
ARGS{1} = cell(5,1);
ARGS{1}{1} = coder.typeof(0,[6 180000],[1 1]);
ARGS{1}{2} = coder.typeof(0,[6 1],[1 0]);
ARGS{1}{3} = struct;
ARGS{1}{3}.bestLead = coder.typeof(0);
ARGS{1}{3}.bestLeadPeaks = coder.typeof(0);
ARGS{1}{3}.leadsInclude = coder.typeof(0,[6 1],[1 0]);
ARGS{1}{3}.pos = coder.typeof(0,[1 5000],[0 1]);
ARGS{1}{3}.rel = coder.typeof(0);
ARGS{1}{3} = coder.typeof(ARGS{1}{3});
ARGS{1}{4} = coder.typeof(0);
ARGS{1}{5} = struct;
ARGS{1}{5}.filtData = coder.typeof(0,[6 180000],[1 1]);
ARGS{1}{5}.matData = coder.typeof(0,[6 180000],[1 1]);
ARGS{1}{5}.mQRS_struct = struct;
ARGS{1}{5}.mQRS_struct.bestLead = coder.typeof(0);
ARGS{1}{5}.mQRS_struct.bestLeadPeaks = coder.typeof(0);
ARGS{1}{5}.mQRS_struct.leadsInclude = coder.typeof(0,[6 1],[1 0]);
ARGS{1}{5}.mQRS_struct.pos = coder.typeof(0,[1 5000],[0 1]);
ARGS{1}{5}.mQRS_struct.rel = coder.typeof(0);
ARGS{1}{5}.mQRS_struct = coder.typeof(ARGS{1}{5}.mQRS_struct);
ARGS{1}{5}.fetData = coder.typeof(0,[6 180000],[1 1]);
ARGS{1}{5}.relRemEng = coder.typeof(0,[6 1],[1 0]);
ARGS{1}{5}.noisyBeatFlag = coder.typeof(0,[6 5000],[1 1]);
ARGS{1}{5} = coder.typeof(ARGS{1}{5});

%% Invoke MATLAB Coder.
codegen -config cfg doDetectFetal -args ARGS{1}
