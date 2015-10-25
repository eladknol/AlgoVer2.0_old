% CODER_KMEDIODS_CODE_GENERATOR   Generate MEX-function kMedoids_mex from
%  kMedoids.
% 
% Script generated from project 'kMedoids.prj' on 18-Oct-2015.
% 
% See also CODER, CODER.CONFIG, CODER.TYPEOF, CODEGEN.

%% Create configuration object of class 'coder.MexCodeConfig'.
cfg = coder.config('mex');
cfg.CustomInclude = sprintf('C:\\Users\\Admin\\Google_Drive\\Rnd\\Algorithms\\Implementation\\Cpp\\refs\\cluster-1.52a\\src\n"C:\\Users\\Admin\\Documents\\Visual Studio 2013\\Projects\\Project3\\Project3"\n');
cfg.CustomSource = sprintf('C:\\Users\\Admin\\Google_Drive\\Rnd\\Algorithms\\Implementation\\Cpp\\refs\\cluster-1.52a\\src\\cluster.c\n"C:\\Users\\Admin\\Documents\\Visual Studio 2013\\Projects\\Project3\\Project3\\clustInterface.c"');
cfg.GenerateReport = true;
cfg.EnableDebugging = true;
cfg.GlobalDataSyncMethod = 'NoSync';

%% Define argument types for entry-point 'kMedoids'.
ARGS = cell(1,1);
ARGS{1} = cell(4,1);
ARGS{1}{1} = coder.typeof(0,[1000   1],[1 0]);
ARGS{1}{2} = coder.typeof(0);
ARGS{1}{3} = coder.typeof(0);
ARGS{1}{4} = coder.typeof(false);

%% Invoke MATLAB Coder.
codegen -config cfg kMedoids -args ARGS{1}
