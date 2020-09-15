function varargout = emailFeatureGUI(varargin)
% EMAILFEATUREGUI MATLAB code for emailFeatureGUI.fig
%      EMAILFEATUREGUI, by itself, creates a new EMAILFEATUREGUI or raises the existing
%      singleton*.
%
%      H = EMAILFEATUREGUI returns the handle to a new EMAILFEATUREGUI or the handle to
%      the existing singleton*.
%
%      EMAILFEATUREGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EMAILFEATUREGUI.M with the given input arguments.
%
%      EMAILFEATUREGUI('Property','Value',...) creates a new EMAILFEATUREGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before emailFeatureGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to emailFeatureGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help emailFeatureGUI

% Last Modified by GUIDE v2.5 16-Dec-2019 11:09:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @emailFeatureGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @emailFeatureGUI_OutputFcn, ...
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


% --- Executes just before emailFeatureGUI is made visible.
function emailFeatureGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to emailFeatureGUI (see VARARGIN)

% Choose default command line output for emailFeatureGUI
handles.output = hObject;
handles.origin = varargin{1};
set(handles.emailTextbox,'enable','off');
set(handles.errorlogattach, 'enable','off');
set(handles.tcagree, 'enable','off');
set(handles.okpushbutton, 'enable','off');
% handles.origin.emailOptions.agree
if isfield(handles.origin,'emailOptions')
    if handles.origin.emailOptions.agree == 1
        set(handles.tcagree,'Value',1);
        set(handles.emailTextbox,'String',handles.origin.emailOptions.emailAddress);
        set(handles.email_radiobutton,'Value',1);
        set(handles.emailTextbox,'enable','on');
        set(handles.errorlogattach, 'enable','on');
        set(handles.tcagree, 'enable','on');
        set(handles.okpushbutton, 'enable','on');
    end
    if handles.origin.emailOptions.errorlog == 1
        set(handles.errorlogattach,'Value',1);
    end
end
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes emailFeatureGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = emailFeatureGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% guidata(hObject, handles);
% waitfor(handles.okpushbutton,'Value',1);
% handles
varargout{1} = get(handles.tcagree,'Value');
varargout{2} = get(handles.errorlogattach,'Value');
varargout{3} = get(handles.emailTextbox,'String');
% guidata(hObject, handles);
delete(handles.figure1);

% --- Executes on button press in email_radiobutton.
function email_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to email_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.email_radiobutton,'Value')
    set(handles.emailTextbox,'enable','on');
    set(handles.errorlogattach, 'enable','on');
    set(handles.tcagree, 'enable','on');
else 
    set(handles.emailTextbox,'enable','off');
    set(handles.errorlogattach, 'enable','off');
    set(handles.tcagree, 'enable','off');
end
% Hint: get(hObject,'Value') returns toggle state of email_radiobutton

function emailTextbox_Callback(hObject, eventdata, handles)
% hObject    handle to emailTextbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of emailTextbox as text
%        str2double(get(hObject,'String')) returns contents of emailTextbox as a double

% --- Executes during object creation, after setting all properties.
function emailTextbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to emailTextbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in tcagree.
function tcagree_Callback(hObject, eventdata, handles)
% hObject    handle to tcagree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.tcagree,'Value')
    set(handles.okpushbutton,'enable','on');
else
    set(handles.okpushbutton,'enable','off');
end
% Hint: get(hObject,'Value') returns toggle state of tcagree

% --- Executes on button press in tcLook.
function tcLook_Callback(hObject, eventdata, handles)
% hObject    handle to tcLook (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('https://github.com/methlabUZH/automagic/wiki/Email-notifications-feature');

% --- Executes on button press in errorlogattach.
function errorlogattach_Callback(hObject, eventdata, handles)
% hObject    handle to errorlogattach (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of errorlogattach


% --- Executes on button press in okpushbutton.
function okpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to okpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% emailFeatureGUI_OutputFcn(hObject, eventdata, handles);
guidata(hObject, handles);
close('emailFeatureGUI');

% --- Executes on button press in cancelpushbutton.
function cancelpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close('emailFeatureGUI');

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
