function [EEG, EOG] = performTrimData(EEG, EOG, TrimDataParams)

% performTrimData  trims EEG data 
%
%   [data] = performTrimData(data, TrimDataParams) where data is the EEGLAB data
%   structure. TrimDataParams is an parameter which must be a structure.
%   
%
%   An example of the TrimDataParams is as below:
%
%   TrimDataParams = struct('checkbox_firstTrigger', 1, ...   
%                   'checkbox_lastTrigger', 0, ...
%                   'changeCheck', 1, ...
%                   'edit_firstTrigger', '41', ...
%                   'edit_lastTrigger', '50');
%                   'edit_paddingFirst', '-500', ...
%                   'edit_paddingLast', '300');
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

% in case EEG has a 'sample' events instead of 'latency'
if isfield(EEG.event, 'sample')
    [EEG.event.latency] = EEG.event.sample;
end

% extract vars
firstTrigger = TrimDataParams.edit_firstTrigger;
lastTrigger = TrimDataParams.edit_lastTrigger;
paddingFirst = TrimDataParams.edit_paddingFirst;
paddingLast = TrimDataParams.edit_paddingLast;
triggers = strtrim({EEG.event.type});
latencies = cell2mat({EEG.event.latency});

if isempty(paddingFirst)
    paddingFirst = 0;
else
    paddingFirst = str2double(paddingFirst);
end
if isempty(paddingLast)
    paddingLast = 0;
else
    paddingLast = str2double(paddingLast);
end

% find indices
idx_firstTrigger = strcmp(triggers, firstTrigger);
idx_lastTrigger = strcmp(triggers, lastTrigger);

new_start = latencies(1, idx_firstTrigger) + paddingFirst;
new_end = latencies(1, idx_lastTrigger) + paddingLast;

% if more the same triggers, take the first and the last
if ~isempty(new_start)
    new_start = new_start(1);
else
    new_start = 1;
end
if ~isempty(new_end)
    new_end = new_end(end);
else
    new_end = EEG.pnts;
end

% check, if data in boundaries
if new_start < 0 | new_end > EEG.pnts
    disp('Beyond boudaries, trimming not performed')
    EEG = EEG;
    
elseif isempty(firstTrigger) & isempty(lastTrigger)
    EEG = EEG;
    
% trim data
else
    EEG = pop_select(EEG, 'point', [new_start new_end]);
    EOG = pop_select(EOG, 'point', [new_start new_end]);
    
end

% remove boundaries for PREP            
eTypes = find(strcmpi({EEG.event.type}, 'boundary'));
if ~isempty(eTypes)
    if eTypes(1) == 1
        EEG.event(1) = [];
    end
end
            
end
