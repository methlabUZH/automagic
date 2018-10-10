function handles = draw_line(y, maxX, handles, color, axe)
%draw_line Draw a horizontal line on the channel selected by y to mark it on the
%plot
%   handles  structure with handles of the gui
%   y        the y-coordinate of the selected point to be drawn
%   maxX     the maximum x-coordinate until which the line must be drawn in
%          the x-axis
%   color    color of the line

hold on;
p1 = [0, maxX];
p2 = [y, y];
p = plot(axe, p1, p2, color ,'LineWidth', 3);
set(p, 'ButtonDownFcn', {@delete_interpolate_line, p, y, handles})
hold off;