function varargout = TrimOutlierGUI(varargin)
% TRIMOUTLIERGUI MATLAB code for TrimOutlierGUI.fig
%      TRIMOUTLIERGUI, by itself, creates a new TRIMOUTLIERGUI or raises the existing
%      singleton*.
%
%      H = TRIMOUTLIERGUI returns the handle to a new TRIMOUTLIERGUI or the handle to
%      the existing singleton*.
%
%      TRIMOUTLIERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRIMOUTLIERGUI.M with the given input arguments.
%
%      TRIMOUTLIERGUI('Property','Value',...) creates a new TRIMOUTLIERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TrimOutlierGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TrimOutlierGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TrimOutlierGUI

% Last Modified by GUIDE v2.5 05-Oct-2020 08:53:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TrimOutlierGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @TrimOutlierGUI_OutputFcn, ...
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


% --- Executes just before TrimOutlierGUI is made visible.
function TrimOutlierGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TrimOutlierGUI (see VARARGIN)

movegui(handles.figure1,'center')
params = varargin{1};
handles.params = params;

% changing trimDataParams, if already exists
if isfield(params,'TrimOutlierParams')
    set(handles.edit_AmpTresh, 'String', params.TrimOutlierParams.AmpTresh);
    set(handles.edit_rejRange, 'String', params.TrimOutlierParams.rejRange);   
end

% Choose default command line output for TrimOutlierGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TrimOutlierGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TrimOutlierGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = get(handles.edit_AmpTresh, 'String');
varargout{2} = get(handles.edit_rejRange, 'String');

guidata(hObject, handles);
delete(handles.figure1);


% --- Executes on button press in OKButton.
function OKButton_Callback(hObject, eventdata, handles)
% hObject    handle to OKButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);
close('Trim Outlier');


% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close('Trim Outlier');



function edit_AmpTresh_Callback(hObject, eventdata, handles)
% hObject    handle to edit_AmpTresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_AmpTresh as text
%        str2double(get(hObject,'String')) returns contents of edit_AmpTresh as a double


% --- Executes during object creation, after setting all properties.
function edit_AmpTresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_AmpTresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rejRange_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rejRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rejRange as text
%        str2double(get(hObject,'String')) returns contents of edit_rejRange as a double


% --- Executes during object creation, after setting all properties.
function edit_rejRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rejRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%delete(hObject);
guidata(hObject, handles);  % Store the outputs in the GUI
uiresume()   % resume UI which will trigger the OutputFcn
