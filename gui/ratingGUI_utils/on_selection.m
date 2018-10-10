function on_selection(~, event, handles)
%on_selection Event handler for the selection
%   handles  structure with handles of the gui
%   event    the event object

if( handles.selection_mode )
    y = event.IntersectionPoint(2);
    process_input(y, handles);
end