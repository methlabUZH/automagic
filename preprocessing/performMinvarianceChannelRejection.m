function EEG_out = performMinvarianceChannelRejection(EEG_in, varargin)
% performMinvarianceChannelRejection   reject bad channels based on minimum
%   standard deviation
%
%   rejected = performMinvarianceChannelRejection(EEG, params)
%   where rejected is a list of channels that must be removed. EEG is a
%   EEGLAB data structure. params is an optional argument with optional
%   field 'sd' to specify the threshold.
%   When params is ommited default values are used. When a field of params 
%   is ommited, default value for that field is used. 
%   Default values are taken from DefaultParameters.m
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

defaults = DefaultParameters.MinvarParams;
recs = RecommendedParameters.MinvarParams;
if isempty(defaults)
    defaults = recs;
end

p = inputParser;
addParameter(p,'sd', defaults.sd, @isnumeric);
parse(p, varargin{:});
sd_threshold = p.Results.sd;

removedMask = EEG_in.automagic.preprocessing.removedMask;

[s, ~] = size(EEG_in.data);
badChansMask = false(1, s); clear s;

rejected = var(EEG_in.data') <= sd_threshold;

% Save the original EEG.icachansind.
% If we don't, pop_select() on line 642 will mark more components to remove 
% than necessary (because EEG.icachansind contains the original channel indices, 
% e.g., 1:128, but now the data has fewer channels).
orig_icachansind = EEG_in.icachansind;
EEG_in.icachansind = 1 : EEG_in.nbchan;

[~, EEG_out] = evalc('pop_select(EEG_in, ''nochannel'', find(rejected))');

% recompute and save icachansind
EEG_out.icachansind = orig_icachansind(not(rejected));

badChansMask(rejected) = true;
newMask = removedMask;
oldMask = removedMask;
newMask(~newMask) = badChansMask;
badChans = setdiff(find(newMask), find(oldMask));
removedMask = newMask; 

EEG_out.automagic.minVarianceRejection.performed = 'yes';
EEG_out.automagic.minVarianceRejection.badChans = badChans;
EEG_out.automagic.minVarianceRejection.sd = sd_threshold;

% .preprocessing field is used for internal purposes and will be removed at
% the end of the preprocessing
EEG_out.automagic.preprocessing.removedMask = removedMask;

