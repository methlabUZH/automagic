%% This script starts Automagic

automagic = 'automagic'; % Folder name of automagic
srcFolder = 'src/';
mainGuiFile = 'mainGUI';
addpath('.');
if ispc
    slash = '\';
    seperator = ';';
else
    slash = '/';
    seperator = ':';
end
matlabPaths = matlabpath;
parts = strsplit(matlabPaths, seperator);
Index = not(~contains(parts, automagic));
automagicPath = parts{Index};
path = [automagicPath slash];
addpath(path);
addpath([path srcFolder])

Project.addAutomagicPaths();
run(mainGuiFile)

