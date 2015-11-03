function Out1 = fastICA(icaSigs, nonLin)

if(coder.target('matlab'))
    Out1 = icaSigs;
    inc = ~all(isnan(icaSigs)');
    
    Out1 = fastica(icaSigs(inc, :), 'g', nonLin, 'verbose', 'off');
else 
    Out1 = icaSigs;
end
