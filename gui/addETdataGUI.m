function varargout = addETdataGUI(varargin)
% ADDETDATAGUI MATLAB code for addETdataGUI.fig
%      ADDETDATAGUI, by itself, creates a new ADDETDATAGUI or raises the existing
%      singleton*.
%
%      H = ADDETDATAGUI returns the handle to a new ADDETDATAGUI or the handle to
%      the existing singleton*.
%
%      ADDETDATAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDETDATAGUI.M with the given input arguments.
%
%      ADDETDATAGUI('Property','Value',...) creates a new ADDETDATAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before addETdataGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to addETdataGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help addETdataGUI

% Last Modified by GUIDE v2.5 28-Oct-2021 19:18:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @addETdataGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @addETdataGUI_OutputFcn, ...
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


% --- Executes just before addETdataGUI is made visible.
function addETdataGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to addETdataGUI (see VARARGIN)

movegui(handles.fig_addETdataGUI,'center')
params = varargin{1};
handles.params = params;


% changing ETguidedICAparams, if already exists
if isfield(params,'addETdataParams')
    % set(handles.checkbox_firstTrigger, 'Value', params.addETdataParams.checkbox_firstTrigger);

    set(handles.fileext_edit, 'String', params.addETdataParams.fileext_edit);
    set(handles.datafolder_edit, 'String', params.addETdataParams.datafolder_edit);
    set(handles.l_gaze_x_edit, 'String', params.addETdataParams.l_gaze_x_edit);
    set(handles.l_gaze_y_edit, 'String', params.addETdataParams.l_gaze_y_edit);
    set(handles.r_gaze_x_edit, 'String', params.addETdataParams.r_gaze_x_edit);
    set(handles.r_gaze_y_edit, 'String', params.addETdataParams.r_gaze_y_edit);
    set(handles.startTrigger_edit, 'String', params.addETdataParams.startTrigger_edit);
    set(handles.endTrigger_edit, 'String', params.addETdataParams.endTrigger_edit);
    set(handles.screenWidth_edit, 'String', params.addETdataParams.screenWidth_edit);
    set(handles.screenHeight_edit, 'String', params.addETdataParams.screenHeight_edit);
    set(handles.from_edit, 'String', params.addETdataParams.from_edit);
    set(handles.to_edit, 'String', params.addETdataParams.to_edit);
   

end



% Choose default command line output for addETdataGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes addETdataGUI wait for user response (see UIRESUME)
uiwait(handles.fig_addETdataGUI);


% --- Outputs from this function are returned to the command line.
function varargout = addETdataGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

handles.addETdataParams.fileext_edit = get(handles.fileext_edit,'String');
handles.addETdataParams.datafolder_edit = get(handles.datafolder_edit,'String');
handles.addETdataParams.l_gaze_x_edit = get(handles.l_gaze_x_edit,'String');
handles.addETdataParams.l_gaze_y_edit = get(handles.l_gaze_y_edit,'String');
handles.addETdataParams.r_gaze_x_edit = get(handles.r_gaze_x_edit,'String');
handles.addETdataParams.r_gaze_y_edit = get(handles.r_gaze_y_edit,'String');
handles.addETdataParams.startTrigger_edit = get(handles.startTrigger_edit,'String');
handles.addETdataParams.endTrigger_edit = get(handles.endTrigger_edit,'String');
handles.addETdataParams.screenWidth_edit = get(handles.screenWidth_edit,'String');
handles.addETdataParams.screenHeight_edit = get(handles.screenHeight_edit,'String');
handles.addETdataParams.from_edit = get(handles.from_edit,'String');
handles.addETdataParams.to_edit = get(handles.to_edit,'String');

varargout{1} = handles.addETdataParams;

guidata(hObject, handles);
delete(hObject);

% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close('fig_addETdataGUI');

% --- Executes on button press in ok_button.
function ok_button_Callback(hObject, eventdata, handles)
% hObject    handle to ok_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
guidata(hObject, handles);
close('fig_addETdataGUI');

% --- Executes on button press in choose_button.
function choose_button_Callback(hObject, eventdata, handles)
% hObject    handle to choose_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

et_fileext = get(handles.fileext_edit,'String');
if isempty(et_fileext)
    popup_msg('Please specify File Extenson first', 'Error');
    return
end

folder = uigetdir();
if(folder ~= 0)
    slash = filesep;
    folder = strcat(folder,slash);
    
    d=dir(folder);
    d=d(~ismember({d.name},{'.','..', '.DS_Store'}));
    nSub = length(d);
    
    d=dir([folder, '*/', '*', et_fileext]);
    nETfiles = length(d);

    set(handles.datafolder_edit, 'String', folder)
    set(handles.numSubFiles, 'String', [num2str(nSub) ' Subjects and ' num2str(nETfiles) ' ET Files found'])
end

function datafolder_edit_Callback(hObject, eventdata, handles)
% hObject    handle to datafolder_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of datafolder_edit as text
%        str2double(get(hObject,'String')) returns contents of datafolder_edit as a double




% --- Executes during object creation, after setting all properties.
function datafolder_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datafolder_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fileext_edit_Callback(hObject, eventdata, handles)
% hObject    handle to fileext_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileext_edit as text
%        str2double(get(hObject,'String')) returns contents of fileext_edit as a double


% --- Executes during object creation, after setting all properties.
function fileext_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileext_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close fig_addETdataGUI.
function fig_addETdataGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to fig_addETdataGUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
guidata(hObject, handles); 
uiresume()   % resume UI which will trigger the OutputFcn



function endTrigger_edit_Callback(hObject, eventdata, handles)
% hObject    handle to endTrigger_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of endTrigger_edit as text
%        str2double(get(hObject,'String')) returns contents of endTrigger_edit as a double


% --- Executes during object creation, after setting all properties.
function endTrigger_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endTrigger_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function l_gaze_x_edit_Callback(hObject, eventdata, handles)
% hObject    handle to l_gaze_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of l_gaze_x_edit as text
%        str2double(get(hObject,'String')) returns contents of l_gaze_x_edit as a double


% --- Executes during object creation, after setting all properties.
function l_gaze_x_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to l_gaze_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function l_gaze_y_edit_Callback(hObject, eventdata, handles)
% hObject    handle to l_gaze_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of l_gaze_y_edit as text
%        str2double(get(hObject,'String')) returns contents of l_gaze_y_edit as a double


% --- Executes during object creation, after setting all properties.
function l_gaze_y_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to l_gaze_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function r_gaze_y_edit_Callback(hObject, eventdata, handles)
% hObject    handle to r_gaze_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of r_gaze_y_edit as text
%        str2double(get(hObject,'String')) returns contents of r_gaze_y_edit as a double


% --- Executes during object creation, after setting all properties.
function r_gaze_y_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r_gaze_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function r_gaze_x_edit_Callback(hObject, eventdata, handles)
% hObject    handle to r_gaze_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of r_gaze_x_edit as text
%        str2double(get(hObject,'String')) returns contents of r_gaze_x_edit as a double


% --- Executes during object creation, after setting all properties.
function r_gaze_x_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r_gaze_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startTrigger_edit_Callback(hObject, eventdata, handles)
% hObject    handle to startTrigger_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startTrigger_edit as text
%        str2double(get(hObject,'String')) returns contents of startTrigger_edit as a double


% --- Executes during object creation, after setting all properties.
function startTrigger_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startTrigger_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function screenWidth_edit_Callback(hObject, eventdata, handles)
% hObject    handle to screenWidth_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of screenWidth_edit as text
%        str2double(get(hObject,'String')) returns contents of screenWidth_edit as a double


% --- Executes during object creation, after setting all properties.
function screenWidth_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to screenWidth_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function screenHeight_edit_Callback(hObject, eventdata, handles)
% hObject    handle to screenHeight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of screenHeight_edit as text
%        str2double(get(hObject,'String')) returns contents of screenHeight_edit as a double


% --- Executes during object creation, after setting all properties.
function screenHeight_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to screenHeight_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in helpButton.
function helpButton_Callback(hObject, eventdata, handles)
% hObject    handle to helpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('https://github.com/methlabUZH/automagic/wiki/', '-browser');



function from_edit_Callback(hObject, eventdata, handles)
% hObject    handle to from_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of from_edit as text
%        str2double(get(hObject,'String')) returns contents of from_edit as a double


% --- Executes during object creation, after setting all properties.
function from_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to from_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function to_edit_Callback(hObject, eventdata, handles)
% hObject    handle to to_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of to_edit as text
%        str2double(get(hObject,'String')) returns contents of to_edit as a double


% --- Executes during object creation, after setting all properties.
function to_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to to_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
