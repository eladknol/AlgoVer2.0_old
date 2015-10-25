classdef FileManager
    %DataManager manages the files
    %   This is the main files manager
    % Any file related operation should be implemented here 
    % Any file related operation should pass through this class
    % This class should be hidden from the end user, only a superclass can control this class 
 
    % Subclasses:
        % no
    % SuperClasses
        % (1) DataManager
    
    properties
        databasePath = matDataDir();
    end
    
    methods(Access = 'public', Static = true)
        function fileFullPath = getECGFile(database)
            if(nargin)
                %                 GUI_CommonClassInst.databasePath = matDataDir(database);
                databasePath = matDataDir(database);
            end
            
            ccd = cd;
            cd(databasePath);
            filesFilter = {'*.mat'};
            [fileName, pathName] = uigetfile(filesFilter,'Select a file');
            cd(ccd);
            if(pathName==0)
                fileFullPath = [];
            else
                fileFullPath = [pathName fileName];
            end
        end
        function Files = getECGFilesList(database)
            if(nargin)
                %                 GUI_CommonClassInst.databasePath = matDataDir(database);
                databasePath = matDataDir(database);
            end
            
            ccd = cd;
            cd(databasePath);
            filesFilter = {'*.mat'};
            files = dir(filesFilter{1});
            for i = 1:length(files)
                Files{i} = [databasePath '\' files(i).name];
            end
            cd(ccd);
        end
        
    end
    
end

