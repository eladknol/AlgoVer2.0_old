function [corrVal, lag] = fastXcorr(sig1, sig2)

corrVal = 0;
lag = int32(0);

coder.ceval('fastXcorr_wrapper', coder.ref(sig1), coder.ref(sig2), int32(length(sig1)), coder.ref(corrVal), coder.ref(lag));

lag = lag - int32(length(sig1)) + 1;
