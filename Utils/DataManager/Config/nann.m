function res = nann(str)

switch(lower(str))
    case 'maternal'
        res = 1;
    case 'fetal'
        res = 2;
    otherwise
        res = 0;
end