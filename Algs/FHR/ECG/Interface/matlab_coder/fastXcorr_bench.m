function [corrVal, lag] = fastXcorr_bench(sig1, sig2)

coder.extrinsic('tic', 'toc', 'disp');
corrVal = 0;
lag = int32(0);
tic;
for i=1:1000
    coder.ceval('fastXcorr_wrapper', coder.ref(sig1), coder.ref(sig2), int32(length(sig1)), coder.ref(corrVal), coder.ref(lag));
end

lag = lag - int32(length(sig1)) + 1;

disp(toc/1000);
