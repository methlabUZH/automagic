function EEGClean = performICLabel(EEG, varargin)
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
%   fields 'probTher' and 'high'. An example of params is given below:
%
%   params = = struct('probTher', 0.8, ...
%                     'high',       struct('freq', 1.0, 'order', []))
%   
%   Components with more than params.probTher probability of 'Brain' are 
%   kept and other components are rejected.
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

defaults = DefaultParameters.ICLabelParams;
recs = RecommendedParameters.ICLabelParams;
if isempty(defaults)
    defaults = recs;
end

CSTS = PreprocessingConstants.ICLabelCsts;
%% Parse and check parameters
p = inputParser;
addParameter(p,'probTher', defaults.probTher, @isnumeric);
addParameter(p,'high', defaults.high, @isstruct);
parse(p, varargin{:});
probTher = p.Results.probTher;
high = p.Results.high;

%% Perform ICA
display(CSTS.RUN_MESSAGE);
EEGFiltered = EEG;
if( ~isempty(high) )
    [~, EEGFiltered, ~, b] = evalc('pop_eegfiltnew(EEG, high.freq, 0, high.order)');
    EEGFiltered.automagic.iclabel.highpass.performed = 'yes';
    EEGFiltered.automagic.iclabel.highpass.freq = high.freq;
    EEGFiltered.automagic.iclabel.highpass.order = length(b)-1;
    EEGFiltered.automagic.iclabel.highpass.transitionBandWidth = 3.3 / (length(b)-1) * EEGFiltered.srate;
else
    EEGFiltered.automagic.iclabel.highpass.performed = 'no';
end

[~, EEG, ~] = evalc('pop_runica(EEGFiltered, ''icatype'',''runica'')');
EEG = iclabel(EEG);
components = find(EEG.etc.ic_classification.ICLabel.classifications(:, 1) < probTher);
if ~isempty(setdiff_bc(1:size(EEG.icaweights,1), components))
    EEGClean = pop_subcomp(EEG, components);
else
    EEGClean = EEG;
end
EEGClean.automagic.iclabel.performed = 'yes';
EEGClean.automagic.iclabel.rejectComponents = components;