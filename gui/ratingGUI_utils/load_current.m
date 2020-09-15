function [handles, data] = load_current(handles, getReduced) %#ok<STOUT>
%load_current Load the current "reduced" file to the work space (The file is 
% downsampled to speed up the loading)
%   handles   structure with handles of the gui
%   getReduced  a bool indicating to load the reduced file instead of the
%   original file

project = handles.project;
if ( project.current == - 1 || is_filtered(handles, project.current))
    data = [];
else
    block = project.getCurrentBlock();
    if(isa(block, 'Block'))
        block.updateAddresses(project.dataFolder, project.resultFolder);
        if(getReduced)
            load(block.reducedAddress);
            data = reduced;
        else
            load(block.resultAddress);
            data.data = EEG.data;
            data.srate = EEG.srate;
            data.chanlocs = EEG.chanlocs;
            data.event = EEG.event;
        end
    elseif(isa(block, 'EEGLabBlock'))
        data = block.getReduced();
    end
    handles.project.maxX = max(project.maxX, size(data.data, 2));% for the plot
end