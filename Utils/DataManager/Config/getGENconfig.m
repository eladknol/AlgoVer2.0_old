function gen_cfg = getGENconfig(sampleRate)

nNumOfChannels = 10;
% Signal params
gen_cfg.sampleRate = sampleRate;
gen_cfg.satLevel = 10;

gen_cfg.channelType = repmat(struct('value', 'ECG'), 10,1);

coder.varsize('gen_cfg.channelType', [10 1], [1 0]); % #CODER_VARSIZE

temp = ['ECG'; 'ECG'; 'ECG'; 'ECG'; 'ECG'; 'ECG'; 'MIC'; 'MIC'; 'MIC'; 'MIC'];

for i=1:nNumOfChannels
    gen_cfg.channelType(i).value = temp(i,:);
end

gen_cfg.nNumOfChannels = nNumOfChannels;

% env params
gen_cfg.usePar = true(1);
gen_cfg.useStats = true(1);

% Error handling
gen_cfg.errorCodes = getErrorCodes();
