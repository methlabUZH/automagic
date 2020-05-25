function EEG_out = performHighvarianceChannelRejection(EEG_in, varargin)
% performHighvarianceChannelRejection   reject bad channels based on high
%   standard deviation
%
%   rejected = performHighvarianceChannelRejection(EEG, params)
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

defaults = DefaultParameters.HighvarParams;
recs = RecommendedParameters.HighvarParams;
if isempty(defaults)
    defaults = recs;
end

p = inputParser;
addParameter(p,'sd', defaults.sd, @isnumeric);
addParameter(p,'cutoff', defaults.cutoff, @isnumeric);
addParameter(p,'rejRatio', defaults.rejRatio, @isnumeric);
parse(p, varargin{:});
sd_threshold = p.Results.sd;
ignoreCutOff = p.Results.cutoff;
rejectCutOff = p.Results.rejRatio;

removedMask = EEG_in.automagic.preprocessing.removedMask;

[s, ~] = size(EEG_in.data);
badChansMask = false(1, s); clear s;
% --------------------------------------------------------------
%modificaton 1 here : remove timepoints of very high variance from channel
% ignoreCutOff=100; %this has to be added as argument of the function and removed from here!
tmpData=EEG_in.data;
tmpData = tmpData - sum(sum(tmpData))/numel(tmpData); % Re-reference to the average temporarily
ignoreMask=tmpData>ignoreCutOff|tmpData<-ignoreCutOff;
tmpData(ignoreMask)=NaN;
rejected = nanstd(tmpData,[],2) > sd_threshold;
%----------------

%modification 2: get rid of channels with too many values above cut off
% rejectCutOff=0.5; % ratio of bad timepoints per channel before channel gets rejected- also needs to be argument of the function and set by suer
NaNsPerChan=sum(ignoreMask');
NaNsPerChan=NaNsPerChan/size(tmpData,2);
rejected_NaNs=NaNsPerChan>rejectCutOff;
rejected_full=[rejected | rejected_NaNs'];

%now write it back to variable "rejected"
rejected=rejected_full;
% -------------------------------------
% end of modifications

[~, EEG_out] = evalc('pop_select(EEG_in, ''nochannel'', find(rejected))');

badChansMask(rejected) = true;
newMask = removedMask;
oldMask = removedMask;
newMask(~newMask) = badChansMask;
badChans = setdiff(find(newMask), find(oldMask));
removedMask = newMask; 

EEG_out.automagic.highVarianceRejection.performed = 'yes';
EEG_out.automagic.highVarianceRejection.badChans = badChans;
EEG_out.automagic.highVarianceRejection.sd = sd_threshold;
EEG_out.automagic.highVarianceRejection.cutoff = ignoreCutOff;
EEG_out.automagic.highVarianceRejection.rejRatio = rejectCutOff;

% .preprocessing field is used for internal purposes and will be removed at
% the end of the preprocessing
EEG_out.automagic.preprocessing.removedMask = removedMask;

