function [EEG, EOG, EEGSystem, MARAParams] = ...
                        systemDependentParse(EEG, EEGSystem, ...
                        ChannelReductionParams, MARAParams, ORIGINAL_FILE) %#ok<INUSD>
% systemDependentParse parse EEG input depending on the EEG system.
%   This function prepares the input for preprocessing. It makes sure that
%   the correct channel location field is a part of the input EEG. In
%   addition, it makes sure the reference channel is detected. If no
%   reference channel is provided, an additional channel containing zeros
%   is concatenated as a last channel. As a next step, it separates the EEG
%   from EOG for further processing. It also excludes specified channels
%   from the preprocessing. In the end, it makes sure the correct mapping
%   for the MARA ICA is provided.
%
%   EEG is the EEG/EOG input data loaded from the file.
%   
%   EEGSystem must be a structure with fields 'name', 'sys10_20', 'refChan', 
%   'locFile' and 'fileLocType'.  EEGSystem.name can be either 'EGI' or 
%   'Others'. EEGSystem.sys10_20 is a boolean indicating whether to use 
%   10-20 system to find channel locations or not. All other following 
%   fields are optional if EEGSystem.name='EGI' and can be left empty. 
%   But in the case of EEGSystem.name='Others':
%   EEGSystem.refChan.idx the index of the reference channel in dataset. 
%   If it's left empty, a new reference channel will be added as the last 
%   channel of the dataset where all values are zeros and this new channel 
%   will be considered as the reference channel. If 
%   EEGSystem.refChan == struct([]) no reference channel is added and no 
%   channel is considered as reference channel at all. 
%   EEGSystem.locFile must be the name of the file (preferably) located 
%   in 'matlab_scripts' folder that can be used by pop_chanedit to find 
%   channel locations and finally EEGSystem.fileLocType must be the type 
%   of that file. Please see pop_chanedit for more information. Obviously 
%   only types supported by pop_chanedit are supported.
%
%   ChannelReductionParams has a field 
%   ChannelReductionParams.tobeExcludedChanswhich is an array of 
%   numbers indicating indices of the channels to be excluded from the 
%   analysis
%
%   EOGRegressionParams has a field performEOGRegression that 
%   must be a boolean indication whether to perform EOG Regression or not. 
%   The default value is 'EOGRegressionParams.performEOGRegression = 1'
%   which performs eog regression. The other field 
%   EOGRegressionParams.eogChans must be an array of numbers 
%   indicating indices of the EOG channels in the data.
%
%   ORIGINAL_FILE is necassary only in case of *.fif files. In that case,
%   this should be the address of the file where this EEG data is loaded
%   from.

%   MARAParams is explained in detail in performMARA.m
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
Csts = PreprocessingConstants;

% Get the exclude channel list
defaults = DefaultParameters.ChannelReductionParams;
recs = RecommendedParameters.ChannelReductionParams;
if isempty(defaults) || ~isfield(defaults, 'tobeExcludedChans')
    defaults = recs;
end
if isempty(ChannelReductionParams)
    tobeExcludedChans = [];
elseif ~isfield(ChannelReductionParams, 'tobeExcludedChans')
    tobeExcludedChans = defaults.tobeExcludedChans;
else
    tobeExcludedChans = ChannelReductionParams.tobeExcludedChans;
end

% Get the eog channel list
defaults = DefaultParameters.EEGSystem;
recs = RecommendedParameters.EEGSystem;
if isempty(defaults) || ~isfield(defaults, 'eogChans')
    defaults = recs;
end
if ~isfield(EEGSystem, 'eogChans')
    eog_channels = defaults.EEGSystem.eogChans;
else
    eog_channels = EEGSystem.eogChans;
end

% Add the 10_20 file to EEGSystem
parts = addEEGLab();
if(~isempty(parts)) 
    
    % System dependence:
    slash = filesep;

    EEGSystem.sys10_20_file = Csts.EEGSystemCsts.sys10_20_file;
    Index = not(~contains(parts, 'BESA'));
    EEGSystem.sys10_20_file = strcat(parts{Index}, slash, ...
             Csts.EEGSystemCsts.sys10_20_file);
end

% Case of others where the location file must have been provided
if (~isempty(EEGSystem.name) && ...
        strcmp(EEGSystem.name, Csts.EEGSystemCsts.OTHERS_NAME))
    
    if(~isempty(EEGSystem.refChan) && isempty(EEGSystem.refChan.idx))
        EEG.data(end+1,:) = 0;
        EEG.nbchan = EEG.nbchan + 1;
        EEGSystem.refChan.idx = EEG.nbchan;
        
        % Add an arbitraty channel location for the reference channel
        % but only if EEG.chanlocs exists
        if (size(EEG.chanlocs,2) ~= size(EEG.data,1) && ~isempty(EEG.chanlocs))
            EEG.chanlocs(size(EEG.data,1)) = EEG.chanlocs(end);
            EEG.chanlocs(end).labels = 'REF';
        end
        
        % If the added electrode should be Cz, but no chanloc file will be
        % provided (e.g. in BIDS format, .tsv file does not come with
        % coordinates for Cz).
        if isfield(EEG, 'BIDS') && isfield(EEG.BIDS,'tInfo') && ...
            isfield(EEG.BIDS.tInfo,'EEGReference')
            
            if strcmp(EEG.BIDS.tInfo.EEGReference, 'Cz')
                EEG.chanlocs(end).labels = 'Cz';                
                EEG.chanlocs(end).X = 0.00000;
                EEG.chanlocs(end).Y = 0.00000;
                EEG.chanlocs(end).Z = 9.68308;    
                
                % recompute sph_theta, ..
                EEG.chanlocs(end).sph_theta = [];               
                EEG = eeg_checkset(EEG, 'chanlocs_homogeneous');
            end
        end
        
    end
    all_chans = 1:EEG.nbchan;
    eeg_channels = setdiff(all_chans, union(eog_channels, tobeExcludedChans));
    clear all_chans;
    
    % If chanloc is not a provided field load it from the provided file
    if(isempty(EEG.chanlocs) || isempty([EEG.chanlocs.X]) || ...
        length(EEG.chanlocs) ~= EEG.nbchan || ~isempty(EEGSystem.locFile))
    
        if isempty(EEGSystem.locFile) || isempty(EEGSystem.fileLocType)
            error(['Either provide a channel location field for the '...
                'input EEG or provide a channel location file as '...
                'argument (or in the GUI)'])
        end
        
        if(~ EEGSystem.sys10_20)
            [~, EEG] = evalc(['pop_chanedit(EEG,' ...
                '''load'',{ EEGSystem.locFile , ''filetype'', EEGSystem.fileLocType})']);
        else
            [~, EEG] = evalc(['pop_chanedit(EEG, ''lookup'', EEGSystem.sys10_20_file,' ...
                '''load'',{ EEGSystem.locFile , ''filetype'', ''autodetect''})']);
        end
    end
    
    % Make ICA map of channels
    if (~isempty(MARAParams) && isfield(MARAParams, 'chanlocMap') && ...
            isempty(MARAParams.chanlocMap)) % if it's empty, the default EGI are used
        switch EEG.nbchan
            case 129
                % Make the map for ICA
                if(MARAParams.largeMap)
                    keySet = {'E36', 'E104', 'E129', 'E24', 'E124', 'E33', 'E122', 'E22', 'E9', ...
                        'E15', 'E11', 'E70', 'E83', 'E52', 'E92', 'E58', 'E96',  ...
                        'E23', 'E3', 'E26', 'E2', 'E16', 'E30', 'E105', 'E41', 'E103', 'E37', ...
                        'E87', 'E42', 'E93', 'E47', 'E98', 'E55', 'E19', 'E1', 'E4', 'E27', ...
                        'E123', 'E32', 'E13', 'E112', 'E29', 'E111', 'E28', 'E117', 'E6', ...
                        'E12', 'E34', 'E116', 'E38', 'E75', 'E60', 'E64', 'E95', 'E85', ...
                        'E51', 'E97', 'E67', 'E77', 'E65', 'E90', 'E72', 'E62', ...
                        'E114', 'E44', 'E100', 'E46', 'E102', 'E57'};
                    valueSet =   {'C3', 'C4', 'Cz', 'F3', 'F4', 'F7', 'F8', 'FP1', 'FP2', ...
                        'FPZ', 'Fz', 'O1', 'O2', 'P3', 'P4', 'P7', 'P8', 'AF3',...
                        'AF4', 'AF7', 'AF8', 'Afz', 'C1', 'C2', 'C5', 'C6', 'CP1', 'Cp2', ...
                        'CP3', 'CP4', 'Cp5', 'CP6', 'CpZ', 'F1', 'F10', 'F2', 'F5', 'F6', ...
                        'F9', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'Fcz', 'Ft10', ...
                        'FT7', 'FT8', 'Ft9', 'Oz', 'P1', 'P9', 'P10', 'P2', 'P5', 'P6', ...
                        'PO3', 'PO4', 'PO7', 'PO8', 'Poz', 'Pz', 'T10',...
                        'T9', 'TP10', 'Tp7', 'TP8', 'TP9'};
                else
                    keySet = {'E17', 'E22', 'E9', 'E11', 'E24', 'E124', 'E33', 'E122', ...
                        'E129', 'E36', 'E104', 'E45', 'E108', 'E52', 'E92', 'E57', 'E100', ...
                        'E58', 'E96', 'E70', 'E75', 'E83', 'E62', 'E15'};
                    valueSet =   {'NAS', 'Fp1', 'Fp2', 'Fz', 'F3', 'F4', 'F7', 'F8', 'Cz', ...
                        'C3', 'C4', 'T7', 'T8', 'P3', 'P4', 'LM', 'RM', 'P7', 'P8', 'O1', ...
                        'Oz', 'O2', 'Pz', 'FPZ'};
                end
                MARAParams.chanlocMap = containers.Map(keySet,valueSet);
            case 257
                if(MARAParams.largeMap)
                    keySet = {'E59', 'E183', 'E257', 'E36', 'E224', 'E47', 'E2', 'E37', ...
                        'E18', 'E26', 'E21', 'E116', 'E150', 'E87', 'E153', 'E69', 'E202', ...
                        'E96', 'E170', 'E101', 'E119', 'E5', 'E49', 'E219', 'E194', 'E67', ...
                        'E222', 'E211', 'E10', 'E81', 'E172', 'E64', 'E164', 'E169', 'E252', ...
                        'E88', 'E86', 'E34', 'E44', 'E161', 'E12', 'E179', 'E42', ...
                        'E66', 'E162', 'E109', 'E185', 'E24', 'E140', 'E126', 'E143', 'E207',...
                        'E79', 'E94', 'E29', 'E15', 'E190', 'E226', 'E142', 'E48', 'E106', ...
                        'E206', 'E76', 'E213', 'E97', 'E46', 'E84', 'E62', 'E68', 'E210'};
                    valueSet =   {'C3', 'C4', 'Cz', 'F3', 'F4', 'F7', 'F8', 'FP1', 'FP2', ...
                        'FPZ', 'Fz', 'O1', 'O2', 'P3', 'P4', 'T7', 'T8', 'P7', 'P8', 'Pz',...
                        'Poz', 'F2', 'FC5', 'Ft10', 'C6', 'Ft9', 'F6', 'FT8', 'AF8', 'CpZ',...
                        'CP6', 'C5', 'CP4', 'P10', 'F9', 'P1', 'P5', 'AF3', 'C1', 'PO8', ...
                        'AF4', 'TP8', 'FC3', 'CP3', 'P6', 'PO3', 'C2', 'FC1', 'PO4', ...
                        'Oz', 'Cp2', 'FC2', 'CP1', 'TP9', 'F1', 'Fcz', 'TP10', 'F10', 'P2', ...
                        'F5', 'P9', 'FC4', 'Cp5', 'FC6', 'Po7', 'AF7', 'Tp7', ...
                        'FT7', 'T9', 'T10'};
                else
                    keySet = {'E31', 'E37', 'E18', 'E21', 'E36', 'E224', 'E47', ...
                        'E2', 'E257', 'E59', 'E183', 'E69', 'E202', 'E87', 'E153', ...
                        'E94', 'E190', 'E96', 'E170', 'E116', 'E126', 'E150', 'E101', 'E26'};
                    valueSet =   {'NAS', 'Fp1', 'Fp2', 'Fz', 'F3', 'F4', 'F7', 'F8', 'Cz', ...
                        'C3', 'C4', 'T7', 'T8', 'P3', 'P4', 'LM', 'RM', 'P7', 'P8', 'O1', ...
                        'Oz', 'O2', 'Pz', 'FPZ'};
                end
                MARAParams.chanlocMap = containers.Map(keySet,valueSet);
        end
        clear keySet valueSet;
    end

% Case of EGI (Langer Presets)
elseif(~isempty(EEGSystem.name) && ...
        strcmp(EEGSystem.name, Csts.EEGSystemCsts.EGI_NAME))
    
    if( ~isempty(ChannelReductionParams))
        chan128 = [1:129];
%         chan128 = [2 3 4 5 6 7 9 10 11 12 13 15 16 18 19 20 22 23 24 26 27 ...
%             28 29 30 31 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 50 51 ...
%             52 53 54 55 57 58 59 60 61 62 64 65 66 67 69 70 71 72 74 75 76 ...
%             77 78 79 80 82 83 84 85 86 87 89 90 91 92 93 95 96 97 98 100 ...
%             101 102 103 104 105 106 108 109 110 111 112 114 115 116 117 ...
%             118 120 121 122 123 124 129];
        chan256 = [1:257];
%         chan256  = [2 3 4 5 6 7 8 9 11 12 13 14 15 16 17 19 20 21 22 ...
%             23 24 26 27 28 29 30 33 34 35 36 38 39 40 41 42 43 44 45 ...
%             47 48 49 50 51 52 53 55 56 57 58 59 60 61 62 63 64 65 66 ...
%             68 69 70 71 72 74 75 76 77 78 79 80 81 83 84 85 86 87 88 ...
%             89 90 93 94 95 96 97 98 99 100 101 103 104 105 106 107 108 ...
%             109 110 112 113 114 115 116 117 118 119 121 122 123 124 125 ...
%             126 127 128 129 130 131 132 134 135 136 137 138 139 140 141 ...
%             142 143 144 146 147 148 149 150 151 152 153 154 155 156 157 ...
%             158 159 160 161 162 163 164 166 167 168 169 170 171 172 173 ...
%             175 176 177 178 179 180 181 182 183 184 185 186 188 189 190 ...
%             191 192 193 194 195 196 197 198 200 201 202 203 204 205 206 ...
%             207 210 211 212 213 214 215 220 221 222 223 224 257];
    else
        chan128 = 1:129;
        chan256 = 1:257;
    end

    switch EEG.nbchan
        case 128
            eog_channels = []; %eog_channels = sort([1 32 8 14 17 21 25 125 126 127 128]);
            eeg_channels = setdiff(chan128, eog_channels);
            tobeExcludedChans = setdiff(1:129, union(chan128, eog_channels));
            
            EEG.data(end+1,:) = 0;
            EEG.nbchan = EEG.nbchan + 1;
            EEGSystem.refChan.idx = EEG.nbchan;
            
            
            if(length(EEG.chanlocs) ~= EEG.nbchan)                   
                if(~ EEGSystem.sys10_20)  % This is a look up which locates the channels based on 10-20 system labels
                    [~, EEG] = evalc(['pop_chanedit(EEG,' ...
                        '''load'',{ ''GSN-HydroCel-129.sfp'' , ''filetype'', ''sfp''})']);
                else
                    [~, EEG] = evalc(['pop_chanedit(EEG, ''lookup'', EEGSystem.sys10_20_file,' ...
                        '''load'',{ ''GSN-HydroCel-129.sfp'' , ''filetype'', ''autodetect''})']);
                end
            end
        case (128 + 1)
            eog_channels = sort([1 32 8 14 17 21 25 125 126 127 128]);
            eeg_channels = setdiff(chan128, eog_channels);
            tobeExcludedChans = setdiff(1:129, union(chan128, eog_channels));
            
            EEGSystem.refChan.idx = EEG.nbchan;
            if(length(EEG.chanlocs) ~= EEG.nbchan)                   
                if(~ EEGSystem.sys10_20) % Look up of the channel location coordinates based on the labels
                    [~, EEG] = evalc(['pop_chanedit(EEG,' ...
                        '''load'',{ ''GSN-HydroCel-129.sfp'' , ''filetype'', ''sfp''})']);
                else
                    [~, EEG] = evalc(['pop_chanedit(EEG, ''lookup'', EEGSystem.sys10_20_file,' ...
                        '''load'',{ ''GSN-HydroCel-129.sfp'' , ''filetype'', ''autodetect''})']);
                end
            end
        case 256
            eog_channels = [];
%             eog_channels = sort([31 32 37 46 54 252 248 244 241 25 18 10 1 226 ...
%                 230 234 238]);
            eeg_channels = setdiff(chan256, eog_channels);
            tobeExcludedChans = setdiff(1:257, union(chan256, eog_channels));
            
            EEG.data(end+1,:) = 0;
            EEG.nbchan = EEG.nbchan + 1;
            EEGSystem.refChan.idx = EEG.nbchan;
            if(length(EEG.chanlocs) ~= EEG.nbchan)                    
                if(~ EEGSystem.sys10_20)
                    [~, EEG] = evalc(['pop_chanedit(EEG,' ...
                        '''load'',{ ''GSN-HydroCel-257_be.sfp'' , ''filetype'', ''sfp''})']);
                else
                    [~, EEG] = evalc(['pop_chanedit(EEG, ''lookup'', EEGSystem.sys10_20_file,' ...
                        '''load'',{ ''GSN-HydroCel-257_be.sfp'' , ''filetype'', ''autodetect''})']);
                end
            end
        case (256 + 1)
            eog_channels = sort([31 32 37 46 54 252 248 244 241 25 18 10 1 226 ...
                230 234 238]);
            eeg_channels = setdiff(chan256, eog_channels);
            tobeExcludedChans = setdiff(1:257, union(chan256, eog_channels));
            
            EEGSystem.refChan.idx = EEG.nbchan;
            if(length(EEG.chanlocs) ~= EEG.nbchan)
                if(~ EEGSystem.sys10_20)
                    [~, EEG] = evalc(['pop_chanedit(EEG,' ...
                        '''load'',{ ''GSN-HydroCel-257_be.sfp'' , ''filetype'', ''sfp''})']);
                else
                    [~, EEG] = evalc(['pop_chanedit(EEG, ''lookup'', EEGSystem.sys10_20_file,' ...
                        '''load'',{ ''GSN-HydroCel-257_be.sfp'' , ''filetype'', ''autodetect''})']);
                end
            end
        case 395  %% .fif files
            addpath('../fieldtrip-20160630/'); 
            % Get rid of two wrong channels 63 and 64
            eegs = arrayfun(@(x) strncmp('EEG',x.labels, length('EEG')), EEG.chanlocs, 'UniformOutput', false);
            not_ecg = arrayfun(@(x) ~ strncmp('EEG063',x.labels, length('EEG063')), EEG.chanlocs, 'UniformOutput', false);
            not_wrong = arrayfun(@(x) ~ strncmp('EEG064',x.labels, length('EEG064')), EEG.chanlocs, 'UniformOutput', false);
            eeg_channels = find(cell2mat(eegs) & cell2mat(not_ecg) & cell2mat(not_wrong)); %#ok<NASGU>
            [~, EEG] = evalc('pop_select( EEG , ''channel'', channels)');
            EEG.data = EEG.data * 1e6;% Change from volt to microvolt
            % Convert channel positions to EEG_lab format 
            [~, hd] = evalc('ft_read_header(ORIGINAL_FILE)');
            hd_idx = true(1,74);
            hd_idx(63:64) = false;
            positions = hd.elec.chanpos(hd_idx,:);
            fid = fopen( 'pos_temp.txt', 'wt' );
            fprintf( fid, 'NumberPositions=	72\n');
            fprintf( fid, 'UnitPosition	cm\n');
            fprintf( fid, 'Positions\n');
            for pos = 1:length(positions)
              fprintf( fid, '%.8f %.8f %.8f\n', positions(pos,:));
            end
            fprintf( fid, 'Labels\n');
            fprintf( fid, ['EEG01	EEG02	EEG03	EEG04	EEG05	EEG06	EEG07	EEG08	EEG09	EEG010	EEG011	EEG012 '...
                          'EEG013	EEG014	EEG015	EEG016	EEG017	EEG018	EEG019	EEG020	EEG021	EEG022	EEG023	EEG024 '...
                          'EEG025	EEG026	EEG027	EEG028	EEG029	EEG030	EEG031	EEG032	EEG033	EEG034	EEG035	EEG036 '...
                          'EEG037	EEG038	EEG039	EEG040	EEG041	EEG042	EEG043	EEG044	EEG045	EEG046	EEG047	EEG048 '...
                          'EEG049	EEG050	EEG051	EEG052	EEG053	EEG054	EEG055	EEG056	EEG057	EEG058	EEG059	EEG060 '...
                          'EEG061	EEG062 EEG065	EEG066	EEG067	EEG068	EEG069	EEG070	EEG071	EEG072 '...
                          'EEG073	EEG074']);
            fprintf( fid, '\n');
            fclose(fid);
            eeglab_pos = readeetraklocs('pos_temp.txt');
            delete('pos_temp.txt');
            EEG.chanlocs = eeglab_pos;

            % Distinguish EOGs(61 & 62) from EEGs
            eegs = arrayfun(@(x) strncmp('EEG',x.labels, length('EEG')), EEG.chanlocs, 'UniformOutput', false);
            eog1 = arrayfun(@(x) strncmp('EEG061',x.labels, length('EEG061')), EEG.chanlocs, 'UniformOutput', false);
            eog2 = arrayfun(@(x) strncmp('EEG062',x.labels, length('EEG062')), EEG.chanlocs, 'UniformOutput', false); 

            eeg_channels = find((cellfun(@(x) x == 1, eegs)));
            channel1 = find((cellfun(@(x) x == 1, eog1)));
            channel2 = find((cellfun(@(x) x == 1, eog2)));
            eog_channels = [channel1 channel2];
            eeg_channels = setdiff(eeg_channels, eog_channels); 
            EEGSystem.refChan.idx = EEG.nbchan;
            clear channel1 channel2 eegs eog1 eog2 eeglab_pos fid hd_idx hd not_wrong not_ecg eegs;
        otherwise
            error('This number of channel is not supported.')

    end
    clear chan128 chan256;
    
    % Make ICA map of channels
    if (~isempty(MARAParams))
        switch EEG.nbchan
            case 129
                % Make the map for ICA
                if(MARAParams.largeMap)
                    keySet = {'E36', 'E104', 'E129', 'E24', 'E124', 'E33', 'E122', 'E22', 'E9', ...
                        'E15', 'E11', 'E70', 'E83', 'E52', 'E92', 'E58', 'E96',  ...
                        'E23', 'E3', 'E26', 'E2', 'E16', 'E30', 'E105', 'E41', 'E103', 'E37', ...
                        'E87', 'E42', 'E93', 'E47', 'E98', 'E55', 'E19', 'E1', 'E4', 'E27', ...
                        'E123', 'E32', 'E13', 'E112', 'E29', 'E111', 'E28', 'E117', 'E6', ...
                        'E12', 'E34', 'E116', 'E38', 'E75', 'E60', 'E64', 'E95', 'E85', ...
                        'E51', 'E97', 'E67', 'E77', 'E65', 'E90', 'E72', 'E62', ...
                        'E114', 'E44', 'E100', 'E46', 'E102', 'E57'};
                    valueSet =   {'C3', 'C4', 'Cz', 'F3', 'F4', 'F7', 'F8', 'FP1', 'FP2', ...
                        'FPZ', 'Fz', 'O1', 'O2', 'P3', 'P4', 'P7', 'P8', 'AF3',...
                        'AF4', 'AF7', 'AF8', 'Afz', 'C1', 'C2', 'C5', 'C6', 'CP1', 'Cp2', ...
                        'CP3', 'CP4', 'Cp5', 'CP6', 'CpZ', 'F1', 'F10', 'F2', 'F5', 'F6', ...
                        'F9', 'FC1', 'FC2', 'FC3', 'FC4', 'FC5', 'FC6', 'Fcz', 'Ft10', ...
                        'FT7', 'FT8', 'Ft9', 'Oz', 'P1', 'P9', 'P10', 'P2', 'P5', 'P6', ...
                        'PO3', 'PO4', 'PO7', 'PO8', 'Poz', 'Pz', 'T10',...
                        'T9', 'TP10', 'Tp7', 'TP8', 'TP9'};
                else
                    keySet = {'E17', 'E22', 'E9', 'E11', 'E24', 'E124', 'E33', 'E122', ...
                        'E129', 'E36', 'E104', 'E45', 'E108', 'E52', 'E92', 'E57', 'E100', ...
                        'E58', 'E96', 'E70', 'E75', 'E83', 'E62', 'E15'};
                    valueSet =   {'NAS', 'Fp1', 'Fp2', 'Fz', 'F3', 'F4', 'F7', 'F8', 'Cz', ...
                        'C3', 'C4', 'T7', 'T8', 'P3', 'P4', 'LM', 'RM', 'P7', 'P8', 'O1', ...
                        'Oz', 'O2', 'Pz', 'FPZ'};
                end
                MARAParams.chanlocMap = containers.Map(keySet,valueSet);
            case 257
                if(MARAParams.largeMap)
                    keySet = {'E59', 'E183', 'E257', 'E36', 'E224', 'E47', 'E2', 'E37', ...
                        'E18', 'E26', 'E21', 'E116', 'E150', 'E87', 'E153', 'E69', 'E202', ...
                        'E96', 'E170', 'E101', 'E119', 'E5', 'E49', 'E219', 'E194', 'E67', ...
                        'E222', 'E211', 'E10', 'E81', 'E172', 'E64', 'E164', 'E169', 'E252', ...
                        'E88', 'E86', 'E34', 'E44', 'E161', 'E12', 'E179', 'E42', ...
                        'E66', 'E162', 'E109', 'E185', 'E24', 'E140', 'E126', 'E143', 'E207',...
                        'E79', 'E94', 'E29', 'E15', 'E190', 'E226', 'E142', 'E48', 'E106', ...
                        'E206', 'E76', 'E213', 'E97', 'E46', 'E84', 'E62', 'E68', 'E210'};
                    valueSet =   {'C3', 'C4', 'Cz', 'F3', 'F4', 'F7', 'F8', 'FP1', 'FP2', ...
                        'FPZ', 'Fz', 'O1', 'O2', 'P3', 'P4', 'T7', 'T8', 'P7', 'P8', 'Pz',...
                        'Poz', 'F2', 'FC5', 'Ft10', 'C6', 'Ft9', 'F6', 'FT8', 'AF8', 'CpZ',...
                        'CP6', 'C5', 'CP4', 'P10', 'F9', 'P1', 'P5', 'AF3', 'C1', 'PO8', ...
                        'AF4', 'TP8', 'FC3', 'CP3', 'P6', 'PO3', 'C2', 'FC1', 'PO4', ...
                        'Oz', 'Cp2', 'FC2', 'CP1', 'TP9', 'F1', 'Fcz', 'TP10', 'F10', 'P2', ...
                        'F5', 'P9', 'FC4', 'Cp5', 'FC6', 'Po7', 'AF7', 'Tp7', ...
                        'FT7', 'T9', 'T10'};
                else
                    keySet = {'E31', 'E37', 'E18', 'E21', 'E36', 'E224', 'E47', ...
                        'E2', 'E257', 'E59', 'E183', 'E69', 'E202', 'E87', 'E153', ...
                        'E94', 'E190', 'E96', 'E170', 'E116', 'E126', 'E150', 'E101', 'E26'};
                    valueSet =   {'NAS', 'Fp1', 'Fp2', 'Fz', 'F3', 'F4', 'F7', 'F8', 'Cz', ...
                        'C3', 'C4', 'T7', 'T8', 'P3', 'P4', 'LM', 'RM', 'P7', 'P8', 'O1', ...
                        'Oz', 'O2', 'Pz', 'FPZ'};
                end
                MARAParams.chanlocMap = containers.Map(keySet,valueSet);
        end
        clear keySet valueSet;
    end
else
   if(isempty(EEG.chanlocs) || isempty([EEG.chanlocs.X]) || ...
                    length(EEG.chanlocs) ~= EEG.nbchan)
       error('EEG.chanlocs is necessary for interpolation.');
   end
    all_chans = 1:EEG.nbchan;
    eeg_channels = setdiff(all_chans, union(eog_channels, tobeExcludedChans));
    clear all_chans;
end

% Seperate EEG channels from EOG channels
[~, EOG] = evalc('pop_select( EEG , ''channel'', eog_channels)');
[~, EEG] = evalc('pop_select( EEG , ''channel'', eeg_channels)');
% Map original channel lists to new ones after the above separation
if ~isempty(EEGSystem.refChan)
    [~, idx] = ismember(EEGSystem.refChan.idx, eeg_channels);
    EEGSystem.refChan.idx = idx(idx ~= 0);
end

% Chanloc standard dimension
chanSize = size(EEG.chanlocs);
if chanSize(2) == 1
    EEG.chanlocs = EEG.chanlocs';
    EOG.chanlocs = EOG.chanlocs';
end
clear chanSize;


EEG.automagic.EEGSystem.params = EEGSystem;
EEG.automagic.channelReduction.params = ChannelReductionParams;
EEG.automagic.channelReduction.excludedChannels = tobeExcludedChans;
EEG.automagic.channelReduction.usedEEGChannels = eeg_channels;
EEG.automagic.channelReduction.usedEOGChannels = eog_channels;

end