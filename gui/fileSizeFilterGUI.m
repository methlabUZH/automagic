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

% Last Modified by GUIDE v2.5 09-Dec-2019 14:38:17

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
set(handles.dataedit,'enable','off');
set(handles.MADedit,'enable','off');
set(handles.IQRedit,'enable','off');
if isfield(params,'filesizeParams')
    set(handles.dataedit, 'String', params.filesizeParams.absThresh);
    set(handles.absCheckbox, 'Value', params.filesizeParams.absCheckbox);
    set(handles.MADcheckbox, 'Value', params.filesizeParams.MADcheckbox);
    set(handles.IQRcheckbox, 'Value', params.filesizeParams.IQRcheckbox);
    set(handles.IQRedit, 'String', params.filesizeParams.IQRedit);
    set(handles.MADedit, 'String', params.filesizeParams.MADedit);
    if params.filesizeParams.absCheckbox == 1
        set(handles.dataedit,'enable','on');
    end
    if params.filesizeParams.MADcheckbox == 1
        set(handles.MADedit,'enable','on');
    end
    if params.filesizeParams.IQRcheckbox == 1
        set(handles.IQRedit,'enable','on');
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
varargout{1} = get(handles.dataedit, 'String');
varargout{2} = get(handles.absCheckbox, 'Value');
varargout{3} = get(handles.MADcheckbox, 'Value');
varargout{4} = get(handles.IQRcheckbox, 'Value');
varargout{5} = (varargout{2}|varargout{3}|varargout{4});
varargout{6} = get(handles.MADedit, 'String');
varargout{7} = get(handles.IQRedit, 'String');
guidata(hObject, handles);
delete(handles.figure1);

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

% --- Executes on button press in boxplotButton.
function boxplotButton_Callback(hObject, eventdata, handles)
% hObject    handle to okpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% slash = filesep;
% if ~ contains(get(handles.dataedit, 'String'), slash)
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
% set(handles.dataedit, 'String', '');
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

% --- Executes on button press in absCheckbox.
function absCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to absCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.absCheckbox,'Value')
    set(handles.dataedit,'enable','on');
else
    set(handles.dataedit,'enable','off');
end
% Hint: get(hObject,'Value') returns toggle state of absCheckbox

% --- Executes on button press in MADcheckbox.
function MADcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to MADcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.MADcheckbox,'Value')
    set(handles.MADedit,'enable','on');
else
    set(handles.MADedit,'enable','off');
end
% Hint: get(hObject,'Value') returns toggle state of MADcheckbox

% --- Executes on button press in derivativesBVAcheckbox.
function IQRcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to derivativesBVAcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.IQRcheckbox,'Value')
    set(handles.IQRedit,'enable','on');
else
    set(handles.IQRedit,'enable','off');
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
fileSizeList = [];
subjFolders = dir(resultsFolder);
for subj = 3 : size(subjFolders,1)
    subjName = subjFolders(subj).name;
    filepath = [resultsFolder subjName];
    subjFiles = dir(filepath);
    for file = 3 : size(subjFiles,1)
        filename = subjFiles(file).name;
        exten = handles.params.extedit.String;
        fileSize = subjFiles(file).bytes;
        if contains(filename,exten)
        fileSizeList = [fileSizeList; fileSize];
        end
    end
end
fileSizeList = fileSizeList/10e5;
absThresh = get(handles.dataedit, 'String');
absCase = get(handles.absCheckbox, 'Value');
madCase = get(handles.MADcheckbox, 'Value');
iqrCase = get(handles.IQRcheckbox, 'Value');
IQRquantile = get(handles.IQRedit, 'String');
MADscalar = get(handles.MADedit, 'String');
IQRquantile = str2double(IQRquantile)/100;
MADscalar = str2double(MADscalar);
absThresh = str2double(absThresh);
if isempty(absThresh)
    absThresh = 0;
    set(handles.dataedit,'String', '0');
end
if isempty(MADscalar)
    MADscalar = 0;
    set(handles.MADedit,'String', '0');
end
if isempty(IQRquantile)
    IQRquantile = 0;
    set(handles.IQRedit,'String', '0');
end
if absCase
    absList = fileSizeList<=absThresh;
else
    absList = zeros(numel(fileSizeList),1);
end    
if madCase
    madThr = MADscalar*mad(fileSizeList,1); % median 
    madList = fileSizeList<=madThr+median(fileSizeList);
else
    madList = zeros(numel(fileSizeList),1);    
end
if iqrCase
    iqrThr = [quantile(fileSizeList,IQRquantile),quantile(fileSizeList,(1-IQRquantile))];
    iqrList = [fileSizeList<=iqrThr(:,1),fileSizeList>=iqrThr(:,2)];
    iqrList = iqrList(:,1)|iqrList(:,2);
else
    iqrList = zeros(numel(fileSizeList),1);    
end
exclusionList = absList | madList | iqrList;
percentLost = num2str(100*sum(exclusionList)/length(exclusionList));
set(handles.percentLost,'String',percentLost);


% --- Executes on button press in createHistogram.
function createHistogram_Callback(hObject, eventdata, handles)
% hObject    handle to createHistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
resultsFolder = handles.resultsfolder{1};
fileSizeList = [];
subjFolders = dir(resultsFolder);
for subj = 3 : size(subjFolders,1)
    subjName = subjFolders(subj).name;
    filepath = [resultsFolder subjName];
    subjFiles = dir(filepath);
    for file = 3 : size(subjFiles,1)
        fileSize = subjFiles(file).bytes;
        fileSizeList = [fileSizeList; fileSize];
    end
end
figure;
histogram(fileSizeList/10e6);
ylabel('Frequency');
xlabel('File Size (MBytes)');
title('Histogram of whole dataset file sizes');



function IQRedit_Callback(hObject, eventdata, handles)
% hObject    handle to IQRedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IQRedit as text
%        str2double(get(hObject,'String')) returns contents of IQRedit as a double

% --- Executes during object creation, after setting all properties.
function IQRedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IQRedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function MADedit_Callback(hObject, eventdata, handles)
% hObject    handle to MADedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of MADedit as text
%        str2double(get(hObject,'String')) returns contents of MADedit as a double


% --- Executes during object creation, after setting all properties.
function MADedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MADedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

