Obj = LASCAR;
% files = dir('R:\SpecialCourseSafak\LASCAR_Data\*.txt');
% fileList = fullfile({files.folder}', {files.name}');
% Obj = LASCAR.run(fileList(2));
% gObj = LASCAR_GUI;
%        timeStop
%          angAzm
%          velRad
%       gateRange

% Obj.rawData.plot
% Obj.postData.plot


% dhmObj = DHM;
% dhmObj.set_surfDat;
% dhmObj.set_terrDat;
% dhmObj.plot_surf;
% dhmObj.plot_terr;
% 
% fig4 = figure(3);
% fig2 = figure(2);
% 
% 
% copyobj(fig2.Children(2).Children(2),fig4)
% fig4.Children(1).Color = 'none';

% 
% fig4.Children(3).Position 
% fig4.Children(3).XLim
% lenScan = 4/diff(fig4.Children(3).XLim)*fig4.Children(3).Position(3);
% degree = abs(fig4.Children(1).ThetaLim-270);
% heiScan = sum(sind(degree)*4)/diff(fig4.Children(3).YLim)*fig4.Children(3).Position(4);
% XStartScan = fig4.Children(3).Position(1)+((fig4.Children(3).Children(1).XData-fig4.Children(3).XLim(1))/5)*fig4.Children(3).Position(3);
% YStartScan = fig4.Children(3).Position(2)+((fig4.Children(3).Children(1).YData-sind(degree(1))*4-fig4.Children(3).YLim(1))/3)*fig4.Children(3).Position(4);
% fig4.Children(1).Position = [XStartScan,YStartScan,lenScan,heiScan];
 
 %Create a zoom handle and define the post-callback process
% handles.zhndl = zoom;  
% handles.zhndl.ActionPostCallback = {@zoomMapAspect,handles};
%Post-callback function  

 
%  
% fig4.Children(3).YLim
% 
% lidLoc = fig4.Children(3).Children(2)
% lidEnd = fig4.Children(3).Children(1)
% fig4.Children(3) % pos of axes