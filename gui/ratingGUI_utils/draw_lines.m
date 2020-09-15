function draw_lines(handles)
%draw_lines Draw all the channels that has been previously selected to be
%interpolated
%   handles  structure with handles of the gui

project = handles.project;
if(project.current == -1)
    return;
end
block = project.getCurrentBlock();
if strcmp(block.rate, handles.CGV.RATINGS.Interpolate)
    list = block.tobeInterpolated;
else
    list = [];
end

axe = handles.axes;
axes(axe);
for chan = 1:length(list)
    draw_line(list(chan), project.maxX, handles, 'b', axe);
end
set(handles.channellistbox,'String',list)