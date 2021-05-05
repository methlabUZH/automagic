function [EEG_out, EOG_out] = performCleanrawdata(EEG_in, EOG_in, varargin)
% performCleanrawdata makes channel rejection using clean_rawdata()
%   This function does not change the output values if and only if
%   BurstCriterion and WindowCriterion are deactiavted (it is the case by 
%   default). In this case, only indices of the bad channels are kept to 
%   be removed in a later step of the preprocessing. If the two mentiond 
%   criteria are selected however, the channels will be removed, data 
%   will be cleaned and high passed filtered as specified in clean_rawdata(), 
%   and noisy windows are removed. Then the same time windows are removed 
%   from the EOG data for coherence and possibe further EOG regression
%   which requires same length signals. Note that this behaviour is due to
%   the behaviour of the algorithm which inherently cleans the EEG.
%
%   [EEG_out, EOG_out] = performCleanrawdata(EEG_in, EOG_in, params)
%
%   EEG_in is the input EEG structure.
%
%   EOG_in is the input EOG structure.
%
%   params is an optional structure required as in clean_rawdata(). An
%   example of this param is as shown below:
%
%   params = struct('ChannelCriterion',     0.85,...
%                   'LineNoiseCriterion',   4,...
%                   'BurstCriterion',       5,...
%                   'WindowCriterion',      0.25, ...
%                   'Highpass',             [0.25 0.75]);
%
%   If params is ommited default values are used. Please see
%   clean_rawdata() for more information on more possible parameters.
%
%   The default parameters of the example above are taken from
%   DefaultParameters.m. The default parameters of all other parameters
%   required by clean_rawdata() are specified by the same function
%   clean_rawdata().
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

EEG_out = EEG_in;
EOG_out = EOG_in;
EEG_out.automagic.crd.performed = 'no';
if isempty(varargin{:})
    return; end

defaults = DefaultParameters.CRDParams;
recs = RecommendedParameters.CRDParams;
if isempty(defaults)
    defaults = recs;
end

p = inputParser;
addParameter(p,'ChannelCriterion', defaults.ChannelCriterion);
addParameter(p,'LineNoiseCriterion', defaults.LineNoiseCriterion);
addParameter(p,'BurstCriterion', defaults.BurstCriterion);
addParameter(p,'WindowCriterion', defaults.WindowCriterion);
addParameter(p,'Highpass', defaults.Highpass);  
parse(p, varargin{:});
params.ChannelCriterion = p.Results.ChannelCriterion;
params.LineNoiseCriterion = p.Results.LineNoiseCriterion;
params.BurstCriterion = p.Results.BurstCriterion;
params.WindowCriterion = p.Results.WindowCriterion;
params.Highpass = p.Results.Highpass;

toRemove = EEG_in.automagic.preprocessing.toRemove;
removedMask = EEG_in.automagic.preprocessing.removedMask;
badChans = [];

fprintf('Detecting bad channels using routines of clean_raw_data()...\n');
[~, EEGCleaned] = evalc('clean_artifacts(EEG_in, params)');

% If only channels are removed, remove them from the original EEG so
% that the effect of high pass filtering is not there anymore
newToRemove = toRemove;
if(isfield(EEGCleaned, 'etc'))
    etcfield = EEGCleaned.etc;
    if(isfield(EEGCleaned.etc, 'clean_channel_mask'))
        newMask = removedMask;
        oldMask = removedMask;
        newMask(~newMask) = ~etcfield.clean_channel_mask;
        badChans = setdiff(find(newMask), find(oldMask));

        newToRemove = union(toRemove, badChans);
    end
    EEG_out.etc = etcfield;

    % Remove the same time-windows from the EOG channels
   if(isfield(EEGCleaned.etc, 'clean_sample_mask'))
       EEG_out = EEGCleaned;

       if(isfield(EEGCleaned.etc, 'clean_channel_mask'))
            removedMask = newMask;
            newToRemove = toRemove;
        end

       removed = EEGCleaned.etc.clean_sample_mask;
       firsts = find(diff(removed) == -1) + 1;
       seconds = find(diff(removed) == 1);
       if(removed(1) == 0)
           firsts = [1, firsts];
       end
       if(removed(end) == 0)
           seconds = [seconds, length(removed)];
       end
       remove_range = [firsts; seconds]'; %#ok<NASGU>
       [~, EOG_out] = evalc('pop_select(EOG_in, ''nopoint'', remove_range)');
   end
end

% Add the info to the output structure
EEG_out.automagic.crd.performed = 'yes';
EEG_out.automagic.crd.badChans = badChans;
if isfield(EEG_out.etc, 'flatlines')
    EEG_out.automagic.crd.flatlines = find(EEG_out.etc.flatlines);
end
if isfield(EEG_out.etc, 'ChannelCriterion')
    EEG_out.automagic.crd.ChannelCriterion = find(EEG_out.etc.ChannelCriterion);
end
if isfield(EEG_out.etc, 'LineNoiseCriterion')
    EEG_out.automagic.crd.LineNoiseCriterion = find(EEG_out.etc.LineNoiseCriterion);
end
EEG_out.automagic.crd.params = params;

% .preprocessing field is used for internal purposes and will be removed at
% the end of the preprocessing
EEG_out.automagic.preprocessing.toRemove = newToRemove;
EEG_out.automagic.preprocessing.removedMask = removedMask;