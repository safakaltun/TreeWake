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
            Obj.get_speed;
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
        function get_speed(Obj)
            Obj.spd.val1530 = sqrt((Obj.spd.u1530.^2)+(Obj.spd.v1530.^2));
            Obj.spd.val212  = sqrt((Obj.spd.u212.^2)+(Obj.spd.v212.^2));
            Obj.spd.valall  = sqrt((Obj.spd.uall.^2)+(Obj.spd.vall.^2));
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
            rmInd = squeeze(squeeze(sum(intVelRad==0,2))>size(intVelRad,2)*0.4);
            Obj.wakeChar(rmInd) = NaN;
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
                Obj.wakeChar_10min.spdValue1530(:,iTenMins)  =  mean(Obj.spd.val1530(:,uniScan),2);
                Obj.wakeChar_10min.spdValue212(:,iTenMins)   =  mean(Obj.spd.val212(:,uniScan),2);
                Obj.wakeChar_10min.spdValueall(:,iTenMins)   =  mean(Obj.spd.valall(:,uniScan),2);
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
            binSize = 2;
            bins = 200:binSize:330;
            
            [binCnt,bins,dirInd]= histcounts(wDir,bins);
            
            
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
                Obj.wakeChar_dir.bin(:,count) = [bins(iDir) bins(iDir+1)];
                Obj.wakeChar_dir.meanAngle(count)    = mean(wDir(cond));
                Obj.wakeChar_dir.nSample(count)  = sum(cond);
            end
            
            
            %%
            
            fig = figure(97);
            fig.Position= [412 89 1083 760];
            sp1 = subplot(2,2,1);
            sp2 = subplot(2,2,2);
            sp3 = subplot(2,2,3);
            sp4 = subplot(2,2,4);
            range = 68:82;
            %             outrange = [1:range(1)-1 range(end)+1:197];
            
            int1530 = Obj.wakeChar_10min.dirValue1530;
            int1530(range,:) = NaN;
            
            velocity = Obj.wakeChar_10min.dirValue1530(range,:);
            interv = sshist(velocity);
            bounds = linspace(220,320,interv-1);
            legendColor = cool(interv);
            
            for i = 1:15
                velocityone = velocity(i,:);
                interval =  (arrayfun(@(L,U) find(not(abs(sign(sign(L - velocityone) + sign(U - velocityone))))==1),[-Inf bounds],[bounds Inf],'uni',false));
                %                 interval(cellfun(@isempty,interval)) = [];
                for iInt = 1:size(interval,2)
                    colors(interval{iInt},i,:) = repmat(legendColor(iInt,:),size(interval{iInt},2),1);
                end
            end
            
            sf = surf(sp1,Obj.wakeChar_10min.time,Obj.gateRange,int1530);
            sp1.XAxis.TickLabels = datestr(sp1.XAxis.TickValues,'dd/mm HH:MM');
            sp1.XAxis.TickLabelRotation = 45;
            sf.EdgeColor = 'none';
            hold(sp1,'on')
            sf = surf(sp1,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValue1530(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            view(sp1,[45 45])
            caxis(sp1,[200 360])
            
            xlabel(sp1,'Date')
            ylabel(sp1,'Distance from Scanner [m]')
            zlabel(sp1,'Wind Direction [\circ]')
            
            sf = surf(sp2,Obj.wakeChar_10min.time,Obj.gateRange,int1530);
            sp2.XAxis.TickLabels = datestr(sp2.XAxis.TickValues,'dd/mm HH:MM');
            sp2.XAxis.TickLabelRotation = 45;
            sf.EdgeColor = 'none';
            hold(sp2,'on')
            sf = surf(sp2,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValue1530(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            view(sp2,[0 90])
            caxis(sp2,[200 360])
            xlabel(sp2,'Date')
            ylabel(sp2,'Distance from Scanner [m]')
            zlabel(sp2,'Wind Direction [\circ]')
            cb = colorbar(sp2,'Location','south','TickDirection','in','AxisLocation','in');
            %             cb.Position(4) = 0.02;
            
            sf = surf(sp3,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValue1530(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            sp3.XAxis.TickLabels = datestr(sp3.XAxis.TickValues,'dd/mm HH:MM');
            sp3.XAxis.TickLabelRotation = 45;
            caxis(sp3,[220 320])
            colormap(sp3,legendColor)
            view(sp3,[0 0])
            %             cb.Position(4) = 0.02;
            xlabel(sp3,'Date')
            ylabel(sp3,'Distance from Scanner [m]')
            zlabel(sp3,'Wind Direction [\circ]')
            
            sf = surf(sp4,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValue1530(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            sp4.XAxis.TickLabels = datestr(sp4.XAxis.TickValues,'dd/mm HH:MM');
            sp4.XAxis.TickLabelRotation = 45;
            view(sp4,[0 90])
            Obj.wakeChar_10min.dirValue1530 = mean(Obj.wakeChar_10min.dirValue1530(range,:),1);
            
            cb = colorbar(sp4,'Location','south','TickDirection','in','AxisLocation','in');
            caxis(sp4,[220 320])
            colormap(sp4,legendColor)
            xlabel(sp4,'Date')
            ylabel(sp4,'Distance from Scanner [m]')
            zlabel(sp4,'Wind Direction [\circ]')
            clear colors velocity interval bounds legendColor
            grid(sp2,'off')
            grid(sp4,'off')
             
            figName = fullfile('R:\SpecialCourseSafak\Figures\DirBased','Para_97');
            saveas(fig,figName,'epsc')
            saveas(fig,figName,'jpeg')
            saveas(fig,figName,'fig')
            %%
            fig = figure(98);
            fig.Position= [412 89 1083 760];
            sp1 = subplot(2,2,1);
            sp2 = subplot(2,2,2);
            sp3 = subplot(2,2,3);
            sp4 = subplot(2,2,4);
            range = 68:82;
            %             outrange = [1:range(1)-1 range(end)+1:197];
            
            int1530 = Obj.wakeChar_10min.spdValue1530;
            int1530(range,:) = NaN;
            
            velocity = Obj.wakeChar_10min.spdValue1530(range,:);
            interv = sshist(velocity);
            bounds = linspace(0,15,interv-1);
            legendColor = cool(interv);
            
            for i = 1:15
                velocityone = velocity(i,:);
                interval =  (arrayfun(@(L,U) find(not(abs(sign(sign(L - velocityone) + sign(U - velocityone))))==1),[-Inf bounds],[bounds Inf],'uni',false));
                %                 interval(cellfun(@isempty,interval)) = [];
                for iInt = 1:size(interval,2)
                    colors(interval{iInt},i,:) = repmat(legendColor(iInt,:),size(interval{iInt},2),1);
                end
            end
            
            sf = surf(sp1,Obj.wakeChar_10min.time,Obj.gateRange,int1530);
            sp1.XAxis.TickLabels = datestr(sp1.XAxis.TickValues,'dd/mm HH:MM');
            sp1.XAxis.TickLabelRotation = 45;
            sf.EdgeColor = 'none';
            hold(sp1,'on')
            sf = surf(sp1,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.spdValue1530(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            view(sp1,[45 45])
            caxis(sp1,[0 30])
            
            xlabel(sp1,'Date')
            ylabel(sp1,'Distance from Scanner [m]')
            zlabel(sp1,'Wind Speed [m/s]')
            
            sf = surf(sp2,Obj.wakeChar_10min.time,Obj.gateRange,int1530);
            sp2.XAxis.TickLabels = datestr(sp2.XAxis.TickValues,'dd/mm HH:MM');
            sp2.XAxis.TickLabelRotation = 45;
            sf.EdgeColor = 'none';
            hold(sp2,'on')
            sf = surf(sp2,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.spdValue1530(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            view(sp2,[0 90])
            caxis(sp2,[0 40])
            xlabel(sp2,'Date')
            ylabel(sp2,'Distance from Scanner [m]')
            zlabel(sp2,'Wind Speed [m/s]')
            cb = colorbar(sp2,'Location','south','TickDirection','in','AxisLocation','in');
            %             cb.Position(4) = 0.02;
            
            sf = surf(sp3,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.spdValue1530(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            sp3.XAxis.TickLabels = datestr(sp3.XAxis.TickValues,'dd/mm HH:MM');
            sp3.XAxis.TickLabelRotation = 45;
            caxis(sp3,[0 15])
            colormap(sp3,legendColor)
            view(sp3,[0 0])
            %             cb.Position(4) = 0.02;
            xlabel(sp3,'Date')
            ylabel(sp3,'Distance from Scanner [m]')
            zlabel(sp3,'Wind Speed [m/s]')
            
            sf = surf(sp4,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.spdValue1530(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            sp4.XAxis.TickLabels = datestr(sp4.XAxis.TickValues,'dd/mm HH:MM');
            sp4.XAxis.TickLabelRotation = 45;
            view(sp4,[0 90])
            Obj.wakeChar_10min.spd.Value1530 = mean(Obj.wakeChar_10min.spdValue1530(range,:),1);
            
            cb = colorbar(sp4,'Location','south','TickDirection','in','AxisLocation','in');
            caxis(sp4,[0 15])
            colormap(sp4,legendColor)
            xlabel(sp4,'Date')
            ylabel(sp4,'Distance from Scanner [m]')
            zlabel(sp4,'Wind Speed [m/s]')
            clear colors velocity interval bounds legendColor
            grid(sp2,'off')
            grid(sp4,'off')
             
            figName = fullfile('R:\SpecialCourseSafak\Figures\DirBased','Para_97_spd');
            saveas(fig,figName,'epsc')
            saveas(fig,figName,'jpeg')
            saveas(fig,figName,'fig')
            %% Direction Based
            fig = figure(99);
            fig.Position= [412 89 1083 760];
            sp1 = subplot(2,2,1);
            sp2 = subplot(2,2,2);
            sp3 = subplot(2,2,3);
            sp4 = subplot(2,2,4);
            range = 79:102;
            
            int212 = Obj.wakeChar_10min.dirValue212;
            int212(range,:) = NaN;
            
            velocity = Obj.wakeChar_10min.dirValue212(range,:);
            interv = sshist(velocity);
            bounds = linspace(220,320,interv-1);
            legendColor = cool(interv);
            
            for i = 1:24
                velocityone = velocity(i,:);
                interval =  (arrayfun(@(L,U) find(not(abs(sign(sign(L - velocityone) + sign(U - velocityone))))==1),[-Inf bounds],[bounds Inf],'uni',false));
                %                 interval(cellfun(@isempty,interval)) = [];
                for iInt = 1:size(interval,2)
                    colors(interval{iInt},i,:) = repmat(legendColor(iInt,:),size(interval{iInt},2),1);
                end
            end
            
            sf = surf(sp1,Obj.wakeChar_10min.time,Obj.gateRange,int212);
            sp1.XAxis.TickLabels = datestr(sp1.XAxis.TickValues,'dd/mm HH:MM');
            sp1.XAxis.TickLabelRotation = 45;
            sf.EdgeColor = 'none';
            hold(sp1,'on')
            sf = surf(sp1,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValue212(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            view(sp1,[45 45])
            %             view(sp1,[-89 10])
            caxis(sp1,[200 360])
            
            xlabel(sp1,'Date')
            ylabel(sp1,'Distance from Scanner [m]')
            zlabel(sp1,'Wind Direction [\circ]')
            
            sf = surf(sp2,Obj.wakeChar_10min.time,Obj.gateRange,int212);
            sp2.XAxis.TickLabels = datestr(sp2.XAxis.TickValues,'dd/mm HH:MM');
            sp2.XAxis.TickLabelRotation = 45;
            sf.EdgeColor = 'none';
            hold(sp2,'on')
            sf = surf(sp2,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValue212(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            view(sp2,[0 90])
            caxis(sp2,[200 360])
            xlabel(sp2,'Date')
            ylabel(sp2,'Distance from Scanner [m]')
            zlabel(sp2,'Wind Direction [\circ]')
            
            sf = surf(sp3,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValue212(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            sp3.XAxis.TickLabels = datestr(sp3.XAxis.TickValues,'dd/mm HH:MM');
            sp3.XAxis.TickLabelRotation = 45;
            view(sp3,[0 0])
            xlabel(sp3,'Date')
            ylabel(sp3,'Distance from Scanner [m]')
            zlabel(sp3,'Wind Direction [\circ]')
            
            
            
            sf = surf(sp4,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValue212(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            sp4.XAxis.TickLabels = datestr(sp4.XAxis.TickValues,'dd/mm HH:MM');
            sp4.XAxis.TickLabelRotation = 45;
            view(sp4,[0 90])
            caxis(sp4,[220 320])
            colormap(sp4,legendColor)
            xlabel(sp4,'Date')
            ylabel('Distance from Scanner [m]')
            zlabel('Wind Direction [\circ]')
            
            cb = colorbar(sp2,'Location','south','TickDirection','in','AxisLocation','in');
            %             cb.Position(4) = 0.02;
            cb = colorbar(sp4,'Location','south','TickDirection','in','AxisLocation','in');
            %             cb.Position(4) = 0.02;
            grid(sp2,'off')
            grid(sp4,'off')
            Obj.wakeChar_10min.dirValue212 = mean(Obj.wakeChar_10min.dirValue212(range,:),1);
            clear colors velocity interval bounds legendColor
            figName = fullfile('R:\SpecialCourseSafak\Figures\DirBased','Para_98');
            saveas(fig,figName,'epsc')
            saveas(fig,figName,'jpeg')
            saveas(fig,figName,'fig')
            %%
            fig = figure(100);
            fig.Position= [412 89 1083 760];
            sp1 = subplot(2,2,1);
            sp2 = subplot(2,2,2);
            sp3 = subplot(2,2,3);
            sp4 = subplot(2,2,4);
            range = 79:102;
            %             outrange = [1:range(1)-1 range(end)+1:197];
            
            int212 = Obj.wakeChar_10min.spdValue212;
            int212(range,:) = NaN;
            
            velocity = Obj.wakeChar_10min.spdValue212(range,:);
            interv = sshist(velocity);
            bounds = linspace(0,15,interv-1);
            legendColor = cool(interv);
            
            for i = 1:24
                velocityone = velocity(i,:);
                interval =  (arrayfun(@(L,U) find(not(abs(sign(sign(L - velocityone) + sign(U - velocityone))))==1),[-Inf bounds],[bounds Inf],'uni',false));
                %                 interval(cellfun(@isempty,interval)) = [];
                for iInt = 1:size(interval,2)
                    colors(interval{iInt},i,:) = repmat(legendColor(iInt,:),size(interval{iInt},2),1);
                end
            end
            
            sf = surf(sp1,Obj.wakeChar_10min.time,Obj.gateRange,int212);
            sp1.XAxis.TickLabels = datestr(sp1.XAxis.TickValues,'dd/mm HH:MM');
            sp1.XAxis.TickLabelRotation = 45;
            sf.EdgeColor = 'none';
            hold(sp1,'on')
            sf = surf(sp1,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.spdValue212(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            view(sp1,[45 45])
            caxis(sp1,[0 40])
            
            xlabel(sp1,'Date')
            ylabel(sp1,'Distance from Scanner [m]')
            zlabel(sp1,'Wind Speed [m/s]')
            
            sf = surf(sp2,Obj.wakeChar_10min.time,Obj.gateRange,int212);
            sp2.XAxis.TickLabels = datestr(sp2.XAxis.TickValues,'dd/mm HH:MM');
            sp2.XAxis.TickLabelRotation = 45;
            sf.EdgeColor = 'none';
            hold(sp2,'on')
            sf = surf(sp2,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.spdValue212(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            view(sp2,[0 90])
            caxis(sp2,[0 40])
            xlabel(sp2,'Date')
            ylabel(sp2,'Distance from Scanner [m]')
            zlabel(sp2,'Wind Speed [m/s]')
            cb = colorbar(sp2,'Location','south','TickDirection','in','AxisLocation','in');
            %             cb.Position(4) = 0.02;
            
            sf = surf(sp3,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.spdValue212(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            sp3.XAxis.TickLabels = datestr(sp3.XAxis.TickValues,'dd/mm HH:MM');
            sp3.XAxis.TickLabelRotation = 45;
            caxis(sp3,[0 15])
            colormap(sp3,legendColor)
            view(sp3,[0 0])
            %             cb.Position(4) = 0.02;
            xlabel(sp3,'Date')
            ylabel(sp3,'Distance from Scanner [m]')
            zlabel(sp3,'Wind Speed [m/s]')
            
            sf = surf(sp4,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.spdValue212(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            sp4.XAxis.TickLabels = datestr(sp4.XAxis.TickValues,'dd/mm HH:MM');
            sp4.XAxis.TickLabelRotation = 45;
            view(sp4,[0 90])
            Obj.wakeChar_10min.spd.Value212 = mean(Obj.wakeChar_10min.spdValue212(range,:),1);
            
            cb = colorbar(sp4,'Location','south','TickDirection','in','AxisLocation','in');
            caxis(sp4,[0 15])
            colormap(sp4,legendColor)
            xlabel(sp4,'Date')
            ylabel(sp4,'Distance from Scanner [m]')
            zlabel(sp4,'Wind Speed [m/s]')
            clear colors velocity interval bounds legendColor
            grid(sp2,'off')
            grid(sp4,'off')
             
            figName = fullfile('R:\SpecialCourseSafak\Figures\DirBased','Para_98_spd');
            saveas(fig,figName,'epsc')
            saveas(fig,figName,'jpeg')
            saveas(fig,figName,'fig')
            %% Direction Based
            fig = figure(101);
            fig.Position= [412 89 1083 760];
            sp1 = subplot(2,2,1);
            sp2 = subplot(2,2,2);
            sp3 = subplot(2,2,3);
            sp4 = subplot(2,2,4);
            range = 79:102;
            
            intAll = Obj.wakeChar_10min.dirValueall;
            intAll(range,:) = NaN;
            
            velocity = Obj.wakeChar_10min.dirValueall(range,:);
            interv = sshist(velocity);
            bounds = linspace(220,320,interv-1);
            legendColor = cool(interv);
            
            for i = 1:24
                velocityone = velocity(i,:);
                interval =  (arrayfun(@(L,U) find(not(abs(sign(sign(L - velocityone) + sign(U - velocityone))))==1),[-Inf bounds],[bounds Inf],'uni',false));
                %                 interval(cellfun(@isempty,interval)) = [];
                for iInt = 1:size(interval,2)
                    colors(interval{iInt},i,:) = repmat(legendColor(iInt,:),size(interval{iInt},2),1);
                end
            end
            sf = surf(sp1,Obj.wakeChar_10min.time,Obj.gateRange,intAll);
            sp1.XAxis.TickLabels = datestr(sp1.XAxis.TickValues,'dd/mm HH:MM');
            sp1.XAxis.TickLabelRotation = 45;
            sf.EdgeColor = 'none';
            hold(sp1,'on')
            sf = surf(sp1,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValueall(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            view(sp1,[45 45])
            %             view(sp1,[-89 10])
            caxis(sp1,[200 360])
            
            xlabel(sp1,'Date')
            ylabel(sp1,'Distance from Scanner [m]')
            zlabel(sp1,'Wind Direction [\circ]')
            
            sf = surf(sp2,Obj.wakeChar_10min.time,Obj.gateRange,intAll);
            sp2.XAxis.TickLabels = datestr(sp2.XAxis.TickValues,'dd/mm HH:MM');
            sp2.XAxis.TickLabelRotation = 45;
            sf.EdgeColor = 'none';
            hold(sp2,'on')
            sf = surf(sp2,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValueall(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            view(sp2,[0 90])
            caxis(sp2,[200 360])
            xlabel(sp2,'Date')
            ylabel(sp2,'Distance from Scanner [m]')
            zlabel(sp2,'Wind Direction [\circ]')
            
            
            
            sf = surf(sp3,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValueall(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            sp3.XAxis.TickLabels = datestr(sp3.XAxis.TickValues,'dd/mm HH:MM');
            sp3.XAxis.TickLabelRotation = 45;
            view(sp3,[0 0])
            xlabel(sp3,'Date')
            ylabel(sp3,'Distance from Scanner [m]')
            zlabel(sp3,'Wind Direction [\circ]')
            
            
            sf = surf(sp4,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.dirValueall(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            sp4.XAxis.TickLabels = datestr(sp4.XAxis.TickValues,'dd/mm HH:MM');
            sp4.XAxis.TickLabelRotation = 45;
            view(sp4,[0 90])
            caxis(sp4,[220 320])
            colormap(sp4,legendColor)
            xlabel(sp4,'Date')
            ylabel('Distance from Scanner [m]')
            zlabel('Wind Direction [\circ]')
            
            
            cb = colorbar(sp2,'Location','south','TickDirection','in','AxisLocation','in');
            %             cb.Position(4) = 0.02;
            cb = colorbar(sp4,'Location','south','TickDirection','in','AxisLocation','in');
            %             cb.Position(4) = 0.02;
            grid(sp2,'off')
            grid(sp4,'off')
            figName = fullfile('R:\SpecialCourseSafak\Figures\DirBased','Para_99');
            saveas(fig,figName,'epsc')
            saveas(fig,figName,'jpeg')
            saveas(fig,figName,'fig')
            Obj.wakeChar_10min.dirValueall = mean(Obj.wakeChar_10min.dirValueall(range,:),1);
            
            %%
            fig = figure(102);
            fig.Position= [412 89 1083 760];
            sp1 = subplot(2,2,1);
            sp2 = subplot(2,2,2);
            sp3 = subplot(2,2,3);
            sp4 = subplot(2,2,4);
            range = 79:102;
            %             outrange = [1:range(1)-1 range(end)+1:197];
            
            intall = Obj.wakeChar_10min.spdValueall;
            intall(range,:) = NaN;
            
            velocity = Obj.wakeChar_10min.spdValueall(range,:);
            interv = sshist(velocity);
            bounds = linspace(0,15,interv-1);
            legendColor = cool(interv);
            
            for i = 1:24
                velocityone = velocity(i,:);
                interval =  (arrayfun(@(L,U) find(not(abs(sign(sign(L - velocityone) + sign(U - velocityone))))==1),[-Inf bounds],[bounds Inf],'uni',false));
                %                 interval(cellfun(@isempty,interval)) = [];
                for iInt = 1:size(interval,2)
                    colors(interval{iInt},i,:) = repmat(legendColor(iInt,:),size(interval{iInt},2),1);
                end
            end
            
            sf = surf(sp1,Obj.wakeChar_10min.time,Obj.gateRange,intall);
            sp1.XAxis.TickLabels = datestr(sp1.XAxis.TickValues,'dd/mm HH:MM');
            sp1.XAxis.TickLabelRotation = 45;
            sf.EdgeColor = 'none';
            hold(sp1,'on')
            sf = surf(sp1,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.spdValueall(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            view(sp1,[45 45])
            caxis(sp1,[0 40])
            
            xlabel(sp1,'Date')
            ylabel(sp1,'Distance from Scanner [m]')
            zlabel(sp1,'Wind Speed [m/s]')
            
            sf = surf(sp2,Obj.wakeChar_10min.time,Obj.gateRange,intall);
            sp2.XAxis.TickLabels = datestr(sp2.XAxis.TickValues,'dd/mm HH:MM');
            sp2.XAxis.TickLabelRotation = 45;
            sf.EdgeColor = 'none';
            hold(sp2,'on')
            sf = surf(sp2,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.spdValueall(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            view(sp2,[0 90])
            caxis(sp2,[0 40])
            xlabel(sp2,'Date')
            ylabel(sp2,'Distance from Scanner [m]')
            zlabel(sp2,'Wind Speed [m/s]')
            cb = colorbar(sp2,'Location','south','TickDirection','in','AxisLocation','in');
            %             cb.Position(4) = 0.02;
            
            sf = surf(sp3,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.spdValueall(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            sp3.XAxis.TickLabels = datestr(sp3.XAxis.TickValues,'dd/mm HH:MM');
            sp3.XAxis.TickLabelRotation = 45;
            caxis(sp3,[0 15])
            colormap(sp3,legendColor)
            view(sp3,[0 0])
            %             cb.Position(4) = 0.02;
            xlabel(sp3,'Date')
            ylabel(sp3,'Distance from Scanner [m]')
            zlabel(sp3,'Wind Speed [m/s]')
            
            sf = surf(sp4,Obj.wakeChar_10min.time,Obj.gateRange(range),Obj.wakeChar_10min.spdValueall(range,:),permute(colors,[2 1 3]));
            sf.EdgeColor = 'none';
            sp4.XAxis.TickLabels = datestr(sp4.XAxis.TickValues,'dd/mm HH:MM');
            sp4.XAxis.TickLabelRotation = 45;
            view(sp4,[0 90])
            Obj.wakeChar_10min.spd.Valueall = mean(Obj.wakeChar_10min.spdValueall(range,:),1);
            
            cb = colorbar(sp4,'Location','south','TickDirection','in','AxisLocation','in');
            caxis(sp4,[0 15])
            colormap(sp4,legendColor)
            xlabel(sp4,'Date')
            ylabel(sp4,'Distance from Scanner [m]')
            zlabel(sp4,'Wind Speed [m/s]')
            clear colors velocity interval bounds legendColor
            grid(sp2,'off')
            grid(sp4,'off')
             
            figName = fullfile('R:\SpecialCourseSafak\Figures\DirBased','Para_99_spd');
            saveas(fig,figName,'epsc')
            saveas(fig,figName,'jpeg')
            saveas(fig,figName,'fig')
            
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