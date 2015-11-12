function RTAnalyzeAcq2mat(handles)
% This function converts all valid .acq files in folder to .mat and returns
% and displays an appropriate message.
% Input - handles - handle to GUI figure
try
    set(handles.text6,'String','Converting acq to mat ...');
    pause(0.1);
    count=acq2matFunc(handles.folder);
    if ~isempty(count)
        switch count
            case 0
            set(handles.text6,'String','No files were converted');
            case 1
            set(handles.text6,'String',[ num2str(count) ' file was successfully converted']);
            otherwise
            set(handles.text6,'String', [ num2str(count) ' files were successfully converted']);
        end;
    end
catch ME
    set(handles.text6,'String','File conversion from .acq to .mat had failed');
    RTAnalyzeLog(handles,ME);
end
end