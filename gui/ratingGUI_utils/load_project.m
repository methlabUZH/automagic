function handles = load_project(handles)
%load_project Set the gui components according to this project's properties
%   handles       structure with handles of the gui

set_color_scale(handles);
handles = set_gui_subjects_list(handles);
cutoffs = handles.project.qualityCutoffs;
set_gui_rating(handles, cutoffs);
handles = update_next_and_previous_button(handles);

% Load and show the first image
[handles, data] = load_current(handles, true);
handles = show_current(data, false, handles);

clear data;