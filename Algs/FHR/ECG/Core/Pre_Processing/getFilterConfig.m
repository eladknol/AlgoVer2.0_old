function filterProps = getFilterConfig(type, val)

switch(type)
    case {'PWR'}
        filterProps = get50HzFilterProps();
        if(nargin>0)
            filterProps.Fc = val;
        end
    case {'BSLN'}
        filterProps = getBaselineFilterProps();
        if(nargin>0)
            filterProps.medianLength = val;
        end
    case {'EMG'}
        filterProps = getEMGFilterProps();
        if(nargin>0)
            filterProps.Fc = val;
        end
end