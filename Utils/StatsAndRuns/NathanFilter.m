function [ss,b,a]=NathanFilter(dd, HSlow, HShigh, fs)

if 1,                                   % Use Guy Amit's heart sound filter
    fltOrder = 3;   % the actual order is 2*n
    ripple = 0.2;
    doFilter = 1;
    if (HSlow > 0)
        if (HShigh < fs/2) % bandpass filter
            %        [b,a] = butter(fltOrder,[HSlow HShigh]/(0.5*fs));
            [b,a] = cheby1(fltOrder,ripple,[HSlow HShigh]/(0.5*fs));
        else    % highpass filter
            %        [b,a] = butter(2*fltOrder,HSlow/(0.5*fs),'high');
            [b,a] = cheby1(2*fltOrder,ripple,HSlow/(0.5*fs),'high');
        end
    else    % lowpass filter
        if (HShigh < fs/2)
            %        [b,a] = butter(2*fltOrder,HShigh/(0.5*fs));
            [b,a] = cheby1(2*fltOrder,ripple,HShigh/(0.5*fs));
        else
            doFilter = 0;
        end
    end
    
    if (doFilter)
        %fltData = filter(b,a,data);     % filter version
        ss = filtfilt(b,a,dd);   % filtfilt version
        % if ~isempty(tt),
        if 0, fprintf('** MyFilter: Guy Chebychev HS Filt [%d - %d] Hz\n', HSlow, HShigh); end
    else
        ss = dd;
    end
    %-------------------------------------------------------------
else
    ftype = 'ButterW';
    if lower(ftype(1:4)) == 'butt',
        norder = 3; % Mar 28, 06 number was 5
        [bb25, aa25]= butter(norder, [HSlow/(0.5*fs)],'high');
        [bb300, aa300]= butter(5, [HShigh/(0.5*fs)],'low');
        ss = filter(bb25, aa25, dd);
        ss = filter(bb300, aa300, ss);
    elseif lower(ftype(1:4)) == 'cheb',              % Used by Guy
        norder = 2;
        ripple = 0.2;   % Changed from order 3
        [bb,aa] = cheby1(norder,ripple,[HSlow HShigh]/(0.5*fs));
        ss = filtfilt(bb,aa,dd); fprintf('Cheb: ');
        disp('++ In myfilter after cheb');
    end
    fprintf('Heart %d''th Ord %s.  Samp Freq %dHz,  %d Samples,  BW %d - %dHz\n', ...
        nOrder, ftype, fs, length(ss), HSlow, HShigh);
end