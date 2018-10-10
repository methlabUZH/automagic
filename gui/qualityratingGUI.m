function varargout = qualityratingGUI(varargin)
% QUALITYRATINGGUI MATLAB code for qualityratingGUI.fig
%      QUALITYRATINGGUI, by itself, creates a new QUALITYRATINGGUI or raises the existing
%      singleton*.
%
%      H = QUALITYRATINGGUI returns the handle to a new QUALITYRATINGGUI or the handle to
%      the existing singleton*.
%
%      QUALITYRATINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QUALITYRATINGGUI.M with the given input arguments.
%
%      QUALITYRATINGGUI('Property','Value',...) creates a new QUALITYRATINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before qualityratingGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to qualityratingGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help qualityratingGUI

% Last Modified by GUIDE v2.5 19-Sep-2018 15:35:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @qualityratingGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @qualityratingGUI_OutputFcn, ...
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


% --- Executes just before qualityratingGUI is made visible.
function qualityratingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to qualityratingGUI (see VARARGIN)

if( nargin - 3 ~= 1 )
    error('wrong number of arguments. Project must be given as argument.')
end

project = varargin{1};
assert(isa(project, 'Project'));
handles.project = project;
handles.CGV = ConstantGlobalValues;
% Set the title to the current version
handles.title_name = ['Automagic v.', handles.CGV.VERSION, ' Quality Rating'];
set(handles.qualityrating, 'Name', handles.title_name);

cutoffs = handles.project.qualityCutoffs;
renderChanges(handles, cutoffs);
% Choose default command line output for qualityratingGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes qualityratingGUI wait for user response (see UIRESUME)
% uiwait(handles.qualityrating);


% --- Outputs from this function are returned to the command line.
function varargout = qualityratingGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function renderChanges(handles, cutoffs)
handles.project.qualityCutoffs = cutoffs;
render_project(handles, cutoffs);
renderAxes(handles, cutoffs);
change_ratingGUI(false, cutoffs);

function handles = render_project(handles, cutoffs)

set(handles.ohapopupmenu,...
    'String',handles.project.qualityThresholds.overallThresh, ...
    'Value', handles.project.qualityScoreIdx.OHA);

set(handles.thvpopupmenu,...
    'String',handles.project.qualityThresholds.timeThresh, ...
    'Value', handles.project.qualityScoreIdx.THV);

set(handles.chvpopupmenu,...
    'String',handles.project.qualityThresholds.chanThresh, ...
    'Value', handles.project.qualityScoreIdx.CHV);

if any(strfind(cutoffs.Qmeasure,'OHA'))
    set(handles.oharadio, 'Value', 1);
    set(handles.ohaslider1, 'Value', cutoffs.overallGoodCutoff);
    set(handles.ohaslider2, 'Value', cutoffs.overallBadCutoff);
else
    set(handles.oharadio, 'Value', 0);
    set(handles.ohaslider1, 'Value', 0);
    set(handles.ohaslider2, 'Value', 0);
end
set(handles.ohaslider1text, 'String', get(handles.ohaslider1, 'Value'));
set(handles.ohaslider2text, 'String', get(handles.ohaslider2, 'Value'));

if any(strfind(cutoffs.Qmeasure,'THV'))
    set(handles.thvradio, 'Value', 1);
    set(handles.thvslider1, 'Value', cutoffs.timeGoodCutoff);
    set(handles.thvslider2, 'Value', cutoffs.timeBadCutoff);
else
    set(handles.thvradio, 'Value', 0);
    set(handles.thvslider1, 'Value', 0);
    set(handles.thvslider2, 'Value', 0);
end
set(handles.thvslider1text, 'String', get(handles.thvslider1, 'Value'));
set(handles.thvslider2text, 'String', get(handles.thvslider2, 'Value'));

if any(strfind(cutoffs.Qmeasure,'CHV'))
    set(handles.chvradio, 'Value', 1);
    set(handles.chvslider1, 'Value', cutoffs.channelGoodCutoff);
    set(handles.chvslider2, 'Value', cutoffs.channelBadCutoff);
else
    set(handles.chvradio, 'Value', 0);
    set(handles.chvslider1, 'Value', 0);
    set(handles.chvslider2, 'Value', 0);
end
set(handles.chvslider1text, 'String', get(handles.chvslider1, 'Value'));
set(handles.chvslider2text, 'String', get(handles.chvslider2, 'Value'));

if any(strfind(cutoffs.Qmeasure,'RBC'))
    set(handles.rbcradio, 'Value', 1);
    set(handles.rbcslider1, 'Value', cutoffs.BadChannelGoodCutoff);
    set(handles.rbcslider2, 'Value', cutoffs.BadChannelBadCutoff);
else
    set(handles.rbcradio, 'Value', 0);
    set(handles.rbcslider1, 'Value', 0);
    set(handles.rbcslider2, 'Value', 0);
end
set(handles.rbcslider1text, 'String', get(handles.rbcslider1, 'Value'));
set(handles.rbcslider2text, 'String', get(handles.rbcslider2, 'Value'));

function cutoffs = get_gui_values(handles)

cutoffs = struct('Qmeasure', '');                                
if get(handles.oharadio, 'Value')
    cutoffs.Qmeasure = [cutoffs.Qmeasure 'OHA'];
    cutoffs.overallGoodCutoff = get(handles.ohaslider1, 'Value');
    cutoffs.overallBadCutoff = get(handles.ohaslider2, 'Value');
end

if get(handles.thvradio, 'Value')
    cutoffs.Qmeasure = [cutoffs.Qmeasure 'THV'];
    cutoffs.timeGoodCutoff = get(handles.thvslider1, 'Value');
    cutoffs.timeBadCutoff = get(handles.thvslider2, 'Value');
end

if get(handles.chvradio, 'Value')
    cutoffs.Qmeasure = [cutoffs.Qmeasure 'CHV'];
    cutoffs.channelGoodCutoff = get(handles.chvslider1, 'Value');
    cutoffs.channelBadCutoff = get(handles.chvslider2, 'Value');
end

if get(handles.rbcradio, 'Value')
    cutoffs.Qmeasure = [cutoffs.Qmeasure 'RBC'];
    cutoffs.BadChannelGoodCutoff = get(handles.rbcslider1, 'Value');
    cutoffs.BadChannelBadCutoff = get(handles.rbcslider2, 'Value');
end

function change_ratingGUI(render_lines, cutoffs)
h = findobj(allchild(0), 'flat', 'Tag', 'ratingGUI');
ratingGUI_handle = guidata(h);
set_gui_rating(ratingGUI_handle, cutoffs);
if render_lines
    update_lines(ratingGUI_handle);
end

function renderAxes(handles, cutoffs)
ratings = handles.project.getQualityRatings(cutoffs);
cutoffAxes = handles.cutoffaxes;
rateingHist = histogram(categorical(ratings, {'Good' 'OK' 'Bad' 'Manually Rated'},'Ordinal',true), 'Parent', cutoffAxes);
text(1:length(rateingHist.Categories),rateingHist.Values-0.3*rateingHist.Values,num2cell(rateingHist.Values))
Y_axis_max = max(rateingHist.Values) + ceil(0.1 * max(rateingHist.Values));
n_Y = Y_axis_max / 10.0;
set(cutoffAxes, 'YTick', 0:ceil(n_Y):ceil(Y_axis_max))
set(cutoffAxes,'fontsize', 10)
title('Frequencies of data qualities based on selected cutoffshow')
if max(rateingHist.Values) ~= 0
    ylim([0 (max(rateingHist.Values) + ceil(0.1 * max(rateingHist.Values)))])
end

function ret_val = apply_to_all(handles, cutoffs)
% Change the cutoff the project
% Change rating of everyfile
ret_val = [];
project = handles.project;

question = 'Would you like to apply changes on also manually rated files';
handle = findobj(allchild(0), 'flat', 'Tag', 'qualityrating');
set(handle, 'units', 'pixels')
main_pos = get(handle,'position');
set(handle, 'units', 'normalized')
screen_size = get( groot, 'Screensize' );
choice = MFquestdlg([main_pos(3)/1.5/screen_size(3) main_pos(4)/1.5/screen_size(4)], question, ...
    'Apply on all files',...
    'Apply on all', 'Do not apply on manually rated files','Do not apply on manually rated files');

switch choice
    case 'Apply on all'
        apply_to_manually_rated = true;
    case 'Do not apply on manually rated files'
        apply_to_manually_rated = false;
    otherwise
        return;
end

set(handles.qualityrating, 'pointer', 'watch')
drawnow;
project.applyQualityRatings(cutoffs, apply_to_manually_rated);
change_ratingGUI(true, cutoffs);
set(handles.qualityrating, 'pointer', 'arrow');
ret_val = handles;

% --- Executes on button press in commitbutton.
function commitbutton_Callback(hObject, eventdata, handles)
% hObject    handle to commitbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cutoffs = get_gui_values(handles);
ret_val = apply_to_all(handles, cutoffs);
if ~ isempty(ret_val)
    close(handles.title_name);
end

% --- Executes on button press in resetbutton.
function resetbutton_Callback(hObject, eventdata, handles)
% hObject    handle to resetbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cutoffs = handles.CGV.DefaultVisualisationParams.RateQualityParams;
renderChanges(handles, cutoffs);

% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.title_name);

% --- Executes on slider movement.
function ohaslider1_Callback(hObject, eventdata, handles)
% hObject    handle to ohaslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
goodValue = get(hObject,'Value');
badValue = get(handles.ohaslider2, 'Value');
if (goodValue > badValue)
    set(handles.ohaslider2, 'Value', goodValue)
end
set(handles.ohaslider1text, 'String', goodValue);
cutoffs = get_gui_values(handles);
renderChanges(handles, cutoffs);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function ohaslider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ohaslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in chvradio.
function chvradio_Callback(hObject, eventdata, handles)
% hObject    handle to chvradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.chvslider1, 'enable', 'on')
    set(handles.chvslider2, 'enable', 'on')
else
    set(handles.chvslider1, 'enable', 'off')
    set(handles.chvslider2, 'enable', 'off')
end
cutoffs = get_gui_values(handles);
renderChanges(handles, cutoffs);
% Hint: get(hObject,'Value') returns toggle state of chvradio


% --- Executes on button press in thvradio.
function thvradio_Callback(hObject, eventdata, handles)
% hObject    handle to thvradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.thvslider1, 'enable', 'on')
    set(handles.thvslider2, 'enable', 'on')
else
    set(handles.thvslider1, 'enable', 'off')
     set(handles.thvslider2, 'enable', 'off')
end
cutoffs = get_gui_values(handles);
renderChanges(handles, cutoffs);
% Hint: get(hObject,'Value') returns toggle state of thvradio


% --- Executes on button press in oharadio.
function oharadio_Callback(hObject, eventdata, handles)
% hObject    handle to oharadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.ohaslider1, 'enable', 'on')
    set(handles.ohaslider2, 'enable', 'on')
else
    set(handles.ohaslider1, 'enable', 'off')
    set(handles.ohaslider2, 'enable', 'off')
end
cutoffs = get_gui_values(handles);
renderChanges(handles, cutoffs);
% Hint: get(hObject,'Value') returns toggle state of oharadio


% --- Executes on button press in rbcradio.
function rbcradio_Callback(hObject, eventdata, handles)
% hObject    handle to rbcradio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.rbcslider1, 'enable', 'on')
    set(handles.rbcslider2, 'enable', 'on')
else
    set(handles.rbcslider1, 'enable', 'off')
    set(handles.rbcslider2, 'enable', 'off')
end
cutoffs = get_gui_values(handles);
renderChanges(handles, cutoffs);
% Hint: get(hObject,'Value') returns toggle state of rbcradio


% --- Executes on slider movement.
function rbcslider1_Callback(hObject, eventdata, handles)
% hObject    handle to rbcslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
goodValue = get(hObject,'Value');
badValue = get(handles.rbcslider2, 'Value');
if (goodValue > badValue)
    set(handles.rbcslider2, 'Value', goodValue)
end
set(handles.rbcslider1text, 'String', goodValue);
cutoffs = get_gui_values(handles);
renderChanges(handles, cutoffs);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function rbcslider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbcslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function rbcslider2_Callback(hObject, eventdata, handles)
% hObject    handle to rbcslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
badValue = get(hObject,'Value');
goodValue = get(handles.rbcslider1, 'Value');
if (goodValue > badValue)
    set(handles.rbcslider1, 'Value', badValue)
end
set(handles.rbcslider2text, 'String', badValue);
cutoffs = get_gui_values(handles);
renderChanges(handles, cutoffs);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function rbcslider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rbcslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function chvslider1_Callback(hObject, eventdata, handles)
% hObject    handle to chvslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
goodValue = get(hObject,'Value');
badValue = get(handles.chvslider2, 'Value');
if (goodValue > badValue)
    set(handles.chvslider2, 'Value', goodValue)
end
set(handles.chvslider1text, 'String', goodValue);
cutoffs = get_gui_values(handles);
renderChanges(handles, cutoffs);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function chvslider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chvslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function chvslider2_Callback(hObject, eventdata, handles)
% hObject    handle to chvslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
badValue = get(hObject,'Value');
goodValue = get(handles.chvslider1, 'Value');
if (goodValue > badValue)
    set(handles.chvslider1, 'Value', badValue)
end
set(handles.chvslider2text, 'String', badValue);
cutoffs = get_gui_values(handles);
renderChanges(handles, cutoffs);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function chvslider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chvslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function thvslider1_Callback(hObject, eventdata, handles)
% hObject    handle to thvslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
goodValue = get(hObject,'Value');
badValue = get(handles.thvslider2, 'Value');
if (goodValue > badValue)
    set(handles.thvslider2, 'Value', goodValue)
end
set(handles.thvslider1text, 'String', goodValue);
cutoffs = get_gui_values(handles);
renderChanges(handles, cutoffs);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function thvslider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thvslider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function thvslider2_Callback(hObject, eventdata, handles)
% hObject    handle to thvslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
badValue = get(hObject,'Value');
goodValue = get(handles.thvslider1, 'Value');
if (goodValue > badValue)
    set(handles.thvslider1, 'Value', badValue)
end
set(handles.thvslider2text, 'String', badValue);
cutoffs = get_gui_values(handles);
renderChanges(handles, cutoffs);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function thvslider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thvslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function ohaslider2_Callback(hObject, eventdata, handles)
% hObject    handle to ohaslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
badValue = get(hObject,'Value');
goodValue = get(handles.ohaslider1, 'Value');
if (goodValue > badValue)
    set(handles.ohaslider1, 'Value', badValue)
end
set(handles.ohaslider2text, 'String', badValue);
cutoffs = get_gui_values(handles);
renderChanges(handles, cutoffs);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function ohaslider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ohaslider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes when user attempts to close qualityrating.
function qualityrating_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to qualityrating (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on selection change in chvpopupmenu.
function chvpopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to chvpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));
val = contents{get(hObject,'Value')};
idx = find(handles.project.qualityThresholds.chanThresh == str2num(val));
handles.project.qualityScoreIdx.CHV = idx;
renderAxes(handles, handles.project.qualityCutoffs);
change_ratingGUI(false, handles.project.qualityCutoffs);
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns chvpopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chvpopupmenu


% --- Executes during object creation, after setting all properties.
function chvpopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chvpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in thvpopupmenu.
function thvpopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to thvpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));
val = contents{get(hObject,'Value')};
idx = find(handles.project.qualityThresholds.timeThresh == str2num(val));
handles.project.qualityScoreIdx.THV = idx;
renderAxes(handles, handles.project.qualityCutoffs);
change_ratingGUI(false, handles.project.qualityCutoffs);
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns thvpopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from thvpopupmenu


% --- Executes during object creation, after setting all properties.
function thvpopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thvpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ohapopupmenu.
function ohapopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to ohapopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));
val = contents{get(hObject,'Value')};
idx = find(handles.project.qualityThresholds.overallThresh == str2num(val));
handles.project.qualityScoreIdx.OHA = idx;
renderAxes(handles, handles.project.qualityCutoffs);
change_ratingGUI(false, handles.project.qualityCutoffs);
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns ohapopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ohapopupmenu


% --- Executes during object creation, after setting all properties.
function ohapopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ohapopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
