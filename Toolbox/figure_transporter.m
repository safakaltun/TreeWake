fig  = figure(1);
pfig = figure(1E6);
clf(pfig);
axMP = fig.Children(3).Children(1).Children(3).Children;
axTS = fig.Children(3).Children(3).Children(1).Children;
actAx = axTS;
a = copyobj(actAx,pfig);
return
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
    end
end