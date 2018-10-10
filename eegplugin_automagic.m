function eegplugin_automagic(fig, try_strings, catch_strings)
% Create the menu 'automagic' and three submenus for preprocessing, rating
% and interpolating respectively. See Documentation to find out more about
% each of these steps.
%
% Usage:
%   >> eegplugin_automagic(fig, trystrs, catchstrs);
%
% Inputs:
%   fig        - [integer] eeglab figure.
%   trystrs    - [struct] "try" strings for menu callbacks.
%   catchstrs  - [struct] "catch" strings for menu callbacks.
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

% display help if not enough arguments
% ------------------------------------
if nargin < 3
    error('eegplugin_automagic requires 3 arguments');
end


% Add all files of the automagic to path. EEGLAB must be already set to
% matlab path.
% ------------------------------------
matlab_paths = matlabpath;
if(ispc)
    parts = strsplit(matlab_paths, ';');
else
    parts = strsplit(matlab_paths, ':');
end
IndexC = strfind(parts, 'automagic');
Index = not(cellfun('isempty', IndexC));
automagic_path = parts{Index};
automagic_path = genpath(automagic_path);
if(ispc)
    parts = strsplit(automagic_path, ';');
else
    parts = strsplit(automagic_path, ':');
end
IndexC = strfind(parts, 'matlab_scripts/eeglab');
Index = not(cellfun('isempty', IndexC));
parts(Index) = [];
if(ispc)
    automagic_path = strjoin(parts, ';');
else
    automagic_path = strjoin(parts, ':');
end
addpath(automagic_path);

% Create the menu and its submenues
% ------------------------------------
processing_command = ...
    [ try_strings.check_chanlocs '[EEG, com] = pop_parameters(EEG);' catch_strings.store_and_hist ];
rating_command = ...
    [ try_strings.no_check '[EEG, com] = pop_rating(ALLEEG);' catch_strings.store_and_hist ];
interpolate_command = ...
    [ try_strings.check_chanlocs '[EEG, com] = pop_interpolate(ALLEEG);' catch_strings.store_and_hist ];

main = uimenu( fig, 'label', 'Automagic');
uimenu( main, 'label', 'Start preprocessing...', 'callback', processing_command);
uimenu( main, 'label', 'Start manual rating...', 'callback', rating_command);
uimenu( main, 'label', 'Start interpolation...', 'callback', interpolate_command);