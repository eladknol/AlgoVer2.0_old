function CL = clt(signal, config)

dtSqr = (1/config.Fs)^2;
% if(coder.target('matlab'))
%     [b, a] = fir1(config.CLT.filter.order, config.CLT.filter.fc/(config.Fs/2), config.CLT.filter.type);
% else    
%     [b, a] = fir1(100, [5 20]/(1000/2), 'bandpass');
% end

if(config.CLT.filter.order == 100 && all(config.CLT.filter.fc/(config.reqFs/2) == [0.00250000000000000, 0.0100000000000000]))
    b = [0.000904864914120499,0.000944055544957658,0.00100539206842470,0.00109061950370202,0.00120133467094266,0.00133897178858794,0.00150478913925631,0.00169985691009956,0.00192504630532671,0.00218102001963473,0.00246822415161980,0.00278688162594521,0.00313698718218756,0.00351830397695125,0.00393036183411694,0.00437245716606016,0.00484365457643032,0.00534279014271149,0.00586847636438569,0.00641910875018152,0.00699287400570915,0.00758775977084797,0.00820156584465783,0.00883191682441567,0.00947627607472232,0.0101319609325610,0.0107961590447957,0.0114659457259479,0.0121383022162499,0.0128101347130022,0.0134782940422176,0.0141395958324610,0.0147908410487309,0.0154288367412137,0.0160504168617901,0.0166524630003125,0.0172319248929003,0.0177858405558260,0.0183113559009712,0.0188057436923127,0.0192664217074184,0.0196909699734666,0.0200771469538074,0.0204229045685111,0.0207264019406484,0.0209860177691472,0.0212003612389180,0.0213682813894500,0.0214888748741776,0.0215614920545246,0.0215857413845566,0.0215614920545246,0.0214888748741776,0.0213682813894500,0.0212003612389180,0.0209860177691472,0.0207264019406484,0.0204229045685111,0.0200771469538074,0.0196909699734666,0.0192664217074184,0.0188057436923127,0.0183113559009712,0.0177858405558260,0.0172319248929003,0.0166524630003125,0.0160504168617901,0.0154288367412137,0.0147908410487309,0.0141395958324610,0.0134782940422176,0.0128101347130022,0.0121383022162499,0.0114659457259479,0.0107961590447957,0.0101319609325610,0.00947627607472232,0.00883191682441567,0.00820156584465783,0.00758775977084797,0.00699287400570915,0.00641910875018152,0.00586847636438569,0.00534279014271149,0.00484365457643032,0.00437245716606016,0.00393036183411694,0.00351830397695125,0.00313698718218756,0.00278688162594521,0.00246822415161980,0.00218102001963473,0.00192504630532671,0.00169985691009956,0.00150478913925631,0.00133897178858794,0.00120133467094266,0.00109061950370202,0.00100539206842470,0.000944055544957658,0.000904864914120499];
    a = 1;
else
    %[b, a] = fir1(config.CLT.filter.order, config.CLT.filter.fc/(config.reqFs/2), config.CLT.filter.type);
    error('CLT filter parameters are not supported. Pre-design the filters before you can use them.');
end


y = filtfilt(b,a, signal);

winsize = config.CLT.filter.winsize;

len = length(y);
CL = zeros(1, len);

for i=2+winsize:len
    k = i-winsize:i;
    CL(i) = sum(sqrt(dtSqr + (y(k) - y(k-1)).^2));
end
