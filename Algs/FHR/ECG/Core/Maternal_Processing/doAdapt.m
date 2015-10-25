function signal = doAdapt(mult, inds, signal, config)

tmp.P   = mult(1);
tmp.QRS = mult(2);
tmp.T   = mult(3);

mults = zeros(1, length(signal)); % it shoud be dynamic

mults(inds.P) = tmp.P;
mults(inds.QRS) = tmp.QRS;
mults(inds.T) = tmp.T;
if(config.multsSmoother == 15)
    mults = smooth_fast(mults);
else
    mults = smooth(mults, 'MA', config.multsSmoother); % smooth the mults
end
signal = mults.*signal;
