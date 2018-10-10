function parts = addEEGLab()
% addEEGLab  Add the eeglab package to the path
%   eeglab package is assumed to be in folder matlab_scripts located in the
%   parent directory. The need for this function is to remove the path to
%   few folders of eeglab which make conflicts with other MATLAB functions.
%   
%   parts = addEEGLab()
%
%   parts: TODO
%
% Copyright (C) 2017  Amirreza Bahreini, amirreza.bahreini@uzh.ch
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


% System dependence:
if(ispc)
    slash = '\';
else
    slash = '/';
end

matlab_paths = genpath(['..' slash 'matlab_scripts' slash]);
if(ispc)
    parts = strsplit(matlab_paths, ';');
else
    parts = strsplit(matlab_paths, ':');
end

% Exclude paths which create conflicts
Index = not(~contains(parts, 'compat'));
parts(Index) = [];
Index = not(~contains(parts, 'neuroscope'));
parts(Index) = [];
Index = not(~contains(parts, 'dpss'));
parts(Index) = [];
if(ispc)
    matlab_paths = strjoin(parts, ';');
else
    matlab_paths = strjoin(parts, ':');
end
addpath(matlab_paths);
    
end