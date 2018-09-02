classdef LASCAR_Processed < LASCAR_Raw
    properties
        noise
        spd
        dir
    end
    methods
        function Obj = LASCAR_Processed()
        end
        function set_data(Obj)
            set_data@LASCAR_Raw(Obj);
            Obj.noise = (Obj.CNR< -25 | Obj.CNR > 0);
            Obj.CNR(Obj.noise) = 0;
            Obj.velRad(Obj.noise) = 0;
            Obj.get_velocity_components;
            Obj.get_direction;
            Obj.get_wake_character;
        end
        function get_velocity_components(Obj)
            for i = 1:197
                intVelRad = reshape(Obj.velRad,30,[],197);
                intVelRad(:,1,:) = [];
                intVelRad = intVelRad(15:30,:,i);
                azimuths = reshape(Obj.angAzm,30,[]);
                azimuths(:,1) = [];
                azimuths = azimuths(15:30,:);
                
                Obj.spd.u1530(i,:) = ((sum(intVelRad.*cosd(azimuths),1).*sum(sind(azimuths).^2,1))-...
                    (sum(intVelRad.*sind(azimuths),1).*sum(cosd(azimuths).*sind(azimuths),1)))./...
                    ((sum(cosd(azimuths).^2,1).*sum(sind(azimuths).^2,1))-...
                    (sum(cosd(azimuths).*sind(azimuths),1).^2));
                
                Obj.spd.v1530(i,:) = ((sum(intVelRad.*sind(azimuths),1).*sum(cosd(azimuths).^2,1))-...
                    (sum(intVelRad.*cosd(azimuths),1).*sum(cosd(azimuths).*sind(azimuths),1)))./...
                    ((sum(cosd(azimuths).^2,1).*sum(sind(azimuths).^2,1))-...
                    (sum(cosd(azimuths).*sind(azimuths),1).^2));
            end
            
            for i = 1:197
                intVelRad = reshape(Obj.velRad,30,[],197);
                intVelRad(:,1,:) = [];
                intVelRad = intVelRad(2:12,:,i);
                azimuths = reshape(Obj.angAzm,30,[]);
                azimuths(:,1) = [];
                azimuths = azimuths(2:12,:);
                
                Obj.spd.u212(i,:) = ((sum(intVelRad.*cosd(azimuths),1).*sum(sind(azimuths).^2,1))-...
                    (sum(intVelRad.*sind(azimuths),1).*sum(cosd(azimuths).*sind(azimuths),1)))./...
                    ((sum(cosd(azimuths).^2,1).*sum(sind(azimuths).^2,1))-...
                    (sum(cosd(azimuths).*sind(azimuths),1).^2));
                
                Obj.spd.v212(i,:) = ((sum(intVelRad.*sind(azimuths),1).*sum(cosd(azimuths).^2,1))-...
                    (sum(intVelRad.*cosd(azimuths),1).*sum(cosd(azimuths).*sind(azimuths),1)))./...
                    ((sum(cosd(azimuths).^2,1).*sum(sind(azimuths).^2,1))-...
                    (sum(cosd(azimuths).*sind(azimuths),1).^2));
            end
            
            for i = 1:197
                intVelRad = reshape(Obj.velRad,30,[],197);
                intVelRad(:,1,:) = [];
                intVelRad = intVelRad(1:30,:,i);
                azimuths = reshape(Obj.angAzm,30,[]);
                azimuths(:,1) = [];
                azimuths = azimuths(1:30,:);
                
                Obj.spd.uall(i,:) = ((sum(intVelRad.*cosd(azimuths),1).*sum(sind(azimuths).^2,1))-...
                    (sum(intVelRad.*sind(azimuths),1).*sum(cosd(azimuths).*sind(azimuths),1)))./...
                    ((sum(cosd(azimuths).^2,1).*sum(sind(azimuths).^2,1))-...
                    (sum(cosd(azimuths).*sind(azimuths),1).^2));
                
                Obj.spd.vall(i,:) = ((sum(intVelRad.*sind(azimuths),1).*sum(cosd(azimuths).^2,1))-...
                    (sum(intVelRad.*cosd(azimuths),1).*sum(cosd(azimuths).*sind(azimuths),1)))./...
                    ((sum(cosd(azimuths).^2,1).*sum(sind(azimuths).^2,1))-...
                    (sum(cosd(azimuths).*sind(azimuths),1).^2));
            end
        end
        function get_direction(Obj)
            Obj.dir.value1530 = rad2deg(atan2(Obj.spd.v1530,Obj.spd.u1530))+180;
            Obj.dir.value212  = rad2deg(atan2(Obj.spd.v212,Obj.spd.u212))+180;
            Obj.dir.valueall  = rad2deg(atan2(Obj.spd.vall,Obj.spd.uall))+180;
        end
        function get_wake_character(Obj)
            %% All
            intVelRad = reshape(Obj.velRad,30,[],197);
            Obj.wakeChar = squeeze(mean(intVelRad,2));
            azimuths = reshape(Obj.angAzm,30,[]);
            %% 10 Min
            tenMin = 1/24/6;
            h = (Obj.timeStop(1))-floor(Obj.timeStop(1));
            startTime = floor(Obj.timeStop(1))+ (floor(h/tenMin)+1)*tenMin;
            
            timeGates = [startTime:tenMin:Obj.timeStop(end) Obj.timeStop(end)];
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
                    noUseBeamInd = sum(squeeze(intVelRad(iLine,uniScan,:))==0,1)>22;
                    intVelRad(iLine,uniScan,noUseBeamInd) = NaN;
                end
                Obj.wakeChar_10min.value(:,:,iTenMins) = squeeze(mean(intVelRad(:,uniScan,:),2));
                Obj.wakeChar_10min.dirValue1530(:,iTenMins) =  mean(Obj.dir.value1530(:,uniScan),2);
                Obj.wakeChar_10min.dirValue212(:,iTenMins)  =  mean(Obj.dir.value212(:,uniScan),2);
                Obj.wakeChar_10min.dirValueall(:,iTenMins)  =  mean(Obj.dir.valueall(:,uniScan),2);
                Obj.wakeChar_10min.Normvalue(:,:,iTenMins) = Obj.wakeChar_10min.value(:,:,iTenMins)./Obj.wakeChar_10min.value(6,74,iTenMins);
                Obj.wakeChar_10min.time(iTenMins) = Obj.timeStop(ind{iTenMins}(end));
                Obj.wakeChar_10min.azimuth(:,iTenMins) = deg2rad(mean(azimuths(:,uniScan),2));
            end
            %% Direction Based
            
            intVelRad = reshape(Obj.velRad,30,[],197);
            azimuths = reshape(Obj.angAzm,30,[]);
            range = 68:82;
            wDir = mean(Obj.dir.value1530(range,:),1);
            numBins = sshist(wDir);
            binSize = 5;
%             bins = 200-binSize/2:binSize:330;
            
            [binCnt,bins,dirInd]= histcounts(wDir,numBins);
            
            
            %             uniDir = unique(dirInd);
            uniInd = find(binCnt>45);
            count = 0;
            for iDir = uniInd
                count = count+1;
                cond = dirInd==iDir;
                for iLine = 1:30
                    noUseBeamInd = sum(squeeze(intVelRad(iLine,cond,:))==0,1)>45;
                    intVelRad(iLine,cond,noUseBeamInd) = NaN;
                end
                Obj.wakeChar_dir.value(:,:,count) = mean(intVelRad(:,cond,:),2);
                Obj.wakeChar_dir.Normvalue(:,:,count) = Obj.wakeChar_dir.value(:,:,count)./Obj.wakeChar_dir.value(6,74,count);
                Obj.wakeChar_dir.azimuth(:,count) = deg2rad(mean(azimuths(:,cond),2));
                Obj.wakeChar_dir.bin(:,count) = bins(iDir);
            end
            
            
            %%
            
            fig = figure(97);
            fig.Position= [412 89 874 760];
            sp1 = subplot(2,2,1);
            sp2 = subplot(2,2,2);
            sp3 = subplot(2,2,3);
            sp4 = subplot(2,2,4);
            
            sf = surf(sp1,Obj.wakeChar_10min.time,Obj.gateRange,Obj.wakeChar_10min.dirValue1530);
            sf.EdgeColor = 'none';
            view(sp1,[0 0])
            
            sf = surf(sp2,Obj.wakeChar_10min.time,Obj.gateRange,Obj.wakeChar_10min.dirValue1530);
            sf.EdgeColor = 'none';
            view(sp2,[0 90])
            
            range = 68:82;
            sf = surf(sp3,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValue1530(range,:));
            sf.EdgeColor = 'none';
            hold(sp3,'on')
            %             figure;plot(Obj.gateRange(range),mean(Obj.wakeChar_10min.dirValue(range,:),1));
            
            view(sp3,[0 0])
            
            
            sf = surf(sp4,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValue1530(range,:));
            sf.EdgeColor = 'none';
            view(sp4,[0 90])
            Obj.wakeChar_10min.dirValue1530 = mean(Obj.wakeChar_10min.dirValue1530(range,:),1);
            
            %% Direction Based
            fig = figure(98);
            fig.Position= [412 89 874 760];
            sp1 = subplot(2,2,1);
            sp2 = subplot(2,2,2);
            sp3 = subplot(2,2,3);
            sp4 = subplot(2,2,4);
            
            sf = surf(sp1,Obj.wakeChar_10min.time,Obj.gateRange,Obj.wakeChar_10min.dirValue212);
            sf.EdgeColor = 'none';
            view(sp1,[0 0])
            
            sf = surf(sp2,Obj.wakeChar_10min.time,Obj.gateRange,Obj.wakeChar_10min.dirValue212);
            sf.EdgeColor = 'none';
            view(sp2,[0 90])
            
            range = 79:102;
            sf = surf(sp3,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValue212(range,:));
            sf.EdgeColor = 'none';
            hold(sp3,'on')
            %             figure;plot(Obj.gateRange(range),mean(Obj.wakeChar_10min.dirValue(range,:),1));
            
            view(sp3,[0 0])
            
            
            sf = surf(sp4,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValue212(range,:));
            sf.EdgeColor = 'none';
            view(sp4,[0 90])
            
            Obj.wakeChar_10min.dirValue212 = mean(Obj.wakeChar_10min.dirValue212(range,:),1);
            
            %% Direction Based
            fig = figure(99);
            fig.Position= [412 89 874 760];
            sp1 = subplot(2,2,1);
            sp2 = subplot(2,2,2);
            sp3 = subplot(2,2,3);
            sp4 = subplot(2,2,4);
            
            sf = surf(sp1,Obj.wakeChar_10min.time,Obj.gateRange,Obj.wakeChar_10min.dirValueall);
            sf.EdgeColor = 'none';
            view(sp1,[0 0])
            
            sf = surf(sp2,Obj.wakeChar_10min.time,Obj.gateRange,Obj.wakeChar_10min.dirValueall);
            sf.EdgeColor = 'none';
            view(sp2,[0 90])
            
            range = 79:102;
            sf = surf(sp3,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValueall(range,:));
            sf.EdgeColor = 'none';
            hold(sp3,'on')
            %             figure;plot(Obj.gateRange(range),mean(Obj.wakeChar_10min.dirValue(range,:),1));
            
            view(sp3,[0 0])
            
            
            sf = surf(sp4,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValueall(range,:));
            sf.EdgeColor = 'none';
            view(sp4,[0 90])
            
            Obj.wakeChar_10min.dirValueall = mean(Obj.wakeChar_10min.dirValueall(range,:),1);
        end
        function pc = plotter(Obj,inp)
            dir1 = inp;
            mult = 5;
            velocity = Obj.wakeChar_dir.Normvalue(:,:,dir1)';
            interv = sshist(velocity)*mult;
            bounds = linspace(min(velocity(:)),(max(velocity(:))),interv-1);
            azimuths = Obj.wakeChar_10min.azimuth(:,dir1);
            
            
            xLocs = arrayfun(@(x) 0+Obj.gateRange.*(sin(x)),azimuths,'uni',false);
            xall = [xLocs{:}];
            yLocs = arrayfun(@(x) 0+Obj.gateRange.*(cos(x)),azimuths,'uni',false);
            yall = [yLocs{:}];
            %             height = DHM.get_beam_height(Obj.gateRange./1E3,Obj.geoDat.targetInfo.Height,Obj.geoDat.targetInfo.Lat);
            %             hall = repmat(height,1,30);
            colors = ones(size(Obj.gateRange,1),30,3);
            %             legendColor = [linspace(0,1,50)' linspace(0,1,50)' ones(50,1); ones(50,1) linspace(1,0,50)' linspace(1,0,50)' ];
            legendColor = jet(interv);
            legendColor(1,:) = NaN;
            for i = 1:30
                velocityone = velocity(:,i);
                velocityone(isnan(velocityone)) = -100;
                interval =  (arrayfun(@(L,U) find(not(abs(sign(sign(L - velocityone) + sign(U - velocityone))))==1),[-Inf bounds],[bounds Inf],'uni',false));
                for iInt = 1:size(interval,2)
                    colors(interval{iInt},i,:) = repmat(legendColor(iInt,:),size(interval{iInt},1),1);
                end
            end
            fig = figure(1001);
            pc = surf(xall./1E3,yall./1E3,velocity,colors);
            pc.EdgeColor = 'none';
            view([ 0 90])
            
        end
    end
    
end