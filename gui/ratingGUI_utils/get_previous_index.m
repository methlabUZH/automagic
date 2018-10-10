function previous = get_previous_index(handles)
%get_prevous_index Get the index of the previous file if any.
%   There are five different lists corresponding to different ratings. The
%   first possible block from each list is first chosen, and finally the one
%   which follows all others in the main list is chosen. For more info 
%   please read the docs.
%   handles  structure with handles of the gui

% Get the current project and file
project = handles.project;
block =  project.getCurrentBlock();
uniqueName = block.uniqueName;

% Check which ratings are filtered and which are not
good_bool = get(handles.goodcheckbox,'Value');
ok_bool = get(handles.okcheckbox,'Value');
bad_bool = get(handles.badcheckbox,'Value');
interpolate_bool = get(handles.interpolatecheckbox,'Value');
notrated_bool = get(handles.notratedcheckbox,'Value');

if( ~ is_filtered(handles, uniqueName ))
    previous_idx = project.current;
else
    previous_idx = -1;
end

previous = project.getPreviousIndex(previous_idx, good_bool, ...
                ok_bool, bad_bool, interpolate_bool, notrated_bool);
end