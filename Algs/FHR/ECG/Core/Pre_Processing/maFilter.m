function signal_res = maFilter(signal, config)

signal_res = zeros(size(signal));

if(config.maLength>15)
    signal_res = signal - smooth(signal, 'MA', config.maLength);
else
    signal_res = smooth(signal, 'MA', config.maLength);
end
