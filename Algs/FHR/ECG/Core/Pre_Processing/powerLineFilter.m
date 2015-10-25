function filtSig = powerLineFilter(signal, inConfig)
%#codegen

% #CODER_REMOVE
% This code is under the code rewriting process for the coder. Remove this line when done.


if(coder.target('matlab'))
    filtSig = applyPwrNotchFiltering_matlab(signal, inConfig);
else
    filtSig = applyPwrNotchFiltering(signal, inConfig);
end