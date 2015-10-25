function Config = getConfig(type)

switch(type)
    case {'maternal','mother','mom'},
        Config = getMaternalConfig();
        Config.procType = 'maternal';
    case {'fetal','fetus'}
        Config = getFetalConfig();
        Config.procType = 'fetal';
end