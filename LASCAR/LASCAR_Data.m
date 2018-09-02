classdef (Abstract) LASCAR_Data < matlab.mixin.SetGet
    properties
        File
        Info
        Data
        numLoS
        angElv
        CNR
        currentTime
        timeStop
        angAzm
        velRad
        gateRange
        wakeChar
        wakeChar_10min
        wakeChar_dir
    end
    methods
        function Obj = LASCAR_Data()
        end
        set_data(Obj)
    end
    
end