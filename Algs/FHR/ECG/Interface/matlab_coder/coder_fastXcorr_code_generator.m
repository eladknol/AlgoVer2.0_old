% CODER_FASTXCORR_CODE_GENERATOR   Generate MEX-function fastXcorr_mex from
%  fastXcorr.
% 
% Script generated from project 'fastXcorr.prj' on 25-Aug-2015.
% 
% See also CODER, CODER.CONFIG, CODER.TYPEOF, CODEGEN.

%% Create configuration object of class 'coder.MexCodeConfig'.
cfg = coder.config('mex');
cfg.CustomInclude = sprintf('"C:\\Users\\Admin\\Documents\\Visual Studio 2013\\Projects\\Project4\\Project4"\n');
cfg.CustomSource = sprintf('"C:\\Users\\Admin\\Documents\\Visual Studio 2013\\Projects\\Project4\\Project4\\fastXC.c"');
cfg.GenerateReport = true;
cfg.EnableDebugging = true;
%% Define argument types for entry-point 'fastXcorr'.
ARGS = cell(1,1);
ARGS{1} = cell(2,1);
ARGS{1}{1} = coder.typeof(0,[10000   1],[1 0]);
ARGS{1}{2} = coder.typeof(0,[10000   1],[1 0]);

%% Invoke MATLAB Coder.
codegen -config cfg fastXcorr -args ARGS{1}
