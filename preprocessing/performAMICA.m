function EEGClean = performAMICA(EEG, varargin)

%% NEED TO EDIT THIS
% performAMICA  perform adaptive ICA using multiple models with shared components (AMICA) 
%   This function applies a high pass filter before the ICA. But the output
%   result is NOT high passed filtered, rather only cleaned with ICA. This
%   option allows to choose a separate high pass filter only for ICA from
%   the desired high pass filtered after the entire preprocessing. Please
%   note that at this stage of the preprocessing, another high pass filter
%   has been already applied on the data in the performFilter.m. Please use
%   accordingly.
%
%   data_out = performMARA(data, params) where data is the input EEGLAB data
%   structure and data_out is the output EEGLAB data structure after ICA. 
%   params is an optional parameter which must be a structure with optional 
%   fields 'chanlocMap' and 'high'. An example of params is given below:
%
%   params = = struct('chanlocMap', containers.Map, ...
%                     'largeMap',   0, ...
%                     'high',       struct('freq', 1.0, 'order', []))
%   
%   params.chanlocMap must be a map (of type containers.Map) which maps all
%   "possible" current channel labels to the standard channel labels given 
%   by FPz, F3, Fz, F4, Cz, Oz, ... as required by processMARA. Please note
%   that if the channel labels are already the same as the mentionned 
%   standard, an empty map would be enough. However if the map is empty and
%   none of the labels has the same semantic as required, no ICA will be
%   applied. For more information please see processMARA. An example of
%   such a map is given in systemDependentParse.m where a containers.Map is
%   created for the MARAParams.chanlocMap in the case of EGI systems.
%   Sometimes this field may be ignored, but here then it get replaced with
%   a new empty mapping.
%   
%   params.high is a structure indicating the high pass frequency
%   (params.high.freq) and order (params.high.order) of the high pass
%   filter applied on the data before ICA. For more information on this
%   parameter please see performFilter.m
%
%   If varargin is ommited, default values are used. If any fields of
%   varargin is ommited, corresponsing default value is used.
%
%   Default values are taken from DefaultParameters.m.
%
% Copyright (C) 2017  Amirreza Bahreini, methlabuzh@gmail.com
%%
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

defaults = DefaultParameters.AMICAParams;
CSTS = PreprocessingConstants.AMICACsts;

%% Parse and check parameters
p = inputParser;
validate_param = @(x) isa(x, 'containers.Map');
% addParameter(p,'chanlocMap', defaults.chanlocMap, validate_param);
% addParameter(p,'largeMap', defaults.largeMap);
% addParameter(p,'high', defaults.high, @isstruct);
parse(p, varargin{:});
% chanlocMap = p.Results.chanlocMap;

%% Perform ICA
display(CSTS.RUN_MESSAGE);
dataFiltered = EEG;
num_models = defaults.num_models;
numprocs = defaults.numprocs;
max_threads = defaults.max_threads;
max_iter = defaults.max_iter;
outdir = [ pwd filesep 'amicaouttmp' filesep ];
[weights,sphere,mods] = runamica15(EEG.data, 'num_models',num_models, 'outdir',outdir, ...
    'numprocs', numprocs, 'max_threads', max_threads, 'max_iter',max_iter);
% type “help runamica15()” for a full list and explanation of the parameters


end