function signal = padArr(signal, val, len, side)

switch(nargin)
    case 0,
        return;
    case 1,
        val = 0;
        len = 10;
        side = 'both';
    case 2,
        len = 10;
        side = 'both';
    case 3,
        side = 'both';
    otherwise,
        %disp('Using only the first 3 inputs');
end

padVec = val*ones(1, len);
switch(side)
    case 'before',
        signal = [padVec signal];
    case 'after',
        signal = [signal padVec];
    case 'both',
        signal = [padVec signal padVec];
    otherwise,
        signal = signal;
end