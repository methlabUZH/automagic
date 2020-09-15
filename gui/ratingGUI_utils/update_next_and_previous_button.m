function handles = update_next_and_previous_button(handles)
%update_next_and_previous_button Activate or deactivate the next and
%previous button
%   If there is no previous, desactivate the previous button, if there 
%   is no next, desactivate the next button. And vice versa in order to 
%   reset the action.
%   handles  structure with handles of the gui

if( handles.project.current == -1)
    set(handles.nextbutton,'Enable', 'off');
    set(handles.previousbutton,'Enable', 'off');
    return;
end
project = handles.project;
if( project.current == get_next_index(handles))
    set(handles.nextbutton,'Enable', 'off');
end

if( project.current ~= get_previous_index(handles))
    set(handles.previousbutton,'Enable', 'on');
end

if( project.current == get_previous_index(handles))
    set(handles.previousbutton,'Enable', 'off');
end

if( project.current ~= get_next_index(handles))
    set(handles.nextbutton,'Enable', 'on');
end