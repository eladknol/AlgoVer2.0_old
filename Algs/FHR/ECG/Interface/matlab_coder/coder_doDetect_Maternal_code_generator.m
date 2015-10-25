% CODER_DODETECT_MATERNAL_CODE_GENERATOR   Generate MEX-function
%  doDetectMaternal_mex from doDetectMaternal.
% 
% Script generated from project 'doDetectMaternal.prj' on 19-Aug-2015.
% 
% See also CODER, CODER.CONFIG, CODER.TYPEOF, CODEGEN.

%% Create configuration object of class 'coder.MexCodeConfig'.
cfg = coder.config('mex');
cfg.CustomInclude = sprintf('C:\\Users\\Admin\\Google_Drive\\Rnd\\Algorithms\\Implementation\\Cpp\\refs\\cluster-1.52a\\src\n"C:\\Users\\Admin\\Documents\\Visual Studio 2013\\Projects\\Project3\\Project3"\n');
cfg.CustomSource = sprintf('C:\\Users\\Admin\\Google_Drive\\Rnd\\Algorithms\\Implementation\\Cpp\\refs\\cluster-1.52a\\src\\cluster.c\n"C:\\Users\\Admin\\Documents\\Visual Studio 2013\\Projects\\Project3\\Project3\\clustInterface.c"');
cfg.GenerateReport = true;
cfg.LaunchReport = true;
cfg.EnableDebugging = true;

%% Define argument types for entry-point 'doDetectMaternal'.
ARGS = cell(1,1);
ARGS{1} = cell(3,1);
ARGS{1}{1} = coder.typeof(0,[6 180000],[1 1]);
ARGS{1}{2} = coder.typeof(0,[6 180000],[1 1]);
ARGS{1}{3} = coder.typeof(false,[1 6],[0 1]);

%% Invoke MATLAB Coder.
codegen -config cfg doDetectMaternal -args ARGS{1}
