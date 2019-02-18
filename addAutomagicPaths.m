function addAutomagicPaths()
% addAutomagicPaths  Add all the necessary paths to start up Automagic
%   This is specially recommended over `addpath(genpath(path/to/automagic))`
%   as it will avoid to add conflicting functions of EEGLAB.
%
% Copyright (C) 2018  Amirreza Bahreini, amirreza.bahreini@uzh.ch
%
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% strings below correspond to current folders of Automagic
automagic = 'automagic';
libName = 'matlab_scripts'; 
srcFolder = 'src'; 
guiFolder = 'gui';
preproFolder = 'preprocessing';
pluginFolder = 'eeglab_plugin';

addpath(['.' filesep])
matlabPaths = matlabpath;
parts = strsplit(matlabPaths, pathsep);
Index = contains(parts, automagic);
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
