function swapSignals = reArrangeData(signals, pos)

% perform simple swap in the signals accourding to pos

swapSignals = signals;

for i=1:length(pos)
    swapSignals(i,:) = signals(pos(i),:); 
    swapSignals(pos(i),:) = signals(i,:);
end