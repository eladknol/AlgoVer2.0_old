function chInds = getChannelsByType(configProvider, inChType)

chInds = [];
coder.varsize('chInds', [1 inf], [0 1]);
for iCh=1:configProvider.GEN_CFG.nNumOfChannels
    if(strcmpi(configProvider.GEN_CFG.channelType(iCh).value, inChType))
        chInds = [chInds iCh];
    end
end