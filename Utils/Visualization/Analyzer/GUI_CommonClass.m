classdef GUI_CommonClass
    %GUI_COMMONCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dataBasePath = matDataDir();
    end
    
    methods(Access = 'public', Static = true)
        function fileFullPath = getECGFile(database)
            if(nargin)
                %                 GUI_CommonClassInst.dataBasePath = matDataDir(database);
                dataBasePath = matDataDir(database);
            end
            
            ccd = cd;
            cd(dataBasePath);
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
                %                 GUI_CommonClassInst.dataBasePath = matDataDir(database);
                dataBasePath = matDataDir(database);
            end
            
            ccd = cd;
            cd(dataBasePath);
            filesFilter = {'*.mat'};
            files = dir(filesFilter{1});
            for i = 1:length(files)
                Files{i} = [dataBasePath '\' files(i).name];
            end
            cd(ccd);
        end
        
    end
    
end

