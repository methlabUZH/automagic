function mark_interpolated_chans(handles)
%mark_interpolated_chans  Draw a star * on the plot to show the channels 
% that have been selected as bad channels during the preprocessing step. 
% Note that they are not necessary interpolated.
%   handles  structure with handles of the gui

project = handles.project;
if(project.current == -1)
    return;
end
block = project.getCurrentBlock();
badchans = block.autoBadChans;
axe = handles.axes;
axes(axe);
hold on;
for i = 1:length(badchans)
    plot(0 , badchans(i),'r*')
end
hold off;