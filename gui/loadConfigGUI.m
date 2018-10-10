function varargout = loadConfigGUI(varargin)
% LOADCONFIGGUI MATLAB code for loadConfigGUI.fig
%      LOADCONFIGGUI, by itself, creates a new LOADCONFIGGUI or raises the existing
%      singleton*.
%
%      H = LOADCONFIGGUI returns the handle to a new LOADCONFIGGUI or the handle to
%      the existing singleton*.
%
%      LOADCONFIGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOADCONFIGGUI.M with the given input arguments.
%
%      LOADCONFIGGUI('Property','Value',...) creates a new LOADCONFIGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before loadConfigGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to loadConfigGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help loadConfigGUI

% Last Modified by GUIDE v2.5 10-Oct-2018 10:48:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @loadConfigGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @loadConfigGUI_OutputFcn, ...
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


% --- Executes just before loadConfigGUI is made visible.
function loadConfigGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to loadConfigGUI (see VARARGIN)

movegui(handles.figure1,'center')

% Choose default command line output for loadConfigGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes loadConfigGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = loadConfigGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = get(handles.pathedit, 'String');
delete(handles.figure1);


% --- Executes on button press in statebutton.
function statebutton_Callback(hObject, eventdata, handles)
% hObject    handle to statebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[name, project_path, ~] = uigetfile('load');
% If user cancelled the process, choose the previous project
if( name ~= 0 )
    path = strcat(project_path, name);
    set(handles.pathedit, 'String', path)
end



function pathedit_Callback(hObject, eventdata, handles)
% hObject    handle to pathedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pathedit as text
%        str2double(get(hObject,'String')) returns contents of pathedit as a double


% --- Executes during object creation, after setting all properties.
function pathedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pathedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in okbutton.
function okbutton_Callback(hObject, eventdata, handles)
% hObject    handle to okbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close('loadConfigGUI');

% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.pathedit, 'String', '');
close('loadConfigGUI');


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
