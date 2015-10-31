function ParseArgs( varscell )

nArg = length(varscell);
if rem( nArg, 2 ) 
	error('Invalid number of Name/Value pairs');
end
for i=1:2:nArg
    name = varscell{i};
    value = varscell{i+1};
	assignin('caller',name,value);
end

end