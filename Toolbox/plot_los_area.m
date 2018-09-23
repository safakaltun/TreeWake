Obj = LASCAR_Processed;
Obj.File = 'R:\SpecialCourseSafak\LASCAR_Data\20171114153902_PPI1_merged.txt';
Obj.set_data;
angles = Obj.angAzm(31:60);
xDist = Obj.gateRange*sind(angles)';
yDist = Obj.gateRange*cosd(angles)';
xCasea = [0;xDist(:,15) ; xDist(197,16:29)';xDist(197:-1:1,30);0];
yCasea = [0;yDist(:,15) ; yDist(197,16:29)';yDist(197:-1:1,30);0];
xCaseb = [0;xDist(:,2) ; xDist(197,3:11)';xDist(197:-1:1,12);0];
yCaseb = [0;yDist(:,2) ; yDist(197,3:11)';yDist(197:-1:1,12);0];
xCasec = [0;xDist(:,1) ; xDist(197,2:29)';xDist(197:-1:1,30);0];
yCasec = [0;yDist(:,1) ; yDist(197,2:29)';yDist(197:-1:1,30);0];
close all
f = figure;
f.Position =  [903 439 894 420];
plot(xCasec,yCasec,'-g','LineWidth',2)
hold on
plot(xCaseb,yCaseb,'--b','LineWidth',2)
plot(xCasea,yCasea,'--k','LineWidth',2)

daspect([1 1 1])
scatter(0,0,'filled','Marker','square','MarkerFaceColor','r','LineWidth',2)
xlim([-4500 500])
legend('Area of Case C','Area of Case B','Area of Case A','Sirocco')
xlabel('Horizontal Distance [m]')
ylabel('Vertical Distance [m]')

figName = fullfile('R:\SpecialCourseSafak\Figures\','LOScaseArea');
saveas(f,figName,'epsc')
saveas(f,figName,'jpeg')
saveas(f,figName,'fig')