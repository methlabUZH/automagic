function [com] = pop_start()
% Opens up the Automagic. 
%
% Usage:
%   >> EEG = pop_rating ( EEG );
%
% Inputs:
%   EEG     - EEGLab EEG structure where the data has been already
%   preprocessed.
%
% Outputs:
%   EEG     -  EEGLab EEG structure where the field EEG.automagic is
%   modified to have new information about ratings.
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

% ------------------------------------
waitfor(RunAutomagic);


% return the string command
% -------------------------
com = sprintf('pop_start()');
