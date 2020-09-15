function bool = is_filtered(handles, file)
%is_filtered Check whether this file is filtered by the user
%   handles  structure with handles of the gui
%   file     could be a double indicating the index of the file or a char
%          indicating the name of it
project = handles.project;
if( project.current == -1)
    bool = true;
    return;
end

project = handles.project;
switch class(file)
    case 'double'
        unique_name = project.processedList{file};
    case 'char'
        unique_name = file;
end

block = project.blockMap(unique_name);
rate = block.rate;
switch rate
    case handles.CGV.RATINGS.Good
        bool = ~ get(handles.goodcheckbox,'Value');
    case handles.CGV.RATINGS.OK
        bool = ~ get(handles.okcheckbox,'Value');
    case handles.CGV.RATINGS.Bad
        bool = ~ get(handles.badcheckbox,'Value');
    case handles.CGV.RATINGS.Interpolate
        bool = ~ get(handles.interpolatecheckbox,'Value');
    case handles.CGV.RATINGS.NotRated
        bool = ~ get(handles.notratedcheckbox,'Value');
    otherwise
        bool = false;
end