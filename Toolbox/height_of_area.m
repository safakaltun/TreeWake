Obj = DHM;
% Obj.highResDat
higresX = Obj.highResDat.X;
higresY = Obj.highResDat.Y;
higresZ = Obj.highResDat.Z;
f = figure;
f.Position= [2319 277 1112 420];
ax = axes;
ax2 = axes(f);
ax2.Position =[ 0.161870503597125   0.588095238095244   0.215827338129494   0.335714285714281];
% p = scatter3(ax,higresX,higresY,higresZ);

% p.MarkerEdgeAlpha = 0;
% p.MarkerFaceColor = 'flat';
% p.SizeData = 3;
% zlim(ax,[0 35])
hold(ax,'on')
% xlim(Obj.xLims)
% ylim(Obj.yLims)
% view([12 0])

[X,Y] = meshgrid((690:0.002:(695)),(6174:0.002:(6177)));
dhmInt = scatteredInterpolant([reshape(X,[],1),reshape(Y,[],1)],reshape(Obj.surfDat,[],1),'linear','none');
pcInt = scatteredInterpolant([higresX,higresY]./1E3,higresZ,'linear','none');

elDist = -100:0.5:100;
elAngle =  258.4627826086956;
dhmTree = [6.93422e+02 6.175546e+03]*1E3;
[~,a]=max(higresZ);
 pcTree = [higresX(a) higresY(a)]/1E3;
 dhmCPts = [-elDist.*sind(elAngle);-elDist.*cosd(elAngle)]';
 dhmCPts =(dhmCPts+dhmTree);
 lines =     dhmCPts./1E3;
 plot(ax,elDist,dhmInt(lines),'-k')
 plot(ax,elDist,pcInt(lines),'-r')
   plot3(ax2,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*29.9,'LineWidth',2,'Color','r','LineStyle',':');

  pcCPts = [-elDist.*sind(elAngle);-elDist.*cosd(elAngle)]';
 pcCPts =(pcCPts/1E3+pcTree);
 lines = pcCPts;
 plot(ax,elDist,dhmInt(lines),'--k')
 plot(ax,elDist,pcInt(lines),'--r')
 daspect([1 1 1])
 legend('DHM Pos1','Point Cloud Pos1','DHM Pos2','Point Cloud Pos2','Location','south','Orientation','horizontal')
%  at = dhmTree-pcTree*1E3
  plot3(ax2,lines(:,1),lines(:,2),ones(length(lines(:,2)),1)*29.9,'LineWidth',2,'Color','c','LineStyle',':');
 
 
 
 
 
