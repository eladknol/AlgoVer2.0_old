function E = getSignalEnergy(signal)
E = nansum(signal.*signal);
