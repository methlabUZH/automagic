function handles = update_gui_selected_subject(handles)
%update_gui_selected_subject Show the current ptoject as the selected one 
%in the menu
%   handles  structure with handles of the gui

project = handles.project;
if( project.current == -1)
    return;
end
unique_name = project.processedList{project.current};
IndexC = strfind(handles.subjectsmenu.String, unique_name);
Index = find(not(cellfun('isempty', IndexC)));
if(isempty(Index))
    Index = 1;
end
set(handles.subjectsmenu,'Value',Index);