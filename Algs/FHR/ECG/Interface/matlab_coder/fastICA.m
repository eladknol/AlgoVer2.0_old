function Out1 = fastICA(icaSigs, nonLin)

if(coder.target('matlab'))
    Out1 = icaSigs;
    Out1 = fastica(icaSigs, 'g', nonLin, 'verbose', 'off');
else 
    Out1 = icaSigs;
end
