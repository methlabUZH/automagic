function addAutomagicPaths()
% addAutomagicPaths  Add all the necessary paths to start up Automagic
%   This is specially recommended over `addpath(genpath(path/to/automagic))`
%   as it will avoid to add conflicting functions of EEGLAB.
%
% Copyright (C) 2018  Amirreza Bahreini, methlabuzh@gmail.com
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

automagicPath= fileparts(mfilename('fullpath'));
addpath(automagicPath)
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


pathCheck{1}=automagicPath;
pathCheck{2}=[automagicPath srcFolder filesep];
pathCheck{3}=[automagicPath guiFolder filesep];
pathCheck{4}=[automagicPath preproFolder filesep];
pathCheck{5}=[automagicPath libName filesep];
pathCheck{6}=[automagicPath pluginFolder filesep];
matlabPaths = matlabpath;
parts = strsplit(matlabPaths, pathsep);
Index = contains(parts, pathCheck);
if sum(Index)<5
    warning('You need to include Automagic in your matlab path');
end

disp('Checking required toolbooxes...')
toolboxes = ver;
toolboxes(8:10) = [];
% Check that user has the Signal Processing Toolbox installed.
hasIPT = license('test', 'Signal_Toolbox');
if ~any(ismember({toolboxes.Name}, 'Signal Processing Toolbox'))    

  % User does not have the toolbox installed.
  message = sprintf(['Sorry, but you do not seem to have the Signal Processing Toolbox.' ...
                     '\nSome important functions might be missing which will result in error.' ...
                     '\nDo you want to try to continue anyway?']);
  reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
  if strcmpi(reply, 'No')
    % User said No, so exit.
    return;
  end

else
    disp('Signal Processing Toolbox installed...')
end


% Check that user has the Statistics and Machine Learning Toolbox installed.
hasIPT = license('test', 'Statistics_Toolbox');
if ~any(ismember({toolboxes.Name}, 'Statistics and Machine Learning Toolbox')) 

  % User does not have the toolbox installed.
  message = sprintf(['Sorry, but you do not seem to have the Statistics and Machine Learning Toolbox.' ...
                     '\nSome important functions might be missing which will result in error.' ...
                     '\nDo you want to try to continue anyway?']);
  reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
  if strcmpi(reply, 'No')
    % User said No, so exit.
    return;
  end

else
    disp('Statistics and Machine Learning Toolbox installed...')
end

% Check that user has the Parallel Computing Toolbox installed.

hasIPT = license('test', 'Distrib_Computing_Toolbox');
if ~any(ismember({toolboxes.Name}, 'Parallel Computing Toolbox  ')) 

  % User does not have the toolbox installed.
  message = sprintf(['Sorry, but you do not seem to have the Parallel Computing Toolbox.' ...
                     '\nSome preprocessing steps might take longer.' ...
                     '\nDo you want to try to continue anyway?']);
  reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
  if strcmpi(reply, 'No')
    % User said No, so exit.
    return;
  end

else
    disp('Parallel Computing Toolbox installed...')
end

disp('Starting Automagic... First time takes longer...')
