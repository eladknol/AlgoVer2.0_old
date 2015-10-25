function relPath = getRelativePath(fullPath, baseDir)

relPath = strrep(fullPath, baseDir, '');