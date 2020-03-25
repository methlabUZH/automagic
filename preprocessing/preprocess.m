function [EEG, varargout] = preprocess(data, varargin)
% preprocess the input EEG 
%   [EEG, varargout] = preprocess(data, params)
%   where data is the EEGLAB data structure and params is an 
%   optional parameter specifying preprocessing parameters.
%   EEG is the output EEG after being preprocessed with additional fields.
%   varargout is a list of plots obtained during the preprocessing.
%
%   And example of the params where filtering parameters and clean_rawdata()
%   parameters are specified and other parameters are ommitted so that the 
%   deafult value is used, is as shown below:
%   params = struct('FilterParams', struct('notch', struct('freq', 50), ...
%                                        'high',  struct('freq', 0.5,...
%                                                        'order', []),...
%                                        'low',   struct('freq', 30,...
%                                                         'order',
%                                                         []))),...
%                   'CRDParams',    struct('ChannelCriterion',   0.85,...
%                                          'LineNoiseCriterion', 4,...
%                                          'BurstCriterion',     5,...
%                                          'WindowCriterion',    0.25, ...
%                                          'Highpass',           [0.25 0.75])
%                    )
%   
%   params must be a structure with optional fields 
%   'FilterParams', 'CRDParams', 'RPCAParams', 'MARAParams', 'PrepParams',
%   'InterpolationParams', 'EOGRegressionParams', 'EEGSystem',
%   'ChannelReductionParams', 'HighvarParams', 'MinvarParams', 'Settings', 'DetrendingParams'
%   and 'ORIGINAL_FILE' to specify parameters for filtering, clean_rawdata(), 
%   rpca, mara ica, prep robust average referencing, interpolation, 
%   eog regression, channel locations, reducing channels, high variance 
%   channel rejection, settings of this preprocess.m file, detrending and 
%   original file address respectively. The latter one is the only non-struct 
%   one, and needed only if a '*.fif' file is used, otherwise it can be omitted.
%
%   If params is ommited, default values are used. If any of the fields
%   of params are ommited, corresponsing default values are used. If a
%   structure is given as 'struct([])' then the corresponding operation is
%   omitted and is not performed; for example, MARAParams = struct([])
%   skips the ICA and does not perform any ICA. Whereas if MARAParams =
%   struct() or if MARAParams is simply not given, then the default value 
%   will be used.
%   
%   'PrepParams' is an optional struture required by prep library. For more
%   information please see their documentation.
%   
%   'InterpolationParams' is an optional structure with an optional field
%   'method' which can be on of the following chars: 'spherical',
%   'invdist' and 'spacetime'. To learn more about these
%   three methods please see eeg_interp.m of EEGLAB.
%
%   DetrendingParams could be either struct() or struct([]) specifying
%   whether to perfrom detrending or not.
%
%   'ORIGINAL_FILE' is necassary only in case of '*.fif' files. In that case,
%   this should be the address of the file where this EEG data is loaded
%   from.
%  
%   To learn more about 'FilterParams', 'CRDParams', 'MARAParams', 
%   'RPCAParams', 'EOGRegressionParams' and 'HighvarParams' please see 
%   their corresponding functions performFilter.m,  performCleanrawdata.m,
%   performMaraICA.m, performRPCA.m, performEOGRegression.m and 
%   performHighvarianceChannelRejection.m.
%
%   To learn more about EEGSystem and ChannelreductionParams please see
%   SystemDependentParse.m.
%
%   A complete example of all possible parameters can be found in
%   RecommendedParameters.m (please do not change this file). All default
%   values are taken from DefaultParameters.m.
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

Defaults = DefaultParameters;
Recs = RecommendedParameters;
Csts = PreprocessingConstants;
p = inputParser;
addParameter(p,'EEGSystem', Defaults.EEGSystem, @isstruct);
addParameter(p,'FilterParams', Defaults.FilterParams, @isstruct);
addParameter(p,'PrepParams', Defaults.PrepParams, @isstruct);
addParameter(p,'CRDParams', Defaults.CRDParams, @isstruct);
addParameter(p,'RPCAParams', Defaults.RPCAParams, @isstruct);
addParameter(p,'HighvarParams', Defaults.HighvarParams, @isstruct);
addParameter(p,'MinvarParams', Defaults.MinvarParams, @isstruct);
addParameter(p,'MARAParams', Defaults.MARAParams, @isstruct);
addParameter(p,'ICLabelParams', Defaults.ICLabelParams, @isstruct);
addParameter(p,'InterpolationParams', Defaults.InterpolationParams, @isstruct);
addParameter(p,'EOGRegressionParams', Defaults.EOGRegressionParams, @isstruct);
addParameter(p,'ChannelReductionParams', Defaults.ChannelReductionParams, @isstruct);
addParameter(p,'Settings', Defaults.Settings, @isstruct);
addParameter(p,'DetrendingParams', Defaults.DetrendingParams, @isstruct);
addParameter(p,'ORIGINAL_FILE', Csts.GeneralCsts.ORIGINAL_FILE, @ischar);
parse(p, varargin{:});
params = p.Results;
EEGSystem = p.Results.EEGSystem;
FilterParams = p.Results.FilterParams;
CRDParams = p.Results.CRDParams;
PrepParams = p.Results.PrepParams;
HighvarParams = p.Results.HighvarParams;
MinvarParams = p.Results.MinvarParams;
RPCAParams = p.Results.RPCAParams;
MARAParams = p.Results.MARAParams;
ICLabelParams = p.Results.ICLabelParams;
InterpolationParams = p.Results.InterpolationParams; %#ok<NASGU>
EOGRegressionParams = p.Results.EOGRegressionParams;
ChannelReductionParams = p.Results.ChannelReductionParams;
Settings = p.Results.Settings;
DetrendingParams = p.Results.DetrendingParams;
ORIGINAL_FILE = p.Results.ORIGINAL_FILE;

if isempty(Settings)
    Settings = Recs.Settings;
end
clear p varargin;

% Add and download necessary paths
addPreprocessingPaths(struct('PrepParams', PrepParams, 'CRDParams', CRDParams, ...
    'RPCAParams', RPCAParams, 'MARAParams', MARAParams, 'ICLabelParams', ICLabelParams));
                          
% Set system dependent parameters and eeparate EEG from EOG
[EEG, EOG, EEGSystem, MARAParams] = ...
    systemDependentParse(data, EEGSystem, ChannelReductionParams, ...
    MARAParams, ORIGINAL_FILE);
EEGRef = EEG;

% Remove the reference channel from the rest of preprocessing
if ~isempty(EEGSystem.refChan)
    [~, EEG] = evalc('pop_select(EEG, ''nochannel'', EEGSystem.refChan.idx)');
end
EEG.automagic.channelReduction.newRefChan = EEGSystem.refChan;
EEGOrig = EEG;

if Settings.trackAllSteps
   allSteps = matfile(Settings.pathToSteps, 'Writable', true);
   allSteps.EEGOrig = EEGOrig;
end


% Remove biosemi before preprocessing steps to avoid potential conflicts
allPaths = path;
allPaths = strsplit(allPaths, pathsep);
idx = contains(allPaths, 'biosig');
allPaths(~idx) = [];
automagicPaths = strjoin(allPaths, pathsep);
rmpath(automagicPaths);

%% Preprocessing
[s, ~] = size(EEG.data);
EEG.automagic.preprocessing.toRemove = [];
EEG.automagic.preprocessing.removedMask = false(1, s); clear s;
EEG.chanlocs(1).maraLabel = [];

% Running prep
try
[EEG, EOG] = performPrep(EEG, EOG, PrepParams, EEGSystem.refChan);
catch ME
    message = ['PREP is not done on this subject, continue with the next steps: ' ...
        ME.message];
        warning(message)
        EEG.automagic.PREP.performed = 'FAILED';
        EEG.automagic.error_msg = message;
end
if Settings.trackAllSteps && ~isempty(PrepParams)
   allSteps = matfile(Settings.pathToSteps, 'Writable', true);
   allSteps.EEGprep = EEG;
end

% Clean EEG using clean_rawdata()
[EEG, EOG] = performCleanrawdata(EEG, EOG, CRDParams);
if Settings.trackAllSteps && ~isempty(CRDParams)
   allSteps = matfile(Settings.pathToSteps, 'Writable', true);
   allSteps.EEGcrd = EEG;
end

if isfield(EEG.automagic.crd,'badChans')
if (length(EEG.automagic.crd.badChans) == length(EEG.automagic.channelReduction.usedEEGChannels))
    message = 'All non-excluded channels identified as bad channels. Interpolation will not be possible';
    warning(message)
    EEG.automagic.badChanError = message;
end
end

% Filtering on the whole dataset
display(PreprocessingConstants.FilterCsts.RUN_MESSAGE);
EEG = performFilter(EEG, FilterParams);
if isfield(EEG.automagic,'ZapFig')
    fig3 = EEG.automagic.ZapFig;
    EEG.automagic = rmfield(EEG.automagic,'ZapFig');
else
    fig3 = [];
end

if ~isempty(EOG.data)
    EOG = performFilter(EOG, FilterParams);
    if isfield(EEG.automagic,'ZapFig')
        EEG.automagic = rmfield(EEG.automagic,'ZapFig');
    end
end

if Settings.trackAllSteps && ~isempty(FilterParams)
   allSteps = matfile(Settings.pathToSteps, 'Writable', true);
   allSteps.EEGfiltered = EEG;
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
EEG = performEOGRegression(EEG, EOG, EOGRegressionParams);
EEG_regressed = EEG;

if Settings.trackAllSteps && ~isempty(EOGRegressionParams)
   allSteps = matfile(Settings.pathToSteps, 'Writable', true);
   allSteps.EEGRegressed = EEG;
end

% PCA or ICA
EEG.automagic.mara.performed = 'no';
EEG.automagic.rpca.performed = 'no';
EEG.automagic.iclabel.performed = 'no';
if ( ~isempty(ICLabelParams) )
    try
        EEG = performICLabel(EEG, ICLabelParams);
        EEG.icachansind = find(~EEG.automagic.preprocessing.removedMask);
    catch ME
        message = ['ICLabel is not done on this subject, continue with the next steps: ' ...
            ME.message];
        warning(message)
        EEG.automagic.iclabel.performed = 'FAILED';
        EEG.automagic.error_msg = message;
    end
elseif ( ~isempty(MARAParams) )
    try
        EEG = performMARA(EEG, MARAParams);
        EEG.icachansind = find(~EEG.automagic.preprocessing.removedMask);
    catch ME
        message = ['MARA ICA is not done on this subject, continue with the next steps: ' ...
            ME.message];
        warning(message)
        EEG.automagic.mara.performed = 'FAILED';
        if size(EEG.chanlocs,2) < 3 && contains(ME.identifier,'Automagic:MARA:notEnoughChannels')
            message = 'MARA ICA is not done on this subject: Most likely too few good channels remain';
            EEG.automagic.error_msg = message;
            disp(message);
        else
            EEG.automagic.error_msg = message;
        end        
    end
elseif ( ~isempty(RPCAParams))
    [EEG, pca_noise] = performRPCA(EEG, RPCAParams);
end
EEG_cleared = EEG;

if Settings.trackAllSteps
    if ~isempty(RPCAParams)
       allSteps = matfile(Settings.pathToSteps, 'Writable', true);
       allSteps.EEGRPCA = EEG;
    elseif ~isempty(MARAParams)
       allSteps = matfile(Settings.pathToSteps, 'Writable', true);
       allSteps.EEGMARA = EEG;
    elseif ~isempty(ICLabelParams)
        allSteps = matfile(Settings.pathToSteps, 'Writable', true);
        allSteps.EEGICLabel = EEG;
    end
end

% Detrending
if ~ isempty(DetrendingParams)
    doubled_data = double(EEG.data);
    res = bsxfun(@minus, doubled_data, mean(doubled_data, 2));
    singled_data = single(res);
    EEG.data = singled_data;
    clear doubled_data res singled_data;

    if Settings.trackAllSteps
       allSteps = matfile(Settings.pathToSteps, 'Writable', true);
       allSteps.EEGdetrended = EEG;
    end
end

% Reject channels based on high variance
EEG.automagic.highVarianceRejection.performed = 'no';
if ~isempty(HighvarParams)
    [~, EEG] = evalc('performHighvarianceChannelRejection(EEG, HighvarParams)');
end

if Settings.trackAllSteps && ~isempty(HighvarParams)
   allSteps = matfile(Settings.pathToSteps, 'Writable', true);
   allSteps.EEGHighvarred = EEG;
end

% Reject channels based on minimum variance
EEG.automagic.minVarianceRejection.performed = 'no';
if ~isempty(MinvarParams)
    [~, EEG] = evalc('performMinvarianceChannelRejection(EEG, MinvarParams)');
end

if Settings.trackAllSteps && ~isempty(MinvarParams)
   allSteps = matfile(Settings.pathToSteps, 'Writable', true);
   allSteps.EEGMinvarred = EEG;
end

% Put back removed channels
removedChans = find(EEG.automagic.preprocessing.removedMask);
for chan_idx = 1:length(removedChans)
    chan_nb = removedChans(chan_idx);
    EEG.data = [EEG.data(1:chan_nb-1,:); ...
        NaN(1,size(EEG.data,2));...
        EEG.data(chan_nb:end,:)];
    EEGOrig.chanlocs(chan_nb).maraLabel = [];
    EEG.chanlocs = [EEG.chanlocs(1:chan_nb-1), ...
        EEGOrig.chanlocs(chan_nb), EEG.chanlocs(chan_nb:end)];
    EEG.nbchan = size(EEG.data,1);
end

% Put back refrence channel
if ~isempty(EEGSystem.refChan)
    refChan = EEGSystem.refChan.idx;
    EEG.data = [EEG.data(1:refChan-1,:); ...
        zeros(1,size(EEG.data,2));...
        EEG.data(refChan:end,:)];
    
    EEGRef.chanlocs(refChan).maraLabel = [];
    
    EEG.chanlocs = [EEG.chanlocs(1:refChan-1), EEGRef.chanlocs(refChan), ...
        EEG.chanlocs(refChan:end)];
    EEG.nbchan = size(EEG.data,1);
    clear chan_nb re_chan;
end

% Write back output
if ~isempty(EEGSystem.refChan)
    EEG.automagic.autoBadChans = setdiff(removedChans, EEGSystem.refChan.idx);
else
    EEG.automagic.autoBadChans = removedChans;
end
EEG.automagic.params = params;
EEG.automagic = rmfield(EEG.automagic, 'preprocessing');

if Settings.trackAllSteps
   allSteps = matfile(Settings.pathToSteps, 'Writable', true);
   allSteps.EEGFinal = EEG;
end

%% Creating the final figure to save
if ~isempty(FilterParams.high)
    plot_FilterParams = FilterParams;
else
    disp('No high-pass filter selected. Plotting with 1Hz by default');

    plot_FilterParams.high.freq = 1;
    plot_FilterParams.high.order = [];
end
% plot_FilterParams.high.freq = 1;
% plot_FilterParams.high.order = [];
EEG_filtered_toplot = performFilter(EEGOrig, plot_FilterParams);
fig1 = figure('visible', 'off');
set(gcf, 'Color', [1,1,1])
hold on
% eog figure
subplot(11,1,1)
if ~isempty(EOG.data)
    visEOG = zscore(EOG.data');
    visEOG = visEOG';
    imagesc(visEOG);
    colormap jet
    scale_min = round(min(min(visEOG)));
    scale_max = round(max(max(visEOG)));
    caxis(1*[scale_min scale_max])
    XTicks = [] ;
    XTicketLabels = [];
    set(gca,'XTick', XTicks)
    set(gca,'XTickLabel', XTicketLabels)
    yticks = get(gca,'YTickLabel');
    set(gca,'YTickLabel', yticks, 'fontsize', 7);
    title('Filtered (z-scored) EOG data');
    colorbar;
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
if isempty(FilterParams.high)
    title('1Hz Filtered EEG data')
else
    title('Filtered EEG data')
end
colorbar;
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
colorbar;
% figure;
eogRegress_subplot=subplot(11,1,6:7);
imagesc(EEG_regressed.data);
colormap jet
caxis([-100 100])
set(gca,'XTick',XTicks)
set(gca,'XTickLabel',XTicketLabels)
if strcmp(EEG_regressed.automagic.EOGRegression.performed,'no')
            title_text = '\color{red}No EOG-Regression requested';
            cla(eogRegress_subplot)
else
    title_text = 'EOG regressed out';
end
title(title_text);
colorbar;
%figure;
ica_subplot = subplot(11,1,8:9);
imagesc(EEG_cleared.data);
colormap jet
caxis([-100 100])
set(gca,'XTick',XTicks)
set(gca,'XTickLabel',XTicketLabels)
if (~isempty(MARAParams))
    if strcmp(EEG.automagic.mara.performed, 'FAILED')
        title_text = '\color{red}ICA FAILED';
        cla(ica_subplot)
    else
        title_text = 'ICA corrected clean data';
    end
elseif(~isempty(RPCAParams))
    title_text = 'RPCA corrected clean data';
else
    title_text = '';
end
title(title_text)
colorbar;
%figure;
if( ~isempty(fieldnames(RPCAParams)) && (isempty(RPCAParams.lambda) || RPCAParams.lambda ~= -1))
    subplot(11,1,10:11)
    imagesc(pca_noise);
    colormap jet
    caxis([-100 100])
    XTicks = 0:length(EEG.data)/5:length(EEG.data) ;
    XTicketLabels = round(0:length(EEG.data)/EEG.srate/5:length(EEG.data)/EEG.srate);
    set(gca,'XTick',XTicks)
    set(gca,'XTickLabel',XTicketLabels)
    title('RPCA noise')
    colorbar;
end

if isempty(FilterParams.high)
    annotation('textbox', [0.3, 0.2, 0, 0], 'string', 'No high-pass filter selected. Plotting with 1Hz by default','FitBoxToText','on');
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
colorbar;

varargout{1} = fig1;
varargout{2} = fig2;
varargout{3} = fig3;
