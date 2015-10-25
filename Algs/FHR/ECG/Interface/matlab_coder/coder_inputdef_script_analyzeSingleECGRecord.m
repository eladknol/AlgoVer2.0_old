filename = 'C:\Users\Admin\Google_Drive\Nuvo Algorithm team\Database\20150630\subject 4\ALU_36-5_LYG_CTG_1.ngf';
% filename = 'C:\Users\Admin\Google_Drive\Nuvo Algorithm team\Database\20150616\subject 5\ALU_36-5_LYG_1.ngf';
% filename = 'C:\Users\Admin\Google_Drive\Nuvo Algorithm team\Database\20150428\subject 4\ALU_36-5_LYG_2.ngf';
filename = filesList{1};
inputStruct = loadECGData(filename);
inputStruct.data = inputStruct.data(:, 1:60000);

% tick = tic;
tic
% [a1,b1] = analyzeSingleECGRecord(inputStruct, 0,8,0,0);
toc
tic
[a2,b2] = analyzeSingleECGRecord__CDR(inputStruct, 0);
toc
% toc(tick)
