a = gca;
plot(a,(a.Children.XData),a.Children.ZData');
a.XAxis.TickLabels = datestr(a.XAxis.TickValues,'dd/mm HH:MM');
a.XAxis.TickLabelRotation = 45;
xlabel(a,'Date')
ylabel(a,'Wind Direction [\circ]')
grid on