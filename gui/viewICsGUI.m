function varargout = viewICsGUI(varargin)
% VIEWICSGUI MATLAB code for viewICsGUI.fig
%      VIEWICSGUI, by itself, creates a new VIEWICSGUI or raises the existing
%      singleton*.
%
%      H = VIEWICSGUI returns the handle to a new VIEWICSGUI or the handle to
%      the existing singleton*.
%
%      VIEWICSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWICSGUI.M with the given input arguments.
%
%      VIEWICSGUI('Property','Value',...) creates a new VIEWICSGUI or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewICsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewICsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewICsGUI

% Last Modified by GUIDE v2.5 06-Mar-2021 15:10:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewICsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @viewICsGUI_OutputFcn, ...
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

% --- Executes just before viewICsGUI is made visible.
function viewICsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewICsGUI (see VARARGIN)


movegui(handles.figure_viewIC,'center')

% Change the cursor to a watch while updating...
set(handles.figure_viewIC, 'pointer', 'watch')
drawnow;
    
project = varargin{1};
EEG = varargin{2};
set(handles.edit_numberICs, 'String', size(EEG.etc.ic_classification.ICLabel.all_classifications, 1))
set(handles.radiobutton_all,'Value', 1);

% find indices of all IC labels
iclabel = EEG.etc.ic_classification.ICLabel;
[row, type] = find(ismember(iclabel.all_classifications, max(iclabel.all_classifications, [], 2)));

brain = row((type == 1));
muscle = row((type == 2));
eye = row((type == 3));
heart = row((type == 4));
line_n = row((type == 5));
chan_n = row((type == 6));
other = row((type == 7));

allICs = {brain, muscle, eye, heart, line_n, chan_n, other}';

% check, if IClabel installed, because pop_vieprops comes with it
parts = addEEGLab();
ICLabelFolderIndex = find(~cellfun(@isempty,strfind(parts,'ICLabel')));
found = ~isempty(ICLabelFolderIndex);
if found == 0
    disp('Installing ICLabel');
    evalc('plugin_askinstall(''ICLabel'',[],true)');
    close();
end
str = which('vl_nnconv.mexw64');
mexFolder = strfind(str,filesep);
mexFolder = str(1:mexFolder(end));
addpath(mexFolder);
addEEGLab();

% Change back the cursor to an arrow
set(handles.figure_viewIC, 'pointer', 'arrow')

% Choose default command line output for viewICsGUI
handles.output = hObject;
handles.EEG = EEG;
handles.allICs = allICs;
clear EEG


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes viewICsGUI wait for user response (see UIRESUME)
% uiwait(handles.figure_viewIC);


% --- Outputs from this function are returned to the command line.
function varargout = viewICsGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function edit_numberICs_Callback(hObject, eventdata, handles)
% hObject    handle to edit_numberICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_numberICs as text
%        str2double(get(hObject,'String')) returns contents of edit_numberICs as a double


% --- Executes during object creation, after setting all properties.
function edit_numberICs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_numberICs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_all.
function radiobutton_all_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_all
set(handles.radiobutton_brain,'Value', 0);
set(handles.radiobutton_heart,'Value', 0);
set(handles.radiobutton_eye,'Value', 0);
set(handles.radiobutton_line,'Value', 0);
set(handles.radiobutton_chan_n,'Value', 0);
set(handles.radiobutton_other,'Value', 0);
set(handles.radiobutton_muscle,'Value', 0);

selectedICs = select_comps(handles);
set(handles.edit_numberICs, 'String', size(cell2mat(selectedICs), 1))

% --- Executes on button press in radiobutton_brain.
function radiobutton_brain_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_brain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_brain
set(handles.radiobutton_all,'Value', 0);

selectedICs = select_comps(handles);
set(handles.edit_numberICs, 'String', size(cell2mat(selectedICs), 1))


% --- Executes on button press in radiobutton_eye.
function radiobutton_eye_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_eye (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_eye
set(handles.radiobutton_all,'Value', 0);

selectedICs = select_comps(handles);
set(handles.edit_numberICs, 'String', size(cell2mat(selectedICs), 1))

% --- Executes on button press in radiobutton_heart.
function radiobutton_heart_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_heart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_heart
set(handles.radiobutton_all,'Value', 0);

selectedICs = select_comps(handles);
set(handles.edit_numberICs, 'String', size(cell2mat(selectedICs), 1))

% --- Executes on button press in radiobutton_line.
function radiobutton_line_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_line (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_line
set(handles.radiobutton_all,'Value', 0);

selectedICs = select_comps(handles);
set(handles.edit_numberICs, 'String', size(cell2mat(selectedICs), 1))

% --- Executes on button press in radiobutton_other.
function radiobutton_other_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_other (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_other
set(handles.radiobutton_all,'Value', 0);

selectedICs = select_comps(handles);
set(handles.edit_numberICs, 'String', size(cell2mat(selectedICs), 1))

% --- Executes on button press in callback_viewIC.
function callback_viewIC_Callback(hObject, eventdata, handles)
% hObject    handle to callback_viewIC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% find indices
selectedICs = select_comps(handles);
idx = cell2mat(selectedICs);

% before ic removal
EEG_sancheck = handles.EEG;
EEG_sancheck.etc.ic_classification.ICLabel.classifications = handles.EEG.etc.ic_classification.ICLabel.all_classifications; % 10.2021 - new, because pop_subcomp removes comps from here. I am saving a copy of original list in 'all_classifications'
EEG_sancheck.chanlocs = handles.EEG.etc.beforeICremove.chanlocs;
EEG_sancheck.icaact = handles.EEG.etc.beforeICremove.icaact;
EEG_sancheck.icawinv = handles.EEG.etc.beforeICremove.icawinv;
EEG_sancheck.icasphere = handles.EEG.etc.beforeICremove.icasphere;
EEG_sancheck.icaweights = handles.EEG.etc.beforeICremove.icaweights;
EEG_sancheck.icachansind = 1:size(EEG_sancheck.icaact ,1);

% important, if user dont want to view all ICs
numIC = str2double(get(handles.edit_numberICs, 'String')); 

% parameters: EEG, 0 = component, comp idx to plot
pop_viewprops(EEG_sancheck, 0, idx(1:numIC)');

guidata(hObject, handles);
close('View ICs');

% --- Executes on button press in callback_cancel.
function callback_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to callback_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);
close('View ICs');


% --- Executes on button press in radiobutton_chan_n.
function radiobutton_chan_n_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_chan_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_chan_n
set(handles.radiobutton_all,'Value', 0);

selectedICs = select_comps(handles);
set(handles.edit_numberICs, 'String', size(cell2mat(selectedICs), 1))

% --- Executes on button press in radiobutton_muscle.
function radiobutton_muscle_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_muscle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_muscle
set(handles.radiobutton_all,'Value', 0);

selectedICs = select_comps(handles);
set(handles.edit_numberICs, 'String', size(cell2mat(selectedICs), 1))


function selectedICs = select_comps(handles)

allICs = handles.allICs;

if get(handles.radiobutton_all,'Value')
    i = logical([1, 1, 1, 1, 1, 1, 1]');   
else
    i = logical([get(handles.radiobutton_brain,'Value'), ...
        get(handles.radiobutton_muscle,'Value'), ...
        get(handles.radiobutton_eye,'Value'), ...
        get(handles.radiobutton_heart,'Value'), ...
        get(handles.radiobutton_line,'Value'), ...
        get(handles.radiobutton_chan_n,'Value'), ...
        get(handles.radiobutton_other,'Value'), ...
        ]');
end

selectedICs = allICs(i);