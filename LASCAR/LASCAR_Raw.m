classdef LASCAR_Raw < LASCAR_Data
    properties
        beamHeight
    end
    methods
        function Obj = LASCAR_Raw()
        end
        function set_data(Obj)
            Obj.Info.numCol  = 796;
            rawDat  = fileread(Obj.File);
            rawDat  =  textscan(rawDat,'%f','Delimiter',';');
            rawDat  = rawDat{1};
            rawDat  = reshape(rawDat,Obj.Info.numCol,[])';
            endtoberemoved = mod(size(rawDat,1),30);
            if endtoberemoved == 0
                endtoberemoved = 30;
            end
            data2use = 31:(size(rawDat,1)-endtoberemoved);
            Obj.numLoS    = rawDat(data2use,2);
            Obj.timeStop  = datenum(datetime(rawDat(data2use,6)-2082844800-(1/(24*6)),'ConvertFrom','posixtime'));
            Obj.angAzm    = rawDat(data2use,7);
            Obj.angElv    = rawDat(data2use,8);
            Obj.gateRange = unique(rawDat(data2use,9:4:end));
            Obj.velRad    = rawDat(data2use,10:4:end);
            Obj.CNR       = rawDat(data2use,11:4:end);
            Obj.Info.start_date = datestr(Obj.timeStop(1));
            Obj.Info.end_date   = datestr(Obj.timeStop(end));
        end
    end
   
end