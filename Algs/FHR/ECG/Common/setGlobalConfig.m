function setGlobalConfig(inConfig)
% The function always overrides old config

global config;

flds = fields(inConfig);

for i = 1:numel(flds)
    config.(flds{i}) = inConfig.(flds{i});
end
