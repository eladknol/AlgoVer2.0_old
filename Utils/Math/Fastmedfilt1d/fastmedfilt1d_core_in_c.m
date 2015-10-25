function output = fastmedfilt1d_core_in_c(inSig, W2)

output = inSig;

coder.ceval('medianFilter_wrapper', coder.ref(inSig), int32(length(inSig)), int32(W2), coder.ref(output));
