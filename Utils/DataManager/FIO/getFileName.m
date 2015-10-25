function [fileName, path, ext] = getFileName(fileFullPath)
%[fileName, path, ext] = getFileName(fileFullPath)

try
    [aa, bb, cc] = fileparts(fileFullPath);
    fileName = bb;
    path = aa;
    ext = cc;
catch
    fileName = [];
    path = [];
    ext = [];
end