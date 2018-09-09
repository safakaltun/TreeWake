clr;
uiopen('R:\SpecialCourseSafak\Figures\Climate\long_WSP_reversed.fig',1)
filename = 'R:\SpecialCourseSafak\Figures\Climate\LONG_WSPD_CORR';

lims = [0 25];
% plotLim = [3 15];
plotLim = [0 25];
sloc = [lims(2) 1.5];
dotSize  = 3.5;
fig = gcf;
% fig.Children.Children = flipud(fig.Children.Children);
ind = ~isnan(fig.Children.Children(1).YData)&~isnan(fig.Children.Children(6).YData);
time = fig.Children.Children(end).XData(ind);
dat1530 = fig.Children.Children(1).YData(ind);
dat212 = fig.Children.Children(2).YData(ind);
datall = fig.Children.Children(3).YData(ind);
dat18 = fig.Children.Children(4).YData(ind);
dat31 = fig.Children.Children(5).YData(ind);
dat44 = fig.Children.Children(6).YData(ind);
dat57 = fig.Children.Children(7).YData(ind);
dat70 = fig.Children.Children(8).YData(ind);


coeffs11  = [ones(length(dat18),1) dat18']\dat1530';
coeffs12  = [ones(length(dat18),1) dat18']\dat212';
coeffs13  = [ones(length(dat18),1) dat18']\datall';

coeffs21 = [ones(length(dat31),1) dat31']\dat1530';
coeffs22 = [ones(length(dat31),1) dat31']\dat212';
coeffs23 = [ones(length(dat31),1) dat31']\datall';

coeffs31 = [ones(length(dat44),1) dat44']\dat1530';
coeffs32 = [ones(length(dat44),1) dat44']\dat212';
coeffs33 = [ones(length(dat44),1) dat44']\datall';

coeffs41 = [ones(length(dat57),1) dat57']\dat1530';
coeffs42 = [ones(length(dat57),1) dat57']\dat212';
coeffs43 = [ones(length(dat57),1) dat57']\datall';

coeffs51 = [ones(length(dat70),1) dat70']\dat1530';
coeffs52 = [ones(length(dat70),1) dat70']\dat212';
coeffs53 = [ones(length(dat70),1) dat70']\datall';

reg11 = coeffs11(2);
reg12 = coeffs12(2);
reg13 = coeffs13(2);
                
reg21 = coeffs21(2);
reg22 = coeffs22(2);
reg23 = coeffs23(2);
                
reg31 = coeffs31(2);
reg32 = coeffs32(2);
reg33 = coeffs33(2);
                
reg41 = coeffs41(2);
reg42 = coeffs42(2);
reg43 = coeffs43(2);
                
reg51 = coeffs51(2);
reg52 = coeffs52(2);
reg53 = coeffs53(2);


offset11 = coeffs11(1);
offset12 = coeffs12(1);
offset13 = coeffs13(1);
                    
offset21 = coeffs21(1);
offset22 = coeffs22(1);
offset23 = coeffs23(1);
                    
offset31 = coeffs31(1);
offset32 = coeffs32(1);
offset33 = coeffs33(1);

offset41 = coeffs41(1);
offset42 = coeffs42(1);
offset43 = coeffs43(1);

offset51 = coeffs51(1);
offset52 = coeffs52(1);
offset53 = coeffs53(1);


reg11Dat = offset11 + dat18*reg11;
reg12Dat = offset12 + dat18*reg12;
reg13Dat = offset13 + dat18*reg13;
                     
reg21Dat = offset21 + dat31*reg21;
reg22Dat = offset22 + dat31*reg22;
reg23Dat = offset23 + dat31*reg23;
                     
reg31Dat = offset31 + dat44*reg31;
reg32Dat = offset32 + dat44*reg32;
reg33Dat = offset33 + dat44*reg33;
                     
reg41Dat = offset41 + dat57*reg41;
reg42Dat = offset42 + dat57*reg42;
reg43Dat = offset43 + dat57*reg43;
                     
reg51Dat = offset51 + dat70*reg51;
reg52Dat = offset52 + dat70*reg52;
reg53Dat = offset53 + dat70*reg53;



%%


%%
f = figure(2);
f.Position= [373 97 1171 867];
clf

sb01 = subplot(4,1,1);

plot(sb01,time,dat1530)
hold on
plot(sb01,time,dat212 )
plot(sb01,time,datall )
plot(sb01,time,dat18  )
plot(sb01,time,dat31  )
plot(sb01,time,dat44  )
plot(sb01,time,dat57  )
plot(sb01,time,dat70  )
datetick(sb01,'x','dd-mm-yy HH:MM')
xlim(sb01,[time(1) time(end)])
ylim(plotLim)
xlabel('Date')
ylabel('Wspd [m/s]')
legend('Case 1','Case 2','Case 3','Mast 18m','Mast 31m','Mast 44m','Mast 57m','Mast 70m','Location','north','Orientation','horizontal')
grid on


sb06 = subplot(4,5,6);

scatter(dat18,dat1530,dotSize,'filled')
ylabel('Wspd 22.5m (Case 1)')
hold on
plot(dat18,reg11Dat,'-r')
xlim(lims)
ylim(lims)
text(sloc(1),sloc(2),['y = ' num2str(offset11) ' + ' num2str(reg11) 'x'],'FontSize',8,'HorizontalAlignment','right')
grid minor
 daspect( [1 1 1])
sb07 = subplot(4,5,7);

scatter(dat31,dat1530,dotSize,'filled')
hold on
plot(dat31,reg21Dat,'-r')
xlim(lims)
ylim(lims)
text(sloc(1),sloc(2),['y = ' num2str(offset21) ' + ' num2str(reg21) 'x'],'FontSize',8,'HorizontalAlignment','right')
grid minor
 daspect( [1 1 1])
sb08 = subplot(4,5,8);

scatter(dat44,dat1530,dotSize,'filled')
hold on
plot(dat44,reg31Dat,'-r')
xlim(lims)
ylim(lims)
text(sloc(1),sloc(2),['y = ' num2str(offset31) ' + ' num2str(reg31) 'x'],'FontSize',8,'HorizontalAlignment','right')
grid minor
 daspect( [1 1 1])
sb09 = subplot(4,5,9);

scatter(dat57,dat1530,dotSize,'filled')
hold on
plot(dat57,reg41Dat,'-r')
xlim(lims)
ylim(lims)
text(sloc(1),sloc(2),['y = ' num2str(offset41) ' + ' num2str(reg41) 'x'],'FontSize',8,'HorizontalAlignment','right')
grid minor
 daspect( [1 1 1])
sb10 = subplot(4,5,10);

scatter(dat70,dat1530,dotSize,'filled')
hold on
plot(dat70,reg51Dat,'-r')
xlim(lims)
ylim(lims)
text(sloc(1),sloc(2),['y = ' num2str(offset51) ' + ' num2str(reg51) 'x'],'FontSize',8,'HorizontalAlignment','right')
grid minor
 daspect( [1 1 1])
sb11 = subplot(4,5,11);

scatter(dat18,dat212,dotSize,'filled')
ylabel('Wspd 22.5m (Case 2)')
hold on
plot(dat18,reg12Dat,'-r')
xlim(lims)
ylim(lims)
text(sloc(1),sloc(2),['y = ' num2str(offset12) ' + ' num2str(reg12) 'x'],'FontSize',8,'HorizontalAlignment','right')
grid minor
 daspect( [1 1 1])
sb12 = subplot(4,5,12);

scatter(dat31,dat212,dotSize,'filled')
hold on
plot(dat31,reg22Dat,'-r')
xlim(lims)
ylim(lims)
text(sloc(1),sloc(2),['y = ' num2str(offset22) ' + ' num2str(reg22) 'x'],'FontSize',8,'HorizontalAlignment','right')
grid minor
 daspect( [1 1 1])
sb13 = subplot(4,5,13);

scatter(dat44,dat212,dotSize,'filled')
hold on
plot(dat44,reg32Dat,'-r')
xlim(lims)
ylim(lims)
text(sloc(1),sloc(2),['y = ' num2str(offset32) ' + ' num2str(reg32) 'x'],'FontSize',8,'HorizontalAlignment','right')
grid minor
 daspect( [1 1 1])
sb14 = subplot(4,5,14);

scatter(dat57,dat212,dotSize,'filled')
hold on
plot(dat57,reg42Dat,'-r')
xlim(lims)
ylim(lims)
text(sloc(1),sloc(2),['y = ' num2str(offset42) ' + ' num2str(reg42) 'x'],'FontSize',8,'HorizontalAlignment','right')
grid minor
 daspect( [1 1 1])
sb15 = subplot(4,5,15);

scatter(dat70,dat212,dotSize,'filled')
hold on
plot(dat70,reg52Dat,'-r')
xlim(lims)
ylim(lims)
text(sloc(1),sloc(2),['y = ' num2str(offset52) ' + ' num2str(reg52) 'x'],'FontSize',8,'HorizontalAlignment','right')
grid minor
 daspect( [1 1 1])
sb16 = subplot(4,5,16);

scatter(dat18,datall,dotSize,'filled')
xlabel('Wspd 18m (Mast)')
ylabel('Wspd 22.5m (Case 3)')
hold on
plot(dat18,reg13Dat,'-r')
xlim(lims)
ylim(lims)
text(sloc(1),sloc(2),['y = ' num2str(offset13) ' + ' num2str(reg13) 'x'],'FontSize',8,'HorizontalAlignment','right')
grid minor
 daspect( [1 1 1])
sb17 = subplot(4,5,17);

scatter(dat31,datall,dotSize,'filled')
xlabel('Wspd 31m (Mast)')
hold on
plot(dat31,reg23Dat,'-r')
xlim(lims)
ylim(lims)
text(sloc(1),sloc(2),['y = ' num2str(offset23) ' + ' num2str(reg23) 'x'],'FontSize',8,'HorizontalAlignment','right')
grid minor
 daspect( [1 1 1])
sb18 = subplot(4,5,18);

scatter(dat44,datall,dotSize,'filled')
xlabel('Wspd 44m (Mast)')
hold on
plot(dat44,reg33Dat,'-r')
xlim(lims)
ylim(lims)
text(sloc(1),sloc(2),['y = ' num2str(offset33) ' + ' num2str(reg33) 'x'],'FontSize',8,'HorizontalAlignment','right')
grid minor
 daspect( [1 1 1])
sb19 = subplot(4,5,19);

scatter(dat57,datall,dotSize,'filled')
xlabel('Wspd 57m (Mast)')
hold on
plot(dat57,reg43Dat,'-r')
xlim(lims)
ylim(lims)
text(sloc(1),sloc(2),['y = ' num2str(offset43) ' + ' num2str(reg43) 'x'],'FontSize',8,'HorizontalAlignment','right')
grid minor
 daspect( [1 1 1])
sb20 = subplot(4,5,20);

scatter(dat70,datall,dotSize,'filled')
xlabel('Wspd 70m (Mast)')
hold on
plot(dat70,reg53Dat,'-r')
xlim(lims)
ylim(lims)
text(sloc(1),sloc(2),['y = ' num2str(offset53) ' + ' num2str(reg53) 'x'],'FontSize',8,'HorizontalAlignment','right')
grid minor
 daspect( [1 1 1])
 
 saveas(f,filename,'fig')
saveas(f,filename,'epsc')
saveas(f,filename,'jpeg')