% CODER_FASTMEDFILT1_CODE_GENERATOR   Generate MEX-function fastmedfilt1d_mex
%  from fastmedfilt1d.
% 
% Script generated from project 'fastmedfilt1d.prj' on 09-Sep-2015.
% 
% See also CODER, CODER.CONFIG, CODER.TYPEOF, CODEGEN.

%% Create configuration object of class 'coder.MexCodeConfig'.
cfg = coder.config('mex');
cfg.CustomSourceCode = '#include "fastmedfilt1d_core_coder.h"';
cfg.CustomInclude = sprintf('"C:\\Users\\Admin\\Documents\\Visual Studio 2013\\Projects\\Project9\\Project9"\n');
cfg.CustomSource = sprintf('"C:\\Users\\Admin\\Documents\\Visual Studio 2013\\Projects\\Project9\\Project9\\fastmedfilt1d_core_coder.cpp"');
cfg.GenerateReport = true;
cfg.EnableDebugging = true;

%% Define argument types for entry-point 'fastmedfilt1d'.
ARGS = cell(1,1);
ARGS{1} = cell(2,1);
ARGS{1}{1} = coder.typeof(0,[10000   1],[1 0]);
ARGS{1}{2} = coder.typeof(0);

%% Invoke MATLAB Coder.
cd('C:\Users\Admin\Google_Drive\Rnd\Algorithms\Implementation\Cpp\src\MATLAB\Common\Utils\Fastmedfilt1d');
codegen -config cfg fastmedfilt1d -args ARGS{1}
