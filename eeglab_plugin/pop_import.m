function [com, ALLEEG, EEG, CURRENTSET] = pop_import(ALLEEG)
% pop up a window allowing user to select which results to import. 
%
% Usage:
%   >> ALLEEG = pop_import(ALLEEG);
%
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

% ------------------------------------


params = ImportParams({});
waitfor(importResultsGUI(params));

project = params.project;
selectedList = params.selectedList;
for i = 1:length(selectedList)
   fileName = selectedList{i};
   block = project.blockMap(fileName);
   block.updateAddresses(project.dataFolder, project.resultFolder);
   filePath = block.resultAddress;
   
   preprocessed = matfile(filePath,'Writable',true);
   EEG = preprocessed.EEG;
   EEG.setname = fileName;
   automagic = preprocessed.automagic;
   EEG.automagic = automagic;
   
   [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
end

% return the string command
% -------------------------
com = sprintf('[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);');
