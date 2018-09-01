classdef LASCAR_Processed < LASCAR_Raw
    properties
        noise
    end
    methods
        function Obj = LASCAR_Processed()
        end
        function set_data(Obj)
            set_data@LASCAR_Raw(Obj);
            Obj.noise = (Obj.CNR< -25 | Obj.CNR > 0);
            Obj.CNR(Obj.noise) = 0;
            Obj.velRad(Obj.noise) = 0;
            Obj.get_wake_character;
        end
        function get_wake_character(Obj)
            intVelRad = reshape(Obj.velRad,30,[],197);
            Obj.wakeChar = squeeze(mean(intVelRad,2));
            azimuths = reshape(Obj.angAzm,30,[]);
            
            tenMin = 1/24/6;
            timeGates = [Obj.timeStop(1):tenMin:Obj.timeStop(end) Obj.timeStop(end)];
            ind = arrayfun(@(x,y) find(Obj.timeStop>=x&Obj.timeStop<y),timeGates(1:end-1),timeGates(2:end),'uni',false);
            for iTenMins = 1:size(ind,2)-1
                modular = mod(size(ind{iTenMins},1),30);
                if modular>15
                    extractFromNext = ind{iTenMins+1}(1:30-modular);
                    ind{iTenMins}(end+1:end+30-modular) = extractFromNext;
                    ind{iTenMins+1}(1:30-modular) = [];
                elseif modular > 0
                    add2Next = ind{iTenMins}(end-modular+1:end);
                    ind{iTenMins}(end-modular+1:end) = [];
                    ind{iTenMins+1} = [add2Next; ind{iTenMins+1}];
                end
            end
                ind(end) = [];
                timeStamps = reshape(Obj.timeStop,30,[]);
            for iTenMins = 1:size(ind,2)
                [lineNum,scanNum] =ind2sub(size(timeStamps),ind{iTenMins});
                uniLine = unique(lineNum);
                uniScan = unique(scanNum);
                for iLine = 1:length(uniLine)
                    noUseBeamInd = sum(squeeze(intVelRad(iLine,uniScan,:))==0,1)>10;
                    intVelRad(iLine,uniScan,noUseBeamInd) = NaN;
                end
                Obj.wakeChar_10min.value(:,:,iTenMins) = squeeze(mean(intVelRad(:,uniScan,:),2));
                Obj.wakeChar_10min.Normvalue(:,:,iTenMins) = Obj.wakeChar_10min.value(:,:,iTenMins)./Obj.wakeChar_10min.value(6,74,iTenMins);
                Obj.wakeChar_10min.time(iTenMins) = Obj.timeStop(ind{iTenMins}(end));
                Obj.wakeChar_10min.azimuth(:,iTenMins) = deg2rad(mean(azimuths(:,uniScan),2));
            end
           
        end
    end
    
end