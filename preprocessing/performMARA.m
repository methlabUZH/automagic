function EEGClean = performMARA(data, varargin)
% performMARA  perform Independent Component Analysis (ICA) on the high 
%   passsed data.
%   This function applies a high pass filter before the ICA. But the output
%   result is NOT high passed filtered, but only cleaned with ICA. This
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

defaults = DefaultParameters.MARAParams;
CSTS = PreprocessingConstants.MARACsts;

%% Parse and check parameters
p = inputParser;
validate_param = @(x) isa(x, 'containers.Map');
addParameter(p,'chanlocMap', defaults.chanlocMap, validate_param);
addParameter(p,'largeMap', defaults.largeMap);
addParameter(p,'high', defaults.high, @isstruct);
parse(p, varargin{:});
chanlocMap = p.Results.chanlocMap;
high = p.Results.high;

% Change channel labels to their corresponding ones as required by 
% processMARA. This is done only for those labels that are given in the map.
if( ~ isempty(chanlocMap))
    inverseChanlocMap = containers.Map(chanlocMap.values, ...
                                         chanlocMap.keys);
    idx = find(ismember({data.chanlocs.labels}, chanlocMap.keys));
    for i = idx
       data.chanlocs(1,i).labels = chanlocMap(data.chanlocs(1,i).labels);
    end
    
    % Temporarily change the name of all other labels to make sure they
    % don't create conflicts
    for i = 1:length(data.chanlocs)
       if(~ any(i == idx))
          data.chanlocs(1,i).labels = strcat(data.chanlocs(1,i).labels, ...
                                            '_automagiced');
       end
    end
end

% Check if the channel system is according to what Mara is expecting.
intersect_labels = intersect(cellstr(CSTS.REQ_CHAN_LABELS), ...
                            {data.chanlocs.labels});
if(length(intersect_labels) < 3)
    msg = ['The channel location system was very probably ',...
    'wrong and MARA ICA could not be used correctly.' '\n' 'MARA ICA for this ',... 
    'file is skipped.'];
    ME = MException('Automagic:MARA:notEnoughChannels', msg);
    
    % Change back the labels to the original one
    if( ~ isempty(chanlocMap))
        for i = idx
           data.chanlocs(1,i).labels = inverseChanlocMap(...
                                                data.chanlocs(1,i).labels);
        end
        
        for i = 1:length(data.chanlocs)
            if(~ any(i == idx))
                data.chanlocs(1,i).labels = strtok(...
                    data.chanlocs(1,i).labels, '_automagiced');
            end
        end
    end
    data.automagic.mara.performed = 'no';
    throw(ME)
end

%% Perform ICA
display(CSTS.RUN_MESSAGE);
dataFiltered = data;
if( ~isempty(high) )
    [~, dataFiltered, ~, b] = evalc('pop_eegfiltnew(data, high.freq, 0, high.order)');
    dataFiltered.automagic.mara.highpass.performed = 'yes';
    dataFiltered.automagic.mara.highpass.freq = high.freq;
    dataFiltered.automagic.mara.highpass.order = length(b)-1;
    dataFiltered.automagic.mara.highpass.transitionBandWidth = 3.3 / (length(b)-1) * dataFiltered.srate;
else
    dataFiltered.automagic.mara.highpass.performed = 'no';
end
        
options = [0 1 0 0 0]; %#ok<NASGU>
[~, ALLEEG, EEGMara, ~] = evalc('processMARA_with_no_popup(dataFiltered, dataFiltered, 1, options)');

% Get bak info before ica components were rejected
[~, artcomps, MARAinfo] = evalc('MARA(EEGMara)');
[~, retVar]  = compvar(EEGMara.data, ...
    {EEGMara.icasphere EEGMara.icaweights}, ...
    EEGMara.icawinv, setdiff(EEGMara.icachansind, artcomps)); 

% Clean with ICA
EEGMara.data = data.data;
EEGClean = pop_subcomp(EEGMara, []);

EEGClean.automagic.mara.performed = 'yes';
EEGClean.automagic.mara.prerejection.reject = EEGMara.reject;
EEGClean.automagic.mara.prerejection.icaact  = EEGClean.icaact;
EEGClean.automagic.mara.prerejection.icawinv     = EEGClean.icawinv;
EEGClean.automagic.mara.prerejection.icaweights  = EEGClean.icaweights;
EEGClean.automagic.mara.ICARejected = find(EEGMara.reject.gcompreject == 1);
EEGClean.automagic.mara.retainedVariance = retVar;
EEGClean.automagic.mara.postArtefactProb = MARAinfo.posterior_artefactprob;
EEGClean.automagic.mara.MARAinfo = MARAinfo;
%% Return
% Change back the labels to the original one
if( ~ isempty(chanlocMap))
    for i = idx
       EEGClean.chanlocs(1,i).labels = inverseChanlocMap(...
                                                EEGClean.chanlocs(1,i).labels);
    end
    
    for i = 1:length(EEGClean.chanlocs)
        if(~ any(i == idx))
            EEGClean.chanlocs(1,i).labels = strtok(...
                EEGClean.chanlocs(1,i).labels, '_automagiced');
        end
    end
end

if(~isreal(EEGClean.data))
    msg = 'ICA returns complex values. Probably due to rank deficiency.';
    ME = MException('Automagic:ICA:complexValuesReturned', msg);
    throw(ME)
end

end

function [ALLEEG,EEG,CURRENTSET] = processMARA_with_no_popup(ALLEEG,EEG,CURRENTSET,varargin) %#ok<DEFNU>
% This is only an (almost) exact copy of the function processMARA where few
% of the paramters are changed for our need. (Mainly to supress outputs)

addpath('../matlab_scripts');
    if isempty(EEG.chanlocs)
        try
            error('No channel locations. Aborting MARA.')
        catch
           eeglab_error; 
           return; 
        end
    end
    
    if not(isempty(varargin))
        options = varargin{1}; 
    else
        options = [0 0 0 0 0]; 
    end
    

    %% filter the data
    if options(1) == 1
        disp('Filtering data');
        [EEG, LASTCOM] = pop_eegfilt(EEG);
        eegh(LASTCOM);
        [ALLEEG EEG CURRENTSET, LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET);
        eegh(LASTCOM);
    end

    %% run ica
    if options(2) == 1
        disp('Run ICA');
        
        [EEG, LASTCOM] = pop_runica(EEG, 'icatype','runica');
        g.gui = 'off';
        [ALLEEG EEG CURRENTSET, LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET, g);
        eegh(LASTCOM);
    end

    %% check if ica components are present
    [EEG LASTCOM] = eeg_checkset(EEG, 'ica'); 
    if LASTCOM < 0
        disp('There are no ICA components present. Aborting classification.');
        return 
    else
        eegh(LASTCOM);
    end

    %% classify artifactual components with MARA
    [artcomps, MARAinfo] = MARA(EEG);
    EEG.reject.MARAinfo = MARAinfo; 
    disp('MARA marked the following components for rejection: ')
    if isempty(artcomps)
        disp('None')
    else
        disp(artcomps)    
        disp(' ')
    end
   
    
    if isempty(EEG.reject.gcompreject) 
        EEG.reject.gcompreject = zeros(1,size(EEG.icawinv,2)); 
        gcompreject_old = EEG.reject.gcompreject;
    else % if gcompreject present check whether labels differ from MARA
        if and(length(EEG.reject.gcompreject) == size(EEG.icawinv,2), ...
            not(isempty(find(EEG.reject.gcompreject))))
            
            tmp = zeros(1,size(EEG.icawinv,2));
            tmp(artcomps) = 1; 
            if not(isequal(tmp, EEG.reject.gcompreject)) 
       
                answer = questdlg(... 
                    'Some components are already labeled for rejection. What do you want to do?',...
                    'Labels already present','Merge artifactual labels','Overwrite old labels', 'Cancel','Cancel'); 
            
                switch answer,
                    case 'Overwrite old labels',
                        gcompreject_old = EEG.reject.gcompreject;
                        EEG.reject.gcompreject = zeros(1,size(EEG.icawinv,2));
                        disp('Overwrites old labels')
                    case 'Merge artifactual labels'
                        disp('Merges MARA''s and old labels')
                        gcompreject_old = EEG.reject.gcompreject;
                    case 'Cancel',
                        return; 
                end 
            else
                gcompreject_old = EEG.reject.gcompreject;
            end
        else
            EEG.reject.gcompreject = zeros(1,size(EEG.icawinv,2));
            gcompreject_old = EEG.reject.gcompreject;
        end
    end
    EEG.reject.gcompreject(artcomps) = 1;     
    
    try 
        EEGLABfig = findall(0, 'tag', 'EEGLAB');
        MARAvizmenu = findobj(EEGLABfig, 'tag', 'MARAviz'); 
        set(MARAvizmenu, 'Enable', 'on');
    catch
        keyboard
    end

    
    %% display components with checkbox to label them for artifact rejection  
    if options(3) == 1
        if isempty(artcomps)
            answer = questdlg2(... 
                'MARA identied no artifacts. Do you still want to visualize components?',...
                'No artifacts identified','Yes', 'No', 'No'); 
            if strcmp(answer,'No')
                return; 
            end
        end
        [EEG, LASTCOM] = pop_selectcomps_MARA(EEG, gcompreject_old); 
        eegh(LASTCOM);  
        if options(4) == 1
            pop_visualizeMARAfeatures(EEG.reject.gcompreject, EEG.reject.MARAinfo); 
        end
    end

    %% automatically remove artifacts
    if and(and(options(5) == 1, not(options(3) == 1)), not(isempty(artcomps)))
        try
            [EEG LASTCOM] = pop_subcomp(EEG, []);
            eegh(LASTCOM);
        catch
            display('WARNING: ICA not possible on this file.');
        end
        g.gui = 'off';
        [ALLEEG EEG CURRENTSET LASTCOM] = pop_newset(ALLEEG, EEG, CURRENTSET, g); 
        eegh(LASTCOM);
        disp('Artifact rejection done.');
    end
end