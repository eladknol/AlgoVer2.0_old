function S=ICAall(X,FunctionNum)



SystemAudioParams;
ICAfunctionsBank={'pow3', 'tanh' , 'gaus', 'skew'};
ICAfunctionsUsed=[1, 2];
approaches={'symm', 'defl'};

approach=2;


if size(X,2)<size(X,1)
    X=X';
end

for k=1:length(ICAfunctionsUsed)

 [S1, A, W] = fastica(X,'approach' , approaches{approach},'g',ICAfunctionsBank{ICAfunctionsUsed(k)},'verbose','off');
 
 
 S(k).FastICA={S1',A,W};
 S(k).FunctionName=ICAfunctionsBank{ICAfunctionsUsed(k)};
 

end
