function templateSize = getMECGTemplateSize(mult)

if(~nargin)
    mult = 1;
end
templateSize.onset  = -50*mult;
templateSize.offset = +50*mult;
