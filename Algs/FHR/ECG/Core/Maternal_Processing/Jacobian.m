function J = Jacobian(template, phi_c, reconParams, config)

nNumOfParams = length(reconParams.val);
lenPot = length(phi_c);
J = zeros(nNumOfParams, lenPot);
delta = config.jacbDelta;
R = reconParams.val;
for i = 1:nNumOfParams
    R_temp = R;
    R_temp(i) = R_temp(i) + delta;
    reconParams.val = R_temp;
    phi = doAdapt(reconParams.val, reconParams.inds, template, config);
    J(i,:) = (phi-phi_c)/delta;
end
J = J';
