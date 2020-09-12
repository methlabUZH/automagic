function varargout = fileSizeFilterGUI(varargin)
% fileSizeFilterGUI MATLAB code for fileSizeFilterGUI.fig
%      fileSizeFilterGUI, by itself, creates a new fileSizeFilterGUI or raises the existing
%      singleton*.
%
%      H = fileSizeFilterGUI returns the handle to a new fileSizeFilterGUI or the handle to
%      the existing singleton*.
%
%      fileSizeFilterGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in fileSizeFilterGUI.M with the given input arguments.
%
%      fileSizeFilterGUI('Property','Value',...) creates a new fileSizeFilterGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fileSizeFilterGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fileSizeFilterGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fileSizeFilterGUI

% Last Modified by GUIDE v2.5 08-Sep-2020 17:08:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fileSizeFilterGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @fileSizeFilterGUI_OutputFcn, ...
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


% --- Executes just before fileSizeFilterGUI is made visible.
function fileSizeFilterGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fileSizeFilterGUI (see VARARGIN)

movegui(handles.figure1,'center')
handles.resultsfolder = varargin{1};
params = varargin{2};
handles.params = params;
set(handles.edit_MAD,'enable','off');
set(handles.edit_IQR,'enable','off');
set(handles.edit_MAX,'enable','off');
set(handles.edit_MIN,'enable','off');
% changing filesizeParams, if already exists
if isfield(params,'filesizeParams')
    set(handles.checkbox_MAD, 'Value', params.filesizeParams.checkbox_MAD);
    set(handles.checkbox_IQR, 'Value', params.filesizeParams.checkbox_IQR);
    set(handles.checkbox_MAX, 'Value', params.filesizeParams.checkbox_MAX);
    set(handles.checkbox_MIN, 'Value', params.filesizeParams.checkbox_MIN);
    
    set(handles.edit_MAD, 'String', params.filesizeParams.edit_MAD);
    set(handles.edit_IQR, 'String', params.filesizeParams.edit_IQR);
    set(handles.edit_MAX, 'String', params.filesizeParams.edit_MAX);
    set(handles.edit_MIN, 'String', params.filesizeParams.edit_MIN);
    
    if params.filesizeParams.checkbox_MAD == 1
        set(handles.edit_MAD,'enable','on');
    end
    if params.filesizeParams.checkbox_IQR == 1
        set(handles.edit_IQR,'enable','on');
    end
    if params.filesizeParams.checkbox_MAX == 1
        set(handles.edit_MAX,'enable','on');
    end
    if params.filesizeParams.checkbox_MIN == 1
        set(handles.edit_MIN,'enable','on');
    end
end
% Choose default command line output for fileSizeFilterGUI
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%UIWAIT makes fileSizeFilterGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fileSizeFilterGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure

% this values are passed to mainGUI
varargout{1} = get(handles.checkbox_MAD, 'Value');
varargout{2} = get(handles.checkbox_IQR, 'Value');
varargout{3} = get(handles.checkbox_MAX, 'Value');
varargout{4} = get(handles.checkbox_MIN, 'Value');

varargout{5} = (varargout{1}|varargout{2}|varargout{3}|varargout{4});

varargout{6} = get(handles.edit_MAD, 'String');
varargout{7} = get(handles.edit_IQR, 'String');
varargout{8} = get(handles.edit_MAX, 'String');
varargout{9} = get(handles.edit_MIN, 'String');

guidata(hObject, handles);
delete(handles.figure1);

function edit_MAD_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MAD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MAD as text
%        str2double(get(hObject,'String')) returns contents of edit_MAD as a double


% --- Executes during object creation, after setting all properties.
function edit_MAD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MAD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in boxplotButton.
function boxplotButton_Callback(hObject, eventdata, handles)
% hObject    handle to okpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% slash = filesep;
% if ~ contains(get(handles.edit_MAD, 'String'), slash)
%     return;
% end
filesizeboxplotter(handles);

% --- Executes on button press in okpushbutton.
function okpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to okpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(hObject, handles);
close('File Size Filter');

% --- Executes on button press in cancelpushbutton.
function cancelpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% set(handles.edit_MAD, 'String', '');
close('File Size Filter');

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

% --- Executes on button press in checkbox_MAX.
function checkbox_MAX_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_MAX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.checkbox_MAX,'Value')
    set(handles.edit_MAX,'enable','on');
else
    set(handles.edit_MAX,'String', '0');
    set(handles.edit_MAX,'enable','off');
end
% Hint: get(hObject,'Value') returns toggle state of checkbox_MAX

% --- Executes on button press in checkbox_MAD.
function checkbox_MAD_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_MAD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.checkbox_MAD,'Value')
    set(handles.edit_MAD,'enable','on');
else
    set(handles.edit_MAD,'String', '0');
    set(handles.edit_MAD,'enable','off');  
end
% Hint: get(hObject,'Value') returns toggle state of checkbox_MAD

% --- Executes on button press in derivativesBVAcheckbox.
function checkbox_IQR_Callback(hObject, eventdata, handles)
% hObject    handle to derivativesBVAcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.checkbox_IQR,'Value')
    set(handles.edit_IQR,'enable','on');
else
    set(handles.edit_IQR,'String', '0');
    set(handles.edit_IQR,'enable','off');
end
% Hint: get(hObject,'Value') returns toggle state of derivativesBVAcheckbox

function percentLost_Callback(hObject, eventdata, handles)
% hObject    handle to percentLost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of percentLost as text
%        str2double(get(hObject,'String')) returns contents of percentLost as a double


% --- Executes during object creation, after setting all properties.
function percentLost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to percentLost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in calculatePushbutton.
function calculatePushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to calculatePushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
resultsFolder = handles.resultsfolder{1};
ext = handles.params.extedit.String;
fileSizeList = [];
subjFolders = dir(resultsFolder);
slash = filesep;

for subj = 3 : size(subjFolders,1)
    subjName = subjFolders(subj).name;
    filepath = [resultsFolder subjName];
    subjFiles = dir([filepath slash '*' ext]);
    
    for file = 1 : size(subjFiles,1)
        fileSize = subjFiles(file).bytes/1e+6;
        fileSizeList = [fileSizeList; fileSize];
    end
end
% round MB
fileSizeList = round(fileSizeList,3,'significant');
% get the values and change to double
MADvalue = str2double(get(handles.edit_MAD, 'String'));
IQRvalue = str2double(get(handles.edit_IQR, 'String'));
MAXvalue = str2double(get(handles.edit_MAX, 'String'));
MINvalue = str2double(get(handles.edit_MIN, 'String'));
% get the state of the checkboxes
MAXCase = get(handles.checkbox_MAX, 'Value');
MADCase = get(handles.checkbox_MAD, 'Value');
IQRCase = get(handles.checkbox_IQR, 'Value');
MINCase = get(handles.checkbox_MIN, 'Value');
% change values to 0, if not selected
if isempty(MADvalue)
    MADvalue = 0;
    set(handles.edit_MAD,'String', '0');
end
if isempty(MAXvalue)
    MAXvalue = 0;
    set(handles.edit_MAX,'String', '0');
end
if isempty(IQRvalue)
    IQRvalue = 0;
    set(handles.edit_IQR,'String', '0');
end
if isempty(MINvalue)
    MINvalue = 0;
    set(handles.edit_MIN,'String', '0');
end
% create lists to exclude files with unwanted size
if MINCase
    MIN_List = fileSizeList <= MINvalue;
else
    MIN_List = zeros(numel(fileSizeList),1);
end
if MAXCase
    MAX_List = fileSizeList >= MAXvalue;
else
    MAX_List = zeros(numel(fileSizeList),1);
end
if MADCase
    m = mad(fileSizeList,1,1); % median absolute devations
    med = median(fileSizeList,1); % median of data
    MAD_List = fileSizeList <= med - (m * MADvalue) | fileSizeList >= med + (m * MADvalue);
else
    MAD_List = zeros(numel(fileSizeList),1);    
end
if IQRCase
    P = IQRvalue/100;
    M = 0.5;
    T = M + P/2; % John: my back-of-the-envelope equations. See diary entry date 30/3/2020
    t = quantile(fileSizeList,T);
    Q = M - P/2;
    q = quantile(fileSizeList,Q);
    iqrThr = [q,t];
    IQR_List = [fileSizeList <= iqrThr(1),fileSizeList >= iqrThr(2)];
    IQR_List = IQR_List(:,1) | IQR_List(:,2);
else
    IQR_List = zeros(numel(fileSizeList),1);    
end

exclusionList = MIN_List | MAX_List | MAD_List | IQR_List;

percentLost = num2str(100*sum(exclusionList)/length(exclusionList));
set(handles.percentLost,'String',percentLost);


% --- Executes on button press in createHistogram.
function createHistogram_Callback(hObject, eventdata, handles)
% hObject    handle to createHistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
resultsFolder = handles.resultsfolder{1};
ext = handles.params.extedit.String;
fileSizeList = [];
subjFolders = dir(resultsFolder);
slash = filesep;

for subj = 3 : size(subjFolders,1)
    subjName = subjFolders(subj).name;
    filepath = [resultsFolder subjName];
    subjFiles = dir([filepath slash '*' ext]);
    
    for file = 1 : size(subjFiles,1)
        fileSize = subjFiles(file).bytes/1e+6;
        fileSizeList = [fileSizeList; fileSize];
    end
end
fileSizeList = round(fileSizeList,3,'significant');

[bins,edges] = histcounts(fileSizeList,'BinMethod','fd');

figure;
histogram(fileSizeList, size(bins, 2)*2);
ylabel('Frequency');
xlabel('File Size (MBytes)');
title('Histogram of whole dataset file sizes');



function edit_MIN_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MIN as text
%        str2double(get(hObject,'String')) returns contents of edit_MIN as a double

% --- Executes during object creation, after setting all properties.
function edit_MIN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_MAX_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MAX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edit_MAX as text
%        str2double(get(hObject,'String')) returns contents of edit_MAX as a double


% --- Executes during object creation, after setting all properties.
function edit_MAX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MAX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_MIN.
function checkbox_MIN_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_MIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.checkbox_MIN,'Value')
    set(handles.edit_MIN,'enable','on');
else
    set(handles.edit_MIN,'String', '0');
    set(handles.edit_MIN,'enable','off');
end
% Hint: get(hObject,'Value') returns toggle state of checkbox_MIN



function edit_IQR_Callback(hObject, eventdata, handles)
% hObject    handle to edit_IQR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_IQR as text
%        str2double(get(hObject,'String')) returns contents of edit_IQR as a double


% --- Executes during object creation, after setting all properties.
function edit_IQR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_IQR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
