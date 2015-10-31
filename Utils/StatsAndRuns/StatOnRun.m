function [sigF,sigM]=StatOnRun(folderName)


MatFileList=getNGFfileList(folderName,'.mat');
NGFFileList=getNGFfileList(folderName);
N=length(MatFileList);
sigF=[];
sigM=[];
for k=1:N
    A=load(MatFileList{k});
    for n=1:length(A.Audio)
    sigF=[sigF; A.Audio{n}.Fetal.Signal,  A.Audio{n}.Fetal.Score, A.Audio{n}.Fetal.HR, k]; 
    sigM=[sigM; A.Audio{n}.Maternal.Signal, A.Audio{n}.Maternal.Score, A.Audio{n}.Maternal.HR, k]; 
    end
end
  
