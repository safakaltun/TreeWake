clr;
uiopen('R:\SpecialCourseSafak\Figures\Climate\long_WDIR_c123_41_44.fig',1)
fig = gcf;
filename = 'R:\SpecialCourseSafak\Figures\Climate\LONG_WDIR_CORR';
lims = [200 320];
sloc = [lims(2) 210];
dotSize  = 6;

ind = ~isnan(fig.Children.Children(1).YData)&~isnan(fig.Children.Children(end).YData);
time = fig.Children.Children(end).XData(ind);
dat1530 = fig.Children.Children(end).YData(ind);
dat212 = fig.Children.Children(end-1).YData(ind);
datall = fig.Children.Children(end-2).YData(ind);
dat44 = fig.Children.Children(end-4).YData(ind);
dat41 = fig.Children.Children(end-3).YData(ind);
% ind = ~isnan(fig.Children(2).Children(end).YData);
% dat1530 = fig.Children(2).Children(end).YData(ind);
% dat212 = fig.Children(2).Children(end-1).YData(ind);
% datall = fig.Children(2).Children(end-2).YData(ind);
% dat44 = fig.Children(2).Children(end-3).YData(ind);
% dat41 = fig.Children(2).Children(end-4).YData(ind);
coeffs1  = [ones(length(dat41),1) dat41']\dat1530';
coeffs2  = [ones(length(dat41),1) dat41']\dat212';
coeffs3  = [ones(length(dat41),1) dat41']\datall';
coeffs11 = [ones(length(dat44),1) dat44']\dat1530';
coeffs12 = [ones(length(dat44),1) dat44']\dat212';
coeffs13 = [ones(length(dat44),1) dat44']\datall';


reg1  = coeffs1(2);
reg2  = coeffs2(2);
reg3  = coeffs3(2);
reg11 = coeffs11(2);
reg12 = coeffs12(2);
reg13 = coeffs13(2);

offset1  = coeffs1(1);
offset2  = coeffs2(1);
offset3  = coeffs3(1);
offset11 = coeffs11(1);
offset12 = coeffs12(1);
offset13 = coeffs13(1);

reg1Dat  = offset1 + reg1*dat41;
reg2Dat  = offset2 + reg2*dat41;
reg3Dat  = offset3 + reg3*dat41;
reg11Dat = offset11 + reg11*dat44;
reg12Dat = offset12 + reg12*dat44;
reg13Dat = offset13 + reg13*dat44;
%%
f = figure(2);
f.Position= [402 66 937 922];
clf
sb1 = subplot(3,1,1);
plot(time,dat1530)
hold on
plot(time,dat212)
plot(time,datall)
plot(time,dat41)
plot(time,dat44)
datetick(sb1,'x','dd-mm-yy HH:MM')
% xlim([floor(time(1))+0.5 floor(time(end))+0.5])
xlabel('Time')
ylabel('Wdir [\circ]')
legend('Case 1','Case 2','Case 3','Mast 41m','Mast 44m','Location','south','Orientation','horizontal')
grid on

sb2 = subplot(3,3,4);
scatter(sb2,dat41,dat1530,dotSize,'filled')
xlabel('Wdir 41m (Mast)')
ylabel('Wdir 22.5m (Case 1)')
hold on
plot(dat41,reg1Dat,'-r')
xlim(lims)
ylim(lims)
grid on
text(sloc(1),sloc(2),['y = ' num2str(offset1) ' + ' num2str(reg1) 'x'],'FontSize',8,'HorizontalAlignment','right')


 daspect( [1 1 1])

sb3 = subplot(3,3,5);
scatter(sb3,dat41,dat212,dotSize,'filled')
xlabel('Wdir 41m (Mast)')
ylabel('Wdir 22.5m (Case 2)')
hold on
plot(dat41,reg2Dat,'-r')
xlim(lims)
ylim(lims)
grid on
text(sloc(1),sloc(2),['y = ' num2str(offset2) ' + ' num2str(reg2) 'x'],'FontSize',8,'HorizontalAlignment','right')


 daspect( [1 1 1])

sb4 = subplot(3,3,6);
scatter(sb4,dat41,datall,dotSize,'filled')
xlabel('Wdir 41m (Mast)')
ylabel('Wdir 22.5m (Case 3)')
hold on
plot(dat41,reg3Dat,'-r')
xlim(lims)
ylim(lims)
grid on
text(sloc(1),sloc(2),['y = ' num2str(offset3) ' + ' num2str(reg3) 'x'],'FontSize',8,'HorizontalAlignment','right')


 daspect( [1 1 1])

sb5 = subplot(3,3,7);
scatter(sb5,dat44,dat1530,dotSize,'filled')
xlabel('Wdir 44m (Mast)')
ylabel('Wdir 22.5m (Case 1)')
hold on
plot(dat44,reg11Dat,'-r')
xlim(lims)
ylim(lims)
grid on
text(sloc(1),sloc(2),['y = ' num2str(offset11) ' + ' num2str(reg11) 'x'],'FontSize',8,'HorizontalAlignment','right')


 daspect( [1 1 1])

sb6 = subplot(3,3,8);
scatter(sb6,dat44,dat212,dotSize,'filled')
xlabel('Wdir 44m (Mast)')
ylabel('Wdir 22.5m (Case 2)')
hold on
plot(dat44,reg12Dat,'-r')
xlim(lims)
ylim(lims)
grid on
text(sloc(1),sloc(2),['y = ' num2str(offset12) ' + ' num2str(reg12) 'x'],'FontSize',8,'HorizontalAlignment','right')


 daspect( [1 1 1])

sb7 = subplot(3,3,9);
scatter(sb7,dat44,datall,dotSize,'filled')
xlabel('Wdir 44m (Mast)')
ylabel('Wdir 22.5m (Case 3)')
hold on
plot(dat44,reg13Dat,'-r')
xlim(lims)
ylim(lims)
grid on
text(sloc(1),sloc(2),['y = ' num2str(offset13) ' + ' num2str(reg13) 'x'],'FontSize',8,'HorizontalAlignment','right')


 daspect( [1 1 1])

saveas(f,filename,'fig')
saveas(f,filename,'epsc')
saveas(f,filename,'jpeg')
