function output_txt = ts_cursor(obj,event_obj)
pos = get(event_obj,'Position');
output_txt = {['Date: ',datestr(pos(1),'yyyy-mm-dd HH:MM')],...
    ['Y: ',num2str(pos(2),4)]};

% If there is a Z-coordinate in the position, display it as well
if length(pos) > 2
    output_txt{end+1} = ['Z: ',num2str(pos(3),4)];
end
