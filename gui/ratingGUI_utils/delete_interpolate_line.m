function delete_interpolate_line(source, event, p, y, handles)
%delete_interpolate_line Delete the line selected by y and remove it from 
%the interpolation list 
%   handles  structure with handles of the gui
%   y        the y-coordinate of the line to be deleted (number of the channel)
%   p        the plot handler of the line (this is the plot seperated from the main plot)
%   event    the event object

if( ~ handles.selection_mode )
    return;
end
axes(handles.axes);
delete(p);
block = handles.project.getCurrentBlock();
list = block.tobeInterpolated;
list = list(list ~= y);
block.setRatingInfoAndUpdate(...
    struct('rate', handles.CGV.RATINGS.Interpolate, ...
           'tobeInterpolated', list));
set(handles.channellistbox,'String',list)