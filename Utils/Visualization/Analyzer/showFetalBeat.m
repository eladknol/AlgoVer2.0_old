function resText = showFetalBeat(src, evntData)
% text update part
resText = sprintf('%s \n%s \n ',...
    ['Beat#     : ' num2str(src.Cursor.Position(1))],...
    ['fHR value : '  num2str(src.Cursor.Position(2))]...
    );


% Now for the fun!!

% beat #
currBeatNum = floor(src.Cursor.Position(1));

global GCF_LOCAL;
loadData = getappdata(GCF_LOCAL, 'loadData');

if(isempty(loadData))
    disp('Cannot have fun :(');
    return;
end

handles = getappdata(GCF_LOCAL, 'UsedByGUIData_m');
selectedSignal = get(handles.popupmenu_channel_select, 'value');
currFetalPeak = loadData.fQRS.fQRS_struct.fQRS(currBeatNum);

mult = 1;
currFetalQRSComplex = getQRSComplex(loadData.removeStruct.fetData(selectedSignal, :), currFetalPeak, currFetalPeak==1 || currFetalPeak==length(loadData.fQRS.fQRS_struct.fQRS), mult, 0, 1);

templateSize = getQRSTemplateSize(mult);

% Highlight the current beat only
beforePad = nan(1)*(1:(currFetalPeak + templateSize.onset));
currFetalQRSComplex = [beforePad currFetalQRSComplex];
figure,
xData = linspace(+2/loadData.removeStruct.metaData.Fs, length(loadData.removeStruct.fetData(selectedSignal, :))/loadData.removeStruct.metaData.Fs, length(loadData.removeStruct.fetData(selectedSignal, :)));
plot(xData, loadData.removeStruct.fetData(selectedSignal, :));
hold on;

xData = linspace(0, length(currFetalQRSComplex)/loadData.removeStruct.metaData.Fs, length(currFetalQRSComplex));
plot(xData, currFetalQRSComplex, 'k');
plot(xData, currFetalQRSComplex, '.r');
grid on;
zoom on;

title('Fetal ECG data');
legend('fECG', 'Selected peak', 'Selected beat');


%[ECG, beatLen, nullDataInds] = getAllBeats(loadData.fQRS.fQRS_struct.fQRS, loadData.removeStruct.fetData(selectedSignal, :));
%matVecCorr(ECG, getQRSComplex(loadData.removeStruct.fetData(selectedSignal, :), currFetalPeak, currFetalPeak==1 || currFetalPeak==length(loadData.fQRS.fQRS_struct.fQRS), mult, 0, 1));