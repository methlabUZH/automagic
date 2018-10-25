%% This script starts Automagic

if ispc
    slash = '\';
    seperator = ';';
else
    slash = '/';
    seperator = ':';
end
automagic = 'automagic'; % Folder name of automagic
libName = 'matlab_scripts'; 
srcFolder = 'src'; 
guiFolder = 'gui';
preproFolder = 'preprocessing';

matlabPaths = matlabpath;
parts = strsplit(matlabPaths, seperator);
Index = not(~contains(parts, automagic));
automagicPath = parts{Index};
automagicPath = regexp(automagicPath, ['.*' automagic], 'match');
automagicPath = automagicPath{1};
automagicPath = [automagicPath slash];
addpath(automagicPath);
addpath([automagicPath srcFolder])
addpath([automagicPath guiFolder])
addpath([automagicPath preproFolder])
addpath([automagicPath libName])

run(mainGuiFile)

