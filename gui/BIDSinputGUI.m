function varargout = BIDSinputGUI(varargin)
% BIDSINPUTGUI MATLAB code for BIDSinputGUI.fig
%      BIDSINPUTGUI, by itself, creates a new BIDSINPUTGUI or raises the existing
%      singleton*.
%
%      H = BIDSINPUTGUI returns the handle to a new BIDSINPUTGUI or the handle to
%      the existing singleton*.
%
%      BIDSINPUTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BIDSINPUTGUI.M with the given input arguments.
%
%      BIDSINPUTGUI('Property','Value',...) creates a new BIDSINPUTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BIDSinputGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BIDSinputGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BIDSinputGUI

% Last Modified by GUIDE v2.5 08-Nov-2018 10:56:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BIDSinputGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @BIDSinputGUI_OutputFcn, ...
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


% --- Executes just before BIDSinputGUI is made visible.
function BIDSinputGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BIDSinputGUI (see VARARGIN)

movegui(handles.figure1,'center')

% Choose default command line output for BIDSinputGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%UIWAIT makes BIDSinputGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BIDSinputGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = get(handles.dataedit, 'String');
delete(handles.figure1);


% --- Executes on button press in datapushbutton.
function datapushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to datapushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder = uigetdir();
if(folder ~= 0)
    slash = filesep;
    folder = strcat(folder, slash);
    set(handles.dataedit, 'String', folder)
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
slash = filesep;
if ~ contains(get(handles.dataedit, 'String'), slash)
    return;
end
close('BIDSinputGUI');

% --- Executes on button press in cancelpushbutton.
function cancelpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.dataedit, 'String', '');
close('BIDSinputGUI');


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
