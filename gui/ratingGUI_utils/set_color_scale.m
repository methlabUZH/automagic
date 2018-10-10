function set_color_scale(handles)
%set_color_scale Set components related to color scale
%   handles       structure with handles of the gui

scale = handles.project.colorScale;
set(handles.scaletext, 'String', ...
    ['[ -', num2str(scale), ' ' , num2str(scale),']']);
set(handles.colorscale, 'Value', scale);