function EEG = performMARA(EEG, varargin)
% performMARA  perform Independent Component Analysis (ICA) on the high 
%   passsed data and classifies bad components using MARA.
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

defaults = DefaultParameters.MARAParams;
recs = RecommendedParameters.MARAParams;
if isempty(defaults)
    defaults = recs;
end
% chanlocMap could be inexistant. This might be necessary so that in the
% SystemDependentParse.m the default mapping is not assigned. But here it
% does not matter if it is existent or not as nothing will happen depending
% on this. Existence and non existence of this field is only necessary for
% the above mentioned function.
if ~isfield(defaults, 'chanlocMap')
    defaults = [];
    defaults.chanlocMap = RecommendedParameters.MARAParams.chanlocMap;
end

CSTS = PreprocessingConstants.MARACsts;
%% Parse and check parameters
p = inputParser;
validate_param = @(x) isa(x, 'containers.Map');
addParameter(p,'chanlocMap', defaults.chanlocMap, validate_param);
addParameter(p,'largeMap', defaults.largeMap);
addParameter(p,'high', defaults.high, @isstruct);
addParameter(p,'keep_comps', defaults.keep_comps);
parse(p, varargin{:});
chanlocMap = p.Results.chanlocMap;
high = p.Results.high;
EEG.etc.keep_comps = p.Results.keep_comps;
EEG.etc.keep_comps = ~isempty(EEG.etc.keep_comps);
% Change channel labels to their corresponding ones as required by 
% processMARA. This is done only for those labels that are given in the map.
if( ~ isempty(chanlocMap))
    inverseChanlocMap = containers.Map(chanlocMap.values, ...
                                         chanlocMap.keys);
    EEG.chanlocs(1).maraLabel = [];
    idx = find(ismember({EEG.chanlocs.labels}, chanlocMap.keys));
    for i = idx
        EEG.chanlocs(1,i).maraLabel = chanlocMap(EEG.chanlocs(1,i).labels);
        EEG.chanlocs(1,i).labels = chanlocMap(EEG.chanlocs(1,i).labels);
    end

    % Temporarily change the name of all other labels to make sure they
    % don't create conflicts
    for i = 1:length(EEG.chanlocs)
       if(~ any(i == idx))
          EEG.chanlocs(1,i).labels = strcat(EEG.chanlocs(1,i).labels, ...
                                            '_automagiced');
       end
    end
end

% Check if the channel system is according to what Mara is expecting.
intersect_labels = intersect(cellstr(CSTS.REQ_CHAN_LABELS), ...
                            {EEG.chanlocs.labels});
if(length(intersect_labels) < 3)
    msg = ['The channel location system was very probably ',...
    'wrong and MARA ICA could not be used correctly.' '\n' 'MARA ICA for this ',... 
    'file is skipped.'];
    ME = MException('Automagic:MARA:notEnoughChannels', msg);
    
    % Change back the labels to the original one
    if( ~ isempty(chanlocMap))
        for i = idx
           EEG.chanlocs(1,i).labels = inverseChanlocMap(...
                                                EEG.chanlocs(1,i).labels);
        end
        
        for i = 1:length(EEG.chanlocs)
            if(~ any(i == idx))
                EEG.chanlocs(1,i).labels = strtok(...
                    EEG.chanlocs(1,i).labels, '_automagiced');
            end
        end
    end
    EEG.automagic.mara.performed = 'no';
    throw(ME)
end

%%
display(CSTS.RUN_MESSAGE);
%dataFiltered = EEG;
% % if( ~isempty(high) )
% %     [~, dataFiltered, ~, b] = evalc('pop_eegfiltnew(EEG, high.freq, 0, high.order)');
% %     dataFiltered.automagic.mara.highpass.performed = 'yes';
% %     dataFiltered.automagic.mara.highpass.freq = high.freq;
% %     dataFiltered.automagic.mara.highpass.order = length(b)-1;
% %     dataFiltered.automagic.mara.highpass.transitionBandWidth = 3.3 / (length(b)-1) * dataFiltered.srate;
% % else
% %     dataFiltered.automagic.mara.highpass.performed = 'no';
% % end
        
%% checks of channel locations available
if isempty(EEG.chanlocs)
    try
        error('No channel locations. Aborting MARA.')
    catch
       eeglab_error; 
       return; 
    end
end

    
 %% temporary filtering before ICA
if ( ~isempty(high) )      
    EEG_orig=EEG;  
    [~, EEG, ~, b] = evalc('pop_eegfiltnew(EEG, high.freq, 0, high.order)');    
    EEG_orig.automagic.mara.highpass.performed = 'yes';
    EEG_orig.automagic.mara.highpass.freq = high.freq;
    EEG_orig.automagic.mara.highpass.order = length(b)-1;
    EEG_orig.automagic.mara.highpass.transitionBandWidth = 3.3 / (length(b)-1) * EEG_orig.srate;
else
    EEG_orig = EEG;  % this is only done to keep the the rest of the MARA script as it is.
    EEG_orig.automagic.mara.highpass.performed = 'no';
end

%% Run ICA
disp('Run ICA');
        
[~, EEG, ~] = evalc('pop_runica(EEG, ''icatype'',''runica'',''chanind'',EEG.icachansind)');

if EEG_orig.etc.keep_comps
    EEG_orig.etc.beforeICremove.icaact = EEG.icaact;
    EEG_orig.etc.beforeICremove.icawinv = EEG.icawinv;
    EEG_orig.etc.beforeICremove.icasphere = EEG.icasphere;
    EEG_orig.etc.beforeICremove.icaweights = EEG.icaweights;
    EEG_orig.etc.beforeICremove.chanlocs = EEG.chanlocs;
end

% turn off MARA gui
% g.gui = 'off';
% [ALLEEG EEG CURRENTSET, LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET, g);
% eegh(LASTCOM);

[artcomps, MARAinfo] = MARA(EEG);
EEG.reject.MARAinfo = MARAinfo; 

% Get back info before ica components were rejected
% [~, artcomps, MARAinfo] = evalc('MARA(EEGMara)');

%% compute retained variance
[~, retVar]  = compvar(EEG.data, ...
    {EEG.icasphere EEG.icaweights}, ...
    EEG.icawinv, setdiff(EEG.icachansind, artcomps)); 

%% Remove bad components
% replace the potentially filtered data with the non filtered data 
EEG.data = EEG_orig.data;

% Subtract components from data
if ~isempty(setdiff_bc(1:size(EEG.icaweights,1), artcomps))
    EEG = pop_subcomp(EEG, artcomps);
end

if isempty(EEG.reject) 
    EEG.reject.gcompreject = zeros(1,size(EEG.icawinv,2)); 
end
EEG.reject.gcompreject(artcomps) = 1; 

EEG_orig.automagic.mara.performed = 'yes';
EEG_orig.automagic.mara.prerejection.reject = EEG.reject;
EEG_orig.automagic.mara.prerejection.icaact  = EEG.icaact;
EEG_orig.automagic.mara.prerejection.icawinv     = EEG.icawinv;
EEG_orig.automagic.mara.prerejection.icaweights  = EEG.icaweights;
EEG_orig.automagic.mara.ICARejected = find(EEG.reject.gcompreject == 1);
EEG_orig.automagic.mara.retainedVariance = retVar;
EEG_orig.automagic.mara.postArtefactProb = MARAinfo.posterior_artefactprob;
EEG_orig.automagic.mara.MARAinfo = MARAinfo;

%% Recompute icaact & icawinv         
EEG_orig.icasphere   = EEG.icasphere;
EEG_orig.icaweights  = EEG.icaweights;
EEG_orig.icachansind = EEG.icachansind;
EEG_orig = eeg_checkset(EEG_orig); % let EEGLAB re-compute EEG.icaact & EEG.icawinv
EEG_orig.data = EEG.data; 
EEG = EEG_orig;  


%% Return
% Change back the labels to the original one
if( ~ isempty(chanlocMap))
    for i = idx
       EEG.chanlocs(1,i).labels = inverseChanlocMap(...
                                                EEG.chanlocs(1,i).labels);
    end
    
    for i = 1:length(EEG.chanlocs)
        if(~ any(i == idx))
            EEG.chanlocs(1,i).labels = strtok(...
                EEG.chanlocs(1,i).labels, '_automagiced');
        end
    end
end

if(~isreal(EEG.data))
    msg = 'ICA returns complex values. Probably due to rank deficiency.';
    ME = MException('Automagic:ICA:complexValuesReturned', msg);
    throw(ME)
end

