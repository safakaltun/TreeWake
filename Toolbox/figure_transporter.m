fig  = figure(1);
pfig = figure(1E6);
clf(pfig);
axMP = fig.Children(2).Children(1).Children(3).Children;
% axTS = fig.Children(3).Children(3).Children(1).Children;
actAx = axMP;

%


% sp = subplot(2,1,1)
% cla(sp)
% copyobj(actAx.Children,sp)
% demcmap([-0.2 40])
% caxis(sp,[0 30])
% daspect(sp,[0.01  0.01 5])
% xlim(sp,[693.2 695])
% ylim(sp,[6175.2 6176.2])
% sp = subplot(2,1,2)
% plot(sp,elDist,Obj.H(elCPts./1E3), '-k')
% ylim([-1 30])
% xlabel('Distance [m]')
% ylabel('Surface Height [m]')
% grid on
% hold on
% plot(sp,[0 0],[0 30],'-r')
% xlim([-200 1600])
% sp.XTickLabel(2) = {'0, Tree'};


%
a = copyobj(actAx,pfig);
% return
a.Colormap=actAx.Colormap;
% colorbar(a,'Location','south')

xlabel(a,'Easting [km]')
ylabel(a,'Northing [km]')
% zlabel(a,'Elevation [m]')

angles =  [-120 -78 10 102]; %[-170 -140 -120 -80:-75 10 95:100];
h = 1:2:46;

for i = angles
    for j = h
        view([i j])
        figName = fullfile('R:\SpecialCourseSafak\Figures\Transferred',['try_'  num2str(i) '_' num2str(j)]);
        print(pfig,figName,'-depsc')
        print(pfig,figName,'-djpeg')
%         saveas(fig,filename,'fig')
% saveas(fig,filename,'epsc')
% saveas(fig,filename,'jpeg')
    end
end