function [EEG] = performETguidedICA(EEG, params)

% For details see the underlying publication: Dimigen, 2020, NeuroImage


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


% Check and unzip if EYE_EEG() does not exist
addEYE_EEG()

%% params
ext = params.fileext_edit;
eegFileName = EEG.fileName;
x = split(ext, '.');
ext = x{end};
ETdataFolder = params.datafolder_edit; 
subjectFolder = split(EEG.dataFolder, filesep);
ETdataFolder = fullfile(ETdataFolder, subjectFolder{end}); % get data folder of a specific subject

% check, if data in BIDS format
if startsWith(subjectFolder{end}, 'sub-')
    isBIDS = 1;
else
    isBIDS = 0;
end

L_GAZE_X = params.l_gaze_x_edit;
L_GAZE_Y = params.l_gaze_y_edit;
R_GAZE_X = params.r_gaze_x_edit;
R_GAZE_Y = params.r_gaze_y_edit;
SCREEN_X = str2double(params.screenWidth_edit);
SCREEN_Y = str2double(params.screenHeight_edit);

%% find first and last trigger, if not provided
try
    allstartTriggers = sscanf(params.startTrigger_edit,'%f');
    allendTriggers = sscanf(params.endTrigger_edit,'%f');
catch
    allstartTriggers = [];
    allendTriggers = [];
end

% Sometimes the events have whitspaces in the names (e.g., {'911  '}). Remove 
% leading and trailing whitespace from strings.
eegevent = strtrim({EEG.event.type});

if isempty(allstartTriggers) & isempty(allendTriggers)
    startTrigger = str2double(EEG.event(1).type);
    endTrigger = str2double(EEG.event(end).type);
else
    % if triggers are a list (e.g., different blocks have diffrent triggers), find correspoding triggers
    startTrigger = allstartTriggers (ismember(cellstr(num2str(allstartTriggers)), eegevent));
    endTrigger = allendTriggers( ismember(cellstr(num2str(allendTriggers)), eegevent));
end


%% find corresponding et file - tricky, if more ET files in a folder

if isBIDS
    
    % split the name to get all informations
    parts = strsplit(eegFileName, {'-', '_'});
    
    flag = 1;
    % find out session and run 
    if find(ismember(parts, 'ses'))
        session = parts{find(ismember(parts, 'ses')) + 1};  
        flag = 2;
    end
      
    % find out run
    if find(ismember(parts, 'run'))
        run = parts{find(ismember(parts, 'run')) + 1};
        flag = 3;
    end
    
    % find the correct ET file
    if flag == 2
        d = dir(fullfile(ETdataFolder, '**', 'et', ['*-ses-', session, '*']));
        ETdataFolder = d(1).folder;
        et_fileName = d(1).name;
    elseif flag == 3
        d = dir(fullfile(ETdataFolder, '**', 'et', ['*-ses-', session, '*run-', run, '*']));
        ETdataFolder = d(1).folder;
        et_fileName = d(1).name;
    end
        
else
    d = dir(fullfile(ETdataFolder, ['*' , ext]));

    if length(d) == 1
        et_fileName = d(1).name;   
    else % assume that that the filenames for EEG and ET are identical up to _EEG.mat 
        i = regexpi(eegFileName, 'EEG');
        patt = eegFileName(1:i-2); % remove _EEG from the name
        et_fileName = [patt, '_ET.', ext];
    end
end

%% if .txt, convert to .mat and save as a mat file
if strcmp(ext, 'txt')
    ET = parsesmi(fullfile(ETdataFolder, et_fileName), ETdataFolder);
elseif strcmp(ext, 'mat')
    ET = load(fullfile(ETdataFolder, et_fileName));
end

%% import & synchronize ET data
EEG = pop_importeyetracker(EEG, fullfile(ETdataFolder, et_fileName), ...
    [startTrigger, endTrigger], 1:length( ET.colheader), ET.colheader, 1,1,1,0);
        
        
%% Mark intervals with bad eye tracking data
% important, so these intervals will not influence our saccade detection
% This function is also useful to objectively reject intervals during
% which the participant blinked or did not look at the stimulus

REJECTMODE = 2; % don't reject data, add extra "bad_ET" events to EEG.event

% eye position channels
if any(strcmp({EEG.chanlocs(:).labels},L_GAZE_X)) & ~any(strcmp({EEG.chanlocs(:).labels}, R_GAZE_X))
    LX = find(strcmp({EEG.chanlocs(:).labels}, L_GAZE_X));
    LY = find(strcmp({EEG.chanlocs(:).labels}, L_GAZE_Y));
    
    EEG = pop_rej_eyecontin(EEG, [LX LY], [1 1], [SCREEN_X SCREEN_Y], 25, REJECTMODE);
    
elseif any(strcmp({EEG.chanlocs(:).labels}, R_GAZE_X)) & ~any(strcmp({EEG.chanlocs(:).labels}, L_GAZE_X))
    RX = find(strcmp({EEG.chanlocs(:).labels}, R_GAZE_X));
    RY = find(strcmp({EEG.chanlocs(:).labels}, R_GAZE_Y));
    
    EEG = pop_rej_eyecontin(EEG, [RX RY], [1 1], [SCREEN_X SCREEN_Y], 25, REJECTMODE);
    
elseif any(strcmp({EEG.chanlocs(:).labels}, L_GAZE_X)) & any(strcmp({EEG.chanlocs(:).labels}, R_GAZE_X))
    LX = find(strcmp({EEG.chanlocs(:).labels}, L_GAZE_X));
    LY = find(strcmp({EEG.chanlocs(:).labels}, L_GAZE_Y));
    RX = find(strcmp({EEG.chanlocs(:).labels}, R_GAZE_X));
    RY = find(strcmp({EEG.chanlocs(:).labels}, R_GAZE_Y));
    
    EEG = pop_rej_eyecontin(EEG, [LX LY RX RY], [1 1 1 1], [SCREEN_X SCREEN_Y SCREEN_X SCREEN_Y], 25, REJECTMODE);
end


%% Detect (micro)saccades & fixations (Engbert & Kliegl, 2003)

% ### GUI: "Eyetracker" > "Detect saccades & fixations"
% % see "help pop_detecteyemovements" to see all options
% % 
% DEG_PER_PIXEL = 0.036; % 1 pixel on screen was 0.036 degrees of visual angle
% THRESH        = 6;     % eye velocity threshold (in median-based SDs)
% MINDUR        = 4;     % minimum saccade duration (samples)
% SMOOTH        = 1;     % smooth eye velocities? (recommended if SR > 250 Hz)
% 
% PLOTFIG       = 1;
% WRITESAC      = 1;     % add saccades as events to EEG.event?
% WRITEFIX      = 1;     % add fixations as events to EEG.event?
% % 
% EEG = pop_detecteyemovements(EEG,[LX LY],[RX RY],THRESH,MINDUR,DEG_PER_PIXEL,SMOOTH,0,25,2,PLOTFIG,WRITESAC,WRITEFIX);

%% Create optimized data for ICA training (OPTICAT, Dimigen, 2018)

OW_PROPORTION    = 1.0;          % overweighting proportion
SACCADE_WINDOW   = [str2double(params.from_edit) str2double(params.to_edit)];  % time window to overweight (-20 to 10 ms is default)
REMOVE_EPOCHMEAN = true;         % subtract mean from overweighted epochs? (recommended)

% find name of saccade event 
i = find(~cellfun(@isempty, regexp({EEG.event(:).type}, 'sac')));
for idx = i
    EEG.event(idx).type = 'saccade';
end

% find name of fixation event 
i = find(~cellfun(@isempty, regexp({EEG.event(:).type}, 'fix')));
for idx = i
    EEG.event(idx).type = 'fixation';
end


% Overweight saccade intervals (containing spike potential)
EEG = pop_overweightevents(EEG,'saccade',SACCADE_WINDOW,OW_PROPORTION,REMOVE_EPOCHMEAN);

% Run ICA on optimized training data
fprintf('\nTraining ICA on the optimized data ...')
end


