function y = rms_real(x)

% x must be a 1D vector
y = sqrt(mean(x.*x));