function varargout = loadGUI(varargin)
% LOADGUI MATLAB code for loadGUI.fig
%      LOADGUI, by itself, creates a new LOADGUI or raises the existing
%      singleton*.
%
%      H = LOADGUI returns the handle to a new LOADGUI or the handle to
%      the existing singleton*.
%
%      LOADGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOADGUI.M with the given input arguments.
%
%      LOADGUI('Property','Value',...) creates a new LOADGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before loadGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to loadGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help loadGUI

% Last Modified by GUIDE v2.5 19-Sep-2018 15:35:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @loadGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @loadGUI_OutputFcn, ...
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


% --- Executes just before loadGUI is made visible.
function loadGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to loadGUI (see VARARGIN)

movegui(handles.figure1,'center')

% Choose default command line output for loadGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes loadGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = loadGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = get(handles.dataedit, 'String');
varargout{2} = get(handles.stateedit, 'String');
delete(handles.figure1);


% --- Executes on button press in statepushbutton.
function statepushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to statepushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[name, project_path, ~] = uigetfile('load');
    % If user cancelled the process, choose the previous project
if( name ~= 0 )
    path = strcat(project_path, name);
    set(handles.stateedit, 'String', path)
end


% --- Executes on button press in datapushbutton.
function datapushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to datapushbutton (see GCBO)
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
    set(handles.dataedit, 'String', folder)
end


function stateedit_Callback(hObject, eventdata, handles)
% hObject    handle to stateedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stateedit as text
%        str2double(get(hObject,'String')) returns contents of stateedit as a double


% --- Executes during object creation, after setting all properties.
function stateedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stateedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dataedit_Callback(hObject, eventdata, handles)
% hObject    handle to dataedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dataedit as text
%        str2double(get(hObject,'String')) returns contents of dataedit as a double


% --- Executes during object creation, after setting all properties.
function dataedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okpushbutton.
function okpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to okpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close('loadGUI');

% --- Executes on button press in cancelpushbutton.
function cancelpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.stateedit, 'String', '');
set(handles.dataedit, 'String', '');
close('loadGUI');


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    uiresume(hObject)
else
    delete(hObject);
end
