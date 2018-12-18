classdef ImportParams < handle
    %ImportParams is a class acting as a parameter passed between EEGLAB
    %and Automagic. 
    %
    %   This is specifically useful because of being an instance of the
    %   class `handle` which allows Automagic gui to manipulate the
    %   attributes of the class. Then this changes occur also in the EEGLAB
    %   instace of the class.
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
	properties
        % The project from which preprocessed files are selected to be
        % imported
        project
        
        % List of the preprocessed files selected in the GUI to be imported
		selectedList
	end
	
	methods
		function self = ImportParams(selectedList)
			self.selectedList = selectedList;
		end
	end
end