function handles = show_current(reduced, average_reference, handles)
%show_current Make the plot of the current file
% handles  structure with handles of the gui
% reduced  data file to be plotted
% average_reference bool specifying if average referencing should be
% performed or not

if isfield(reduced, 'data')
    data = reduced.data;
    project = handles.project;
    colorScale = project.colorScale;
    unique_name = project.processedList{project.current};
else
    data = [];
    unique_name = 'no image';
    defVis = handles.CGV.DefaultVisualisationParams;
    colorScale = defVis.COLOR_SCALE; 
end


axe = handles.axes;
cla(axe);

% Averange reference data before plotting
if( average_reference && ~isempty(data))
    data_size = size(data);
    data = data - repmat(nanmean(data, 1), data_size(1), 1);
end

% find colormap selected
if strcmp(project.params.Settings.colormap,'Default')
    CT = 'jet';
else
    cm = project.params.Settings.colormap;
    [~,CT]=evalc('cbrewer(''div'', cm, 64)');
end

im = imagesc(data, 'tag', 'im');
set(im, 'ButtonDownFcn', {@on_selection,handles}, 'AlphaData',~isnan(data))
set(gcf, 'Color', [0.94,0.94,0.94])
colormap(CT)
caxis([-colorScale colorScale])
set(handles.titletext, 'String', unique_name) 
xlabel(axe, 'Time points')
ylabel(axe, 'Channel indices')

draw_lines(handles);
mark_interpolated_chans(handles)