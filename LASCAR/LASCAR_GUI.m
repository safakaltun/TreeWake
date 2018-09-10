classdef LASCAR_GUI < matlab.mixin.SetGet
    properties
        windDat
        geoDat = DHM;
        mastDat = MAST;
        flightDat = Toothless;
    end
    properties
        currentTime
        timeStop
        angAzm
        velRad
        wakeChar
        gateRange
    end
    properties %(Access = protected)dra
        advancedFig
        ax1
        ax11
        ax110
        ax111
        ax12
        ax2
        ax22
        ax3
        ax32
        ax4
        ax5
        ax6
        cax1
        cax2
        cb1
        cb2
        cb3
        cbar
        cbar2
        currentStatDeg = 1;
        currentStatTime = 1;
        dateFilter
        dirFilter
        F
        fig
        filtered
        geo
        H
        hax1
        isNorm
        lidar
        maxMarkerSize = 1.7;
        minDifInd = 0;
        p1
        p2
        p3
        p4
        p5
        p6
        p7
        pan1
        pan2
        pan21
        pan22
        pan3
        pan31
        pan32
        pc
        pf
        pointCloudCheck
        RiNumber
        scanDate
        showContour
        showLidar
        showTrees
        tab1
        tab2
        tab3
        tabgp
        toolbar
        trns = 0.75;
        tsSelection
        tsSelection2
        wakeChar_10min
        wakeChar_dir
        wakeStat10Check
        wakeStatCheck
        wakeStatCheckOff
        wind
        wspFilter
        zoomSlider
        zoomtxt
    end
    properties (Access = protected)
        add  = double(~imread('./Graphs/add.png'))*0.94;
        next  = double(~imread('./Graphs/next.png'))*0.94;
        prev  = double(~imread('./Graphs/prev.png'))*0.94;
        resume  = double(~imread('./Graphs/play.png'))*0.94;
        pause  = double(~imread('./Graphs/pause.png'))*0.94;
        start = double(~imread('./Graphs/first.png'))*0.94;
        end_  = double(~imread('./Graphs/end.png'))*0.94;
        redDot = double(~imread('./Graphs/dot.png'))*0.94;
        
    end
    methods
        function Obj = LASCAR_GUI(varargin)
            Obj.init_GUI;
        end
    end
    
    methods (Hidden)
        function import_data(varargin)
            Obj = varargin{1};
            [filename, pathname, filterindex] = uigetfile('.txt');
            
            if filterindex
                Obj.wakeStatCheck.Enable = 'on';
                Obj.wakeStat10Check.Enable = 'on';
                Obj.wakeStatCheckOff.Enable = 'on';
                
                
                Obj.windDat.raw = [];
                Obj.windDat.processed = [];
                fileName = fullfile(pathname,filename);
                Obj.windDat.raw = LASCAR_Raw;
                Obj.windDat.raw.File = fileName;
                Obj.windDat.processed = LASCAR_Processed;
                Obj.windDat.processed.File = fileName;
                Obj.windDat.raw.set_data;
                Obj.windDat.processed.set_data;
                
                Obj.timeStop  = Obj.windDat.processed.timeStop;
                Obj.angAzm    = Obj.windDat.processed.angAzm;
                Obj.velRad    = Obj.windDat.processed.velRad;
                Obj.gateRange = Obj.windDat.processed.gateRange;
                Obj.wakeChar  = Obj.windDat.processed.wakeChar;
                Obj.wakeChar_10min = Obj.windDat.processed.wakeChar_10min;
                Obj.wakeChar_dir = Obj.windDat.processed.wakeChar_dir;
                Obj.wind.SelectedObject = Obj.wind.Children(3);
                [~,minDif]=min(abs(Obj.mastDat.Data.Time.value-Obj.windDat.processed.wakeChar_10min.time(1)));
                nans =  nan(size(Obj.mastDat.Data.Time.value));
                lenDat = length( Obj.windDat.processed.wakeChar_10min.spd.Value1530);
                Obj.mastDat.Data.Wsp_22p7_1530.value = nans;
                Obj.mastDat.Data.Wsp_22p7_1530.value(minDif:minDif+lenDat-1) = Obj.windDat.processed.wakeChar_10min.spd.Value1530';
                Obj.mastDat.Data.Wsp_22p7_212.value = nans;
                Obj.mastDat.Data.Wsp_22p7_212.value(minDif:minDif+lenDat-1) = Obj.windDat.processed.wakeChar_10min.spd.Value212';
                Obj.mastDat.Data.Wsp_22p7_all.value = nans;
                Obj.mastDat.Data.Wsp_22p7_all.value(minDif:minDif+lenDat-1) = Obj.windDat.processed.wakeChar_10min.spd.Valueall';
                
                Obj.mastDat.Data.W_dir_22p7_Case1.value = nans;
                Obj.mastDat.Data.W_dir_22p7_Case1.value(minDif:minDif+lenDat-1) = Obj.windDat.processed.wakeChar_10min.dirValue1530';
                Obj.mastDat.Data.W_dir_22p7_Case2.value = nans;
                Obj.mastDat.Data.W_dir_22p7_Case2.value(minDif:minDif+lenDat-1) = Obj.windDat.processed.wakeChar_10min.dirValue212';
                Obj.mastDat.Data.W_dir_22p7_Case3.value = nans;
                Obj.mastDat.Data.W_dir_22p7_Case3.value(minDif:minDif+lenDat-1) = Obj.windDat.processed.wakeChar_10min.dirValueall';
                
                %                 Obj.draw_height_plot;
                Obj.draw_polar_plot;
                
                
            end
            
        end
        function init_GUI(Obj)
            Obj.currentTime = 1;
            Obj.fig = figure('Units','normalized');
            Obj.toolbar = uitoolbar(Obj.fig);
            
            LidarButton = uipushtool(Obj.toolbar ,'CData',Obj.add,'TooltipString','Add Wind Scanner Data','HandleVisibility','off');
            
            startButton = uipushtool(Obj.toolbar ,'CData',Obj.start,'TooltipString','First time step','HandleVisibility','off','Separator','on');
            prevButton = uipushtool(Obj.toolbar ,'CData',Obj.prev,'TooltipString','Previous time step','HandleVisibility','off');
            playButton = uitoggletool(Obj.toolbar ,'CData',Obj.resume,'TooltipString','Play','HandleVisibility','off');
            nextButton = uipushtool(Obj.toolbar ,'CData',Obj.next,'TooltipString','Next time step','HandleVisibility','off');
            endButton = uipushtool(Obj.toolbar ,'CData',Obj.end_,'TooltipString','Last time step','HandleVisibility','off');
            Obj.redDot(Obj.redDot(:,:,1)==0) = 1;
            showButton = uitoggletool(Obj.toolbar ,'CData',Obj.redDot,'TooltipString','Show/Hide Scanner Point','HandleVisibility','off','Separator','on');
            greenDot = Obj.redDot(:,:,[2 1 3]);
            showTreeButton = uitoggletool(Obj.toolbar ,'CData',greenDot,'TooltipString','Show/Hide Trees','HandleVisibility','off','Separator','on');
            blueDot = Obj.redDot(:,:,[2 3 1]);
            areaofInterestButton = uipushtool(Obj.toolbar ,'CData',blueDot,'TooltipString','Area of Interest','HandleVisibility','off','Separator','on','Tag','Area of Interest');
            forestAreaButton = uipushtool(Obj.toolbar ,'CData',blueDot,'TooltipString','Forest Area','HandleVisibility','off','Separator','on','Tag','Forest Area');
            buildingAreaButton = uipushtool(Obj.toolbar ,'CData',blueDot,'TooltipString','Building Area','HandleVisibility','off','Separator','on','Tag','Building Area');
            resetAreaButton = uipushtool(Obj.toolbar ,'CData',blueDot,'TooltipString','Reset Area','HandleVisibility','off','Separator','on','Tag','Reset Area');
            
            for iFlight = 1:length(Obj.flightDat.Data)
                drone.(['Flight_' num2str(iFlight)]) = uitoggletool(Obj.toolbar ,'CData',Obj.redDot,'TooltipString',datestr(Obj.flightDat.Data(iFlight).StartDate),'HandleVisibility','off','Tag',['F' num2str(iFlight)]);
            end
            
            
            Obj.tabgp = uitabgroup(Obj.fig);
            Obj.tab1 = uitab(Obj.tabgp,'Title','Field Analysis');
            Obj.tab2 = uitab(Obj.tabgp,'Title','Statistics');
            Obj.tab3 = uitab(Obj.tabgp,'Title','Time Series');
            
            
            Obj.pan1 = uipanel('Parent',Obj.tab1,'Position',[0.2 0.1 0.8 0.9]);
            Obj.pan2 = uipanel('Parent',Obj.tab1,'Position',[0 0 1 0.1]);
            Obj.pan21 = uipanel('Parent',Obj.tab2,'Position',[0 0 0.2 1]);
            Obj.pan22 = uipanel('Parent',Obj.tab2,'Position',[0.2 0 0.8 1]);
            Obj.pan31 = uipanel('Parent',Obj.tab3,'Position',[0 0 0.2 1]);
            Obj.pan32 = uipanel('Parent',Obj.tab3,'Position',[0.2 0 0.8 1]);
            Obj.pan3 = uipanel('Parent',Obj.tab1,'Position',[0 0.1 0.2 0.9]);
            %             Obj.pan2 = uipanel('Parent',Obj.tab1,'Position',[0 0 1 0.1]);
            
            Obj.ax1 = axes(Obj.pan1,'Color','none','Visible','off','Tag','AX1');
            %             setappdata(gcf, 'StoreTheLink', Link);
            Obj.ax110 = axes(Obj.pan3,'Color','none','Visible','on','Position',[10 10 0 0]);
            Obj.ax111 = axes(Obj.pan3,'Color','none','Visible','on','Position',[10 10 0 0]);
            Obj.ax11 = axes(Obj.pan3,'Color','none','Visible','on','Position',[0.2 0.65 0.55 0.3]);
            Obj.ax12 = axes(Obj.pan3,'Color','none','Visible','on','Position',[0.2 0.25 0.55 0.3],'Tag','FOV');
            
            Obj.RiNumber = uicontrol(Obj.pan3,'Style','text','String','Ri,TI','Units','normalized','Position',[0.2 0.55 0.55 0.05]);
            
            vert = [0 0 0;1 0 0;1 1 0;0 1 0;0 0 1;1 0 1;1 1 1;0 1 1];
            fac = [1 2 6 5;2 3 7 6;3 4 8 7;4 1 5 8;1 2 3 4;5 6 7 8];
            patch( Obj.ax12,'Vertices',vert,'Faces',fac,'FaceColor','w')
            text( Obj.ax12,.5,.5,-0.1,'BOTTOM','Color','red','FontSize',14,'HorizontalAlignment','center')
            text( Obj.ax12,.5,.5,1.1,'TOP','Color','red','FontSize',14,'HorizontalAlignment','center')
            text( Obj.ax12,.5,1.1,.5,'N','Color','red','FontSize',14,'HorizontalAlignment','center')
            text( Obj.ax12,.5,-0.1,.5,'S','Color','red','FontSize',14,'HorizontalAlignment','center')
            text( Obj.ax12,-0.1,.5,.5,'W','Color','red','FontSize',14,'HorizontalAlignment','center')
            text( Obj.ax12,1.1,.5,.5,'E','Color','red','FontSize',14,'HorizontalAlignment','center')
            view(Obj.ax12,3);
            Obj.zoomSlider = uicontrol(Obj.pan3,'style','slider','Min',0,'Max',50,'Value',30,'Units','normalized','Position', [0.86 0.29 0.05 0.26],'Tag','Zoomslider');
            
            Obj.zoomtxt = uicontrol(Obj.pan3,'Style','edit','String','30','Units','normalized', 'Position',[0.86 0.25 0.05 0.03],'Tag','Zoomedit','TooltipString','Maximum Height');
            Obj.cb1 = colorbar(Obj.ax12,'Visible','off','Location','south');
            Obj.cb1.Position = [0.100 0.08 0.8 0.03000];
            Obj.cb1.FontSize = 8.2;
            Obj.cb1.Label.String = 'Wind Speed [m/s]';
            Obj.cb1.Label.Units = 'normalized';
            Obj.cb1.Label.Position(2) = 0.8;
            Obj.cb2 = colorbar(Obj.ax110,'Visible','off','Location','south');
            Obj.cb2.Position = [0.100 0.025 0.8 0.03000];
            Obj.cb2.FontSize = 8.2;
            Obj.cb2.Label.String = 'Elevation, DHM [m]';
            Obj.cb2.Label.Units = 'normalized';
            Obj.cb2.Label.Position(2) = 0.8;
            Obj.cb3 = colorbar(Obj.ax111,'Visible','off','Location','south');
            Obj.cb3.Position = [0.100 0.135 0.8 0.03000];
            Obj.cb3.FontSize = 8.2;
            Obj.cb3.Label.String = 'Elevation, Point Cloud [m]';
            Obj.cb3.Label.Units = 'normalized';
            Obj.cb3.Label.Position(2) = 0.8;
            Obj.ax22 = axes(Obj.pan22,'Color','none','Visible','off');
            Obj.ax32 = axes(Obj.pan32,'Color','none','Visible','off');
            Obj.geo = uibuttongroup(Obj.pan2,'Units','normalized','Position', [0 0.5 3/4 0.5]);
            % Create three radio buttons in the button group.
            mG1 = uicontrol(Obj.geo,'Style','radiobutton','String','Surface','Units','normalized','Position', [0 0 1/4 1],'Tag','1');
            mG2 = uicontrol(Obj.geo,'Style','radiobutton','String','Terrain','Units','normalized','Position', [1/4 0 1/4 1],'Tag','2');
            mG3 = uicontrol(Obj.geo,'Style','radiobutton','String','Obstacles','Units','normalized','Position', [2/4 0 1/4 1],'Tag','3');
            mG4 = uicontrol(Obj.geo,'Style','radiobutton','String','Off','Units','normalized','Position', [3/4 0 1/4 1],'Tag','4');
            Obj.pointCloudCheck = uicontrol(Obj.pan2,'style','checkbox','String','Show Point Cloud Data','Value',0,'Units','normalized','Position', [12/16 0.5 0.07051282051282 0.5],'Enable','off');
            
            uicontrol(Obj.pan2,'style','text','String','Show Wake Characteristics','Units','normalized','Position', [0.835 0.5 0.044 0.5]);
            Obj.wakeStatCheck = uicontrol(Obj.pan2,'style','checkbox','String','Full Period','Value',0,'Units','normalized','Position', [0.89 0.5 0.035812401883809 0.5],'Enable','off');
            Obj.wakeStat10Check = uicontrol(Obj.pan2,'style','checkbox','String','10 min','Value',0,'Units','normalized','Position', [0.93 0.5 0.027439822082658 0.5],'Enable','off');
            Obj.wakeStatCheckOff = uicontrol(Obj.pan2,'style','checkbox','String','Off','Value',0,'Units','normalized','Position', [0.96 0.5 0.027439822082658 0.5],'Enable','off');
            
            
            
            
            Obj.geo.SelectedObject = mG4;
            
            Obj.wind = uibuttongroup(Obj.pan2,'Units','normalized','Position', [0 0 3/4 0.5]);
            % Create three radio buttons in the button group.
            lG1 = uicontrol(Obj.wind ,'Style','radiobutton','String','Raw','Units','normalized','Position', [0 0 1/4 1],'Tag','1');
            lG2 = uicontrol(Obj.wind ,'Style','radiobutton','String','Processed','Units','normalized','Position', [1/4 0 1/4 1],'Tag','2');
            lG3 = uicontrol(Obj.wind ,'Style','radiobutton','String','Difference','Units','normalized','Position', [2/4 0 1/4 1],'Tag','3');
            lG4 = uicontrol(Obj.wind ,'Style','radiobutton','String','Off','Units','normalized','Position', [3/4 0 1/4 1],'Tag','4');
            
            Obj.wind .SelectedObject = lG4;
            fields  = fieldnames(Obj.mastDat.Data);
            Obj.filtered.combined = true(size(Obj.mastDat.Data.Time.value));
            Obj.filtered.wdir = Obj.filtered.combined;
            Obj.filtered.wsp = Obj.filtered.combined;
            Obj.filtered.date = Obj.filtered.combined;
            fieldInd = cell2mat(cellfun(@(x) ~isempty(x),strfind(fields,'mean'),'uni',false));
            roseSelection = uicontrol(Obj.pan21,'Style','popup','String',[' '; fields(fieldInd)],'Units','normalized','Position',[0.1 0.8 0.8 0.1]);
            uicontrol(Obj.pan21,'Style','text','String','Channel','Units','normalized','Position',[0.1 0.9 0.8 0.05]);
            Obj.tsSelection = uicontrol(Obj.pan31,'Style','popup','String',[' '; fields],'Units','normalized','Position',[0.1 0.8 0.8 0.1]);
            Obj.tsSelection2 = uicontrol(Obj.pan31,'Style','popup','String',[' '; fields],'Units','normalized','Position',[0.1 0.75 0.8 0.1]);
            uicontrol(Obj.pan31,'Style','text','String','Channel','Units','normalized','Position',[0.1 0.9 0.8 0.05]);
            
            Obj.dirFilter.N  = uicontrol(Obj.pan31,'Style','checkbox','String','N' ,'Units','normalized','Position',[0.1 0.75 0.4 0.05]);
            Obj.dirFilter.W  = uicontrol(Obj.pan31,'Style','checkbox','String','W' ,'Units','normalized','Position',[0.1 0.69 0.4 0.05]);
            Obj.dirFilter.S  = uicontrol(Obj.pan31,'Style','checkbox','String','S' ,'Units','normalized','Position',[0.1 0.63 0.4 0.05]);
            Obj.dirFilter.E  = uicontrol(Obj.pan31,'Style','checkbox','String','E' ,'Units','normalized','Position',[0.1 0.57 0.4 0.05]);
            
            Obj.dirFilter.NW = uicontrol(Obj.pan31,'Style','checkbox','String','NW','Units','normalized','Position',[0.5 0.75 0.4 0.05]);
            Obj.dirFilter.NE = uicontrol(Obj.pan31,'Style','checkbox','String','NE','Units','normalized','Position',[0.5 0.69 0.4 0.05]);
            Obj.dirFilter.SW = uicontrol(Obj.pan31,'Style','checkbox','String','SW','Units','normalized','Position',[0.5 0.63 0.4 0.05]);
            Obj.dirFilter.SE = uicontrol(Obj.pan31,'Style','checkbox','String','SE','Units','normalized','Position',[0.5 0.57 0.4 0.05]);
            
            Obj.wspFilter.max = uicontrol(Obj.pan31,'Style','edit','String','Max Wsp','Units','normalized','Position',[0.1 0.47 0.8 0.05],'TooltipString','Maximum Wind Speed');
            Obj.wspFilter.min = uicontrol(Obj.pan31,'Style','edit','String','Min Wsp','Units','normalized','Position',[0.1 0.41 0.8 0.05],'TooltipString','Minimum Wind Speed');
            Obj.wspFilter.chs = uicontrol(Obj.pan31,'Style','popup','String',['Select Wsp Chs'; fields(fieldInd)],'Units','normalized','Position',[0.1 0.35 0.8 0.05]);
            
            
            Obj.dateFilter.start = uicontrol(Obj.pan31,'Style','edit','String','Start Date [yyyy-mm-dd HH:MM]','Units','normalized','Position',[0.1 0.25 0.8 0.05],'TooltipString','Start Date [yyyy-mm-dd HH:MM]');
            Obj.dateFilter.stop = uicontrol(Obj.pan31,'Style','edit','String','End Date [yyyy-mm-dd HH:MM]','Units','normalized','Position',[0.1 0.19 0.8 0.05],'TooltipString','End Date [yyyy-mm-dd HH:MM]');
            Obj.dateFilter.doSync =  uicontrol(Obj.pan31,'Style','checkbox','String','Sync Date' ,'Units','normalized','Position',[0.1 0.13 0.8 0.05],'TooltipString','Syncronize Date with LIDAR Data.');
            
            buttonTrans = uicontrol(Obj.pan2,'style','slider','Min',0,'Max',1,'Value',0.75,'Units','normalized','Position', [3/4 0 1/4 0.5]);
            rhndl = rotate3d;
            rhndl.ActionPostCallback = {@Obj.camera_control};
            Obj.zoomSlider.Callback =  {@Obj.camera_control};
            Obj.zoomtxt.Callback =  {@Obj.camera_control};
            
            m = uimenu(Obj.fig,'Text','Other');
            Obj.isNorm = uimenu(m,'Text','Normalize','Checked','on');
            
            Obj.isNorm.MenuSelectedFcn  = {@Obj.draw_polar_plot};
            LidarButton.ClickedCallback = {@Obj.import_data};
            startButton.ClickedCallback = {@Obj.first_time};
            prevButton.ClickedCallback = {@Obj.prev_time};
            playButton.ClickedCallback = {@Obj.play};
            nextButton.ClickedCallback = {@Obj.next_time};
            endButton.ClickedCallback = {@Obj.last_time};
            showButton.ClickedCallback = {@Obj.show_lidar};
            showTreeButton.ClickedCallback = {@Obj.show_trees};
            areaofInterestButton.ClickedCallback = {@Obj.area_of_interest};
            buildingAreaButton.ClickedCallback = {@Obj.area_of_interest};
            forestAreaButton.ClickedCallback = {@Obj.area_of_interest};
            resetAreaButton.ClickedCallback = {@Obj.area_of_interest};
            
            
            for iFlight = 1:length(Obj.flightDat.Data)
                drone.(['Flight_' num2str(iFlight)]).ClickedCallback = {@Obj.show_drone_data};
            end
            
            roseSelection.Callback  = {@Obj.draw_stats};
            Obj.tsSelection.Callback  = {@Obj.draw_time_series};
            Obj.tsSelection2.Callback  = {@Obj.draw_time_series};
            
            
            
            mG1.Callback = {@Obj.plot_surf};
            mG2.Callback = {@Obj.plot_terr};
            mG3.Callback = {@Obj.plot_obs};
            mG4.Callback = {@Obj.geo_off};
            Obj.init_surf;
            Obj.pointCloudCheck.Callback = {@Obj.plot_surf};
            Obj.wakeStatCheck.Callback = {@Obj.draw_polar_plot};
            Obj.wakeStat10Check.Callback = {@Obj.draw_polar_plot};
            Obj.wakeStatCheckOff.Callback = {@Obj.draw_polar_plot};
            lG1.Callback = {@Obj.plot_raw};
            lG2.Callback = {@Obj.plot_post};
            lG3.Callback = {@Obj.plot_diff};
            lG4.Callback = {@Obj.wind_off};
            
            %             buttonSlider.Callback = {@Obj.set_marker_size};
            buttonTrans.Callback = {@Obj.set_transparency};
            Obj.tab1.ButtonDownFcn =  {@Obj.show_toolbar};
            Obj.tab2.ButtonDownFcn =  {@Obj.show_toolbar};
            Obj.tab3.ButtonDownFcn =  {@Obj.show_toolbar};
            
            Obj.dirFilter.N.Callback = {@Obj.filter_wdir};
            Obj.dirFilter.W.Callback = {@Obj.filter_wdir};
            Obj.dirFilter.S.Callback = {@Obj.filter_wdir};
            Obj.dirFilter.E.Callback = {@Obj.filter_wdir};
            Obj.dirFilter.NW.Callback = {@Obj.filter_wdir};
            Obj.dirFilter.NE.Callback = {@Obj.filter_wdir};
            Obj.dirFilter.SW.Callback = {@Obj.filter_wdir};
            Obj.dirFilter.SE.Callback = {@Obj.filter_wdir};
            
            Obj.wspFilter.max.Callback = {@Obj.filter_wsp};
            Obj.wspFilter.min.Callback = {@Obj.filter_wsp};
            Obj.wspFilter.chs.Callback = {@Obj.filter_wsp};
            
            Obj.dateFilter.start.Callback = {@Obj.filter_date};
            Obj.dateFilter.stop.Callback = {@Obj.filter_date};
            Obj.dateFilter.doSync.Callback = {@Obj.filter_date};
            
        end
        function set_transparency(varargin)
            Obj = varargin{1};
            handle = varargin{2};
            Obj.trns = handle.Value;
            alpha(Obj.pc,Obj.trns)
        end
        function show_lidar(varargin)
            Obj = varargin{1};
            if nargin > 1
                Obj.showLidar = varargin{2}.State;
            end
            if strcmpi(Obj.showLidar,'on') &&  ~strcmpi(Obj.geo.SelectedObject.Tag,'4')
                Obj.p5.Visible = 'on';
            else
                varargin{2}.State = 'off';
                Obj.showLidar = varargin{2}.State;
                Obj.p5.Visible = 'off';
            end
        end
        function show_trees(varargin)
            Obj = varargin{1};
            if nargin > 1
                Obj.showTrees = varargin{2}.State;
            end
            if strcmpi(Obj.showTrees,'on') && ~strcmpi(Obj.geo.SelectedObject.Tag,'4')
                Obj.p4.Visible = 'on';
            else
                varargin{2}.State = 'off';
                Obj.p4.Visible =  'off';
                Obj.showTrees = varargin{2}.State;
            end
        end
        function show_toolbar(varargin)
            Obj = varargin{1};
            dcm_obj = datacursormode(Obj.fig);
            dcm_obj.UpdateFcn = [];
            if strcmpi(varargin{2}.Title,'Field Analysis')
                Obj.toolbar.Visible = 'on';
            elseif strcmpi(varargin{2}.Title,'Time Series')
                
                fields  = fieldnames(Obj.mastDat.Data);
                Obj.tsSelection.String = [' '; fields];
                Obj.tsSelection2.String = [' '; fields];
                
                set(dcm_obj,'UpdateFcn',@Obj.ts_cursor)
                Obj.toolbar.Visible = 'off';
            else
                Obj.toolbar.Visible = 'off';
            end
        end
        function show_drone_data(varargin)
            Obj = varargin{1};
            if nargin > 1
                Obj.pf.(['show' varargin{2}.Tag]) = varargin{2}.State;
            end
            if strcmpi(Obj.pf.(['show' varargin{2}.Tag]),'on') && ~strcmpi(Obj.geo.SelectedObject.Tag,'4')
                Obj.pf.(varargin{2}.Tag).Visible = 'on';
                zlim(Obj.ax1,[-1 max(ceil(max(Obj.pf.(varargin{2}.Tag).ZData))+1,Obj.ax1.ZLim(2))])
            else
                varargin{2}.State = 'off';
                Obj.pf.(varargin{2}.Tag).Visible =  'off';
                Obj.pf.(varargin{2}.Tag).Visible = varargin{2}.State;
                uplim = str2num(Obj.zoomtxt.String);
                for iFlight = 1:length(Obj.flightDat.Data)
                    if strcmpi(Obj.pf.(['F' num2str(iFlight)]).Visible,'on')
                        uplim = max(uplim,ceil(max(Obj.pf.(['F' num2str(iFlight)]).ZData))+1);
                    end
                end
                zlim(Obj.ax1,[-1 uplim])
            end
            
        end
        function area_of_interest(varargin)
            Obj = varargin{1};
            if strcmpi(varargin{2}.Tag,'Area of Interest')
                xlim(Obj.ax1,[693.2 695])
                ylim(Obj.ax1,[6175.2 6176.2])
            elseif strcmpi(varargin{2}.Tag,'Forest Area')
                xlim(Obj.ax1,[693 694])
                ylim(Obj.ax1,[6175.2 6175.8])
            elseif strcmpi(varargin{2}.Tag,'Building Area')
                xlim(Obj.ax1,[694.6 695])
                ylim(Obj.ax1,[6175.7 6176])
            elseif strcmpi(varargin{2}.Tag,'Reset Area')
                xlim(Obj.ax1,[690 695])
                ylim(Obj.ax1,[6174 6177])
            end
        end
        function camera_control(varargin)
            Obj = varargin{1};
            Obj.ax1.Tag = 'AX1';
            try
                if strcmpi(varargin{3}.Axes.Tag,'FOV')
                    Obj.ax1.View = varargin{3}.Axes.View;
                end
            end
            try
                if strcmpi(varargin{3}.Axes.Tag,'AX1')
                    Obj.ax12.View = varargin{3}.Axes.View;
                end
            end
            try
                if strcmpi(varargin{2}.Tag,'Zoomslider')
                    varargin{2}.Value =  ceil(varargin{2}.Value);
                    Obj.ax1.ZLim = [-1 varargin{2}.Value];
                    caxis(Obj.ax1,[0 varargin{2}.Value])
                    caxis(Obj.ax110,[0 varargin{2}.Value])
                    Obj.zoomtxt.String = num2str(varargin{2}.Value);
                end
            end
            try
                if strcmpi(varargin{2}.Tag,'Zoomedit')
                    val = str2num(varargin{2}.String);
                    if isempty(val)
                        return
                    end
                    Obj.zoomSlider.Value = val;
                    Obj.ax1.ZLim = [-1 val];
                    caxis(Obj.ax1,[0 val])
                    caxis(Obj.ax110,[0 val])
                end
            end
        end
        function first_time(varargin)
            Obj = varargin{1};
            Obj.currentTime = 1;
            Obj.currentStatTime = 1;
            Obj.currentStatDeg = 1;
            Obj.draw_polar_plot;
        end
        function prev_time(varargin)
            Obj = varargin{1};
            if  Obj.currentTime > 30
                Obj.currentTime = Obj.currentTime-30;
            else
                Obj.currentTime = 1;
            end
            if Obj.currentStatTime > 1
                Obj.currentStatTime = Obj.currentStatTime-1;
            else
                Obj.currentStatTime = 1;
            end
            if Obj.currentStatDeg > 1
                Obj.currentStatDeg = Obj.currentStatDeg-1;
            else
                Obj.currentStatDeg = 1;
            end
            
            Obj.draw_polar_plot;
        end
        function play(varargin)
            Obj = varargin{1};
            if strcmpi(varargin{2}.TooltipString,'Play')
                varargin{2}.CData = Obj.pause;
                varargin{2}.TooltipString = 'Stop';
            else
                varargin{2}.CData = Obj.resume;
                varargin{2}.TooltipString = 'Play';
            end
            
            
            while strcmpi(varargin{2}.State,'on')
                if  Obj.currentTime < size(Obj.timeStop,1)-60
                    Obj.currentTime = Obj.currentTime+30;
                else
                    Obj.currentTime = 1;
                end
                
                if Obj.currentStatTime < length(Obj.wakeChar_10min.time)
                    Obj.currentStatTime = Obj.currentStatTime+1;
                else
                    Obj.currentStatTime = 1;
                    varargin{2}.State = 'off';
                    return
                end
                
                if Obj.currentStatDeg < length(Obj.wakeChar_dir.bin)
                    Obj.currentStatDeg = Obj.currentStatDeg+1;
                else
                    Obj.currentStatDeg = 1;
                end
                
                try
                    Obj.draw_polar_plot;
                end
                pause(1/10);
            end
        end
        function next_time(varargin)
            Obj = varargin{1};
            if  Obj.currentTime < size(Obj.timeStop,1)-60
                Obj.currentTime = Obj.currentTime+30;
            end
            if Obj.currentStatTime < length(Obj.wakeChar_10min.time)
                Obj.currentStatTime = Obj.currentStatTime + 1;
            end
            if Obj.currentStatDeg < length(Obj.wakeChar_dir.bin)
                Obj.currentStatDeg = Obj.currentStatDeg + 1;
            end
            try
                Obj.draw_polar_plot;
            end
        end
        function last_time(varargin)
            Obj = varargin{1};
            Obj.currentTime = size(Obj.timeStop,1)-29;
            Obj.currentStatTime = length(Obj.wakeChar_10min.time);
            Obj.currentStatDeg = length(Obj.wakeChar_dir.bin);
            
            Obj.draw_polar_plot;
        end
        function draw_polar_plot(varargin)
            Obj = varargin{1};
            if length(varargin)>1
                if strcmpi(class(varargin{2}),'matlab.ui.container.Menu')
                    if strcmpi(Obj.isNorm.Checked,'on')
                        Obj.isNorm.Checked='off';
                    else
                        Obj.isNorm.Checked='on';
                    end
                end
            end
            Obj.ax1.Children(1:end-(7+length(fieldnames(Obj.pf)))).delete
            hold(Obj.ax1,'on')
            mult = 5;
            if Obj.wakeStatCheck.Value && ~Obj.wakeStat10Check.Value && ~Obj.wakeStatCheckOff.Value
                Obj.wakeStatCheckOff.Value = 0;
                Obj.wakeStat10Check.Value = 0;
                azimuths = reshape(Obj.angAzm,30,[]);
                azimuths = deg2rad(mean(azimuths,2));
                if strcmpi(Obj.isNorm.Checked,'on')
                    velocity = Obj.wakeChar'./Obj.wakeChar(6,74);
                    interv = sshist(velocity)*mult;
                    bounds = linspace(min(velocity(:)),(max(velocity(:))),interv-1);
                else
                    velocity = -Obj.wakeChar';
                    interv = sshist(velocity)*mult;
                    bounds = linspace(min(velocity(:)),(max(velocity(:))),interv-1);
                end
                
                time = '';
                Obj.scanDate = (Obj.timeStop(Obj.currentTime+29));
            elseif Obj.wakeStat10Check.Value
                
                Obj.wakeStatCheck.Value = 0;
                Obj.wakeStatCheckOff.Value = 0;
                if strcmpi(Obj.isNorm.Checked,'on')
                    velocity = Obj.wakeChar_10min.Normvalue(:,:,Obj.currentStatTime)';
                    interv = sshist(velocity)*mult;
                    bounds = linspace(min(velocity(:)),(max(velocity(:))),interv-1);
                else
                    velocity = -Obj.wakeChar_10min.value(:,:,Obj.currentStatTime)';
                    interv = sshist(velocity)*mult;
                    bounds = linspace(min(velocity(:)),(max(velocity(:))),interv-1);
                end
                azimuths = Obj.wakeChar_10min.azimuth(:,Obj.currentStatTime);
                time = datestr(Obj.wakeChar_10min.time(Obj.currentStatTime),'yyyy-mm-dd HH:MM');
                Obj.scanDate = (Obj.wakeChar_10min.time(Obj.currentStatTime));
                
            elseif Obj.wakeStatCheckOff.Value
                
                Obj.wakeStatCheck.Value = 0;
                Obj.wakeStat10Check.Value = 0;
                if strcmpi(Obj.isNorm.Checked,'on')
                    velocity = Obj.wakeChar_dir.Normvalue(:,:,Obj.currentStatDeg)';
                    interv = sshist(velocity)*mult;
                    bounds = linspace(min(velocity(:)),(max(velocity(:))),interv-1);
                else
                    velocity = -Obj.wakeChar_dir.value(:,:,Obj.currentStatDeg)';
                    interv = sshist(velocity)*mult;
                    bounds = linspace(min(velocity(:)),(max(velocity(:))),interv-1);
                end
                azimuths = Obj.wakeChar_dir.azimuth(:,Obj.currentStatDeg);
                time = num2str(Obj.wakeChar_dir.bin(:,Obj.currentStatDeg));
                Obj.scanDate = (Obj.wakeChar_dir.bin(:,Obj.currentStatDeg));
                
                
                
                
                
            else
                azimuths = (deg2rad(Obj.angAzm(Obj.currentTime:Obj.currentTime+29)));
                velocity = Obj.velRad(Obj.currentTime:Obj.currentTime+29,:)';
                interv = 40;
                bounds = linspace(-20,20,39);
                time = datestr(Obj.timeStop(Obj.currentTime+29),'yyyy-mm-dd HH:MM:SS');
                Obj.scanDate = (Obj.timeStop(Obj.currentTime+29));
            end
            xLocs = arrayfun(@(x) Obj.geoDat.targetInfo.X+Obj.gateRange.*(sin(x)),azimuths,'uni',false);
            xall = [xLocs{:}];
            yLocs = arrayfun(@(x) Obj.geoDat.targetInfo.Y+Obj.gateRange.*(cos(x)),azimuths,'uni',false);
            yall = [yLocs{:}];
            height = DHM.get_beam_height(Obj.gateRange./1E3,Obj.geoDat.targetInfo.Height,Obj.geoDat.targetInfo.Lat);
            hall = repmat(height,1,30);
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
            
            clf(fig)
            fig.Position =  [0 113 658 824];
            Obj.ax6 = subplot(2,1,1);
            pc =  surf(Obj.ax6,xall./1E3,yall./1E3,velocity,colors);
            pc.EdgeColor = 'none';
            Obj.ax6.Color = 'none';
            Obj.ax6.GridColor = 'none';
            if Obj.wakeStatCheckOff.Value
                title(Obj.ax6,['Bin : ' num2str(Obj.wakeChar_dir.bin(1,Obj.currentStatDeg)) '\circ-' num2str(Obj.wakeChar_dir.bin(2,Obj.currentStatDeg)) '\circ, N = ' num2str(Obj.wakeChar_dir.nSample(Obj.currentStatDeg))]);
            else
                title(Obj.ax6,time)
            end
            xlim(Obj.ax6,[693.2 695])
            ylim(Obj.ax6,[6175.2 6176.2])
            zlim(Obj.ax6,[0 30])
            caxis(Obj.ax6,[bounds(1) bounds(end)]);
            view(Obj.ax6,[0 90])
            daspect(Obj.ax6,[0.01  0.01 5])
            xlabel(Obj.ax6,'Easting [km]')
            ylabel(Obj.ax6,'Northing [km]')
            cb =colorbar(Obj.ax6,'Location','east','AxisLocation','out') ;
            cb.Label.String = 'Wind Speed [Normalized]';
            
            colormap(Obj.ax6,legendColor);
            
            Obj.pc =  surf(Obj.ax1,xall./1E3,yall./1E3,hall,colors);
            Obj.F = scatteredInterpolant([reshape(xall,[],1)./1E3,reshape(yall,[],1)./1E3],reshape(velocity,[],1),'linear','none');
            
            Obj.pc.EdgeColor = 'none';
            title(Obj.ax1,time)
            Obj.draw_info;
            alpha(Obj.pc,Obj.trns)
            
            colormap(Obj.cb1,legendColor);
            caxis(Obj.ax12,[bounds(1) bounds(end)]);
            Obj.cb1.Visible = 'on';
            
        end
        function draw_info(varargin)
            Obj = varargin{1};
            range = (5:-0.25:-5).*19;
            elDist = -200:0.5:1600;
            if Obj.wakeStatCheckOff.Value

                angle = Obj.wakeChar_dir.meanAngle(Obj.currentStatDeg);
                tree = [6.93422e+05 6.175546e+06];
                
                dist = [6 10 15 20 30].*19;
                cPts =  [-dist.*sind(angle);-dist.*cosd(angle)]';
                
                cPts =(cPts+tree)./1E3;
                
                elCPts = [-elDist.*sind(angle);-elDist.*cosd(angle)]';
                elCPts =(elCPts+tree)./1E3;
                
                bar = [range*sind(angle-270);range*cosd(angle-270)]'./1E3;
                hold(Obj.ax1,'on')
                hold(Obj.ax6,'on')
                lines = elCPts;
                plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle',':');
                plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle',':');
                lines = bar+cPts(1,:);
                plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle','-');
                plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle','-');
                lines = bar+cPts(2,:);
                plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle','--');
                plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle','--');
                lines = bar+cPts(3,:);
                plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle',':');
                plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle',':');
                lines = bar+cPts(4,:);
                plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle','-.');
                plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle','-.');
                lines = bar+cPts(5,:);
                plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k');
                plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k');
                
                fig = figure(1001);
                sp = subplot(2,1,2);
                sp.Color = 'none';
                grid on;
                hold('on')
                plot(-5:0.25:5,Obj.F(bar+cPts(1,:)), '-k')
                plot(-5:0.25:5,Obj.F(bar+cPts(2,:)),'--k')
                plot(-5:0.25:5,Obj.F(bar+cPts(3,:)), ':k')
                plot(-5:0.25:5,Obj.F(bar+cPts(4,:)),'-.k')
                plot(-5:0.25:5,Obj.F(bar+cPts(5,:)), '+k')
                xlabel('Axial Distance from the Center of Tree [H: Tree Height]')
                ylabel('Wind Speed [Normalized]')
                ylim([0.4 1.1])

                %                 title(['Bin : ' num2str(Obj.wakeChar_dir.bin(1,Obj.currentStatDeg)) '\circ-' num2str(Obj.wakeChar_dir.bin(2,Obj.currentStatDeg)) '\circ, Ind = ' num2str(Obj.currentStatDeg)]);
                hold('off')
                legend('6H','10H','15H','20H','30H','Orientation','horizontal','Location','north')
                figName = fullfile('R:\SpecialCourseSafak\Figures\DirBased',['Long_Bin_' num2str(Obj.wakeChar_dir.bin(1,Obj.currentStatDeg)) '_' num2str(Obj.wakeChar_dir.bin(2,Obj.currentStatDeg)) '_' num2str(Obj.currentStatDeg)]);
                
                saveas(fig,figName,'epsc')
                saveas(fig,figName,'jpeg')
                saveas(fig,figName,'fig')
                
                fig2 = figure(1002);
                clf(fig2)
                fig2.Position = [765 727 793 176];
                sp = axes(fig2);
                sp.Color = 'none';
                plot(sp,elDist,Obj.H(elCPts./1E3), '-k')
                ylim([-1 30])
                xlabel('Distance [m]')
                ylabel('Surface Height [m]')
                grid on
                hold on
                plot(sp,[0 0],[0 30],'-r')
                sp.XTickLabel(2) = {'0, Tree'};
                
                
                figName = fullfile('R:\SpecialCourseSafak\Figures\DirBased',['Height' num2str(Obj.wakeChar_dir.bin(1,Obj.currentStatDeg)) '_' num2str(Obj.wakeChar_dir.bin(2,Obj.currentStatDeg)) '_' num2str(Obj.currentStatDeg)]);
                
                saveas(fig2,figName,'epsc')
                saveas(fig2,figName,'jpeg')
                saveas(fig2,figName,'fig')
            end
            try
                [~,minDif]=min(abs(Obj.mastDat.Data.Time.value-Obj.scanDate));
                
                if Obj.minDifInd == minDif
                    return
                else
                    Obj.minDifInd = minDif;
                end
            catch
                return
            end
            fields  = fieldnames(Obj.mastDat.Data);
            
            fieldInd = cell2mat(cellfun(@(x) ~isempty(x),strfind(fields,'mean'),'uni',false));
            heights = char(fields(fieldInd));
            heights = sort(str2num(heights(:,5:6)));
            
            y = 0:80;
            x = zeros(1,size(y,2));
            cla(Obj.ax11)
            plot(Obj.ax11,x,y,'-k');
            hold(Obj.ax11,'on')
            vert_profile = zeros(length(heights),1);
            for iHgt = 1:length(heights)
                plot(Obj.ax11,[-0.6 0],[heights(iHgt) heights(iHgt)],'-r')
                text(Obj.ax11,-0.65,heights(iHgt),[num2str(Obj.mastDat.Data.(['Wsp_' num2str(heights(iHgt)) 'm_mean']).value(minDif),'%5.1f') ' m/s'],'HorizontalAlignment','right')
                vert_profile(iHgt,1) = heights(iHgt);
                vert_profile(iHgt,2) = Obj.mastDat.Data.(['Wsp_' num2str(heights(iHgt)) 'm_mean']).value(minDif);
                
            end
            
            fieldInd = cell2mat(cellfun(@(x) ~isempty(x),strfind(fields,'Wdir'),'uni',false));
            heights = char(fields(fieldInd));
            heights = sort(str2num(heights(:,6:7)));
            for iHgt = 1:length(heights)
                plot(Obj.ax11,[ 0 0.6],[heights(iHgt) heights(iHgt)],'-b')
                angle = mod(Obj.mastDat.Data.(['Wdir_' num2str(heights(iHgt)) 'm']).value(minDif),360);
                text(Obj.ax11,0.65,heights(iHgt),[num2str(angle,'%5.1f') '\circ'],'HorizontalAlignment','left')
            end
            elAngle = mod(Obj.mastDat.Data.(['Wdir_' num2str(44) 'm']).value(minDif),360);
% elAngle =  258.4627826086956;
            %%
            
            angle = Obj.wakeChar_10min.dirValue1530(Obj.currentStatTime);
            
            tree = [6.93422e+05 6.175546e+06];
            dist = [6 10 15 20 30].*19;
            cPts =  [-dist.*sind(angle);-dist.*cosd(angle)]';
            
            cPts =(cPts+tree)./1E3;
            
            elCPts = [-elDist.*sind(elAngle);-elDist.*cosd(elAngle)]';
            elCPts =(elCPts+tree)./1E3;
            
            bar = [range*sind(angle-270);range*cosd(angle-270)]'./1E3;
            hold(Obj.ax1,'on')
            hold(Obj.ax6,'on')
            lines = elCPts;
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle',':');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle',':');
            lines = bar+cPts(1,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle','-');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle','-');
            lines = bar+cPts(2,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle','--');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle','--');
            lines = bar+cPts(3,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle',':');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle',':');
            lines = bar+cPts(4,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle','-.');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k','LineStyle','-.');
            lines = bar+cPts(5,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','k');
            
            fig = figure(1001);
            subplot(2,1,2)
            hold('on')
            plot(-5:0.25:5,Obj.F(bar+cPts(1,:)), '-k')
            plot(-5:0.25:5,Obj.F(bar+cPts(2,:)),'--k')
            plot(-5:0.25:5,Obj.F(bar+cPts(3,:)), ':k')
            plot(-5:0.25:5,Obj.F(bar+cPts(4,:)),'-.k')
            plot(-5:0.25:5,Obj.F(bar+cPts(5,:)), '+k')
%             title([datestr(Obj.wakeChar_10min.time(Obj.currentStatTime)) ', Ind = ' num2str(Obj.currentStatTime)]);
            hold('off')
            %                 legend(num2str(cell2mat(num2cell(dist)')))
            %%
            angle = Obj.wakeChar_10min.dirValue212(Obj.currentStatTime);
            
            tree = [6.93422e+05 6.175546e+06];
            dist = [6 10 15 20 30].*19;
            cPts =  [-dist.*sind(angle);-dist.*cosd(angle)]';
            
            cPts =(cPts+tree)./1E3;
            
            
            bar = [range*sind(angle-270);range*cosd(angle-270)]'./1E3;
            hold(Obj.ax1,'on')
            hold(Obj.ax6,'on')
            lines = bar+cPts(1,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','g','LineStyle','-');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','g','LineStyle','-');
            lines = bar+cPts(2,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','g','LineStyle','--');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','g','LineStyle','--');
            lines = bar+cPts(3,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','g','LineStyle',':');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','g','LineStyle',':');
            lines = bar+cPts(4,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','g','LineStyle','-.');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','g','LineStyle','-.');
            lines = bar+cPts(5,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','g');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','g');
            
            %                 fig = figure(1001);
            subplot(2,1,2)
            hold('on')
            plot(-5:0.25:5,Obj.F(bar+cPts(1,:)), '-g')
            plot(-5:0.25:5,Obj.F(bar+cPts(2,:)),'--g')
            plot(-5:0.25:5,Obj.F(bar+cPts(3,:)), ':g')
            plot(-5:0.25:5,Obj.F(bar+cPts(4,:)),'-.g')
            plot(-5:0.25:5,Obj.F(bar+cPts(5,:)), '+g')
%             title([datestr(Obj.wakeChar_10min.time(Obj.currentStatTime)) ', Ind = ' num2str(Obj.currentStatTime)]);
            hold('off')
            legend(num2str(cell2mat(num2cell(dist)')))
            %%
            angle = Obj.wakeChar_10min.dirValueall(Obj.currentStatTime);
            
            tree = [6.93422e+05 6.175546e+06];
            dist = [6 10 15 20 30].*19;
            cPts =  [-dist.*sind(angle);-dist.*cosd(angle)]';
            
            cPts =(cPts+tree)./1E3;
            
            
            bar = [range*sind(angle-270);range*cosd(angle-270)]'./1E3;
            hold(Obj.ax1,'on')
            hold(Obj.ax6,'on')
            lines = bar+cPts(1,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','c','LineStyle','-');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','c','LineStyle','-');
            lines = bar+cPts(2,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','c','LineStyle','--');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','c','LineStyle','--');
            lines = bar+cPts(3,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','c','LineStyle',':');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','c','LineStyle',':');
            lines = bar+cPts(4,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','c','LineStyle','-.');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','c','LineStyle','-.');
            lines = bar+cPts(5,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','c');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','c');
            
            %                 fig = figure(1001);
            subplot(2,1,2)
            hold('on')
            plot(-5:0.25:5,Obj.F(bar+cPts(1,:)), '-c')
            plot(-5:0.25:5,Obj.F(bar+cPts(2,:)),'--c')
            plot(-5:0.25:5,Obj.F(bar+cPts(3,:)), ':c')
            plot(-5:0.25:5,Obj.F(bar+cPts(4,:)),'-.c')
            plot(-5:0.25:5,Obj.F(bar+cPts(5,:)), '+c')
%             title([datestr(Obj.wakeChar_10min.time(Obj.currentStatTime)) ', Ind = ' num2str(Obj.currentStatTime)]);
            hold('off')
            legend(num2str(cell2mat(num2cell(dist)')))
            
            %%
            angle = mod(Obj.mastDat.Data.(['Wdir_' num2str(heights(iHgt)) 'm']).value(minDif),360);
            
            tree = [6.93422e+05 6.175546e+06];
            dist = [6 10 15 20 30].*19;
            cPts =  [-dist.*sind(angle);-dist.*cosd(angle)]';
            
            cPts =(cPts+tree)./1E3;
            
            
            bar = [range*sind(angle-270);range*cosd(angle-270)]'./1E3;
            hold(Obj.ax1,'on')
            hold(Obj.ax6,'on')
            lines = bar+cPts(1,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','b','LineStyle','-');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','b','LineStyle','-');
            lines = bar+cPts(2,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','b','LineStyle','--');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','b','LineStyle','--');
            lines = bar+cPts(3,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','b','LineStyle',':');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','b','LineStyle',':');
            lines = bar+cPts(4,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','b','LineStyle','-.');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','b','LineStyle','-.');
            lines = bar+cPts(5,:);
            plot3(Obj.ax1,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','b');
            plot3(Obj.ax6,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*23,'LineWidth',2,'Color','b');
            
            %                 fig = figure(1001);
            sub = subplot(2,1,2)
            sub.Color = 'none';
            hold('on')
            plot(-5:0.25:5,Obj.F(bar+cPts(1,:)), '-b')
            plot(-5:0.25:5,Obj.F(bar+cPts(2,:)),'--b')
            plot(-5:0.25:5,Obj.F(bar+cPts(3,:)), ':b')
            plot(-5:0.25:5,Obj.F(bar+cPts(4,:)),'-.b')
            plot(-5:0.25:5,Obj.F(bar+cPts(5,:)), '+b')
            grid on
            %             title([datestr(Obj.wakeChar_10min.time(Obj.currentStatTime),'yyyy-mm-dd HH:MM') ', Ind = ' num2str(Obj.currentStatTime)]);
            hold('off')
            h =  legend(sub,{'6H' '10H' '15H' '20H' '30H'},'Location','north','Orientation','horizontal');
            
            xlabel(sub,'Axial Distance from the Center of Tree [H: Tree Height]')
            ylabel(sub,'Wind Speed [Normalized]')
            ylim(sub,[0.4 1.1])
            legend(Obj.ax6,Obj.ax6.Children(end-2:-5:end-21),{'Case 1','Case 2','Case 3','Mast'},'Location','north','Orientation','horizontal')
            header =  [datestr(Obj.wakeChar_10min.time(Obj.currentStatTime),'yyyy-mm-dd HH:MM') ', Ri_{B} = ' num2str(Obj.mastDat.Data.Ri1870.value(minDif),'%2.10f') ', TI = ' num2str(Obj.mastDat.Data.TI_18m.value(minDif))  ', t_{ind} = ' num2str(Obj.currentStatTime)];
            title(Obj.ax6,header)
            
            
            figName = fullfile('R:\SpecialCourseSafak\Figures\DirBased',['Long_Time_10min_' num2str(Obj.currentStatTime)]);
    
            saveas(fig,figName,'epsc')
            saveas(fig,figName,'jpeg')
            saveas(fig,figName,'fig')
            
            
            fig2 = figure(1002);
            clf(fig2)
            fig2.Position = [765 727 793 176];
            sp = axes(fig2);
            sp.Color = 'none';
            plot(sp,elDist,Obj.H(elCPts./1E3), '-k')
            ylim([-1 30])
            xlabel('Distance [m]')
            ylabel('Surface Height [m]')
            grid on
            hold on
            plot(sp,[0 0],[0 30],'-r')
            xlim([-200 1600])
            sp.XTickLabel(2) = {'0, Tree'};
            
            
            figName = fullfile('R:\SpecialCourseSafak\Figures\DirBased',['Long_Time_10min_Height' num2str(Obj.currentStatTime)]);
                        
            saveas(fig2,figName,'epsc')
            saveas(fig2,figName,'jpeg')
            saveas(fig2,figName,'fig')
            
            %%
            h(1) = plot(Obj.ax11,[0; vert_profile(:,2)],[0 ;vert_profile(:,1)],'DisplayName','Wind Speed');
            
            fieldIndair = cell2mat(cellfun(@(x) ~isempty(x),strfind(fields,'AirAbs'),'uni',false));
            heights = char(fields(fieldIndair));
            heights = sort(str2num(heights(:,8:9)));
            for iHgt = 1:length(heights)
                plot(Obj.ax11,[ 0 0.6],[heights(iHgt) heights(iHgt)],'-r')
                text(Obj.ax11,0.65,heights(iHgt),[num2str(Obj.mastDat.Data.(['AirAbs_' num2str(heights(iHgt)) 'm']).value(minDif),'%5.1f') '\circC'],'HorizontalAlignment','left')
                vert_temp_profile(iHgt,1) = heights(iHgt);
                vert_temp_profile(iHgt,2) = Obj.mastDat.Data.(['AirAbs_' num2str(heights(iHgt)) 'm']).value(minDif);
                
            end
            h(2) = plot(Obj.ax11,vert_temp_profile(:,2),vert_temp_profile(:,1),'DisplayName','Abs Temp');
            
            try
                hold(Obj.ax11,'off');
                Obj.ax11.Color = 'none';
                xlim(Obj.ax11,[-ceil(max([vert_profile(:,2);vert_temp_profile(:,2)])) ceil(max([vert_profile(:,2);vert_temp_profile(:,2)]))]);
                ylim(Obj.ax11,[0 80]);
                ylabel(Obj.ax11,'Height [m]')
                tit = title(Obj.ax11,{['{\color[rgb]{' num2str(h(1).Color) '}---  }' 'Wsp  [m/s]   '],...
                    ['{\color[rgb]{' num2str(h(2).Color) '}---  }' 'Temp [\circC]']});
                tit.FontWeight = 'normal';
                tit.HorizontalAlignment = 'left';
                tit.Units = 'normalized';
                tit.Position = [0.6 1.01 0];
                
                if Obj.mastDat.Data.Ri1870.value(minDif)<0
                    txt = 'Unstable';
                elseif Obj.mastDat.Data.Ri1870.value(minDif)>0
                    txt = 'Stable';
                else
                    txt = 'Neutral';
                end
                
                Obj.RiNumber.String = ['Ri = ' num2str(Obj.mastDat.Data.Ri1870.value(minDif),'%2.10f') ', ' txt ', ' 'TI = ' num2str(Obj.mastDat.Data.TI_18m.value(minDif))];
                Obj.draw_time_series;
            end
        end
        function draw_stats(varargin)
            Obj = varargin{1};
            cla(Obj.ax22);
            if length(Obj.pan22.Children) >1
                Obj.pan22.Children(1).delete
            end
            if varargin{2}.Value ~= 1
                WindRose(Obj.mastDat.Data.Wdir_41m.value,Obj.mastDat.Data.(varargin{2}.String{varargin{2}.Value}).value,'axes',Obj.ax22)
            end
        end
        function draw_time_series(varargin)
            Obj = varargin{1};
            
            cla(Obj.ax32,'reset');
%             yyaxis(Obj.ax32,'left');
            if length(Obj.pan32.Children) >1
                Obj.pan32.Children(1).delete
            end
            if Obj.tsSelection.Value ~= 1
                intDate = Obj.mastDat.Data.Time.value;
                intVal = Obj.mastDat.Data.(Obj.tsSelection.String{Obj.tsSelection.Value}).value;
                intDate(~Obj.filtered.combined) = NaN;
                intVal(~Obj.filtered.combined) = NaN;
                d1 = plot(Obj.ax32,intDate,intVal);
                hold(Obj.ax32,'on');
                lEnt1 = strrep(Obj.tsSelection.String{Obj.tsSelection.Value},'W_dir','Wdir');
                
                if strcmpi(Obj.tsSelection2.Enable,'on') && Obj.tsSelection2.Value ~= 1
                    yyaxis(Obj.ax32,'right');
                    intDate = Obj.mastDat.Data.Time.value;
                    intVal = Obj.mastDat.Data.(Obj.tsSelection2.String{Obj.tsSelection2.Value}).value;
                    intDate(~Obj.filtered.combined) = NaN;
                    intVal(~Obj.filtered.combined) = NaN;
                    d2 = plot(Obj.ax32,intDate,intVal);
                    lEnt2 = strrep(Obj.tsSelection2.String{Obj.tsSelection2.Value},'W_dir','Wdir');
                end
                
                %                 Obj.ax6,Obj.ax6.Children(end-2:-5:end-21),{'Case 1','Case 2','Case 3','Mast'}
%                 minlim = min(Obj.ax32.YAxis(1).Limits(1),(Obj.tsSelection2.Value~=1)*Obj.ax32.YAxis(2).Limits(1));
%                 maxlim = max(Obj.ax32.YAxis(1).Limits(2),(Obj.tsSelection2.Value~=1)*Obj.ax32.YAxis(2).Limits(2));
%                 Obj.ax32.YAxis(1).Limits = [minlim maxlim];
%                 Obj.ax32.YAxis(2).Limits = [minlim maxlim];
                grid on;
                
%                 plot(Obj.ax32,[Obj.mastDat.Data.Time.value(Obj.minDifInd) Obj.mastDat.Data.Time.value(Obj.minDifInd)],[Obj.ax32.YAxis(1).Limits(1) Obj.ax32.YAxis(1).Limits(2)],'-r')
                if strcmpi(Obj.tsSelection2.Enable,'on') && Obj.tsSelection2.Value ~= 1
%                     legend([d1 d2],{lEnt1,lEnt2}, 'Interpreter', 'none')
                else
%                     legend(d1,lEnt1, 'Interpreter', 'none')
                end
                
                datetick(Obj.ax32,'x','dd-mm-yy HH:MM')
                if any(Obj.filtered.date)
                    xlim(Obj.ax32,[min(Obj.mastDat.Data.Time.value(Obj.filtered.date)) max(Obj.mastDat.Data.Time.value(Obj.filtered.date))])
                end
                if ~any(Obj.filtered.date) || ~any(Obj.filtered.combined)
                    errordlg('No Data found for given filters!','No Data','modal')
                end
                Obj.tsSelection2.Enable = 'on';
                
            else
                Obj.tsSelection2.Value = 1;
                Obj.tsSelection2.Enable = 'off';
            end
        end
        function filter_wdir(varargin)
            Obj = varargin{1};
            
            range.N  = [337.5 22.50].*Obj.dirFilter.N.Value;
            range.NE = [22.50 67.50].*Obj.dirFilter.NE.Value;
            range.E  = [67.50 112.5].*Obj.dirFilter.E.Value;
            range.SE = [112.5 157.5].*Obj.dirFilter.SE.Value;
            range.S  = [157.5 202.5].*Obj.dirFilter.S.Value;
            range.SW = [202.5 247.5].*Obj.dirFilter.SW.Value;
            range.W  = [247.5 292.5].*Obj.dirFilter.W.Value;
            range.NW = [292.5 337.5].*Obj.dirFilter.NW.Value;
            ranges = fieldnames(range);
            Obj.filtered.wdir = false(size(Obj.mastDat.Data.Wdir_41m.value));
            
            for iRange = 1:length(ranges)
                if Obj.dirFilter.(ranges{iRange}).Value
                    if strcmpi((ranges{iRange}),'N')
                        ind.(ranges{iRange}) = Obj.mastDat.Data.Wdir_41m.value > range.(ranges{iRange})(1) | ...
                            Obj.mastDat.Data.Wdir_41m.value <= range.(ranges{iRange})(2);
                    else
                        ind.(ranges{iRange}) = Obj.mastDat.Data.Wdir_41m.value > range.(ranges{iRange})(1) & ...
                            Obj.mastDat.Data.Wdir_41m.value <= range.(ranges{iRange})(2);
                    end
                    Obj.filtered.wdir = Obj.filtered.wdir | ind.(ranges{iRange});
                end
            end
            
            if all(~Obj.filtered.wdir)
                Obj.filtered.wdir = ~Obj.filtered.wdir;
            end
            
            Obj.process_filters;
        end
        function filter_wsp(varargin)
            Obj = varargin{1};
            
            highVal = str2num(Obj.wspFilter.max.String);
            if ~isempty(highVal)
                lowpass = true;
            else
                lowpass = false;
            end
            lowVal = str2num(Obj.wspFilter.min.String);
            if ~isempty(lowVal)
                highpass = true;
            else
                highpass = false;
            end
            chsName = Obj.wspFilter.chs.String{Obj.wspFilter.chs.Value};
            if Obj.wspFilter.chs.Value ~=1 && highpass && lowpass
                Obj.filtered.wsp = Obj.mastDat.Data.(chsName).value >= lowVal &...
                    Obj.mastDat.Data.(chsName).value <= highVal;
            elseif Obj.wspFilter.chs.Value ~=1 && highpass
                Obj.filtered.wsp = Obj.mastDat.Data.(chsName).value >= lowVal;
            elseif Obj.wspFilter.chs.Value ~=1 && lowpass
                Obj.filtered.wsp = Obj.mastDat.Data.(chsName).value <= highVal;
            else
                Obj.filtered.wsp  = true(size(Obj.mastDat.Data.Time.value));
            end
            Obj.process_filters;
            
        end
        function filter_date(varargin)
            Obj = varargin{1};
            
            if Obj.dateFilter.doSync.Value
                Obj.dateFilter.start.String = datestr(min(Obj.timeStop),'yyyy-mm-dd HH:MM');
                Obj.dateFilter.stop.String = datestr(max(Obj.timeStop),'yyyy-mm-dd HH:MM');
                Obj.dateFilter.start.Enable = 'off';
                Obj.dateFilter.stop.Enable = 'off';
                startDate = min(Obj.timeStop);
                stopDate  = max(Obj.timeStop);
                lowpass = true;
                highpass = true;
            else
                Obj.dateFilter.start.Enable = 'on';
                Obj.dateFilter.stop.Enable = 'on';
                
                try
                    startDate = datenum(Obj.dateFilter.start.String,'yyyy-mm-dd HH:MM');
                    if isempty(startDate)
                        startDate = datenum('2017-01-01 00:00','yyyy-mm-dd HH:MM');
                        
                    end
                    highpass = true;
                catch
                    highpass = false;
                end
                
                try
                    stopDate = datenum(Obj.dateFilter.stop.String,'yyyy-mm-dd HH:MM');
                    if isempty(stopDate)
                        stopDate = datenum('2018-12-31 23:59','yyyy-mm-dd HH:MM');
                    end
                    lowpass = true;
                catch
                    lowpass = false;
                end
            end
            if highpass && lowpass
                Obj.filtered.date = Obj.mastDat.Data.Time.value >= startDate &...
                    Obj.mastDat.Data.Time.value <= stopDate;
            elseif highpass
                Obj.filtered.date = Obj.mastDat.Data.Time.value >= startDate;
            elseif  lowpass
                Obj.filtered.date = Obj.mastDat.Data.Time.value <= stopDate;
            else
                Obj.filtered.date  = true(size(Obj.mastDat.Data.Time.value));
            end
            
            
            Obj.process_filters;
            
        end
        function process_filters(Obj)
            Obj.filtered.combined = Obj.filtered.wdir & Obj.filtered.wsp & Obj.filtered.date;
            Obj.draw_time_series;
        end
        function init_surf(Obj)
            [X,Y] = meshgrid((690:0.002:(695)),(6174:0.002:(6177)));
            Obj.p1 = surface(Obj.ax1,X,Y,Obj.geoDat.surfDat);
            set(Obj.p1,'EdgeAlpha',0);
            caxis(Obj.ax1,[0 30])
            demcmap([-0.2 40])
            daspect(Obj.ax1,[0.01  0.01 5])
            hold(Obj.ax1,'on')
            Obj.p2 = surface(Obj.ax1,X,Y,Obj.geoDat.terrDat);
            set(Obj.p2,'EdgeAlpha',0);
            obsHeight = (Obj.geoDat.surfDat-Obj.geoDat.terrDat);
            
            Obj.p3 = surface(Obj.ax1,X,Y,obsHeight);
            set(Obj.p3,'EdgeAlpha',0);
            trees = [693422 6175544;693484 6175556 ;693458 6175474;693412 6175402;693570 6175374]./1000;
            %             Obj.p4 = scatter3(Obj.ax1,trees(:,1),trees(:,2),50.*ones(5,1),'vr','MarkerFaceColor',[1 0 0]);
            Obj.p4 = scatter3(Obj.ax1,(Obj.geoDat.targetInfo.All(1:end-10,2)/1e3),(Obj.geoDat.targetInfo.All(1:end-10,1)/1e3),Obj.geoDat.targetInfo.All(1:end-10,3),'vr','MarkerFaceColor',[1 0 0]);
            Obj.p5 = scatter3(Obj.ax1,(Obj.geoDat.targetInfo.All(end-9:end-1,2)/1e3),(Obj.geoDat.targetInfo.All(end-9:end-1,1)/1e3),Obj.geoDat.targetInfo.All(end-9:end-1,3),'vr','MarkerFaceColor',[1 0 0]);
            xlim(Obj.ax1,[690 695])
            ylim(Obj.ax1,[6174 6177])
            
            [X,Y] = meshgrid((690:0.002:(695)),(6174:0.002:(6177)));
            Obj.H = scatteredInterpolant([reshape(X,[],1)./1E3,reshape(Y,[],1)./1E3],reshape(Obj.geoDat.surfDat,[],1),'linear','none');
            
            %%
            minX  = min(Obj.geoDat.highResDat.X)/1E3;
            maxX  = max(Obj.geoDat.highResDat.X)/1E3;
            minY  = min(Obj.geoDat.highResDat.Y)/1E3;
            maxY  = max(Obj.geoDat.highResDat.Y)/1E3;
            
            height = Obj.geoDat.surfDat;
            height(X>=minX & X<=maxX & Y>=minY & Y<=maxY) = NaN;
            
            
            minX  = min(Obj.geoDat.highResDat.Xf)/1E3;
            maxX  = max(Obj.geoDat.highResDat.Xf)/1E3;
            minY  = min(Obj.geoDat.highResDat.Yf)/1E3;
            maxY  = max(Obj.geoDat.highResDat.Yf)/1E3;
            
            height(X>=minX & X<=maxX & Y>=minY & Y<=maxY) = NaN;
            
            
            
            Obj.p6 = surf(Obj.ax1,X,Y,height);
            set(Obj.p6,'EdgeAlpha',0);
            
            
            legendColor = [ones(15,1) ones(15,1) linspace(0,1,15)'; ones(15,1) linspace(1,0,15)' linspace(1,0,15)' ];
            interval =  (arrayfun(@(L,U) find(not(abs(sign(sign(L - [Obj.geoDat.highResDat.Zf; Obj.geoDat.highResDat.Z]) + sign(U - [Obj.geoDat.highResDat.Zf; Obj.geoDat.highResDat.Z]))))==1),[-Inf 1:29],[1:29 Inf],'uni',false));
            for iInt = 1:size(interval,2)
                colors(interval{iInt},:) = repmat(legendColor(iInt,:),size(interval{iInt},1),1);
            end
            colormap(Obj.cb3,legendColor);
            
            Obj.p7 = scatter3(Obj.ax1,[Obj.geoDat.highResDat.Xf; Obj.geoDat.highResDat.X]./1E3,[Obj.geoDat.highResDat.Yf ;Obj.geoDat.highResDat.Y]./1E3,[Obj.geoDat.highResDat.Zf ;Obj.geoDat.highResDat.Z]);
            Obj.p7.CData = colors;
            %             Obj.p7.LineWidth =
            Obj.p7.MarkerEdgeAlpha = 0;
            Obj.p7.MarkerFaceColor = 'flat';
            Obj.p7.SizeData = 3;
            zlim(Obj.ax1,[-1 30]);
            caxis(Obj.ax110,[0 30])
            caxis(Obj.ax111,[0 30])
            
            for iFlight = 1:length(Obj.flightDat.Data)
                Obj.pf.(['F' num2str(iFlight)]) = plot3(Obj.ax1,Obj.flightDat.Data(iFlight).Easting./1E3,Obj.flightDat.Data(iFlight).Northing./1E3,Obj.flightDat.Data(iFlight).Altitude_m+Obj.geoDat.targetInfo.All(4,3),'LineWidth',5);
            end
            
            Obj.geo_off;
            
        end
        function plot_surf(varargin)
            Obj = varargin{1};
            Obj.geo_off;
            Obj.pointCloudCheck.Enable = 'on';
            Obj.ax1.Visible = 'on';
            Obj.cb2.Visible = 'on';
            if Obj.pointCloudCheck.Value
                Obj.cb3.Visible = 'on';
                Obj.p6.Visible = 'on';
                Obj.p7.Visible = 'on';
            else
                caxis(Obj.ax1,[0 Obj.ax1.ZLim(2)])
                caxis(Obj.ax110,[0 Obj.ax1.ZLim(2)])
                Obj.p1.Visible = 'on';
            end
            Obj.show_lidar;
            Obj.show_trees;
            %             Obj.show_drone_data;
        end
        function plot_terr(varargin)
            Obj = varargin{1};
            Obj.geo_off;
            Obj.pointCloudCheck.Enable = 'off';
            
            Obj.ax1.Visible = 'on';
            Obj.p2.Visible = 'on';
            Obj.show_lidar;
            Obj.show_trees;
            %             Obj.show_drone_data;
        end
        function plot_obs(varargin)
            Obj = varargin{1};
            Obj.geo_off;
            Obj.pointCloudCheck.Enable = 'off';
            
            Obj.ax1.Visible = 'on';
            Obj.p3.Visible = 'on';
            Obj.show_lidar;
            Obj.show_trees;
            %             Obj.show_drone_data;
        end
        function geo_off(varargin)
            Obj = varargin{1};
            for iFlight = 1:length(Obj.flightDat.Data)
                Obj.pf.(['F' num2str(iFlight)]).Visible = 'off';
            end
            Obj.cb2.Visible = 'off';
            Obj.cb3.Visible = 'off';
            Obj.ax1.Visible = 'off';
            Obj.p1.Visible = 'off';
            Obj.p2.Visible = 'off';
            Obj.p3.Visible = 'off';
            Obj.p4.Visible = 'off';
            Obj.p5.Visible = 'off';
            Obj.p6.Visible = 'off';
            Obj.p7.Visible = 'off';
            Obj.pointCloudCheck.Enable = 'off';
            title(Obj.ax1,'')
        end
        function plot_raw(varargin)
            Obj = varargin{1};
            Obj.timeStop = Obj.windDat.raw.timeStop;
            Obj.angAzm  = Obj.windDat.raw.angAzm;
            Obj.velRad  = Obj.windDat.raw.velRad;
            Obj.gateRange = Obj.windDat.raw.gateRange;
            Obj.draw_polar_plot;
        end
        function plot_post(varargin)
            Obj = varargin{1};
            Obj.timeStop = Obj.windDat.processed.timeStop;
            Obj.angAzm  = Obj.windDat.processed.angAzm;
            Obj.velRad  = Obj.windDat.processed.velRad;
            Obj.gateRange = Obj.windDat.processed.gateRange;
            Obj.draw_polar_plot;
        end
        function plot_diff(varargin)
            Obj = varargin{1};
            Obj.timeStop = Obj.windDat.raw.timeStop;
            Obj.angAzm  = Obj.windDat.raw.angAzm;
            Obj.velRad  =  Obj.windDat.raw.velRad-Obj.windDat.processed.velRad;
            Obj.gateRange = Obj.windDat.raw.gateRange;
            Obj.draw_polar_plot;
        end
        function wind_off(varargin)
            Obj = varargin{1};
            Obj.ax1.Children(1:end-(7+length(fieldnames(Obj.pf)))).delete
            
            Obj.ax1.Visible = 'off';
            Obj.cb1.Visible = 'off';
        end
        function output_txt = ts_cursor(varargin)
            event_obj = varargin{3};
            pos = get(event_obj,'Position');
            output_txt = {['Date: ',datestr(pos(1),'yyyy-mm-dd HH:MM')],...
                ['Y: ',num2str(pos(2),4)]};
            
            % If there is a Z-coordinate in the position, display it as well
            if length(pos) > 2
                output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
            end
        end
    end
end