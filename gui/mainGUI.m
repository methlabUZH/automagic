function varargout = mainGUI(varargin)
% MAINGUI MATLAB code for mainGUI.fig
%      MAINGUI is the main function of Automagic that must be called in
%      order to start the application. All other functions and guis are 
%      called from within the MAINGUI.
%      
%      No argument is needed to start the application.
%
%      MAINGUI, by itself, creates a new MAINGUI or raises the existing
%      singleton*.
%
%      H = MAINGUI returns the handle to a new MAINGUI or the handle to
%      the existing singleton*.
%
%      MAINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINGUI.M with the given input arguments.
%
%      MAINGUI('Property','Value',...) creates a new MAINGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mainGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mainGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Copyright (C) 2017  Amirreza Bahreini, amirreza.bahreini@uzh.ch
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

% Last Modified by GUIDE v2.5 19-Sep-2018 15:59:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @mainGUI_OpeningFcn, ...
    'gui_OutputFcn',  @mainGUI_OutputFcn, ...
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


% --- Executes just before mainGUI is made visible.
function mainGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mainGUI (see VARARGIN)

% Choose default command line output for mainGUI
handles.output = hObject;

% set( findall( handles.mainGUI, '-property', 'Units' ), 'Units', 'Normalized' )
% set(handles.mainGUI, 'units', 'normalized', 'position', [0.05 0.5 0.9 0.82])
% children = handles.mainGUI.Children;
% for child_idx = 1:length(children)
%     child = children(child_idx);
%     set(child, 'units', 'normalized')
%     for grandchild_idx = 1:length(child.Children)
%        grandchild = child.Children(grandchild_idx);
%        set(grandchild, 'units', 'normalized')
%     end
% end

% Add project paths
% Checks 'project.m' as an example of a file in /src. Could be any other file
% in /src
if( ~exist('Subject.m', 'file')) 
    addpath('../src/');
    addpath('../preprocessing/');
end


% Set Constant Values
handles.CGV = ConstantGlobalValues;

% Set the title to the current version
set(handles.mainGUI, 'Name', ['Automagic v.', handles.CGV.VERSION]);

% Load the state and then the current project
handles = load_state(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mainGUI wait for user response (see UIRESUME)
% uiwait(handles.mainGUI);


% --- Outputs from this function are returned to the command line.
function varargout = mainGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Load the current state of the main gui from file and load the current
% project
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
for i = 1:handles.projectList.Count
    if( ~ strcmp(k(i), handles.CGV.NEW_PROJECT.LIST_NAME) && ...
            ~ strcmp(k(i), handles.CGV.LOAD_PROJECT.LIST_NAME) )
        name = k{i};
        old_project = v{i};
        if( exist(old_project.stateAddress, 'file') )
            load(old_project.stateAddress);
            handles.projectList(name) = self;
        end
    end
end

set(handles.existingpopupmenu,...
    'String',handles.projectList.keys, ...
    'Value', handles.currentProject);

% Update and load project
handles = update_and_load(handles);


% --- First update if any change has happenend since last time and then
% load the project to the gui
function handles = update_and_load(handles)
% handles       main handles of this gui

% Change the cursor to a watch while updating...
set(handles.mainGUI, 'pointer', 'watch')
drawnow;

% Update the project
handles = update_selected_project(handles);

% Load the project
handles = load_selected_project(handles);

% Change back the cursor to an arrow
set(handles.mainGUI, 'pointer', 'arrow')


% --- Check if data structures are changed since last time and updates the
% structure accordingly
function handles = update_selected_project(handles)
% handles           main handle of this gui

% Find the selected project
idx = get(handles.existingpopupmenu, 'Value');
names = handles.projectList.keys;
name = names{idx};

% First update the project from the file (Synchronization with other users)
% (This is redundant if the gui is just started.)
project = handles.projectList(name);
if isempty(project) || ~ exist(project.stateAddress, 'file')
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
        set(handles.mainGUI, 'pointer', 'watch')
        drawnow;
        
        % Update the structure and save results in file
        project.updateRatingStructures();
        
        % Change back the cursor to an arrow
        set(handles.mainGUI, 'pointer', 'arrow')
    end
else
    popup_msg('The project folder does not exists or is not reachable.'...
        , 'Error');
end

% --- Loads the current project selected by gui and set the gui accordingly
function handles = load_selected_project(handles)
% handles           main handles of this gui

% Find the selected project
Index = get(handles.existingpopupmenu, 'Value');
names = handles.projectList.keys;
name = names{Index};

% Special case of New Project
if(strcmp(name, handles.CGV.NEW_PROJECT.LIST_NAME))
    handles.VisualisationParams.CalcQualityParams = handles.CGV.DefaultVisualisationParams.CalcQualityParams;
    handles.VisualisationParams.dsRate = handles.CGV.DefaultVisualisationParams.dsRate;
    handles.params = make_default_params(handles.CGV.DefaultParams);
    set(handles.projectname, 'String', handles.CGV.NEW_PROJECT.NAME);
    set(handles.datafoldershow, 'String', handles.CGV.NEW_PROJECT.DATA_FOLDER);
    set(handles.projectfoldershow, 'String', handles.CGV.NEW_PROJECT.FOLDER);

    set(handles.subjectnumber, 'String', '')
    set(handles.filenumber, 'String', '')
    set(handles.preprocessednumber, 'String', '')
    set(handles.fpreprocessednumber, 'String', '')
    set(handles.ratednumber, 'String', '')
    set(handles.interpolatenumber, 'String', '')
    set(handles.excludecheckbox, 'Value', ...
        handles.params.ChannelReductionParams.performReduceChannels);
    set(handles.extedit, 'String', '')
    set(handles.srateedit, 'String', '')
    set(handles.checkbox1020, 'Value', 0)
    handles = setEEGSystem(handles.params, handles);
    handles.currentProject = Index;
    % Enable modifications
    switch_gui('on', 'off', handles);
    return;
end

% Special case of Load Project
if(strcmp(name, handles.CGV.LOAD_PROJECT.LIST_NAME))
    [data_path, state_path] = load_gui();
    splt = strsplit(state_path, '/');
    jne = strjoin(splt(1:end-1), '/');
    project_path = strcat(jne, '/');
    % If user cancelled the process, choose the previous project
    if( isempty(data_path) || isempty(state_path) )
        set(handles.existingpopupmenu,...
            'String',handles.projectList.keys,...
            'Value', handles.currentProject);
        load_selected_project(handles);
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
            self.UpdateAddressesFormStateFile(project_path, data_path);
            handles.projectList(name) = self;
        else
            popup_msg(['This project already exists. You can not ',...
                'reload it unless it is deleted.'], 'Error');
        end
        
        % Set the gui to this project and load this project
        IndexC = strcmp(handles.projectList.keys, name);
        Index = find(IndexC == 1);
        set(handles.existingpopupmenu,...
            'String',handles.projectList.keys,...
            'Value', Index);
    else
        % The selected state file is not a correct state file. So
        % load the previously loaded project.
        set(handles.existingpopupmenu,...
            'String',handles.projectList.keys,...
            'Value', handles.currentProject);
        load_selected_project(handles);
        return;
    end
end

% Load the project:
project = handles.projectList(name);
handles.params = project.params;
handles.VisualisationParams.dsRate = project.dsRate;
handles.VisualisationParams.CalcQualityParams = project.qualityThresholds;
% Set the current_project to the selected project
handles.currentProject = Index;
if ~ exist(project.stateAddress, 'file')
    if(  ~ exist(project.resultFolder, 'dir') )
        % This can happen when data is on a server and connecton is lost
        popup_msg(['The project folder is unreachable or deleted. ' ...
                        project.resultFolder], 'Error');
        
        set(handles.projectname, 'String', name);
        set(handles.datafoldershow, 'String', '');
        set(handles.projectfoldershow, 'String', '');
        set(handles.subjectnumber, 'String', '')
        set(handles.filenumber, 'String', '')
        set(handles.preprocessednumber, 'String', '')
        set(handles.fpreprocessednumber, 'String', '')
        set(handles.ratednumber, 'String', '')
        set(handles.interpolatenumber, 'String', '')
        set(handles.chanlocedit, 'String', '');
        set(handles.excludeedit, 'String', '');
        set(handles.checkbox1020, 'Value', 0)
        % Disable modifications from gui
        switch_gui('off', 'on', handles);
        return;
    else
        % If the state_file is deleted, remove this project
        popup_msg(['The state_file does not exist anymore.',...
            'You must create a new project.'], 'Error');
        remove(handles.projectList, name);
        handles.currentProject = 1;
        set(handles.existingpopupmenu,...
            'String',handles.projectList.keys,...
            'Value', handles.currentProject);
        update_and_load(handles);
        save_state(handles);
        return;
    end
end

% Set properties of the project:
set(handles.projectname, 'String', name);
set(handles.datafoldershow, 'String', project.dataFolder);
set(handles.projectfoldershow, 'String', project.resultFolder);
set(handles.subjectnumber, 'String', [num2str(project.nSubject) ' subjects...'])
set(handles.filenumber, 'String', [num2str(project.nBlock) ' files...'])
set(handles.preprocessednumber, 'String', ...
    [num2str(project.nProcessedSubjects), ' subjects already done'])
set(handles.fpreprocessednumber, 'String', ...
    [num2str(project.nProcessedFiles), ' files already done'])

% Set the file extension
set(handles.extedit, 'String', project.mask);

% Set the sampling rate. It won't be empty only for .txt extension
set(handles.srateedit, 'String', num2str(project.sRate))

% Set EEG system
handles = setEEGSystem(project.params, handles);

% Set 10-20 checkbox
set(handles.checkbox1020, 'Value', project.params.EEGSystem.sys10_20);


% Set number of rated files
rated_count = project.getRatedCount();
set(handles.ratednumber, 'String', ...
    [num2str(rated_count), ' files already rated'])

% Set number of files to be interpolated
interpolate_count = project.toBeInterpolatedCount();
set(handles.interpolatenumber, 'String', ...
    [num2str(interpolate_count), ' subjects to interpolate'])

% Set reduce channel checkbox
set(handles.excludecheckbox, 'Value', project.params.ChannelReductionParams.performReduceChannels);

% Disable modifications from gui
switch_gui('off', 'on', handles);

save_state(handles);

% --- Enable or Disable the modifiable gui elements
function switch_gui(mode, visibility ,handles)
% handles    main handles of the gui
% mode       string that can be either 'off' (to disable) or 'on' (to enable)
% visibility the visibility of the delete button. It can be either 'on' or
% 'off'. This is seperated as for different cases different functionality
% is needed.
set(handles.projectname, 'enable', mode);
set(handles.datafoldershow, 'enable', mode);
set(handles.projectfoldershow, 'enable', mode);
set(handles.extedit, 'enable', mode);
set(handles.choosedata, 'enable', mode);
set(handles.chooseproject, 'enable', mode);
set(handles.createbutton, 'visible', mode)
set(handles.deleteprojectbutton, 'visible', visibility)
set(handles.excludecheckbox, 'enable', mode);
setEEGSystemVisibility(mode, handles);
setSRateVisibility(mode, handles);

% --- Enable or Disable the EEG system related gui components. These are
% all closely together related. Basically the channel location, eog channel 
% list and file type edit boxes can not be activated if the EGI radio is 
% chosen. 
% This function is supposed to be called from the switch_gui function.
function setEEGSystemVisibility(mode, handles)
% handles    main handles of the gui
% mode       string that can be either 'off' (to disable) or 'on' (to enable)

set(handles.egiradio, 'enable', mode);
set(handles.othersysradio, 'enable', mode);
set(handles.checkbox1020, 'enable', mode);

if( strcmp(mode, 'off'))
    set(handles.chanlocedit, 'enable', mode);
    set(handles.excludeedit, 'enable', mode);
    set(handles.loctypeedit, 'enable', mode);
    set(handles.choosechannelloc, 'enable', mode);
    set(handles.newreferenceradio, 'enable', mode)
    set(handles.hasreferenceradio, 'enable', mode)
    set(handles.hasreferenceedit, 'enable', mode)
elseif(strcmp(mode, 'on'))
    if( ~ get(handles.egiradio, 'Value'))
        set(handles.chanlocedit, 'enable', mode);
        set(handles.excludeedit, 'enable', mode);
        set(handles.loctypeedit, 'enable', mode);
        set(handles.choosechannelloc, 'enable', mode);
        set(handles.newreferenceradio, 'enable', mode)
        set(handles.hasreferenceradio, 'enable', mode)
        set(handles.hasreferenceedit, 'enable', mode)
    end
end

% --- Enable or Disable the sampling rate based on the extension. If
% extension is 'txt' it can be enabled.
function setSRateVisibility(mode, handles)
% handles    main handles of the gui
% mode       string that can be either 'off' (to disable) or 'on' (to enable)
if( strcmp(mode, 'off'))
    set(handles.srateedit, 'enable', mode);
elseif(strcmp(mode, 'on'))
    if( any(strcmp(get(handles.extedit, 'Value'), {handles.CGV.EXTENSIONS.text})))
        set(handles.srateedit, 'enable', mode);
    else
        set(handles.srateedit, 'enable', 'off');
    end
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


% --- Count the number of subjects and files in the folder given by
% argument
function [nSubject, nBlock] = get_subject_and_file_numbers( ...
    handles, folder, ext)
% handles   the main handles of this gui
% folder    the folder to look into
% ext       determines the extension of files

% Change the cursor to a watch while updating...
set(handles.mainGUI, 'pointer', 'watch')
drawnow;

if(isunix)
    slash = '/';
elseif(ispc)
    slash = '\';
end

subjects = list_subjects(folder);
nSubject = length(subjects);
nBlock = 0;
if ~ isempty(ext)
    for i = 1:nSubject
        subject = subjects{i};
        raw_files = dir([folder subject slash '*' ext]);
        idx = ~startsWith({raw_files.name}, '.');
        raw_files = raw_files(idx);
        nBlock = nBlock + length(raw_files);
    end
end
% Change the cursor to normal
set(handles.mainGUI, 'pointer', 'arrow')

% --- return the list of subjects in the folder
function subjects = list_subjects(rootFolder)
% root_folder       the folder in which subjects are looked for
subs = dir(rootFolder);
isub = [subs(:).isdir];
subjects = {subs(isub).name}';
subjects(ismember(subjects,{'.','..'})) = [];


% --- Get the adress of the data folder from the gui, suggest a default
% project folder and set both to on the gui. Set the number of existing
% subjects and files as well
function choosedata_Callback(hObject, eventdata, handles)
% hObject    handle to choosedata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder = uigetdir();
if(folder ~= 0)
    if(isunix)
        slash = '/';
    elseif(ispc)
        slash = '\';
    end
    folder = strcat(folder,slash);
    set(handles.datafoldershow, 'String', folder)
    project_name = get(handles.projectname, 'String');
    
    split = strsplit(folder, slash);
    parent_folder = split(1:end - 2);
    dataFolder = split{end - 1};
    parent_folder = strjoin(parent_folder, slash);
    project_folder = strcat(parent_folder, slash ,dataFolder , '_', ...
        project_name, '_results', slash);
    set(handles.projectfoldershow, 'String', project_folder)
    
    ext = get(handles.extedit, 'String');
    [nSubject, nBlock] = ...
        get_subject_and_file_numbers(handles, folder, ext);
    
    set(handles.subjectnumber, 'String', ...
        [num2str(nSubject) ' subjects...'])
    set(handles.filenumber, 'String', [num2str(nBlock) ' files...'])
    
    if( nSubject == 0)
        popup_msg('There are no files in this folder. Make sure it is the right data folder', 'No data detected')
    end
end


% Update handles structure
guidata(hObject, handles);


% --- Get the adress of project folder and set the gui
function chooseproject_Callback(hObject, eventdata, handles)
% hObject    handle to chooseproject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder = uigetdir();
if(folder ~= 0)
    if(isunix)
        folder = strcat(folder,'/');
    elseif(ispc)
        folder = strcat(folder,'\');
    end
    set(handles.projectfoldershow, 'String', folder)
end
% Update handles structure
guidata(hObject, handles);

% --- Start the rating gui on the current project
function manualratingbutton_Callback(hObject, eventdata, handles)
% hObject    handle to manualratingbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Change the cursor to a watch while updating...
set(handles.mainGUI, 'pointer', 'watch')
drawnow;

% Update the project in case of new changes
handles = update_and_load(handles);

idx = get(handles.existingpopupmenu, 'Value');
projects = get(handles.existingpopupmenu, 'String');
name = projects{idx};
project = handles.projectList(name);

if(isa(project, 'Project'))
    ratingGUI(project);
end

% Change back the cursor to an arrow
set(handles.mainGUI, 'pointer', 'arrow')

% --- Start interpolation on selected files
function interpolatebutton_Callback(hObject, eventdata, handles)
% hObject    handle to interpolatebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update the project in case of new changes
handles = update_and_load(handles);

idx = get(handles.existingpopupmenu, 'Value');
projects = get(handles.existingpopupmenu, 'String');
name = projects{idx};
project = handles.projectList(name);

if(~ isempty(project))
    clc;
    commandwindow;
    project.interpolateSelected();
end

% --- Run preprocessing on all subjects
function runpreprocessbutton_Callback(hObject, eventdata, handles)
% hObject    handle to runpreprocessbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update the project in case of new changes
handles = update_and_load(handles);

idx = get(handles.existingpopupmenu, 'Value');
projects = get(handles.existingpopupmenu, 'String');
name = projects{idx};
project = handles.projectList(name);

if( ~ isempty(project))
    clc;
    commandwindow;
    project.preprocessAll();
end


% --- Load the selected project by gui
function existingpopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to existingpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns existingpopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from existingpopupmenu
handles = update_and_load(handles);
% Update handles structure
guidata(hObject, handles);

% --- Get the selected info and create a new project with them
function createbutton_Callback(hObject, eventdata, handles)
% hObject    handle to createbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CGV = handles.CGV;
name = get(handles.projectname, 'String');
projectFolder = get(handles.projectfoldershow, 'String');
dataFolder = get(handles.datafoldershow, 'String');

% Data folder and project folder must be at least modified !
if( strcmp(dataFolder, handles.CGV.NEW_PROJECT.DATA_FOLDER) || ...
        strcmp(projectFolder, handles.CGV.NEW_PROJECT.FOLDER) || ...
        strcmp(name, handles.CGV.NEW_PROJECT.NAME))
    
    popup_msg('You must choose a name, project folder and data folder.',...
        'Error');
    return;
end

% Get the file extension
ext = get(handles.extedit, 'String');
if(isempty(ext))
    popup_msg('A correct file extension must be given.', 'Error');
    return;
end

sRate = str2num(get(handles.srateedit, 'String'));
if(any(strcmp(ext, {handles.CGV.EXTENSIONS.text})) && isempty(sRate))
    popup_msg('Sampling rate is required when the file EXTENSIONS is .txt',...
        'Error');
    return;
end
    

% Get reduce checkbox
handles.params.ChannelReductionParams.performReduceChannels = ...
    get(handles.excludecheckbox, 'Value');
handles.params.ChannelReductionParams.tobeExcludedChans = ...
    str2num(get(handles.excludeedit, 'String'));
if( ~ get(handles.egiradio, 'Value') && ...
        get(handles.excludecheckbox, 'Value') && ...
        isempty(get(handles.excludeedit, 'String')))
    popup_msg(['A list of channel indices seperated by space or',...
        ' comma must be given to determine channels to be excluded'],...
        'Error');
    return;
end

% Check EOG regression
EOGParams = handles.params.EOGRegressionParams;
if( ~get(handles.egiradio, 'Value') && EOGParams.performEOGRegression && ...
        isempty(EOGParams.eogChans))
    popup_msg(['A list of channel indices seperated by space or',...
        ' comma must be given to determine EOG channels'],...
        'Error');
    return;
end

% Get the EEG system
if ~ get(handles.egiradio, 'Value')
   EEGSystem.name = CGV.PreprocessingCsts.EEGSystemCsts.OTHERS_NAME;
   EEGSystem.locFile = get(handles.chanlocedit, 'String');
   EEGSystem.fileLocType = get(handles.loctypeedit, 'String');
   EEGSystem.refChan = str2num(get(handles.hasreferenceedit, 'String'));
           
   if( get(handles.hasreferenceradio, 'Value') && isempty(EEGSystem.refChan))
        popup_msg('Please choose the index of the reference channel',...
            'Error');
        return;
   end
   
    locFile = EEGSystem.locFile;
    locType = EEGSystem.fileLocType;
    if( ~isempty(locFile) && (isempty(locType) || ~ strcmp(locType(1), '.')))
        popup_msg('Channel location: A correct file extension must be given.',...
            'Error');
        return;
    elseif(isempty(locFile))
        popup_msg({'You have provided no channel location file. Please ' ...
            'make sure the file location is at least provided in the EEG ' ...
            'structure.'}, 'Channel location');
    end

   handles.params.EEGSystem = EEGSystem;
end
handles.params.EEGSystem.sys10_20 = get(handles.checkbox1020, 'Value');

params = handles.params;
VisualisationParams = handles.VisualisationParams;
% Change the cursor to a watch while updating...
set(handles.mainGUI, 'pointer', 'watch')
drawnow;

choice = 'Over Write';
if( exist(Project.makeStateAddress(projectFolder), 'file'))
    handle = findobj(allchild(0), 'flat', 'Tag', 'mainGUI');
    main_pos = get(handle,'position');
    screen_size = get( groot, 'Screensize' );
    choice = MFquestdlg([main_pos(3)/2/screen_size(3) main_pos(4)/2/screen_size(4)],['Another project in this folder already ',...
        'exist. Do you want to load it or overwrite it ?'], ...
        'Pre-existing project in the project folder.',...
        'Over Write', 'Load','Over Write');
end

switch choice
    case 'Load'
        project = load(Project.makeStateAddress(projectFolder));
        project.UpdateAddressesFormStateFile(projectFolder, self.dataFolder);
    case 'Over Write'
        if( exist(Project.makeStateAddress(projectFolder), 'file'))
            load(Project.makeStateAddress(projectFolder));
            if( isKey(handles.projectList, self.name))
                project = handles.projectList(self.name);
                delete(project.stateAddress);
                remove(handles.projectList, self.name);
            else
                delete(Project.makeStateAddress(projectFolder));
            end
        end
        project = Project(name, dataFolder, projectFolder, ext, ...
            params, VisualisationParams, sRate);
end
name = project.name; % Overwrite the name in case the project is loaded.

% Change back the cursor to an arrow
set(handles.mainGUI, 'pointer', 'arrow')

% Set the gui to this project and load this project
handles.projectList(name) = project;
IndexC = strcmp(handles.projectList.keys, name);
Index = find(IndexC == 1);
handles.currentProject = Index;
set(handles.existingpopupmenu,...
    'String',handles.projectList.keys,...
    'Value', handles.currentProject);

switch choice
    case 'Load'
        handles = update_and_load(handles);
    case 'Over Write'
        handles = load_selected_project(handles);
end

save_state(handles);
popup_msg({'The project is successfully created.' ...
    'Now you can start pre-processing.'}, 'New project');
% Update handles structure
guidata(hObject, handles);


% --- Save the main gui's state and close the gui
function mainGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mainGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Change the cursor to a watch while updating...
set(handles.mainGUI, 'pointer', 'watch')
drawnow;

save_state(handles);

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Delete the selected project by gui
function deleteprojectbutton_Callback(hObject, eventdata, handles)
% hObject    handle to deleteprojectbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handle = findobj(allchild(0), 'flat', 'Tag', 'mainGUI');
main_pos = get(handle,'position');
screen_size = get( groot, 'Screensize' );
choice = MFquestdlg([main_pos(3)/2/screen_size(3) main_pos(4)/2/screen_size(4)],['Are you really sure to delete this project? The ',...
    'project will be deleted for all other users. NOTE: The ',...
    'data files and result files will not be deleted.'], ...
    'Take responsibility!',...
    'Cancel', 'Delete','Cancel');

switch choice
    case 'Cancel'
        % Do nothing
    case 'Delete'
        name = get(handles.projectname, 'String');
        project = handles.projectList(name);
        delete(project.stateAddress);
        
        remove(handles.projectList, name);
        handles.currentProject = 1;
        set(handles.existingpopupmenu,...
            'String',handles.projectList.keys, ...
            'Value', handles.currentProject);
        handles = update_and_load(handles);
        save_state(handles);
end


% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in configbutton.
function configbutton_Callback(hObject, eventdata, handles)
% hObject    handle to configbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
is_created = strcmp(get(handles.createbutton, 'visible'), 'off') ;

h = settingsGUI(handles.params, handles.VisualisationParams);
switch_gui('off', 'off', handles);
if(is_created)
    ui_elements = findobj(h.Children, 'Type', 'UiControl');
    set(ui_elements, 'enable', 'off')
    canc = findobj(h.Children, 'tag', 'cancelpushbutton');
    set(canc, 'enable', 'on');
end
set(handles.runpreprocessbutton, 'enable', 'off');
set(handles.manualratingbutton, 'enable', 'off');
set(handles.interpolatebutton, 'enable', 'off');
set(handles.existingpopupmenu, 'enable', 'off');
waitfor(h);
h = findobj(allchild(0), 'flat', 'Tag', 'mainGUI');
handles = guidata(h);
set(handles.runpreprocessbutton, 'enable', 'on');
set(handles.manualratingbutton, 'enable', 'on');
set(handles.interpolatebutton, 'enable', 'on');
set(handles.existingpopupmenu, 'enable', 'on');
if(~is_created)
    switch_gui('on', 'on', handles);
end


function projectname_Callback(hObject, eventdata, handles)
% hObject    handle to projectname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of projectname as text
%        str2double(get(hObject,'String')) returns contents of projectname as a double


% --- Executes during object creation, after setting all properties.
function projectname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projectname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function datafoldershow_Callback(hObject, eventdata, handles)
% hObject    handle to datafoldershow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of datafoldershow as text
%        str2double(get(hObject,'String')) returns contents of datafoldershow as a double


% --- Executes during object creation, after setting all properties.
function datafoldershow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datafoldershow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function projectfoldershow_Callback(hObject, eventdata, handles)
% hObject    handle to projectfoldershow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of projectfoldershow as text
%        str2double(get(hObject,'String')) returns contents of projectfoldershow as a double


% --- Executes during object creation, after setting all properties.
function projectfoldershow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projectfoldershow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function existingpopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to existingpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Get the file extension from the gui and calculate number of files and
% subjects in the datafolder with this extension and set the gui
function extedit_Callback(hObject, eventdata, handles)
% hObject    handle to extedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ext = get(handles.extedit, 'String');
if(any(strcmp(ext, {handles.CGV.EXTENSIONS.text})))
    set(handles.srateedit, 'enable', 'on')
    set(handles.srateedit, 'String', '')
else
    set(handles.srateedit, 'enable', 'off')
    set(handles.srateedit, 'String', '')
end

if( strcmp(get(handles.datafoldershow, 'String'), ... 
        handles.CGV.NEW_PROJECT.DATA_FOLDER) || ...
        isempty(get(handles.extedit, 'String')))
    return
end

folder = get(handles.datafoldershow, 'String');
[nSubject, nBlock] = ...
    get_subject_and_file_numbers(handles, folder, ext);

set(handles.subjectnumber, 'String', ...
    [num2str(nSubject) ' subjects...'])
set(handles.filenumber, 'String', [num2str(nBlock) ' files...'])

% Hints: get(hObject,'String') returns contents of extedit as text
%        str2double(get(hObject,'String')) returns contents of extedit as a double


% --- Executes during object creation, after setting all properties.
function extedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to extedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Set the EEG System to either 'EGI' or 'Others'. In any of the cases
% the corresponding radio button is set to 1, and the corresponding radio
% button of the other one is set to 0 as only one of them can be chosen. In
% the case of EGI the edit boxes for location file, file type and EOG
% channels must be deactivated whereas for the case of 'Others' they must be
% activated so that the user gives them as input.
% TODO: This function currently does not use the values from CGV, al values
% are hardocded!
function handles = setEEGSystem(params, handles)
% system    char that can be either 'EGI' or 'Others'
% handles   main handles of the gui
EEGSystem = params.EEGSystem;
ChannelReductionParams = params.ChannelReductionParams;

switch EEGSystem.name
    case 'EGI'
        set(handles.egiradio, 'Value', 1);
        set(handles.othersysradio, 'Value', 0);
        set(handles.chanlocedit, 'String', '');
        set(handles.loctypeedit, 'String', '');
        set(handles.chanlocedit, 'enable', 'off');
        set(handles.loctypeedit, 'enable', 'off');
        set(handles.choosechannelloc, 'enable', 'off');
        set(handles.excludeedit, 'enable', 'off');
        set(handles.excludeedit, 'String', '');
        set(handles.newreferenceradio, 'Value', 1)
        set(handles.hasreferenceradio, 'value', 0)
        set(handles.hasreferenceedit, 'String', ...
            num2str(handles.CGV.DefaultParams.EEGSystem.refChan))
        set(handles.newreferenceradio, 'enable', 'off')
        set(handles.hasreferenceradio, 'enable', 'off')
        set(handles.hasreferenceedit, 'enable', 'off')
        handles.params.ChannelReductionParams.performReduceChannels = 1;
    case 'Others'
        set(handles.othersysradio, 'Value', 1);
        set(handles.egiradio, 'Value', 0);
        set(handles.chanlocedit, 'enable', 'on');
        set(handles.chanlocedit, 'String', EEGSystem.locFile);
        if(get(handles.excludecheckbox, 'Value'))
           set(handles.excludeedit, 'enable', 'on'); 
           set(handles.excludeedit, 'String', ...
               num2str(ChannelReductionParams.tobeExcludedChans));
        end
        set(handles.loctypeedit, 'enable', 'on');
        set(handles.loctypeedit, 'String', EEGSystem.fileLocType);
        set(handles.excludeedit, 'String', ...
            num2str(ChannelReductionParams.tobeExcludedChans));
        set(handles.choosechannelloc, 'enable', 'on');
        
        if(isempty(EEGSystem.refChan))
            set(handles.newreferenceradio, 'Value', 1)
            set(handles.hasreferenceradio, 'value', 0)
        else
            set(handles.newreferenceradio, 'Value', 0)
            set(handles.hasreferenceradio, 'value', 1)
        end
        set(handles.hasreferenceedit, 'String', ...
            num2str(EEGSystem.refChan))
        
        set(handles.newreferenceradio, 'enable', 'on')
        set(handles.hasreferenceradio, 'enable', 'on')
        if(get(handles.hasreferenceradio, 'Value'))
            set(handles.hasreferenceedit, 'enable', 'on')
        end
        handles.params.ChannelReductionParams.performReduceChannels = 0;
end


function params = make_default_params(DefaultParams)
params.FilterParams = DefaultParams.FilterParams;
params.ASRParams = DefaultParams.ASRParams;
params.PrepParams = DefaultParams.PrepParams;
params.ChannelReductionParams = DefaultParams.ChannelReductionParams;
params.EOGRegressionParams = DefaultParams.EOGRegressionParams;
params.PCAParams = DefaultParams.PCAParams;
params.ICAParams= DefaultParams.ICAParams;
params.InterpolationParams = DefaultParams.InterpolationParams;
params.EEGSystem = DefaultParams.EEGSystem;
params.HighvarParams = DefaultParams.HighvarParams;

% --- Executes on button press in egiradio.
function egiradio_Callback(hObject, eventdata, handles)
% hObject    handle to egiradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = setEEGSystem(handles.CGV.DefaultParams, handles);
% Update handles structure
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of egiradio



function chanlocedit_Callback(hObject, eventdata, handles)
% hObject    handle to chanlocedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chanlocedit as text
%        str2double(get(hObject,'String')) returns contents of chanlocedit as a double


% --- Executes during object creation, after setting all properties.
function chanlocedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chanlocedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function loctypeedit_Callback(hObject, eventdata, handles)
% hObject    handle to loctypeedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loctypeedit as text
%        str2double(get(hObject,'String')) returns contents of loctypeedit as a double


% --- Executes during object creation, after setting all properties.
function loctypeedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loctypeedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in choosechannelloc.
function choosechannelloc_Callback(hObject, eventdata, handles)
% hObject    handle to choosechannelloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[x, y] = uigetfile('*');
full_address = strcat(y, x);
if(full_address ~= 0)
    set(handles.chanlocedit, 'String', full_address)
end


function excludeedit_Callback(hObject, eventdata, handles)
% hObject    handle to excludeedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of excludeedit as text
%        str2double(get(hObject,'String')) returns contents of excludeedit as a double


% --- Executes during object creation, after setting all properties.
function excludeedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to excludeedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in excludecheckbox.
function excludecheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to excludecheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of excludecheckbox
if(get(handles.othersysradio, 'Value'))
    if( get(handles.excludecheckbox, 'Value'))
           set(handles.excludeedit, 'enable', 'on');
    else
           set(handles.excludeedit, 'enable', 'off');
           set(handles.excludeedit, 'String', '');
    end
end



function srateedit_Callback(hObject, eventdata, handles)
% hObject    handle to srateedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of srateedit as text
%        str2double(get(hObject,'String')) returns contents of srateedit as a double


% --- Executes during object creation, after setting all properties.
function srateedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to srateedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1020.
function checkbox1020_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1020 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1020



function hasreferenceedit_Callback(hObject, eventdata, handles)
% hObject    handle to hasreferenceedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hasreferenceedit as text
%        str2double(get(hObject,'String')) returns contents of hasreferenceedit as a double


% --- Executes during object creation, after setting all properties.
function hasreferenceedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hasreferenceedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in newreferenceradio.
function newreferenceradio_Callback(hObject, eventdata, handles)
% hObject    handle to newreferenceradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of newreferenceradio
set(handles.hasreferenceedit, 'enable', 'off')

% --- Executes on button press in hasreferenceradio.
function hasreferenceradio_Callback(hObject, eventdata, handles)
% hObject    handle to hasreferenceradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hasreferenceradio
set(handles.hasreferenceedit, 'enable', 'on')


% --- Executes on button press in othersysradio.
function othersysradio_Callback(hObject, eventdata, handles)
% hObject    handle to othersysradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_pars = handles.CGV.DefaultParams.EEGSystem;
new_pars.name = 'Others';
new_pars.eogChans = [];
new_pars.tobeExcludedChans = [];
new_params = handles.params;
new_params.EEGSystem = new_pars;
handles = setEEGSystem(new_params, handles);
% Update handles structure
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of othersysradio


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over existingpopupmenu.
function existingpopupmenu_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to existingpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
