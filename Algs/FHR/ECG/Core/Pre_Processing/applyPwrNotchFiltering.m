function filtSig = applyPwrNotchFiltering(signal, inConfig)

%#codegen

% #CODER_REMOVE
% This code is under the code rewriting process for the coder. Remove this line when done.

% Fs = 1000
% Order = 10
% Fc = 50 +-0.5 Hz
% See applyPwrNotchFiltering_matlab for how designing the filter coeff

if(mean(inConfig.Fc) == 50)
    b_50 = [
        0.9990   -1.9003    0.9990
        0.9990   -1.9003    0.9990
        0.9975   -1.8973    0.9975
        0.9975   -1.8973    0.9975
        0.9969   -1.8962    0.9969];
    
    a_50 = [
        1.0000   -1.8984    0.9980
        1.0000   -1.9021    0.9981
        1.0000   -1.8961    0.9949
        1.0000   -1.8985    0.9950
        1.0000   -1.8962    0.9937];
    
    filtSig = signal;
    
    filtSig = filtfilt1D(b_50(1, :), a_50(1, :), filtSig);
    filtSig = filtfilt1D(b_50(2,:), a_50(2,:), filtSig);
    filtSig = filtfilt1D(b_50(3,:), a_50(3,:), filtSig);
    filtSig = filtfilt1D(b_50(4,:), a_50(4,:), filtSig);
    filtSig = filtfilt1D(b_50(5,:), a_50(5,:), filtSig);
    
elseif(mean(inConfig.Fc) == 60)
    % Fs = 1000
    % Order = 10
    % Fc = 60 +-0.5 Hz
    b_60 = [
        0.9990   -1.8578    0.9990
        0.9990   -1.8578    0.9990
        0.9975   -1.8548    0.9975
        0.9975   -1.8548    0.9975
        0.9969   -1.8537    0.9969];
    a_60 = [
        1.0000   -1.8555    0.9980
        1.0000   -1.8600    0.9981
        1.0000   -1.8535    0.9949
        1.0000   -1.8562    0.9950
        1.0000   -1.8537    0.9937];
    filtSig = signal;
    
    filtSig = filtfilt1D(b_60(1,:), a_60(1,:), filtSig);
    filtSig = filtfilt1D(b_60(2,:), a_60(2,:), filtSig);
    filtSig = filtfilt1D(b_60(3,:), a_60(3,:), filtSig);
    filtSig = filtfilt1D(b_60(4,:), a_60(4,:), filtSig);
    filtSig = filtfilt1D(b_60(5,:), a_60(5,:), filtSig);

else
    error('power line filter configuration is not valid.');
end
