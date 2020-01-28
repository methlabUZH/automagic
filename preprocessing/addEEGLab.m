function parts = addEEGLab()
% addEEGLab  Add the eeglab package to the path
%   eeglab package is assumed to be in folder matlab_scripts located in the
%   parent directory. The need for this function is to remove the path to
%   few folders of eeglab which make conflicts with other MATLAB functions.
%   This functions is strongly recommended over the use of
%   `addpath(genpath('path/to/eeglab'))`.
%
%   parts = addEEGLab()
%
%   parts: all the paths in EEGLAB folder. This is returned for the cases
%   where it is needed.
%
% Copyright (C) 2017  Amirreza Bahreini, methlabuzh@gmail.com
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

if ~ exist('eeglab', 'file')
    
    CSTS = PreprocessingConstants;
    ZIPName = CSTS.EEGLabCsts.ZIP;
    libraryPath = CSTS.LIBRARY_PATH;

    parts = strsplit(ZIPName, '.zip');
    folderName = parts{1};

    folderName = [libraryPath folderName];
    ZIPName = [libraryPath ZIPName];

    if ~ exist(folderName, 'dir')
        unzip(ZIPName, libraryPath);
    end
    
else
    folderName = fileparts(which('eeglab'));
end
eeglab_paths = genpath(folderName);

parts = strsplit(eeglab_paths, pathsep);
% Exclude paths which create conflicts
Index = contains(parts, 'compat');
parts(Index) = [];
Index = contains(parts, 'neuroscope');
parts(Index) = [];
Index = contains(parts, 'dpss');
parts(Index) = [];
Index = contains(parts, 'maybe-missing');
parts(Index) = [];
Index = contains(parts, 'NaN');
parts(Index) = [];
Index = contains(parts, 't400_Classification');
parts(Index) = [];
eeglab_paths = strjoin(parts, pathsep);
addpath(eeglab_paths);
    
end