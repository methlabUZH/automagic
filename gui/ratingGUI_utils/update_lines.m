function update_lines(handles)
%update_lines Redraw all lines
% handles  structure with handles of the gui
lines = findall(handles.axes,'Type','Line');
for i = 1:length(lines)
   delete(lines(i)); 
end

draw_lines(handles);
mark_interpolated_chans(handles);