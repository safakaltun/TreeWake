classdef MAST < matlab.mixin.SetGet
    properties
        File = 'R:\SpecialCourseSafak\MAST_Data\V52data_Oct2017_Feb2018.csv';
        Data
        
    end
    methods
        function Obj = MAST()
            csvData = csvread(Obj.File,1,0);
            scan = textscan(fopen(Obj.File),'%s');
            header = strsplit(scan{1}{2},',');
            header{1} = 'Time';
            for iColumn = 1:size(csvData,2)
                Obj.Data.(header{iColumn}).value = csvData(:,iColumn);
                if strcmpi(header{iColumn}(end-3:end),'mean')
                    Obj.Data.(header{iColumn}).value(Obj.Data.(header{iColumn}).value>50) = 0;
                end
                if strcmpi(header{iColumn},'Time')
                    Obj.Data.Time.value = datenum(num2str(Obj.Data.Time.value),'yyyymmddHHMM');
                end
                Obj.Data.(header{iColumn}).isTS = true;
            end
            Obj.filter_data;
            Obj.set_potential_temp;
            Obj.get_stability;
            Obj.get_TI;
%             WindRose(Obj.Data.Wdir_41m,Obj.Data.Wsp_70m_mean)
        end
        function filter_data(Obj)
            ind = false(size(Obj.Data.AirAbs_18m.value));
            fields = fieldnames(Obj.Data);
            [Obj.Data.Time.value,tInd] = sort(Obj.Data.Time.value);

            for iChs = 2:length(fields)
                Obj.Data.(fields{iChs}).value = Obj.Data.(fields{iChs}).value(tInd);
                ind = (Obj.Data.(fields{iChs}).value == -9999) | ind;
            end
            ind2 = [false;(abs(diff(Obj.Data.AirAbs_18m.value))>3 | abs(diff(Obj.Data.AirAbs_18m.value))==0)];
            ind2 = ind2 | [false;(abs(diff(Obj.Data.AirAbs_70m.value))>3 | abs(diff(Obj.Data.AirAbs_70m.value))==0)];
            
            
            indWsp = Obj.Data.Wsp_70m_mean.value<1.5 | Obj.Data.Wsp_57m_mean.value<1.5 | Obj.Data.Wsp_44m_mean.value<1.5...
               | Obj.Data.Wsp_31m_mean.value<1.5 | Obj.Data.Wsp_18m_mean.value<1.5;
            
            
            for iChs = 2:length(fields)
                Obj.Data.(fields{iChs}).value(ind | ind2 | indWsp) = NaN;
            end
        end
        function set_potential_temp(Obj)
            
            g = 9.81;
            cp = 1004.67;           % specific heat for dry air at constant pressure
            Obj.Data.PotTemp_18m.value = Obj.Data.AirAbs_18m.value + 18*g/cp;
            Obj.Data.PotTemp_70m.value = Obj.Data.AirAbs_70m.value + 70*g/cp;
        end
        function get_stability(Obj)
            vLow  = Obj.Data.Wsp_18m_mean.value.*sind(Obj.Data.Wdir_41m.value);
            uLow  = Obj.Data.Wsp_18m_mean.value.*cosd(Obj.Data.Wdir_41m.value);
            vHigh = Obj.Data.Wsp_70m_mean.value.*sind(Obj.Data.Wdir_41m.value);
            uHigh = Obj.Data.Wsp_70m_mean.value.*cosd(Obj.Data.Wdir_41m.value);
            
            
            g = 9.81;
            Tv = Obj.Data.AirAbs_70m.value+273;
            dThetaV = Obj.Data.PotTemp_70m.value-Obj.Data.PotTemp_18m.value;
            dZ = 70-18;
            dU = uHigh-uLow;
            dV = vHigh-vLow;
            
            top = ((g./Tv).*dThetaV.*dZ);
            bottom = (dU.^2)+(dV.^2);
            Obj.Data.Ri1870.value = top./bottom;
            
%             
        end
        function get_TI(Obj)
            Obj.Data.TI_70m.value = Obj.Data.Wsp_70m_std.value./Obj.Data.Wsp_70m_mean.value;
            Obj.Data.TI_57m.value = Obj.Data.Wsp_57m_std.value./Obj.Data.Wsp_57m_mean.value;
            Obj.Data.TI_44m.value = Obj.Data.Wsp_44m_std.value./Obj.Data.Wsp_44m_mean.value;
            Obj.Data.TI_31m.value = Obj.Data.Wsp_31m_std.value./Obj.Data.Wsp_31m_mean.value;
            Obj.Data.TI_18m.value = Obj.Data.Wsp_18m_std.value./Obj.Data.Wsp_18m_mean.value;
        end
    end
end