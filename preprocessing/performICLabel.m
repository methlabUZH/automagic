function EEG = performICLabel(EEG, varargin)
% performICLabel  perform Independent Component Analysis (ICA) on the high
%   passsed EEG and classifies bad components using ICLabel.
%   This function applies a high pass filter before the ICA. But the output
%   result is NOT high passed filtered, but only cleaned with ICA. This
%   option allows to choose a separate high pass filter only for ICA from
%   the desired high pass filtered after the entire preprocessing. Please
%   note that at this stage of the preprocessing, another high pass filter
%   has been already applied on the EEG in the performFilter.m. Please use
%   accordingly.
%
%   EEG_out = performICLabel(EEG, params) where EEG is the input EEGLAB
%   data structure and EEG_out is the output EEGLAB data structure after ICA.
%   params is an optional parameter which must be a structure with optional
%   fields 'brainTher', 'muscleTher', 'eyeTher', 'heartTher', 'lineNoiseTher',
%   'channelNoiseTher', 'otherTher', 'includeSelected' and 'high'. An
%   example of params is given below:
%
%   params = struct('brainTher', 0.8, ...
%                   'muscleTher', [], ...
%                   'eyeTher', [], ...
%                   'heartTher', [], ...
%                   'lineNoiseTher', [], ...
%                   'channelNoiseTher', [], ...
%                   'otherTher', 0.8, ...
%                   'includeSelected', 1, ...
%                   'high',     struct('freq', 1.0,...
%                                      'order', []));
%
%   Components with more than params.xxxTher probability are either
%   rejected if params.includeSelected == 0, or kept if
%   params.includeSelected == 1.
%
%   params.high is a structure indicating the high pass frequency
%   (params.high.freq) and order (params.high.order) of the high pass
%   filter applied on the EEG before ICA. For more information on this
%   parameter please see performFilter.m
%
%   If varargin is ommited, default values are used. If any fields of
%   varargin is ommited, corresponsing default value is used.
%
%   Default values are taken from DefaultParameters.m.
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

defaults = DefaultParameters.ICLabelParams;
recs = RecommendedParameters.ICLabelParams;
if isempty(defaults)
    defaults = recs;
end

CSTS = PreprocessingConstants.ICLabelCsts;
%% Parse and check parameters
p = inputParser;
addParameter(p,'keep_comps', []);
addParameter(p,'brainTher', defaults.brainTher, @isnumeric);
addParameter(p,'muscleTher', defaults.muscleTher, @isnumeric);
addParameter(p,'eyeTher', defaults.eyeTher, @isnumeric);
addParameter(p,'heartTher', defaults.heartTher, @isnumeric);
addParameter(p,'lineNoiseTher', defaults.lineNoiseTher, @isnumeric);
addParameter(p,'channelNoiseTher', defaults.channelNoiseTher, @isnumeric);
addParameter(p,'otherTher', defaults.otherTher, @isnumeric);
addParameter(p,'includeSelected', defaults.includeSelected, @isnumeric);
addParameter(p,'high', defaults.high, @isstruct);
parse(p, varargin{:});
brainTher = p.Results.brainTher;
muscleTher = p.Results.muscleTher;
heartTher = p.Results.heartTher;
eyeTher = p.Results.eyeTher;
lineNoiseTher = p.Results.lineNoiseTher;
channelNoiseTher = p.Results.channelNoiseTher;
otherTher = p.Results.otherTher;
includeSelected = p.Results.includeSelected;
high = p.Results.high;
EEG.etc.keep_comps = p.Results.keep_comps;
EEG.etc.keep_comps = ~isempty(EEG.etc.keep_comps);

%% Perform ICA
display(CSTS.RUN_MESSAGE);
if( ~isempty(high) ) % temporary high-pass filter
    EEG_orig = EEG;
    [~, EEG, ~, b] = evalc('pop_eegfiltnew(EEG, high.freq, 0, high.order)');
    
    EEG_orig.automagic.iclabel.highpass.performed = 'yes';
    EEG_orig.automagic.iclabel.highpass.freq = high.freq;
    EEG_orig.automagic.iclabel.highpass.order = length(b)-1;
    EEG_orig.automagic.iclabel.highpass.transitionBandWidth = 3.3 / (length(b)-1) * EEG_orig.srate;
else
    EEG_orig = EEG; % this is only done to keep the the rest of the ICLabel script as it is.
    EEG_orig.automagic.iclabel.highpass.performed = 'no';
end



%% Run ICA
[~, EEG, ~] = evalc('pop_runica(EEG, ''icatype'',''runica'',''chanind'',EEG.icachansind)');
    
if EEG_orig.etc.keep_comps
    EEG_orig.etc.beforeICremove.icaact = EEG.icaact;
    EEG_orig.etc.beforeICremove.icawinv = EEG.icawinv;
    EEG_orig.etc.beforeICremove.icasphere = EEG.icasphere;
    EEG_orig.etc.beforeICremove.icaweights = EEG.icaweights;
    EEG_orig.etc.beforeICremove.chanlocs = EEG.chanlocs;
end
    
%% perform IClabel  
EEG = iclabel(EEG);

brainComponents = [];
if ~ isempty(brainTher)
    brainComponents = find(EEG.etc.ic_classification.ICLabel.classifications(:, 1) > brainTher(1) & EEG.etc.ic_classification.ICLabel.classifications(:, 1) < brainTher(2));
end

muscleComponents = [];
if ~ isempty(muscleTher)
    muscleComponents = find(EEG.etc.ic_classification.ICLabel.classifications(:, 2) > muscleTher(1) & EEG.etc.ic_classification.ICLabel.classifications(:, 2) < muscleTher(2));
end

eyeComponents = [];
if ~ isempty(eyeTher)
    eyeComponents = find(EEG.etc.ic_classification.ICLabel.classifications(:, 3) > eyeTher(1) & EEG.etc.ic_classification.ICLabel.classifications(:, 3) < eyeTher(2));
end

heartComponents = [];
if ~ isempty(heartTher)
    heartComponents = find(EEG.etc.ic_classification.ICLabel.classifications(:, 4) > heartTher(1) & EEG.etc.ic_classification.ICLabel.classifications(:, 4) < heartTher(2));
end

lineNoiseComponents = [];
if ~ isempty(lineNoiseTher)
    lineNoiseComponents = find(EEG.etc.ic_classification.ICLabel.classifications(:, 5) > lineNoiseTher(1) & EEG.etc.ic_classification.ICLabel.classifications(:, 5) < lineNoiseTher(2));
end
channelNoiseComponents = [];
if ~ isempty(channelNoiseTher)
    channelNoiseComponents = find(EEG.etc.ic_classification.ICLabel.classifications(:, 6) > channelNoiseTher(1) & EEG.etc.ic_classification.ICLabel.classifications(:, 6) < channelNoiseTher(2));
end

otherComponents = [];
if ~ isempty(otherTher)
    otherComponents = find(EEG.etc.ic_classification.ICLabel.classifications(:, 7) > otherTher(1) & EEG.etc.ic_classification.ICLabel.classifications(:, 7) < otherTher(2));
end

uni_comps = {brainComponents, muscleComponents, eyeComponents, ...
    heartComponents, lineNoiseComponents, channelNoiseComponents, otherComponents};
components = unique(cat(1, uni_comps{:}));

allComps = 1:length(EEG.etc.ic_classification.ICLabel.classifications(:, 1));
if includeSelected
    components = setdiff(allComps, components);
end


%% replace the potentially filtered data with the non filtered data 
% (if no temporary filter option chosen nothing happens)
EEG.data = EEG_orig.data; 

%% Subtract components from data
if ~isempty(setdiff_bc(1:size(EEG.icaweights,1), components))
    EEG = pop_subcomp(EEG, components);
end

EEG_orig.automagic.iclabel.performed = 'yes';
EEG_orig.automagic.iclabel.rejectComponents = components;
EEG_orig.automagic.iclabel.settings = [];
EEG_orig.automagic.iclabel.settings.brainTher = brainTher;
EEG_orig.automagic.iclabel.settings.muscleTher = muscleTher;
EEG_orig.automagic.iclabel.settings.heartTher = heartTher;
EEG_orig.automagic.iclabel.settings.eyeTher = eyeTher;
EEG_orig.automagic.iclabel.settings.lineNoiseTher = lineNoiseTher;
EEG_orig.automagic.iclabel.settings.channelNoiseTher = channelNoiseTher;
EEG_orig.automagic.iclabel.settings.otherTher = otherTher;
EEG_orig.automagic.iclabel.settings.includeSelected = includeSelected;
EEG_orig.automagic.iclabel.settings.high = high;
EEG_orig.etc.ic_classification = EEG.etc.ic_classification;

% store data in EEG_orig and recompute icaact
EEG_orig.icasphere   = EEG.icasphere;
EEG_orig.icaweights  = EEG.icaweights;
EEG_orig.icachansind = EEG.icachansind;
EEG_orig.icawinv = EEG.icawinv; % computed in pop_subcomp
EEG_orig = eeg_checkset(EEG_orig); % let EEGLAB re-compute EEG.icaact 
EEG_orig.data = EEG.data; 
EEG = EEG_orig;
    







