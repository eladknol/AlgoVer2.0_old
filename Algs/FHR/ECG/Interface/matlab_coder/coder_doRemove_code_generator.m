% CODER_DOREMOVE_CODE_GENERATOR   Generate MEX-function doRemove_mex from
%  doRemove.
% 
% Script generated from project 'doRemove.prj' on 01-Sep-2015.
% 
% See also CODER, CODER.CONFIG, CODER.TYPEOF, CODEGEN.

%% Create configuration object of class 'coder.MexCodeConfig'.
cfg = coder.config('mex');
cfg.MATLABSourceComments = true;
cfg.GenerateReport = true;
cfg.IntegrityChecks = false;
cfg.EnableDebugging = false;

%% Define argument types for entry-point 'doRemove'.
ARGS = cell(1,1);
ARGS{1} = cell(3,1);
ARGS{1}{1} = coder.typeof(0,[6 60000],[1 1]);
ARGS{1}{2} = coder.typeof(0,[6 60000],[1 1]);
ARGS{1}{3} = struct;
ARGS{1}{3}.bestLead = coder.typeof(0);
ARGS{1}{3}.bestLeadPeaks = coder.typeof(0);
ARGS{1}{3}.leadsInclude = coder.typeof(0,[6 1],[1 0]);
ARGS{1}{3}.pos = coder.typeof(0,[1 5000],[0 1]);
ARGS{1}{3}.rel = coder.typeof(0);
ARGS{1}{3} = coder.typeof(ARGS{1}{3});

%% Invoke MATLAB Coder.
codegen -config cfg doRemove -args ARGS{1}
