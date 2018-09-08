fig  = figure(1);
pfig = figure(1E6);
clf(pfig);
axMP = fig.Children(3).Children(1).Children(3).Children;
axTS = fig.Children(3).Children(3).Children(1).Children;
a = copyobj(axMP,pfig);
a.Colormap=axMP.Colormap;
% colorbar(a,'Location','south')
xlabel(a,'Easting [km]')
ylabel(a,'Northing [km]')
% zlabel(a,'Elevation [m]')


angles = -170;%[-170 -140 -120 -80:-75 10 95:100];
h = 0:0.1:15;

for i = angles
    for j = h
        view([i j])
        figName = strrep(fullfile('R:\SpecialCourseSafak\Figures\Transferred',['tryAREA_'  num2str(i) '_' num2str(j)]),'.','-');
        print(pfig,figName,'-depsc')
        print(pfig,figName,'-djpeg')
    end
end