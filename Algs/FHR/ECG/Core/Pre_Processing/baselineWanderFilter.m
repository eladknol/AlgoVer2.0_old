function filtSig = baselineWanderFilter(signal, medianLength)
%#codegen

% Remove baseline wander artifacts
% Subtract median
filtSig = signal - fastmedfilt1d(signal, medianLength)';
