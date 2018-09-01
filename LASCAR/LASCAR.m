classdef LASCAR < matlab.mixin.SetGet
properties
    dataDir
    gui
    rawData  = LASCAR_Raw;
    postData = LASCAR_Processed;
end

methods
    function Obj = LASCAR()
        Obj.gui = LASCAR_GUI;
    end
end
    
methods (Static)
    function Obj = run(varargin)
        Obj = LASCAR;
        files = varargin{1};
        file2Read = max(size(files));
        for iFile = 1:file2Read
            Obj.rawData(iFile).File =  files{iFile};
            Obj.rawData(iFile).set_data;
            Obj.postData(iFile).File =  files{iFile};
            Obj.postData(iFile).set_data;
        end
    end
end
end