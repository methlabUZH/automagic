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

addAutomagicPaths();

% Create the menu and its submenues
% ------------------------------------
start_command = '[com] = pop_automagic();';
import_command = '[com, ALLEEG, EEG, CURRENTSET] = pop_import(ALLEEG);';
import_command = [import_command 'eeglab redraw;'];

main = uimenu( fig, 'label', 'Automagic');
uimenu( main, 'label', 'Open Automagic...', 'callback', start_command);
uimenu( main, 'label', 'Import Automagic results...', 'callback', import_command);