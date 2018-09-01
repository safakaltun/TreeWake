classdef Toothless < matlab.mixin.SetGet
    %     https://forum.dji.com/thread-114810-1-1.html
    properties
        Folder = dir('R:\SpecialCourseSafak\TOOTHLESS_Data\*.csv');
        Files
        Data = FlightData;
    end
    methods
        function Obj = Toothless()
            Obj.import_csv_files;
        end
        function import_csv_files(Obj)
            Obj.Files = [char({Obj.Folder.folder}') repmat('\',size(Obj.Folder,1),1) char({Obj.Folder.name}')];
            Obj.Data(size(Obj.Files,1)) = FlightData;
            for iFile = 1:size(Obj.Files,1)
                fid = fopen(Obj.Files(iFile,:));
                dat = textscan(fid,'%s','Delimiter','\n');
                fclose(fid);
                newDat = cellfun(@(x) strsplit(x,',','CollapseDelimiters',false),dat{:},'uni',false);
                shapedDat = reshape([newDat{:}],42,[])';
                [~,filename] = fileparts(Obj.Files(iFile,:));
                date = strsplit(filename,'_');
                Obj.Data(iFile).StartDate                = datenum([date{2} '_' date{3}],'yyyy-mm-dd_[HH-MM-SS]');
                Obj.Data(iFile).File                     = Obj.Files(iFile,:);
                Obj.Data(iFile).Time_s                   = str2num(char(shapedDat(2:end,2)));
                Obj.Data(iFile).Time_act                 = Obj.Data(iFile).StartDate + (Obj.Data(iFile).Time_s.*(1/24/60/60));
                Obj.Data(iFile).Time_str                 = datestr(Obj.Data(iFile).Time_act,'yyyy-mm-dd HH:MM:SS.FFF');
                Obj.Data(iFile).Latitude                 = str2num(char(shapedDat(2:end,4)));
                Obj.Data(iFile).Longitude                = str2num(char(shapedDat(2:end,5)));
                [Obj.Data(iFile).Easting,Obj.Data(iFile).Northing] = wgs2utm(Obj.Data(iFile).Latitude ,Obj.Data(iFile).Longitude ,32,'N');
                Obj.Data(iFile).FlightMode               = shapedDat(2:end,6);
                Obj.Data(iFile).Altitude_ft              = str2num(char(shapedDat(2:end,7)));
                Obj.Data(iFile).Altitude_m               = str2num(char(shapedDat(2:end,8)));
                shapedDat(cell2mat(cellfun(@(x) isempty(x),shapedDat(:,9),'uni',false)),9) = {'NaN'};
                Obj.Data(iFile).VpsAltitude_f            = str2num(char(shapedDat(2:end,9)));
                shapedDat(cell2mat(cellfun(@(x) isempty(x),shapedDat(:,10),'uni',false)),10) = {'NaN'};
                Obj.Data(iFile).VpsAltitude_m            = str2num(char(shapedDat(2:end,10)));
                Obj.Data(iFile).HSpeed_mph               = str2num(char(shapedDat(2:end,11)));
                Obj.Data(iFile).HSpeed_ms                = str2num(char(shapedDat(2:end,12)));
                Obj.Data(iFile).GpsSpeed_mph             = str2num(char(shapedDat(2:end,13)));
                Obj.Data(iFile).GpsSpeed_ms              = str2num(char(shapedDat(2:end,14)));
                Obj.Data(iFile).HomeDistance_f           = str2num(char(shapedDat(2:end,15)));
                Obj.Data(iFile).HomeDistance_m           = str2num(char(shapedDat(2:end,16)));
                Obj.Data(iFile).HomeLatitude             = str2num(char(shapedDat(2:end,17)));
                Obj.Data(iFile).HomeLongitude            = str2num(char(shapedDat(2:end,18)));
                Obj.Data(iFile).GpsCount                 = str2num(char(shapedDat(2:end,19)));
                Obj.Data(iFile).BatteryPower_p           = str2num(char(shapedDat(2:end,20)));
                Obj.Data(iFile).BatteryVoltage           = str2num(char(shapedDat(2:end,21)));
                Obj.Data(iFile).BatteryVoltageDeviation  = str2num(char(shapedDat(2:end,22)));
                Obj.Data(iFile).BatteryCell1Voltage      = str2num(char(shapedDat(2:end,23)));
                Obj.Data(iFile).BatteryCell2Voltage      = str2num(char(shapedDat(2:end,24)));
                Obj.Data(iFile).BatteryCell3Voltage      = str2num(char(shapedDat(2:end,25)));
                Obj.Data(iFile).VelocityX                = str2num(char(shapedDat(2:end,26)));
                Obj.Data(iFile).VelocityY                = str2num(char(shapedDat(2:end,27)));
                Obj.Data(iFile).VelocityZ                = str2num(char(shapedDat(2:end,28)));
                Obj.Data(iFile).Pitch                    = str2num(char(shapedDat(2:end,29)));
                Obj.Data(iFile).Roll                     = str2num(char(shapedDat(2:end,30)));
                Obj.Data(iFile).Yaw                      = str2num(char(shapedDat(2:end,31)));
                Obj.Data(iFile).Yaw_360                  = str2num(char(shapedDat(2:end,32)));
                Obj.Data(iFile).RcAileron                = str2num(char(shapedDat(2:end,33)));
                Obj.Data(iFile).RcElevator               = str2num(char(shapedDat(2:end,34)));
                Obj.Data(iFile).RcGyro                   = str2num(char(shapedDat(2:end,35)));
                Obj.Data(iFile).RcRudder                 = str2num(char(shapedDat(2:end,36)));
                Obj.Data(iFile).RcThrottle               = str2num(char(shapedDat(2:end,37)));
                Obj.Data(iFile).NonGpsError              = shapedDat(2:end,38);
                Obj.Data(iFile).GoHomeStatus             = shapedDat(2:end,39);
                Obj.Data(iFile).AppTip                   = shapedDat(2:end,40);
                Obj.Data(iFile).AppWarning               = shapedDat(2:end,41);
                Obj.Data(iFile).AppMessage               = shapedDat(2:end,42);
                Obj.Data(iFile).gps_filter;
            end
        end
        function delete(~)
            fclose('all');
        end
    end
    
end