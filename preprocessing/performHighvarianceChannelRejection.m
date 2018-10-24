function EEG_out = performHighvarianceChannelRejection(EEG_in, varargin)
% performHighvarianceChannelRejection   reject bad channels based on high
%   standard deviation
%   rejected = performHighvarianceChannelRejection(EEG, params)
%   where rejected is a list of channels that must be removed. EEG is a
%   EEGLAB data structure. params is an optional argument with optional
%   field 'sd' to specify the threshold.
%   When params is ommited default values are used. When a field of params 
%   is ommited, default value for that field is used. 
%   Default values are taken from DefaultParameters.m
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

defaults = DefaultParameters.HighvarParams;
recs = RecommendedParameters.HighvarParams;
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

rejected = find(nanstd(EEG_in.data,[],2) > sd_threshold);
[~, EEG_out] = evalc('pop_select(EEG_in, ''nochannel'', rejected)');

badChansMask(rejected) = true;
newMask = removedMask;
oldMask = removedMask;
newMask(~newMask) = badChansMask;
badChans = setdiff(find(newMask), find(oldMask));
removedMask = newMask; 

EEG_out.automagic.highVarianceRejection.performed = 'yes';
EEG_out.automagic.highVarianceRejection.badChans = badChans;
EEG_out.automagic.highVarianceRejection.sd = sd_threshold;
EEG_out.automagic.preprocessing.removedMask = removedMask;

