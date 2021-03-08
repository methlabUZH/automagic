function varargout = trimDataGUI(varargin)
% TRIMDATAGUI MATLAB code for trimDataGUI.fig
%      TRIMDATAGUI, by itself, creates a new TRIMDATAGUI or raises the existing
%      singleton*.
%
%      H = TRIMDATAGUI returns the handle to a new TRIMDATAGUI or the handle to
%      the existing singleton*.
%
%      TRIMDATAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRIMDATAGUI.M with the given input arguments.
%
%      TRIMDATAGUI('Property','Value',...) creates a new TRIMDATAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trimDataGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trimDataGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trimDataGUI

% Last Modified by GUIDE v2.5 21-Dec-2020 11:13:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trimDataGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @trimDataGUI_OutputFcn, ...
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


% --- Executes just before trimDataGUI is made visible.
function trimDataGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trimDataGUI (see VARARGIN)

movegui(handles.figure1,'center')
params = varargin{1};
handles.params = params;
set(handles.edit_firstTrigger,'Enable','off');
set(handles.edit_lastTrigger,'Enable','off');
set(handles.edit_paddingFirst,'Enable','off');
set(handles.edit_paddingLast,'Enable','off');

% changing trimDataParams, if already exists
if isfield(params,'TrimDataParams')
    set(handles.checkbox_firstTrigger, 'Value', params.TrimDataParams.checkbox_firstTrigger);
    set(handles.checkbox_lastTrigger, 'Value', params.TrimDataParams.checkbox_lastTrigger);

    set(handles.edit_firstTrigger, 'String', params.TrimDataParams.edit_firstTrigger);
    set(handles.edit_lastTrigger, 'String', params.TrimDataParams.edit_lastTrigger);
    set(handles.edit_paddingFirst, 'String', params.TrimDataParams.edit_paddingFirst);
    set(handles.edit_paddingLast, 'String', params.TrimDataParams.edit_paddingLast);
    
    if params.TrimDataParams.checkbox_firstTrigger == 1
        set(handles.edit_firstTrigger,'Enable','on');
        set(handles.edit_paddingFirst,'Enable','on');
    end
    if params.TrimDataParams.checkbox_lastTrigger == 1
        set(handles.edit_lastTrigger,'Enable','on');
        set(handles.edit_paddingLast,'Enable','on');
    end
end

% Choose default command line output for trimDataGUI
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes trimDataGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trimDataGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% this values are passed to mainGUI
varargout{1} = get(handles.checkbox_firstTrigger, 'Value');
varargout{2} = get(handles.checkbox_lastTrigger, 'Value');
varargout{3} = (varargout{1}|varargout{2});
varargout{4} = get(handles.edit_firstTrigger, 'String');
varargout{5} = get(handles.edit_lastTrigger, 'String');
varargout{6} = get(handles.edit_paddingFirst, 'String');
varargout{7} = get(handles.edit_paddingLast, 'String');

guidata(hObject, handles);
delete(handles.figure1);



function edit_firstTrigger_Callback(hObject, eventdata, handles)
% hObject    handle to edit_firstTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_firstTrigger as text
%        str2double(get(hObject,'String')) returns contents of edit_firstTrigger as a double


% --- Executes during object creation, after setting all properties.
function edit_firstTrigger_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_firstTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_lastTrigger_Callback(hObject, eventdata, handles)
% hObject    handle to edit_lastTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_lastTrigger as text
%        str2double(get(hObject,'String')) returns contents of edit_lastTrigger as a double


% --- Executes during object creation, after setting all properties.
function edit_lastTrigger_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lastTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_paddingFirst_Callback(hObject, eventdata, handles)
% hObject    handle to edit_paddingFirst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_paddingFirst as text
%        str2double(get(hObject,'String')) returns contents of edit_paddingFirst as a double


% --- Executes during object creation, after setting all properties.
function edit_paddingFirst_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_paddingFirst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_paddingLast_Callback(hObject, eventdata, handles)
% hObject    handle to edit_paddingLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_paddingLast as text
%        str2double(get(hObject,'String')) returns contents of edit_paddingLast as a double


% --- Executes during object creation, after setting all properties.
function edit_paddingLast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_paddingLast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_firstTrigger.
function checkbox_firstTrigger_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_firstTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_firstTrigger
if get(handles.checkbox_firstTrigger,'Value')
    set(handles.edit_firstTrigger,'Enable','on');
    set(handles.edit_paddingFirst,'Enable','on');
else
    set(handles.edit_firstTrigger,'String', '');
    set(handles.edit_firstTrigger,'Enable','off');
    set(handles.edit_paddingFirst,'String', '');
    set(handles.edit_paddingFirst,'Enable','off');
end

% --- Executes on button press in checkbox_lastTrigger.
function checkbox_lastTrigger_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_lastTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_lastTrigger
if get(handles.checkbox_lastTrigger,'Value')
    set(handles.edit_lastTrigger,'Enable','on');
    set(handles.edit_paddingLast,'Enable','on');
else
    set(handles.edit_lastTrigger,'String', '');
    set(handles.edit_lastTrigger,'Enable','off');
    set(handles.edit_paddingLast,'String', '');
    set(handles.edit_paddingLast,'Enable','off');
end

% --- Executes on button press in button_Cancel.
function button_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to button_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close('Trim Data'); % name of the window


% --- Executes on button press in button_OK.
function button_OK_Callback(hObject, eventdata, handles)
% hObject    handle to button_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);
close('Trim Data');


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
guidata(hObject, handles);  % Store the outputs in the GUI
uiresume()   % resume UI which will trigger the OutputFcn
