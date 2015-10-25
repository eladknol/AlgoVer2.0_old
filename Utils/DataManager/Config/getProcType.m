function procType = getProcType(ind)

if(ischar(ind))
    switch(ind)
        case 'maternal',
            
            procType = 1;
        case 'fetal',
            procType = 2;
        otherwise,
            procType = 1;
    end
else
    switch(ind)
        case 1,
            procType = 'maternal';
        case 2,
            procType = 'fetal';
        otherwise,
            procType = 'maternal';
    end
end