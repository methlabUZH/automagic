function [EEG, varargout] = preprocess(data, varargin)
% preprocess the input EEG 
%   [EEG, varargout] = preprocess(data, varargin)
%   where data is the EEGLAB data structure and varargin is an 
%   optional parameter which must be a structure with optional fields 
%   'FilterParams', 'ASRParams', 'PCAParams', 'ICAParams', 'PrepParams',
%   'InterpolationParams', 'EOGRegressionParams', 'EEGSystem',
%   'ChannelReductionParams', 'HighvarParams' and 'ORIGINAL_FILE' to 
%   specify parameters for filtering, cleanrawdata(), pca, ica, prep robust 
%   average referencing, interpolation, eog regression, channel locations,
%   reducing channels, high variance channel rejection and original 
%   file address respectively. The latter one is needed only if a '*.fif' 
%   file is used, otherwise it can be omitted.
%   
%   To learn more about 'FilterParams', 'ICAParams', 'PCAParams' and
%   'HighvarParams' please see their corresponding functions performFilter.m, 
%   performMaraICA.m, performPCA.m and performHighvarianceChannelRejection.m.
%
%   To learn more about EEGSystem and ChannelreductionParams please see
%   SystemDependentParse.m.
%   
%   'ASRParams' is an optional structure which has the same parameters as 
%   required by clean_artifacts(). For more information please
%   see clean_artifacts() in Artefact Subspace Reconstruction.
%   
%   'PrepParams' is an optional struture required by prep library. For more
%   information please see their documentation.
%   
%   'InterpolationParams' is an optional structure with an optional field
%   'method' which can be on of the following chars: 'spherical',
%   'invdist' and 'spacetime'. The default value is
%   InterpolationParams.method = 'spherical'. To learn more about these
%   three methods please see eeg_interp.m of EEGLAB.
%
%   'ORIGINAL_FILE' is necassary only in case of '*.fif' files. In that case,
%   this should be the address of the file where this EEG data is loaded
%   from.
%   
%   If varargin is ommited, default values are used. If any of the fields
%   of varargin are ommited, corresponsing default values are used. If a
%   structure is given as 'struct([])' then the corresponding operation is
%   omitted and is not performed; for example, ICAParams = struct([])
%   skips the ICA and does not perform any ICA. Whereas if ICAParams =
%   struct() or if ICAParams is simply not given, then the default value 
%   will be used.
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

Defaults = DefaultParameters;
Csts = PreprocessingConstants;
p = inputParser;
addParameter(p,'EEGSystem', Defaults.EEGSystem, @isstruct);
addParameter(p,'FilterParams', Defaults.FilterParams, @isstruct);
addParameter(p,'PrepParams', Defaults.PrepParams, @isstruct);
addParameter(p,'ASRParams', Defaults.ASRParams, @isstruct);
addParameter(p,'PCAParams', Defaults.PCAParams, @isstruct);
addParameter(p,'HighvarParams', Defaults.HighvarParams, @isstruct);
addParameter(p,'ICAParams', Defaults.ICAParams, @isstruct);
addParameter(p,'InterpolationParams', Defaults.InterpolationParams, @isstruct);
addParameter(p,'EOGRegressionParams', Defaults.EOGRegressionParams, @isstruct);
addParameter(p,'ChannelReductionParams', Defaults.ChannelReductionParams, @isstruct);
addParameter(p,'ORIGINAL_FILE', Csts.GeneralCsts.ORIGINAL_FILE, @ischar);
parse(p, varargin{:});
params = p.Results;
EEGSystem = p.Results.EEGSystem;
FilterParams = p.Results.FilterParams;
ASRParams = p.Results.ASRParams;
PrepParams = p.Results.PrepParams;
HighvarParams = p.Results.HighvarParams;
PCAParams = p.Results.PCAParams;
ICAParams = p.Results.ICAParams;
InterpolationParams = p.Results.InterpolationParams; %#ok<NASGU>
EOGRegressionParams = p.Results.EOGRegressionParams;
ChannelReductionParams = p.Results.ChannelReductionParams;
ORIGINAL_FILE = p.Results.ORIGINAL_FILE;
clear p varargin;

% Add and download necessary paths
downloadAndAddPaths(struct('PrepParams', PrepParams, ...
    'PCAParams', PCAParams));
                          
% Set system dependent parameters and eeparate EEG from EOG
[EEG, EOG, EEGSystem, ICAParams] = ...
    systemDependentParse(data, EEGSystem, ChannelReductionParams, ...
    EOGRegressionParams, ICAParams, ORIGINAL_FILE);
EEGRef = EEG;

% Remove the reference channel from the rest of preprocessing
[~, EEG] = evalc('pop_select(EEG, ''nochannel'', EEGSystem.refChan)');
EEG.automagic.channelReduction.new_RefChan = EEGSystem.refChan;
EEGOrig = EEG;


%% Preprocessing
[s, ~] = size(EEG.data);
EEG.automagic.preprocessing.toRemove = [];
EEG.automagic.preprocessing.removedMask = false(1, s); clear s;

% Running prep
[EEG, EOG] = performPrep(EEG, EOG, PrepParams, EEGSystem.refChan);


% Clean EEG using clean_rawdata()
[EEG, EOG] = perform_cleanrawdata(EEG, EOG, ASRParams);

% Filtering on the whole dataset
display(PreprocessingConstants.FilterCsts.RUN_MESSAGE);
EEG = performFilter(EEG, FilterParams);
if ~isempty(EOG.data)
    EOG = performFilter(EOG, FilterParams);
end

% Remove channels
toRemove = EEG.automagic.preprocessing.toRemove;
removedMask = EEG.automagic.preprocessing.removedMask;
[~, newToRemove] = intersect(find(~removedMask), toRemove); %#ok<ASGLU>
[~, EEG] = evalc('pop_select(EEG, ''nochannel'', newToRemove)');
removedMask(toRemove) = 1;
toRemove = [];
EEG.automagic.preprocessing.removedMask = removedMask;
EEG.automagic.preprocessing.toRemove = toRemove;
clear toRemove removedMask newToRemove;

% Remove effect of EOG
EEG.automagic.EOGRegression.performed = 'no';
if( EOGRegressionParams.performEOGRegression )
    EEG = performEOGRegression(EEG, EOG);
end
EEG_regressed = EEG;

% PCA or ICA
EEG.automagic.ica.performed = 'no';
EEG.automagic.pca.performed = 'no';
if ( ~isempty(ICAParams) )
    try
        EEG = performMaraICA(EEG, ICAParams);
    catch ME
        message = ['ICA is not done on this subject, continue with the next steps: ' ...
            ME.message];
        warning(message)
        EEG.automagic.ica.performed = 'FAILED';
        EEG.automagic.error_msg = message;
    end
elseif ( ~isempty(PCAParams))
    [EEG, pca_noise] = performPCA(EEG, PCAParams);
end
EEG_cleared = EEG;

% Detrending
doubled_data = double(EEG.data);
res = bsxfun(@minus, doubled_data, mean(doubled_data, 2));
singled_data = single(res);
EEG.data = singled_data;
clear doubled_data res singled_data;

% Reject channels based on high variance
EEG.automagic.highVarianceRejection.performed = 'no';
if ~isempty(HighvarParams)
    [~, EEG] = evalc('performHighvarianceChannelRejection(EEG, HighvarParams)');
end

% Put back removed channels
removedChans = find(EEG.automagic.preprocessing.removedMask);
for chan_idx = 1:length(removedChans)
    chan_nb = removedChans(chan_idx);
    EEG.data = [EEG.data(1:chan_nb-1,:); ...
                  NaN(1,size(EEG.data,2));...
                  EEG.data(chan_nb:end,:)];
    EEG.chanlocs = [EEG.chanlocs(1:chan_nb-1), ...
                      EEGOrig.chanlocs(chan_nb), EEG.chanlocs(chan_nb:end)];
end
% Put back refrence channel
refChan = EEGSystem.refChan;
EEG.data = [EEG.data(1:refChan-1,:); ...
                        zeros(1,size(EEG.data,2));...
                        EEG.data(refChan:end,:)];
EEG.chanlocs = [EEG.chanlocs(1:refChan-1), EEGRef.chanlocs(refChan), ...
                    EEG.chanlocs(refChan:end)];                   
EEG.nbchan = size(EEG.data,1);
clear chan_nb re_chan;

% Write back output
EEG.automagic.autoBadChans = setdiff(removedChans, EEGSystem.refChan);
EEG.automagic.params = params;

%% Creating the final figure to save
plot_FilterParams.high.freq = 1;
plot_FilterParams.high.order = [];
EEG_filtered_toplot = performFilter(EEGOrig, plot_FilterParams);
fig1 = figure('visible', 'off');
set(gcf, 'Color', [1,1,1])
hold on
% eog figure
subplot(11,1,1)
if ~isempty(EOG.data)
    imagesc(EOG.data);
    colormap jet
    caxis([-100 100])
    XTicks = [] ;
    XTicketLabels = [];
    set(gca,'XTick', XTicks)
    set(gca,'XTickLabel', XTicketLabels)
    title('Filtered EOG data');
else
    title('No EOG data available');
end
%eeg figure
subplot(11,1,2:3)
imagesc(EEG_filtered_toplot.data);
colormap jet
caxis([-100 100])
XTicks = [] ;
XTicketLabels = [];
set(gca,'XTick', XTicks)
set(gca,'XTickLabel', XTicketLabels)
title('Filtered EEG data')
%eeg figure
subplot(11,1,4:5)
imagesc(EEG_filtered_toplot.data);
axe = gca;
hold on;
bads = EEG.automagic.autoBadChans;
for i = 1:length(bads)
    y = bads(i);
    p1 = [0, size(EEG_filtered_toplot.data, 2)];
    p2 = [y, y];
    plot(axe, p1, p2, 'b' ,'LineWidth', 0.5);
end
hold off;
colormap jet;
caxis([-100 100])
set(gca,'XTick', XTicks)
set(gca,'XTickLabel', XTicketLabels)
title('Detected bad channels')
% figure;
subplot(11,1,6:7)
imagesc(EEG_regressed.data);
colormap jet
caxis([-100 100])
set(gca,'XTick',XTicks)
set(gca,'XTickLabel',XTicketLabels)
title('EOG regressed out');
%figure;
ica_subplot = subplot(11,1,8:9);
imagesc(EEG_cleared.data);
colormap jet
caxis([-100 100])
set(gca,'XTick',XTicks)
set(gca,'XTickLabel',XTicketLabels)
if (~isempty(ICAParams))
    if strcmp(EEG.automagic.ica.performed, 'FAILED')
        title_text = '\color{red}ICA FALIED';
        cla(ica_subplot)
    else
        title_text = 'ICA corrected clean data';
    end
elseif(~isempty(PCAParams))
    title_text = 'PCA corrected clean data';
else
    title_text = '';
end
title(title_text)
%figure;
if( ~isempty(fieldnames(PCAParams)) && (isempty(PCAParams.lambda) || PCAParams.lambda ~= -1))
    subplot(11,1,10:11)
    imagesc(pca_noise);
    colormap jet
    caxis([-100 100])
    XTicks = 0:length(EEG.data)/5:length(EEG.data) ;
    XTicketLabels = round(0:length(EEG.data)/EEG.srate/5:length(EEG.data)/EEG.srate);
    set(gca,'XTick',XTicks)
    set(gca,'XTickLabel',XTicketLabels)
    title('PCA noise')
end

% Pot a seperate figure for only the original filtered data
fig2 = figure('visible', 'off');
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1) * 1.5;
bottom = outerpos(2);
ax_width = outerpos(3) - ti(1) - ti(3) * 1.5;
ax_height = outerpos(4) - ti(2) * 0.5 - ti(4);
ax.Position = [left bottom ax_width ax_height];
set(gcf, 'Color', [1,1,1])
imagesc(EEG_filtered_toplot.data);
colormap jet
caxis([-100 100])
set(ax,'XTick', XTicks)
set(ax,'XTickLabel', XTicketLabels)
title_str = [num2str(plot_FilterParams.high.freq) ' Hz High pass filtered EEG data'];
title(title_str, 'FontSize', 10)

varargout{1} = fig1;
varargout{2} = fig2;
