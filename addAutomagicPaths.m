function addAutomagicPaths()

automagic = 'automagic'; % Folder name of automagic
libName = 'matlab_scripts'; 
srcFolder = 'src'; 
guiFolder = 'gui';
preproFolder = 'preprocessing';
pluginFolder = 'eeglab_plugin';

addpath(['.' filesep])
matlabPaths = matlabpath;
parts = strsplit(matlabPaths, pathsep);
Index = not(~contains(parts, automagic));
automagicPath = parts{Index};
if ~strcmp(automagicPath(end), filesep)
    automagicPath = strcat(automagicPath, filesep);
end
automagicPath = regexp(automagicPath, ['.*' automagic '.*?' filesep], 'match');
automagicPath = automagicPath{1};
if ~strcmp(automagicPath(end), filesep)
    automagicPath = strcat(automagicPath, filesep);
end
addpath(automagicPath);
addpath([automagicPath srcFolder filesep])
addpath([automagicPath guiFolder filesep])
addpath([automagicPath preproFolder filesep])
addpath([automagicPath libName filesep])
addpath([automagicPath pluginFolder filesep])
