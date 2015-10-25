function res = getTimeForSave()
% res = datestr(datetime('now', 'format', 'yyyy-MM-dd HH:mm:ss'));
res = datestr(datetime('now', 'format', 'yyyy-MM-dd HH:mm:ss'), 'yyyy-MM-dd HH:mm:ss');
