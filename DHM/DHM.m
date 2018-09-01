classdef DHM < matlab.mixin.SetGet
    properties
        surfDir
        terrDir
        surfDat
        terrDat
        highResDat
    end
    properties
        kmlDat = kml2struct('./coordinates.kml');
        targetName = 'Sirocco';
        scannerHeight = 1.5;
        targetInfo
    end
    methods
        function Obj = DHM(varargin)
            Obj.surfDir = 'R:\SpecialCourseSafak\DHM_Data\Surface';
            Obj.terrDir = 'R:\SpecialCourseSafak\DHM_Data\Terrain';
            load R:\SpecialCourseSafak\DHM_Data\buildingpoints_and_more.mat X Y Z;
            xInd = X>694.6*1E3;
            yInd = Y>6175.7*1E3;
            finInd =  xInd&yInd;
            Obj.highResDat.X = X(finInd);
            Obj.highResDat.Y = Y(finInd);
            Obj.highResDat.Z = Z(finInd);
            
            forestArea = load('R:\SpecialCourseSafak\DHM_Data\lasdata_to_safak_693_6175.txt');
            xInd = (forestArea(:,1)>693.35*1E3&forestArea(:,1)<693.7*1E3);
            yInd = (forestArea(:,2)>6175.3*1E3&forestArea(:,2)<6175.6*1E3);
            finInd =  xInd&yInd;
            Obj.highResDat.Xf = forestArea(finInd,1);
            Obj.highResDat.Yf = forestArea(finInd,2);
            Obj.highResDat.Zf = forestArea(finInd,3);

            Obj.targetInfo.Ground = [6175826.293274 694874.549082 49.586117];
            Obj.targetInfo.Roof = [6175844.702132 694881.809834 57.202058];
            xmlFile = xml2struct('R:\SpecialCourseSafak\Field_Data\CS20_Data_11072018.xml');
            Obj.targetInfo.All  = str2num(char(arrayfun(@(x) xmlFile.LandXML.CgPoints.CgPoint{x}.Text,[1:9 11:size(xmlFile.LandXML.CgPoints.CgPoint,2)],'uni',false)'));
            
            Obj.targetInfo.Y = Obj.targetInfo.All(end-1,1);
            Obj.targetInfo.X = Obj.targetInfo.All(end-1,2);
            Obj.targetInfo.Height = Obj.targetInfo.All(end-1,3)+Obj.scannerHeight;
            Obj.targetInfo.Lat = str2num(xmlFile.LandXML(1).CgPoints.CgPoint{end-1}.Attributes.latitude);
            Obj.targetInfo.Lon = str2num(xmlFile.LandXML(1).CgPoints.CgPoint{end-1}.Attributes.longitude);
            Obj.set_surfDat;
            Obj.set_terrDat;
        end
    end
    methods
        function Obj = set_surfDat(Obj)
            Obj.surfDat = DHM.read_DHM_data(Obj.surfDir,'DSM');
        end
        function Obj = set_terrDat(Obj)
            Obj.terrDat = DHM.read_DHM_data(Obj.terrDir,'DTM');
        end
        function plot_surf(Obj)
            [X,Y] = meshgrid((690:0.002:(695)),(6174:0.002:(6177)));
            a = pcolor(X,Y,Obj.surfDat);
            set(a,'EdgeAlpha',0);
            set(gca,'FontSize',16);
            xlabel('UTM x, zone 32 [km]');
            ylabel('UTM y, zone 32 [km]');
            axis square
            colorbar
            caxis([0 30])
            demcmap([-0.2 40])
            daspect([5  5 1])
            hold on
            plot(Obj.targetInfo.X/1e3,Obj.targetInfo.Y/1e3,'or','Marker','.','MarkerSize',25)
            plot((Obj.targetInfo.X/1e3)-4,Obj.targetInfo.Y/1e3,'or','Marker','.','MarkerSize',25)
        end
        function plot_terr(Obj)
            [X,Y] = meshgrid((690:0.002:(695)),(6174:0.002:(6177)));
            figure;clf
            a = pcolor(X,Y,Obj.terrDat);
            set(a,'EdgeAlpha',0);
            xlabel('UTM x, zone 32 [km]');
            ylabel('UTM y, zone 32 [km]');
            axis square
            colorbar
            caxis([0 30])
            demcmap([-0.2 40])
            daspect([5  5 1])
        end
    end
    methods (Static)
        function Ethin = read_DHM_data(inpDir,type)
            
            files = dir([inpDir '\*.tif']);
            fileNames = {files.name}';
            fileProps = cellfun(@(x) strsplit(x,'_'),fileNames,'uni',false);
            fileProps = regexprep(reshape([fileProps{:}],4,[])','.tif','');
            numY = min(str2num(cell2mat(fileProps(:,3)))):max(str2num(cell2mat(fileProps(:,3))));
            numX = min(str2num(cell2mat(fileProps(:,4)))):max(str2num(cell2mat(fileProps(:,4))));
            
            count = 0;
            for iY = 1:length(numY)
                for iX = 1:length(numX)
                    count = count+1;
                    artFiles(count) = {[type '_1km_' num2str(numY(iY)) '_' num2str(numX(iX)) '.tif' ]};
                end
            end
            fileProps = cellfun(@(x) strsplit(x,'_'),artFiles,'uni',false);
            fileProps = regexprep(reshape([fileProps{:}],4,[])','.tif','');
            fileList = fullfile(cellstr(repmat(files(1).folder,size(artFiles,2),1)), artFiles');
            
            for iFile = 1:size(artFiles,2)
                try
                    Data.(artFiles{iFile}(1:end-4)).Info.source = fileList{iFile};
                    Data.(artFiles{iFile}(1:end-4)).Info.resolution = fileProps{iFile,2};
                    Data.(artFiles{iFile}(1:end-4)).Info.yStart = str2num(fileProps{iFile,3});
                    Data.(artFiles{iFile}(1:end-4)).Info.xStart = str2num(fileProps{iFile,4});
                    Data.(artFiles{iFile}(1:end-4)).value = imread(fileList{iFile});
                catch
                    Data.(artFiles{iFile}(1:end-4)).Info.source = 'FILE_DOES_NOT_EXIST';
                    Data.(artFiles{iFile}(1:end-4)).Info.resolution = fileProps{iFile,2};
                    Data.(artFiles{iFile}(1:end-4)).Info.yStart = str2num(fileProps{iFile,3});
                    Data.(artFiles{iFile}(1:end-4)).Info.xStart = str2num(fileProps{iFile,4});
                    Data.(artFiles{iFile}(1:end-4)).value = single(ones(2500)*(-9999));
                end
            end
            
            count = 0;
            for iY = length(numY):-1:1
                count = count+1;
                sTxt{count} = [];
                for iX = 1:length(numX)
                    sTxt{count} = [sTxt{count}, sprintf(',Data.%s_1km_%d_%d.value',type,numY(iY),numX(iX))];
                end
                sTxt{count} = sTxt{count}(2:end);
                sTxt{count}(end+1) = ';';
            end
            evalTxt =  ['double([' [sTxt{:}] '])'];
            mergedDat = eval(evalTxt);
            mergedDat(mergedDat==min(mergedDat(:))) = 0;
            
            E = mergedDat;
            
            Ethin = E(1:5:end,1:5:end);
            Ethin = flipud(Ethin);
            Ethin = Ethin -0.2;
            Ethin = [Ethin;Ethin(end,:)];
            Ethin = [Ethin Ethin(:,end)];
        end
        function R = get_earth_radius(lat)
            a = 6378137;
            b = 6356752.3;
            R = sqrt(( ((a.^2).*cosd(lat)).^2 + ((b.^2).*sind(lat)).^2 ) ./ ( (a.*cosd(lat)).^2 + (b.*sind(lat)).^2 ));
        end
        function height = get_beam_height(d,lidarHeight,lidarLat)
            rLid = DHM.get_earth_radius(lidarLat);
            height = sqrt((d.^2)+((rLid+lidarHeight).^2))-rLid;
        end
    end
end
