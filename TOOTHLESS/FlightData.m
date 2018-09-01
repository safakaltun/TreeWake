classdef FlightData < matlab.mixin.SetGet
    properties 
        StartDate
        File
    end
    properties
        Time_s
        Time_str
        Time_act
        Latitude
        Longitude
        Northing
        Easting
        FlightMode
        Altitude_ft
        Altitude_m
        VpsAltitude_f
        VpsAltitude_m
        HSpeed_mph
        HSpeed_ms
        GpsSpeed_mph
        GpsSpeed_ms
        HomeDistance_f
        HomeDistance_m
        HomeLatitude
        HomeLongitude
        GpsCount
        BatteryPower_p
        BatteryVoltage
        BatteryVoltageDeviation
        BatteryCell1Voltage
        BatteryCell2Voltage
        BatteryCell3Voltage
        VelocityX
        VelocityY
        VelocityZ
        Pitch
        Roll
        Yaw
        Yaw_360
        RcAileron
        RcElevator
        RcGyro
        RcRudder
        RcThrottle
        NonGpsError
        GoHomeStatus
        AppTip
        AppWarning
        AppMessage
    end
    methods
        function Obj = FlightData()
        end
        function gps_filter(Obj)
            gpsIndx = Obj.GpsCount<10;
            fields = fieldnames(Obj);
            fields(1:2) = [];
            for iField = 1:length(fields)
                Obj.(fields{iField})(gpsIndx,:) = [];
            end
            
        end
    end
end