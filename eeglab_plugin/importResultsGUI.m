function varargout = importResultsGUI(varargin)
% IMPORTRESULTSGUI MATLAB code for importResultsGUI.fig
%      IMPORTRESULTSGUI, by itself, creates a new IMPORTRESULTSGUI or raises the existing
%      singleton*.
%
%      H = IMPORTRESULTSGUI returns the handle to a new IMPORTRESULTSGUI or the handle to
%      the existing singleton*.
%
%      IMPORTRESULTSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMPORTRESULTSGUI.M with the given input arguments.
%
%      IMPORTRESULTSGUI('Property','Value',...) creates a new IMPORTRESULTSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before importResultsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to importResultsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help importResultsGUI

% Last Modified by GUIDE v2.5 30-Oct-2018 12:57:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @importResultsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @importResultsGUI_OutputFcn, ...
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


% --- Executes just before importResultsGUI is made visible.
function importResultsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to importResultsGUI (see VARARGIN)

% Choose default command line output for importResultsGUI
handles.output = hObject;

if( nargin - 3 ~= 1 )
    error('wrong number of arguments. An ImportParams must be given as argument.')
end

params = varargin{1};
assert(isa(params, 'ImportParams'));
handles.params = params;

handles.CGV = ConstantGlobalValues();
% Set the title to the current version
handles = load_state(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes importResultsGUI wait for user response (see UIRESUME)
% uiwait(handles.importResultsGUI);

function handles = load_state(handles)
% handles       main handles of this gui

if exist(handles.CGV.stateFile.ADDRESS, 'file')
    load(handles.CGV.stateFile.ADDRESS);
    if( isfield(state, 'version') && strcmp(state.version, handles.CGV.VERSION))
        handles.projectList = state.project_list;
        handles.currentProject = state.current_project;
    else % initialise everything if versioning doesn't correspond
        handles.projectList = containers.Map;
        handles.projectList(handles.CGV.NEW_PROJECT.LIST_NAME) = [];
        handles.projectList(handles.CGV.LOAD_PROJECT.LIST_NAME) = [];
        handles.currentProject = 1;
    end
else % initialise everything if main state file does not exist
    handles.projectList = containers.Map;
    handles.projectList(handles.CGV.NEW_PROJECT.LIST_NAME) = [];
    handles.projectList(handles.CGV.LOAD_PROJECT.LIST_NAME) = [];
    handles.currentProject = 1;
end

% For each existing project, update them from their state file.
% (Synchronisation)
k = handles.projectList.keys;
v = handles.projectList.values;
nameList = k(2:end);
for i = 1:handles.projectList.Count
    if( ~ strcmp(k(i), handles.CGV.NEW_PROJECT.LIST_NAME) && ...
            ~ strcmp(k(i), handles.CGV.LOAD_PROJECT.LIST_NAME) )
        name = k{i};
        nameList{i-1} = name;
        old_project = v{i};
        if( exist(old_project.stateAddress, 'file') )
            load(old_project.stateAddress);
            handles.projectList(name) = self;
        end
    end
end

set(handles.popupmenu1, 'String', nameList, ...
                        'Value', max(handles.currentProject - 1, 1));

% Update and load project
handles = update_and_load(handles);


% --- First update if any change has happenend since last time and then
% load the project to the gui
function handles = update_and_load(handles)
% handles       main handles of this gui

% Change the cursor to a watch while updating...
set(handles.importResultsGUI, 'pointer', 'watch')
drawnow;

% Update the project
handles = update_selected_project(handles);

% Load the project
handles = load_selected_project(handles);

% Change back the cursor to an arrow
set(handles.importResultsGUI, 'pointer', 'arrow')


% --- Check if data structures are changed since last time and updates the
% structure accordingly
function handles = update_selected_project(handles)
% handles           main handle of this gui

% Find the selected project
idx = get(handles.popupmenu1, 'Value');
names = handles.projectList.keys;
names(1) = []; % remove the Create New Project
name = names{idx};

% First update the project from the file (Synchronization with other users)
% (This is redundant if the gui is just started.)
project = handles.projectList(name);
if isempty(project) || ~exist(project.stateAddress, 'file')
    return;
else
    load(project.stateAddress);
    handles.projectList(name) = self;
    project = self;
end

% Then update the rating structure of the project
if( exist( project.resultFolder, 'dir'))
    if(project.areFoldersChanged())
        
        % Change the cursor to a watch while updating...
        set(handles.importResultsGUI, 'pointer', 'watch')
        drawnow;
        
        % Update the structure and save results in file
        project.updateRatingStructures();
        
        % Change back the cursor to an arrow
        set(handles.importResultsGUI, 'pointer', 'arrow')
    end
else
    popup_msg('The project folder does not exists or is not reachable.'...
        , 'Error');
end

% --- Loads the current project selected by gui and set the gui accordingly
function handles = load_selected_project(handles)
% handles           main handles of this gui

% Find the selected project
Index = get(handles.popupmenu1, 'Value');
names = handles.projectList.keys;
names(1) = []; % remove the Create New Project
currentIndex = max(handles.currentProject - 1, 1);
name = names{Index};

% Special case of New Project should not happen in the importResultsGUI
assert(~ strcmp(name, handles.CGV.NEW_PROJECT.LIST_NAME));

% Special case of Load Project
if(strcmp(name, handles.CGV.LOAD_PROJECT.LIST_NAME))
    [data_path, state_path] = loadGUI();
    splt = strsplit(state_path, '/');
    jne = strjoin(splt(1:end-1), '/');
    project_path = strcat(jne, '/');
    % If user cancelled the process, choose the previous project
    if( isempty(data_path) || isempty(state_path) )
        set(handles.popupmenu1,...
            'String', names,...
            'Value', currentIndex);
        return;
    end
    
    if exist(state_path, 'file') == 2
        load(state_path);
    end
    if(exist('self', 'var') && isdir(data_path))
        name = self.name;
        
        if( ~ isKey(handles.projectList, name))
            % After load addresses must be updated as this system may have
            % a diferent adsresses than the system where project has been
            % created.
            self.updateAddressesFormStateFile(project_path, data_path);
            handles.projectList(name) = self;
        else
            popup_msg(['This project already exists. You can not ',...
                'reload it unless it is deleted.'], 'Error');
        end
        
        % Set the gui to this project and load this project
        IndexC = strcmp(names, name);
        Index = find(IndexC == 1);
        set(handles.popupmenu1,...
            'String', names,...
            'Value', Index);
    else
        % The selected state file is not a correct state file. So
        % load the previously loaded project.
        set(handles.popupmenu1,...
            'String', names,...
            'Value', currentIndex);
        load_selected_project(handles);
        save_state(handles)
        return;
    end
end

% Load the project:
project = handles.projectList(name);

if ~ exist(project.stateAddress, 'file')
    if(  ~ exist(project.resultFolder, 'dir') )
        % This can happen when data is on a server and connecton is lost
        popup_msg(['The project folder is unreachable or deleted. ' ...
                        project.resultFolder], 'Error');
        set(handles.filelistbox, 'String', 'No access to the project'); 
        return;
    else
        % If the state_file is deleted, remove this project
        popup_msg(['The state_file does not exist anymore.',...
            'You must create a new project.'], 'Error');
        remove(handles.projectList, name);
        handles.currentProject = 1;
        set(handles.popupmenu1, 'String', names, ...
            'Value', handles.currentProject);
        update_and_load(handles);
        save_state(handles);
        return;
    end
end

handles.currentProject = find(contains(handles.projectList.keys, name));
set(handles.filelistbox, 'String', project.processedList); 
save_state(handles)


% --- Outputs from this function are returned to the command line.
function varargout = importResultsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% index_selected = get(handles.filelistbox,'Value');
% varargout{1} = index_selected;
% delete(handles.importResultsGUI);
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = update_and_load(handles);
% Update handles structure
guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in filelistbox.
function filelistbox_Callback(hObject, eventdata, handles)
% hObject    handle to filelistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: contents = cellstr(get(hObject,'String')) returns filelistbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filelistbox


% --- Executes during object creation, after setting all properties.
function filelistbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filelistbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okbutton.
function okbutton_Callback(hObject, eventdata, handles)
% hObject    handle to okbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
values = get(handles.filelistbox,'Value');
items = get(handles.filelistbox,'String');

idx = get(handles.popupmenu1, 'Value');
names = handles.projectList.keys;
names(1) = []; % remove the Create New Project
name = names{idx};
project = handles.projectList(name);

handles.params.selectedList = items(values);
handles.params.project = project;
close('importResultsGUI');

% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.params.selectedList = {};
close('importResultsGUI');


% --- Executes when user attempts to close importResultsGUI.
function importResultsGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to importResultsGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(get(hObject, 'waitstatus'), 'waiting')
    uiresume(hObject)
else
    delete(hObject);
end

% --- Save the gui state
function save_state(handles)
% handles       main handles of this gui

if(isa(handles, 'struct'))
    state.project_list = handles.projectList;
    state.current_project = handles.currentProject;
    state.version = handles.CGV.VERSION;
    
    if(~ exist(handles.CGV.stateFile.FOLDER, 'dir'))
        mkdir(handles.CGV.stateFile.FOLDER);
    end
    save(handles.CGV.stateFile.ADDRESS, 'state');
end
