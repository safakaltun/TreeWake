clr

filename = 'R:\SpecialCourseSafak\Figures\Climate\RI_COMBINED';
leg1Txt = '';
leg2Txt = '';
x1Txt = '';
y1Txt = 'Bulk RichardsonNumber';
x2Txt = '';
y2Txt = 'Bulk RichardsonNumber';
vlim = [-0.5 0.5];

uiopen('R:\SpecialCourseSafak\Figures\Climate\short_RI_reversed.fig',1)
f = gcf;
shortLim = f.Children(end).XLim;
close(f)
uiopen('R:\SpecialCourseSafak\Figures\Climate\long_RI_reversed.fig',1)
f = gcf;
longLim = f.Children(end).XLim;
close(f)
uiopen('R:\SpecialCourseSafak\Figures\Climate\TI.fig',1)


f = gcf;
TS_RI = f.Children.Children.YData;
TS_TI = f.Children.Children.YData;
time = f.Children.Children.XData;
shortInd = time>shortLim(1) & time<shortLim(2);
longInd = time>longLim(1) & time<longLim(2);
scatter(sp1,TS_RI(shortInd),TS_TI(shortInd))
scatter(sp2,TS_RI(longInd),TS_TI(longInd))


fig = figure;
fig.Position = [522 257 628 536];
sp1 = subplot(1,2,1);
copyobj(flipud(f.Children.Children),sp1)
xlim(sp1,shortLim)
datetick(sp1,'x','dd/mm/yy-HH','keeplimits')
ylim(vlim)
ylabel(y1Txt)
grid on
if ~isempty(leg1Txt)
legend(leg1Txt)
end
sp2 = subplot(1,2,2);
copyobj(flipud(f.Children.Children),sp2)
xlim(longLim)
ylim(vlim)
datetick(sp2,'x','dd/mm/yy-HH','keeplimits')
if ~isempty(leg2Txt)
legend(leg2Txt)
end
xlabel(x2Txt)
ylabel(y2Txt)
grid on

saveas(fig,filename,'fig')
saveas(fig,filename,'epsc')
saveas(fig,filename,'jpeg')