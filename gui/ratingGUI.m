function varargout = ratingGUI(varargin)
% RATINGGUI MATLAB code for ratingGUI.fig
%      RATINGGUI is called by the mainGUI. A user must not call this gui 
%      directly. Howerver, for test reasons, one can call RATINGGUI if an 
%      instance of the class Project is given as argument.
%
% Copyright (C) 2017  Amirreza Bahreini, methlabuzh@gmail.com
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Last Modified by GUIDE v2.5 20-Mar-2021 11:39:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ratingGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ratingGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ratingGUI is made visible.
function ratingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ratingGUI (see VARARGIN)

% Change the cursor to a watch while updating...
set(handles.ratingGUI, 'pointer', 'watch')
drawnow;

if ~ exist('update_lines', 'file')
    addpath('ratingGUI_utils/');
end
if( nargin - 4 ~= 1 )
    error('wrong number of arguments. Project must be given as argument.')
end

project = varargin{1};
CGV = varargin{2};
assert(isa(project, 'Project'));
assert(isa(CGV, 'ConstantGlobalValues'));
handles.project = project;
handles.CGV = CGV;

%set(handles.ratingGUI, 'units', 'normalized', 'position', [0.05 0.3 0.8 0.8])

% Set the title to the current version
set(handles.ratingGUI, 'Name', ['Automagic v.', handles.CGV.VERSION, ...
                                 ' Manual Rating']);

% set checkboxes to be all selected on startup
set(handles.interpolatecheckbox,'Value', 1)
set(handles.badcheckbox,'Value', 1)
set(handles.okcheckbox,'Value', 1)
set(handles.goodcheckbox,'Value', 1)
set(handles.notratedcheckbox,'Value', 1)

% Allows to select channels for interpolation if it's set to true.
handles.selection_mode = false;

handles = load_project(handles);

% Set keyboard shortcuts for rating
handles = set_shortcuts(handles);

% Choose default command line output for ratingGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Change back the cursor to an arrow
set(handles.ratingGUI, 'pointer', 'arrow')
% UIWAIT makes ratingGUI wait for user response (see UIRESUME)
% uiwait(handles.ratingGUI);


% --- Outputs from this function are returned to the command line.
function varargout = ratingGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Switch the gui to enable or disable
function switch_gui(mode, handles)
% handles  structure with handles of the gui
% mode     string that can be 'off' or 'on'

set(handles.nextbutton,'Enable', mode)
set(handles.previousbutton,'Enable', mode)
set(handles.interpolaterate,'Enable', mode)
set(handles.okrate,'Enable', mode)
set(handles.badrate,'Enable', mode)
set(handles.goodrate,'Enable', mode)
set(handles.notrate,'Enable', mode)
set(handles.goodcheckbox,'Enable', mode)
set(handles.okcheckbox,'Enable', mode)
set(handles.badcheckbox,'Enable', mode)
set(handles.interpolatecheckbox,'Enable', mode)
set(handles.notratedcheckbox,'Enable', mode)

% --- Executes on button press in turnonbutton. Turn on the selection_mode
function turnonbutton_Callback(hObject, eventdata, handles)
% hObject    handle to turnonbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
project = handles.project;
if( project.current == -1)
    return;
end

handles = turn_on_selection(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in turnoffbutton. Turn off the
% selection_mode
function turnoffbutton_Callback(hObject, eventdata, handles)
% hObject    handle to turnoffbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
project = handles.project;
if( project.current == -1)
    return;
end

handles = turn_off_selection(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in goodcheckbox. If the checkbox is
% unchecked, the blocks with this rating are filtered and can not be shown.
% It processes as explaind below:
% If the filter is turned on and the current block has the same rating , it 
% should be changed to the next not-filtered block. If there is no next
% possible block, a previous not-filtered block is chosen. 
%
% If no image was possible to be shown because of the filterings, and if this
% filtering is finally removed, choose the first possible block to be shown
function goodcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to goodcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
project = handles.project;

next_idx = handles.project.current;
val = get(handles.goodcheckbox, 'Value');
block = project.getCurrentBlock();

% If it's to be filtered and current must be changed
if( ~ val && block.isGood() )
    next_idx = get_next_index(handles);
    if(next_idx == -1)
        next_idx = get_previous_index(handles);
    end
end

% When nothing is shown and filter is off
if((val && is_filtered(handles, project.current)))
    next_idx = get_next_index(handles);
    if(next_idx == -1)
        next_idx = get_previous_index(handles);
    end
end

handles.project.current = next_idx;
handles = load_project(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in okcheckbox. If the checkbox is
% unchecked, the blocks with this rating are filtered and can not be shown.
% It processes as explaind below:
% If the filter is turned on and the current block has the same rating , it 
% should be changed to the next not-filtered block. If there is no next
% possible block, a previous not-filtered block is chosen. 
%
% If no image was possible to be shown because of the filterings, and if this
% filtering is finally removed, choose the first possible block to be shown
function okcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to okcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
project = handles.project;
next_idx = handles.project.current;
val = get(handles.okcheckbox, 'Value');
block = project.getCurrentBlock();
if( ~ val && block.isOk() )
    next_idx = get_next_index(handles);
    if(next_idx == -1)
        next_idx = get_previous_index(handles);
    end
end

% When nothing is shown and filter is off
if((val && is_filtered(handles, project.current)))
    next_idx = get_next_index(handles);
    if(next_idx == -1)
        next_idx = get_previous_index(handles);
    end
end
handles.project.current = next_idx;
handles = load_project(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in badcheckbox. If the checkbox is
% unchecked, the blocks with this rating are filtered and can not be shown.
% It processes as explaind below:
% If the filter is turned on and the current block has the same rating , it 
% should be changed to the next not-filtered block. If there is no next
% possible block, a previous not-filtered block is chosen. 
%
% If no image was possible to be shown because of the filterings, and if this
% filtering is finally removed, choose the first possible block to be shown
function badcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to badcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
project = handles.project;
next_idx = handles.project.current;
val = get(handles.badcheckbox, 'Value');
block = project.getCurrentBlock();
if( ~ val && block.isBad() )
    next_idx = get_next_index(handles);
    if(next_idx == -1)
        next_idx = get_previous_index(handles);
    end
end

% When nothing is shown and filter is off
if((val && is_filtered(handles, project.current)))
    next_idx = get_next_index(handles);
    if(next_idx == -1)
        next_idx = get_previous_index(handles);
    end
end
handles.project.current = next_idx;
handles = load_project(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in interpolatecheckbox. If the checkbox is
% unchecked, the blocks with this rating are filtered and can not be shown.
% It processes as explaind below:
% If the filter is turned on and the current block has the same rating , it 
% should be changed to the next not-filtered block. If there is no next
% possible block, a previous not-filtered block is chosen. 
%
% If no image was possible to be shown because of the filterings, and if this
% filtering is finally removed, choose the first possible block to be shown
function interpolatecheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to interpolatecheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
project = handles.project;
next_idx = handles.project.current;
val = get(handles.interpolatecheckbox, 'Value');
block = project.getCurrentBlock();
if( ~ val && block.isInterpolate() )
    next_idx = get_next_index(handles);
    if(next_idx == -1)
        next_idx = get_previous_index(handles);
    end
end

% When nothing is shown and filter is off
if((val && is_filtered(handles, project.current)))
    next_idx = get_next_index(handles);
    if(next_idx == -1)
        next_idx = get_previous_index(handles);
    end
end
handles.project.current = next_idx;
handles = load_project(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in notratedcheckbox. If the checkbox is
% unchecked, the blocks with this rating are filtered and can not be shown.
% It processes as explaind below:
% If the filter is turned on and the current block has the same rating , it 
% should be changed to the next not-filtered block. If there is no next
% possible block, a previous not-filtered block is chosen. 
%
% If no image was possible to be shown because of the filterings, and if this
% filtering is finally removed, choose the first possible block to be shown
function notratedcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to notratedcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
project = handles.project;
next_idx = handles.project.current;
val = get(handles.notratedcheckbox, 'Value');
block = project.getCurrentBlock();
if( ~ val && block.isNotRated() )
    next_idx = get_next_index(handles);
    if(next_idx == -1)
        next_idx = get_previous_index(handles);
    end
end

% When nothing is shown and filter is off
if((val && is_filtered(handles, project.current)))
    next_idx = get_next_index(handles);
    if(next_idx == -1)
        next_idx = get_previous_index(handles);
    end
end
handles.project.current = next_idx;
handles = load_project(handles);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in previousbutton.
function previousbutton_Callback(hObject, eventdata, handles)
% hObject    handle to previousbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Change the cursor to a watch while updating...
set(handles.ratingGUI, 'pointer', 'watch')
drawnow;

handles = previous(handles);

% Update handles structure
guidata(hObject, handles);

% Change back the cursor to an arrow
set(handles.ratingGUI, 'pointer', 'arrow')

% --- Executes on button press in nextbutton.
function nextbutton_Callback(hObject, eventdata, handles)
% hObject    handle to nextbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Change the cursor to a watch while updating...
set(handles.ratingGUI, 'pointer', 'watch')
drawnow;

handles = next(handles);

% Update handles structure
guidata(hObject, handles);

% Change back the cursor to an arrow
set(handles.ratingGUI, 'pointer', 'arrow')

% --- Executes when selected object is changed in rategroup.
function rategroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in rategroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = change_rating(handles);

% Update handles structure
guidata(hObject, handles);

% --- updates the rating based on gui input
function handles = change_rating(handles)
% handles  structure with handles of the gui

project = handles.project;
if(project.current == -1)
    return;
end
handles = get_rating_from_gui(handles);
block = project.getCurrentBlock();
update_lines(handles)
if( block.isInterpolate() )
   handles = turn_on_selection(handles);
end

% --- Executes on selection change in channellistbox. If a channel from the
% channel list is chosen, it will be drawn with 'red' color. Just a visual
% effect.
function channellistbox_Callback(hObject, eventdata, handles)
% hObject    handle to channellistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if( handles.project.current == -1)
    return;
end
project = handles.project;
index_selected = get(handles.channellistbox,'Value');

if( isempty(index_selected))
    return;
end

channels = cellstr(get(handles.channellistbox,'String'));
channel = channels{index_selected};
channel = str2num(channel);

update_lines(handles);
lines = findall(gcf,'Type','Line');
for i = 1:length(lines)
   if (lines(i).YData(1) == channel)
       break;
   end
end
delete(lines(i));
axe = handles.axes;
axes(axe);
draw_line(channel, project.maxX, handles, 'r', axe)


% --- Executes on selection change in subjectsmenu. It selects the block
% chosen by the user in the subjects menu list
function subjectsmenu_Callback(hObject, eventdata, handles)
% hObject    handle to subjectsmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Determine the selected data set.

% Change the cursor to a watch while updating...
set(handles.ratingGUI, 'pointer', 'watch')
drawnow;

project = handles.project;
list = get(hObject, 'String');
idx = get(hObject,'Value');
unique_name = list{idx};
IndexC = strfind(project.processedList, unique_name);
Index = find(not(cellfun('isempty', IndexC)));
if( isempty(Index) )
    Index = -1;
end
project.current = Index;
handles.project = project;
handles = load_project(handles);

% Update handles structure
guidata(hObject, handles);

% Change back the cursor to an arrow
set(handles.ratingGUI, 'pointer', 'arrow')

% --- Show the next file in the list
function handles = next(handles)
% handles  structure with handles of the gui

handles.project.current = get_next_index(handles);
handles = load_project(handles);

% --- Show the previous file in the list
function handles = previous(handles)
% handles  structure with handles of the gui

handles.project.current = get_previous_index(handles);
handles = load_project(handles);


% --- Get the selected rating from the gui for this current file. It does
% not save the result in the corresponsing file yet, but it does rename the
% result file immediately.
function handles = get_rating_from_gui(handles)
% handles  structure with handles of the gui

project = handles.project;
if ( ~ isa(handles,'struct') || project.current == -1)
    return
end

if( isempty(handles.rategroup.SelectedObject))
    return;
end
block = project.getCurrentBlock();
new_rate = handles.rategroup.SelectedObject.String;
if block.commitedNb > 0 && ...
        isequaln(project.committedQualityCutoffs, project.qualityCutoffs) &&...
        ~ strcmp(new_rate, block.rate)
    popup_msg('This file is already committed. You can not rewrite this','Error');
    switch block.rate
        case 'Good'
            set(handles.rategroup,'selectedobject',handles.goodrate)
        case 'OK'
            set(handles.rategroup,'selectedobject',handles.okrate)
        case 'Bad'
            set(handles.rategroup,'selectedobject',handles.badrate)
        case 'Interpolate'
            set(handles.rategroup,'selectedobject',handles.interpolaterate)
        case 'Not Rated'
            set(handles.rategroup,'selectedobject',handles.notrate)
    end
    return;
end
block.setRatingInfoAndUpdate(struct('rate', new_rate, 'isManuallyRated', 1));

% --- Turn on the selection mode to choose channels that should be
% interpolated
function handles = turn_on_selection(handles)
% handles  structure with handles of the gui
set(handles.turnoffbutton,'Enable', 'on')
set(handles.turnonbutton,'Enable', 'off')
handles.selection_mode = true;

% To update both oncall functions with new handles where the selection is
% changed
im = findobj(allchild(0), 'Tag', 'im');
set(im, 'ButtonDownFcn', {@on_selection, handles})
update_lines(handles) % This is important, otherwise handles.selection_mode 
                      % is not correctly updated

set(gcf,'Pointer','crosshair');
switch_gui('off', handles);

% --- Turn of the slesction mode of channels
function handles = turn_off_selection(handles)
% handles  structure with handles of the gui
set(handles.turnoffbutton,'Enable', 'off')
set(handles.turnonbutton,'Enable', 'on')
handles.selection_mode = false;

% To update both oncall functions with new handles where the selection is
% changed
im = findobj(allchild(0), 'Tag', 'im');
set(im, 'ButtonDownFcn', {@on_selection, handles})
update_lines(handles) % This is important, otherwise handles.selection_mode 
                      % is not correctly updated

set(gcf,'Pointer','arrow');
switch_gui('on', handles);

% --- Save the state of the project
function handles = save_state(handles)
% handles  structure with handles of the gui

if ( ~ isa(handles,'struct') || handles.project.current == -1)
    return
end
        
% Save the stateS
if(isa(handles.project, 'Project'))
    handles.project.saveProject();
end

% --- Executes when user attempts to close ratingGUI.
function ratingGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to ratingGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Change the cursor to a watch while updating...
set(handles.ratingGUI, 'pointer', 'watch')
drawnow;

save_state(handles);

if(isa(handles.project, 'EEGLabProject'))
    delete(hObject);
    return;
end


h = findobj(allchild(0), 'flat', 'Tag', 'qualityrating');
if ~ isempty(h)
    close(h.Name);
end

% Update the main gui's data after rating processing
h = findobj(allchild(0), 'flat', 'Tag', 'mainGUI');
if( isempty(h))
    h = mainGUI;
end
handle = guidata(h);
handle.projectList(handles.project.name) = handles.project;
guidata(handle.mainGUI, handle);
mainGUI();

% Change back the cursor to an arrow
set(handles.ratingGUI, 'pointer', 'arrow')

% Hint: delete(hObject) closes the figure
delete(hObject);

function handles = set_shortcuts(handles)
h = findobj(allchild(0), 'flat', 'Tag', 'ratingGUI');
set(h, 'KeyPressFcn', {@keyPress,handles})

function handles = keyPress(src, e, handles)
set(handles.turnonbutton,'Enable', 'off')
set(handles.turnoffbutton,'Enable', 'off')
shortcuts = handles.CGV.KEYBOARD_SHORTCUTS;

    switch e.Key
        case {shortcuts.GOOD}
            set(handles.rategroup,'selectedobject',handles.goodrate)
            handles = change_rating(handles);
        case {shortcuts.OK}
            set(handles.rategroup,'selectedobject',handles.okrate)
            handles = change_rating(handles);
        case {shortcuts.BAD}
            set(handles.rategroup,'selectedobject',handles.badrate)
            handles = change_rating(handles);
        case {shortcuts.INTERPOLATE}
            set(handles.rategroup,'selectedobject',handles.interpolaterate)
            set(handles.turnonbutton,'Enable', 'on')
            set(handles.turnoffbutton,'Enable', 'on')
            handles = change_rating(handles);
        case {shortcuts.NOTRATED}
            set(handles.rategroup,'selectedobject',handles.notrate)
            handles = change_rating(handles);
        case {shortcuts.NEXT}
            handles = next(handles);
        case {shortcuts.PREVIOUS}
            handles = previous(handles);
    end

% --- Executes during object creation, after setting all properties.
function subjectsmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to subjectsmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function channellistbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channellistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function colorscale_Callback(hObject, eventdata, handles)
% hObject    handle to colorscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_value = int16(get(hObject,'Value'));
set(handles.scaletext, 'String', ['[ -',num2str(new_value), ' ' , num2str(new_value),'] microVolts ']);
handles.project.colorScale = new_value;
handles = load_project(handles);
% Update handles structure
guidata(hObject, handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function colorscale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on key press with focus on goodcheckbox and none of its controls.
function goodcheckbox_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to goodcheckbox (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in eegplotpush.
function eegplotpush_Callback(hObject, eventdata, handles)
% hObject    handle to eegplotpush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addEEGLab();

% Plot
[~, data] = load_current(handles, false);
if(~ isempty(data))
    eegplot(data.data, 'srate', data.srate, 'eloc_file', data.chanlocs,...
        'dispchans', 55,'spacing', 50,'events', data.event,'winlength', 20);
end

% --- Executes on button press in averagereftoggle.
function averagereftoggle_Callback(hObject, eventdata, handles)
% hObject    handle to averagereftoggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(get(hObject,'Value'))
    [~, data] = load_current(handles, true);
    show_current(data, true, handles);
    set(hObject, 'String', sprintf('Average Referencing: On'))
else
    [~, data] = load_current(handles, true);
    show_current(data, false, handles);
    set(hObject, 'String', sprintf('Average Referencing: Off'))
end
clear data;


% --- Executes on button press in detectedpushbutton.
function detectedpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to detectedpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

block = handles.project.getCurrentBlock();
if block.commitedNb > 0 && ...
        isequaln(project.committedQualityCutoffs, project.qualityCutoffs)
    popup_msg('This file is already committed. You can not rewrite this','Error');
    switch block.rate
        case 'Good'
            set(handles.rategroup,'selectedobject',handles.goodrate)
        case 'OK'
            set(handles.rategroup,'selectedobject',handles.okrate)
        case 'Bad'
            set(handles.rategroup,'selectedobject',handles.badrate)
        case 'Interpolate'
            set(handles.rategroup,'selectedobject',handles.interpolaterate)
        case 'Not Rated'
            set(handles.rategroup,'selectedobject',handles.notrate)
    end
    return;
end

interpolated = block.finalBadChans;
tobeInterpolated = block.tobeInterpolated;
autos = block.autoBadChans;
autos = setdiff(autos, interpolated);
tobeInterpolated = union(tobeInterpolated, autos);
block.setRatingInfoAndUpdate(struct('tobeInterpolated', tobeInterpolated'));
% Update handles structure
guidata(hObject, handles);

draw_lines(handles)

cutoffs = handles.project.qualityCutoffs;
set_gui_rating(handles, cutoffs);


% --- Executes on button press in qualitybutton.
function qualitybutton_Callback(hObject, eventdata, handles)
% hObject    handle to qualitybutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% warninig - not all files interpolated yet
interpolate_count = handles.project.toBeInterpolatedCount();
if interpolate_count > 0
    question = 'There are still some files to be interpolated. Are you sure you want to proceed to rate the aready interpolated files?';
    handle = findobj(allchild(0), 'flat', 'Tag', 'ratingGUI');
    set(handle, 'units', 'pixels')
    main_pos = get(handle,'position');
    set(handle, 'units', 'normalized')
    screen_size = get( groot, 'Screensize' );
    choice = MFquestdlg([main_pos(3)/1.5/screen_size(3) main_pos(4)/1.5/screen_size(4)], question, ...
        'There are still some files to be interpolated',...
        'Continue', 'Cancel','Cancel');

    switch choice
        case 'Continue'
        case 'Cancel'
            return;
        otherwise
            return;
    end
end
qualityratingGUI(handles.project, handles.CGV);


% --- Executes on button press in rawpushbutton.
function rawpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to rawpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get current axes position in pixels
set(handles.axes,'units','pixel');
current_pos = get(handles.axes,'position');
set(handles.axes,'units','normalized');

block = handles.project.getCurrentBlock();
file_add = strcat(block.imageAddress, '_orig.jpg');
eeg_filtered = imread(file_add);

figure('units','pixel', 'pos', get(gca, 'pos').* [1, 1, 0, 0] + current_pos .* [0, 0, 1, 1]);
image(eeg_filtered)
ax = gca;

outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1);
bottom = outerpos(2);
ax_width = outerpos(3) - ti(3);
ax_height = outerpos(4) - ti(4);
ax.Position = [left bottom ax_width ax_height];

set(ax,'xtick',[])
set(ax,'xticklabel',[])
set(ax,'ytick',[])
set(ax,'yticklabel',[])
% set(gca, 'units','pixel', 'PlotBoxAspectRatio', current_pbac, ...
%     'pos', get(gca, 'pos').* [1, 1, 0, 0] + current_pos .* [0, 0, 1, 1]);


% --- Executes during object creation, after setting all properties.
function qualityscoretext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to qualityscoretext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in helpratingpushbutton.
function helpratingpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to helpratingpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('https://github.com/methlabUZH/automagic/wiki/Quality-Assessment-and-Rating#quality-assessment', '-browser');


% --- Executes on button press in ThresholdEffects.
function ThresholdEffects_Callback(hObject, eventdata, handles)
% hObject    handle to ThresholdEffects (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[~, data] = load_current(handles, true);

%% Parse and check parameters
CGV = ConstantGlobalValues();
defVis = CGV.DefaultVisualisationParams;
defaults = defVis.CalcQualityParams;
p = inputParser;
addParameter(p,'overallThresh', defaults.overallThresh,@isnumeric );
addParameter(p,'timeThresh', defaults.timeThresh,@isnumeric );
addParameter(p,'chanThresh', defaults.chanThresh,@isnumeric );
addParameter(p,'avRef', defaults.avRef,@isnumeric );
addParameter(p,'checkboxCutoff_CHV', defaults.avRef,@isnumeric );
addParameter(p,'Cutoff_CHV', defaults.avRef,@isnumeric );
addParameter(p,'RejRatio_CHV', defaults.avRef,@isnumeric );
thresholds = handles.project.qualityThresholds;
parse(p, thresholds);
settings = p.Results;
if nargin < 1
    disp('No data to rate')
elseif nargin < 2
    disp('No bad channel information...')
end
% Data preparation
X = data.data;
% Get dimensions of data
t = size(X,2);
c = size(X,1);
% average reference
if settings.avRef 
X = X - repmat(nanmean(X,1),c,1);
end
qualityScoreIdx = handles.project.qualityScoreIdx;
% overall timepoints of high amplitude
OHA_Blue = abs(X) > settings.overallThresh(qualityScoreIdx.OHA);
% timepoints of high variance
THV_Red = bsxfun(@gt, std(X,[],1)', settings.timeThresh(qualityScoreIdx.THV));
% channels above threshold...
CHV_Green = nanstd(X,[],2) > settings.chanThresh(qualityScoreIdx.CHV);

figure;
emptyDataImage = nan(c,t);
emptyDataImage(:,find(THV_Red==1))=1;
emptyDataImage(find(CHV_Green==1),:)=2;
emptyDataImage(find(OHA_Blue==1))=3;
c = [ 1 0 0;0 1 0; 0 0 1]; % [ red, green, blue]
colormap(c)
nanimage(emptyDataImage)
title('Effect of applied quality thresholds');
xlabel('Time Points');
ylabel('Channel Indices');
clear data;


% --- Executes on button press in showICpushbutton.
function showICpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to showICpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

project = handles.project;
block = project.getCurrentBlock();
if(isa(block, 'Block'))
    block.updateAddresses(project.dataFolder, project.resultFolder);
    % Change the cursor to a watch while updating...
    set(handles.ratingGUI, 'pointer', 'watch')
    drawnow;
    
    % load data
    load(block.resultAddress);


end
 
if ~isempty(EEG.icaact)
    viewICsGUI(handles, EEG)
else
    popup_msg('ICA not performed on this subject...',...
        'Error');
    % set cursor back to arrow
    set(handles.ratingGUI, 'pointer', 'arrow')
    return; 
end
% Change back the cursor to an arrow
set(handles.ratingGUI, 'pointer', 'arrow')
