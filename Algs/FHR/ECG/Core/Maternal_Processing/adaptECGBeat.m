function ecg_adapted = adaptECGBeat(localTemplate, currECG, localPeakInd, QRS, config)

%% #pragmas
%#codegen

%% Coder directives
% coder.extrinsic('disp');
% coder.extrinsic('tic');
% coder.extrinsic('toc');
coder.varsize('R_iterative',    [30 5], [1 1]); % #CODER_VARSIZE
coder.varsize('err',            [30 1], [1 0]); % #CODER_VARSIZE
coder.varsize('Err',            [30 1], [1 0]); % #CODER_VARSIZE
coder.varsize('E',              [30 1], [1 0]); % #CODER_VARSIZE
coder.varsize('lambda',         [30 1], [1 0]); % #CODER_VARSIZE

%% Code
PHI_M = currECG;
% Reconstruction params
maxLen = length(currECG);
inds_temp.P   = 1:localPeakInd+QRS.onset-1;
inds_temp.QRS = localPeakInd + (QRS.onset:QRS.offset);
inds_temp.T   = localPeakInd+QRS.offset+1:maxLen;

inds_temp.P  (inds_temp.P   <=0 | inds_temp.P   >maxLen) = [];
inds_temp.QRS(inds_temp.QRS <=0 | inds_temp.QRS >maxLen) = [];
inds_temp.T  (inds_temp.T   <=0 | inds_temp.T   >maxLen) = [];

inds = inds_temp;

tmpVal = median(PHI_M./localTemplate);
if(tmpVal>2 || tmpVal<0.5)
    tmpVal = 1.2;
end

mult.P = tmpVal;
mult.QRS = tmpVal*config.QRSMultCorct;
mult.T = tmpVal;

reconParams.inds = inds;
reconParams.val = [mult.P, mult.QRS, mult.T];

% Alg params
iti     = 1;
k       = 1;
err     = inf;
E       = config.initE;
dR      = config.dR;
lambda  = config.lambda;
Niti    = config.maxIti;
c1      = config.corctP1;
c2      = config.corctP2;

if(Niti>30)
    error('Maximum supported number of iterations is 30.'); % changes the coder.varsize() if you want to use >30 iterations
end
if(length(reconParams.val)>5)
    error('Maximum supported number of reconstruction parameters is 5.'); % changes the coder.varsize() if you want to use >30 iterations
end

R_iterative = [reconParams.val];
Err = inf;
J = zeros(length(currECG), size(R_iterative, 2));
R_good = reconParams.val;

maxlag = length(PHI_M) - 1;
nextPow = 2^nextpow2(2*maxlag + 1);
preCalcFFT = conj(fft(PHI_M, nextPow));
sumSqr = sum(PHI_M.*PHI_M);


while(true)
    phi_c = doAdapt(reconParams.val, reconParams.inds, localTemplate, config); % Calc potentials
    [corrVal, corrLag] = xcorr_muha_lag__preload(phi_c, preCalcFFT, nextPow, sumSqr);
    shift = corrLag + 1;
    
    if(shift~=0)
        phi_c = circshift(phi_c, [0, -shift]); % Phase shift
    end
    
    temp_here = norm(phi_c - PHI_M);
    err = [err; temp_here*temp_here]; % Cost function: norm L2
    Err = [Err; corrVal]; % Cost function: Corr Coeff
    flag = floor(E(end)/err(end));
    if(flag)
        J = Jacobian(localTemplate, phi_c, reconParams, config);
        E = [E; err(end)]; 
        lambda = [lambda; lambda(end)/c1];
        R_good = reconParams.val;
        k = k+1;
    else
        lambda = [lambda; lambda(end)*c2];
    end
    
    J_T_J=J'*J;
    R_iterative = [R_iterative; R_good - (((J_T_J+lambda(end)*diag(diag(J_T_J)))^-1)*J'*((phi_c-PHI_M)'))'];
    dR = sum(abs((reconParams.val-R_iterative(k,:)))); % delta_R
    reconParams.val(:) = R_iterative(k,:);
    iti=iti+1;
    
    if~(iti<Niti && dR>1e-4 && err(end)>5e-4)
        break;
    end
    
end

[~, corrLag] = xcorr_muha_lag__preload(phi_c, preCalcFFT, nextPow, sumSqr);
shift = corrLag + 1;

if(shift~=0)
    ecg_adapted = circshift(phi_c, [0, -shift]);
else
    ecg_adapted = phi_c;
end

%% Private functions
% function J = Jacobian(template, phi_c, reconParams, config)
% function signal = doAdapt(mult, inds, signal, config)
