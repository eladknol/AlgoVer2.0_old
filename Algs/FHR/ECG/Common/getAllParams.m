function params = getAllParams()

params.Fs = 1000;
params.normMatRRSTD = 90; % in mSec

mAge=30;
params.maxMaternalHR = 220 - mAge;
