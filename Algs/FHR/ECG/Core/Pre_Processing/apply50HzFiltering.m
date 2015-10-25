function res = apply50HzFiltering(signal, config)

if(~isfield(config,'type'))
    config.type = 'notch';
end

switch(config.type)
    case 'notch',
        filterProps = get50HzFilterProps();
        if(isfield(config,'Fs'))
            filterProps.Fs = config.Fs;
        else
            filterProps.Fs = 1000;
        end
        res = applyNotchFilter(filterProps, signal);
end