% import_bids() - Import BIDS format folder structure into an EEGLAB
%                    study.
%
% Modified version of the pop_importbids. If the reference channel is not
% provided in the .tsv file, Automagic search for reference in
% '..._eeg.json' file. If the reference is 'Cz', Automagic will add it
% together with the coordinates to EEG.chanlocs (see systemDependentParse.m).
%
%
% Usage of import_bids:
% EEG = import_bids(bidsFolder, self, varargin)
%
% Usage of pop_importbids:
%   >> [STUDY ALLEEG] = pop_importbids(bidsfolder);
%   >> [STUDY ALLEEG] = pop_importbids(bidsfolder, 'key', value);
%
% Inputs:
%   bidsfolder - a loaded epoched EEG dataset structure.
%     options are 'bidsevent', 'bidschanloc' of be turned 'on' (default) or 'off'
%                 'outputdir' default is bidsfolder/derivatives
%                 'studyName' default is eeg
%
% Optional inputs:
%  'studyName'   - [string] name of the STUDY
%  'bidsevent'   - ['on'|'off'] import events from BIDS .tsv file and
%                  ignore events in raw binary EEG files.
%  'bidschanloc' - ['on'|'off'] import channel location from BIDS .tsv file
%                  and ignore locations (if any) in raw binary EEG files.
%  'outputdir'   - [string] output folder (default is to use the BIDS
%                  folders).
%  'eventtype'   - [string] BIDS event column to use for EEGLAB event types.
%                  common choices are usually 'trial_type' or 'value'.
%                  Default is 'value'.
%  'bidstask'    - [string] value of a key task- allowing to analyze some
%                  tasks only
%
% Outputs:
%   STUDY   - EEGLAB STUDY structure
%   ALLEEG  - EEGLAB ALLEEG structure
%   bids    - bids structure
%
% Authors: Arnaud Delorme, SCCN, INC, UCSD, January, 2019
%         Cyril Pernet, University of Edinburgh
%
% Example:
% pop_importbids('/data/matlab/bids_matlab/rishikesh_study/BIDS_EEG_meditation_experiment');

% Copyright (C) Arnaud Delorme, 2018
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function EEG = import_bids(bidsFolder, self, varargin)

STUDY = [];
ALLEEG = [];
bids = [];
stats = [];
commands = '';
if nargin < 1
    bidsFolder = uigetdir('Pick a BIDS folder');
    if isequal(bidsFolder,0), return; end
    
    cb_select = [ 'tmpfolder = uigetdir;' ...
        'if ~isequal(tmpfolder, 0)' ...
        '   set(findobj(gcbf, ''tag'', ''folder''), ''string'', tmpfolder);' ...
        'end;' ...
        'clear tmpfolder;' ];
    type_fields = { 'value' 'trial_type' 'event_kind' };
    
    % scan if multiple tasks are present
    disp('Scanning folders...');
    tasklist = bids_gettaskfromfolder(bidsFolder);
    
    cb_event = 'set(findobj(gcbf, ''userdata'', ''bidstype''), ''enable'', fastif(get(gcbo, ''value''), ''on'', ''off''));';
    cb_task  = 'set(findobj(gcbf, ''userdata'', ''task''), ''enable'', fastif(get(gcbo, ''value''), ''on'', ''off''));';
    promptstr    = { ...
        { 'style'  'text'       'string' 'Enter study name (default is BIDS folder name)' } ...
        { 'style'  'edit'       'string' '' 'tag' 'studyName' } ...
        {} ...
        { 'style'  'checkbox'   'string' 'Use BIDS electrode.tsv files (when present) for channel locations; off: look up locations using channel labels' 'tag' 'chanlocs' 'value' 1 } ...
        { 'style'  'checkbox'   'string' 'Use BIDS event.tsv files for events and use the following BIDS field for event type' 'tag' 'events' 'value' 1 'callback' cb_event } ...
        { 'style'  'popupmenu'  'string' type_fields 'tag' 'typefield' 'value' 1 'userdata' 'bidstype'  'enable' 'on' } ...
        { 'style'  'checkbox'   'string' 'Import only the following BIDS task from the BIDS archive' 'tag' 'bidstask' 'value' 0 'callback' cb_task } ...
        { 'style'  'popupmenu'  'string' tasklist 'tag' 'bidstaskstr' 'value' 1 'userdata' 'task'  'enable' 'off' } ...
        {} ...
        { 'style'  'text'       'string' 'Study output folder' } ...
        { 'style'  'edit'       'string' fullfile(bidsFolder, 'derivatives') 'tag' 'folder' 'HorizontalAlignment' 'left' } ...
        { 'style'  'pushbutton' 'string' '...' 'callback' cb_select } ...
        };
    geometry = {[2 1.5], 1, 1,[1 0.25],[1 0.25],1,[1 2 0.5]};
    
    [~,~,~,res] = inputgui( 'geometry', geometry, 'geomvert', [1 0.5, 1 1 1 0.5 1], 'uilist', promptstr, 'helpcom', 'pophelp(''pop_importbids'')', 'title', 'Import BIDS data -- pop_importbids()');
    if isempty(res), return; end
    
    options = { 'eventtype' type_fields{res.typefield} };
    if res.events,    options = { options{:} 'bidsevent' 'on' };   else options = { options{:} 'bidsevent' 'off' }; end
    if res.chanlocs,  options = { options{:} 'bidschanloc' 'on' }; else options = { options{:} 'bidschanloc' 'off' }; end
    if ~isempty(res.folder),  options = { options{:} 'outputdir' res.folder }; end
    if ~isempty(res.studyName),  options = { options{:} 'studyName' res.studyName }; end
    if res.bidstask,  options = { options{:} 'bidstask' tasklist{res.bidstaskstr} }; end
else
    options = varargin;
end

[~,defaultStudyName] = fileparts(bidsFolder);
opt = finputcheck(options, { ...
    'bidsevent'      'string'    { 'on' 'off' }    'on';  ...
    'bidschanloc'    'string'    { 'on' 'off' }    'on'; ...
    'bidstask'       'string'    {}                ''; ...
    'metadata'       'string'    { 'on' 'off' }    'off'; ...
    'eventtype'      'string'    {  }              'value'; ...
    'outputdir'      'string'    { } fullfile(bidsFolder,'derivatives'); ...
    'studyName'      'string'    { }                defaultStudyName ...
    }, 'pop_importbids');
if isstr(opt), error(opt); end

if ~exist('jsondecode.m','file')
   addpath([fileparts(which('pop_importbids.m')) filesep 'JSONio']) 
end

% Options:
% - copy folder
% - use channel location and event

% load change file
changesFile = fullfile(bidsFolder, 'CHANGES');
bids.CHANGES = '';
if exist(changesFile,'File')
    bids.CHANGES = importalltxt( changesFile );
end

% load Readme file
readmeFile = fullfile(bidsFolder, 'README');
bids.README = '';
if exist(readmeFile,'File')
    bids.README = importalltxt( readmeFile );
end

% load dataset description file
dataset_descriptionFile = fullfile(bidsFolder, 'dataset_description.json');
bids.dataset_description = '';
if exist(dataset_descriptionFile,'File')
    if exist('jsondecode.m','file')
        bids.dataset_description = jsondecode(importalltxt( dataset_descriptionFile ));
    else
        bids.dataset_description = jsonread(dataset_descriptionFile);
    end
end

% load participant file
participantsFile = fullfile(bidsFolder, 'participants.tsv');
bids.participants = '';
if exist(participantsFile,'File')
    bids.participants = importtsv( participantsFile );
end
% if no participants.tsv, use subjects folder names as their IDs
if isempty(bids.participants)
    participantFolders = dir(fullfile(bidsFolder, 'sub-*'));
    bids.participants = {'participant_id' participantFolders.name }';
end

% load participant sidecar file
participantsJSONFile = fullfile(bidsFolder, 'participants.json');
bids.participantsJSON = '';
if exist(participantsJSONFile,'File')
    if exist('jsondecode.m','file')
        bids.participantsJSON = jsondecode(importalltxt( participantsJSONFile ));
    else
        bids.participantsJSON = jsonread(participantsJSONFile);
    end
end

% scan participants
count = 1;
commands = {};
task = [ 'task-' bidsFolder ];
bids.data = [];
inconsistentChannels = 0;
inconsistentEvents   = 0;

%% load the data, chanlocs, events 

parentSubjectFolder = fullfile(bidsFolder   , self.subject.name);

% find folder containing eeg
if exist(fullfile(parentSubjectFolder, 'eeg'),'dir')
    subjectFolder = { fullfile(parentSubjectFolder, 'eeg') };
else
    subFolders = dir(fullfile(parentSubjectFolder, 'ses*'));
    subjectFolder    = {};
    subjectFolderOut = {};

    for iFold = 1:length(subFolders)
        subjectFolder{   iFold} = fullfile(parentSubjectFolder, subFolders(iFold).name, 'eeg');
        if ~exist(subjectFolder{iFold},'dir')
            subjectFolder{   iFold} = fullfile(parentSubjectFolder, subFolders(iFold).name, 'meg');
            if ~exist(subjectFolder{iFold},'dir')
                subjectFolder{   iFold} = fullfile(parentSubjectFolder, subFolders(iFold).name, 'ieeg');
            end
        end
    end
end

% import data
for iFold = 1:length(subjectFolder) % scan sessions
    if ~exist(subjectFolder{iFold},'dir')
        fprintf(2, 'No EEG data folder for subject %s session %s\n', self.subject.name, subFolders(iFold).name);
    else
        % which raw data - with folder inheritance
        eegFile     = searchparent(subjectFolder{iFold}, '*eeg.*');
        if isempty(eegFile)
            eegFile     = searchparent(subjectFolder{iFold}, '*_meg.*');
        end
        infoFile      = searchparent(subjectFolder{iFold}, '*_eeg.json');
        channelFile   = searchparent(subjectFolder{iFold}, '*_channels.tsv');
        elecFile      = searchparent(subjectFolder{iFold}, '*_electrodes.tsv');
        eventFile     = searchparent(subjectFolder{iFold}, '*_events.tsv');
        eventDescFile = searchparent(subjectFolder{iFold}, '*_events.json');

        % check the task
        if ~isempty(opt.bidstask)
            eegFile       = filterFiles(eegFile      , opt.bidstask);
            infoFile      = filterFiles(infoFile     , opt.bidstask);
            channelFile   = filterFiles(channelFile  , opt.bidstask);
            elecFile      = filterFiles(elecFile     , opt.bidstask);
            eventDescFile = filterFiles(eventDescFile, opt.bidstask);
        end

        % raw data
        allFiles = { eegFile.name };
        ind = strmatch( 'json', cellfun(@(x)x(end-3:end), allFiles, 'uniformoutput', false) );
        if ~isempty(ind)
            eegFileJSON = allFiles(ind);
            allFiles(ind) = [];
        end
        ind = strmatch( '.set', cellfun(@(x)x(end-3:end), allFiles, 'uniformoutput', false) ); % EEGLAB
        if ~isempty(ind)
            eegFileRawAll  = allFiles(ind);
        elseif length(allFiles) == 1
            eegFileRawAll  = allFiles;
        else
            ind = strmatch( '.eeg', cellfun(@(x)x(end-3:end), allFiles, 'uniformoutput', false) ); % BVA
            if isempty(ind)
                ind = strmatch( '.edf', cellfun(@(x)x(end-3:end), allFiles, 'uniformoutput', false) ); % EDF
                if isempty(ind)
                    ind = strmatch( '.bdf', cellfun(@(x)x(end-3:end), allFiles, 'uniformoutput', false) ); % BDF
                    if isempty(ind)
                        ind = strmatch( '.fif', cellfun(@(x)x(end-3:end), allFiles, 'uniformoutput', false) ); % FIF
                        if isempty(ind)
                            ind = strmatch( '.gz', cellfun(@(x)x(end-2:end), allFiles, 'uniformoutput', false) ); % FIF
                            if isempty(ind) && ~isempty(allFiles)
                                fprintf(2, 'No EEG file found for subject %s\n', self.subject.name);
                            end
                        end
                    end
                end
            end
            eegFileRawAll  = allFiles(ind);
        end

        % skip most import if set file with no need for modication
        for iFile = 1:length(eegFileRawAll)

            eegFileName = eegFileRawAll{iFile};
            [~,tmpFileName,fileExt] = fileparts(eegFileName);
            eegFileRaw     = fullfile(subjectFolder{   iFold}, eegFileName);

            % what is the run
            iRun = 1;
            ind = strfind(eegFileRaw, '_run-');
            if ~isempty(ind)
                tmpEegFileRaw = eegFileRaw(ind(1)+5:end);
                indUnder = find(tmpEegFileRaw == '_');
                iRun = str2double(tmpEegFileRaw(1:indUnder(1)-1));
                if isnan(iRun) || iRun == 0
                    iRun = str2double(tmpEegFileRaw(1:indUnder(1)-2)); % rare case run 5H in ds003190/sub-01/ses-01/eeg/sub-01_ses-01_task-ctos_run-5H_eeg.eeg
                    if isnan(iRun) || iRun == 0
                        error('Problem converting run information'); 
                    end
                end
            end

            % JSON information file
            infoData = loadfile([ eegFileRaw(1:end-8) '_eeg.json' ], infoFile);

            % extract task name
            underScores = find(tmpFileName == '_');
            if ~strcmpi(tmpFileName(underScores(end)+1:end), 'eeg')
                if ~strcmpi(tmpFileName(underScores(end)+1:end), 'ieeg')
                    if ~strcmpi(tmpFileName(underScores(end)+1:end), 'meg.fif')
                        if ~strcmpi(tmpFileName(underScores(end)+1:end), 'meg')
                            error('Data file name does not contain eeg, ieeg, or meg'); % theoretically impossible
                        end
                    end
                end
            end
            if contains(tmpFileName,'task')
                tStart = strfind(tmpFileName,'_task')+1;
                tEnd = underScores - tStart; 
                tEnd = min(tEnd(tEnd>0)) + tStart - 1;
                task = tmpFileName(tStart:tEnd);
            end

            if ~strcmpi(fileExt, '.set') || strcmpi(opt.bidsevent, 'on') || strcmpi(opt.bidschanloc, 'on') || ~strcmpi(opt.outputdir, bidsFolder)
                fprintf('Importing file: %s\n', eegFileRaw);
                switch lower(fileExt)
                    case '.set' % do nothing
                        if strcmpi(opt.metadata, 'on')
                            EEG = pop_loadset( 'filename', eegFileRaw, 'loadmode', 'info' );
                        else
                            EEG = pop_loadset( 'filename', eegFileName, 'filepath', subjectFolder{iFold});
                        end
                    case {'.bdf','.edf'}
                        EEG = pop_biosig( eegFileRaw ); % no way to read meta data only (because events in channel)
                    case '.eeg'
                        [tmpPath,tmpFileName,~] = fileparts(eegFileRaw);
                        if exist(fullfile(tmpPath, [tmpFileName '.vhdr']), 'file'), ext = '.vhdr'; else ext = '.VMRK'; end
                        if strcmpi(opt.metadata, 'on')
                            EEG = pop_loadbv( tmpPath, [tmpFileName ext], [], [], true );
                        else
                            EEG = pop_loadbv( tmpPath, [tmpFileName ext] );
                        end
                    case '.fif'
                        EEG = pop_fileio(eegFileRaw); % fif folder
                    case '.gz'
                        gunzip(eegFileRaw);
                        EEG = pop_fileio(eegFileRaw(1:end-3)); % fif folder
                    case '.ds'
                        EEG = pop_fileio(eegFileRaw); % fif folder
                    otherwise
                        error('No EEG data found for subject/session %s', subjectFolder{iFold});
                end
                EEGnodata = EEG;
                EEGnodata.data = [];

                % channel location data
                % ---------------------
                channelData = loadfile([ eegFileRaw(1:end-8) '_channels.tsv' ], channelFile);
                elecData    = loadfile([ eegFileRaw(1:end-8) '_electrodes.tsv' ], elecFile);
                if strcmpi(opt.bidschanloc, 'on')
                    chanlocs = [];
                    for iChan = 2:size(channelData,1)
                        % the fields below are all required
                        chanlocs(iChan-1).labels = channelData{iChan,1};
                        chanlocs(iChan-1).type   = channelData{iChan,2};
                        chanlocs(iChan-1).unit   = channelData{iChan,3};
                        if size(channelData,2) > 3
                            chanlocs(iChan-1).status = channelData{iChan,4};
                        end

                        if ~isempty(elecData) && iChan <= size(elecData,1)
                            chanlocs(iChan-1).labels = elecData{iChan,1};
                            chanlocs(iChan-1).X = elecData{iChan,2};
                            chanlocs(iChan-1).Y = elecData{iChan,3};
                            chanlocs(iChan-1).Z = elecData{iChan,4};
                        end
                    end

                    if length(chanlocs) ~= EEG.nbchan
                        warning('Different number of channels in channel location file and EEG file');
                        % check if the difference is due to non EEG channels
                        % list here https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/03-electroencephalography.html
                        keep = {'EEG','EOG','HEOG','VEOG'}; % keep all eeg related channels
                        tsv_eegchannels  = arrayfun(@(x) sum(strcmpi(x.type,keep)),chanlocs,'UniformOutput',true);
                        tmpchanlocs = chanlocs; tmpchanlocs(tsv_eegchannels==0)=[]; % remove non eeg related channels
                        chanlocs = tmpchanlocs; clear tmpchanlocs
                    end

                    if length(chanlocs) ~= EEG.nbchan
                        error('channel location file and EEG file do not have the same number of channels');
                    end

                    if isfield(chanlocs, 'X')
                        EEG.chanlocs = convertlocs(chanlocs, 'cart2all');
                    else
                        EEG.chanlocs = chanlocs;
                    end
                else
                    if isempty(EEG.chanlocs(1).theta) || isempty(EEG.chanlocs(1).X) || isempty(EEG.chanlocs(1).sph_theta)
                        dipfitdefs;
                        EEG = pop_chanedit(EEG, 'lookup', template_models(2).chanfile);
                    else
                        disp('The EEG file has channel locations associated with it, we are keeping them');
                    end
                end

                % event data
                % ----------
                eventData = loadfile( [ eegFileRaw(1:end-8) '_events.tsv' ], eventFile);
%                 bids.data = setallfields(bids.data, [iSubject-1,iFold,iFile], struct('eventinfo', {eventData}));
                eventDesc = loadfile( [ eegFileRaw(1:end-8) '_events.json' ], eventDescFile);
%                 bids.data = setallfields(bids.data, [iSubject-1,iFold,iFile], struct('eventdesc', {eventDesc}));
                bids.eventInfo = {}; % for eInfo. Default is empty. If replacing EEG.event with events.tsv, match field names accordingly
                if strcmpi(opt.bidsevent, 'on')                        
                    events = struct([]);
                    indSample = strmatch('sample', lower(eventData(1,:)), 'exact');
                    indType      = strmatch('type', lower(eventData(1,:)), 'exact');
                    indTrialType = strmatch('trial_type', lower(eventData(1,:)), 'exact');
                    if ~isempty(indType) && isempty(indTrialType)
                        eventData(1,indType) = { 'trial_type' }; % renaming type as trial_type because erased below
                    end
                    indTrial = strmatch( opt.eventtype, lower(eventData(1,:)), 'exact');
                    for iEvent = 2:size(eventData,1)
                        events(end+1).latency  = eventData{iEvent,1}; % convert to samples
                        if EEG.trials > 1
                            events(end).epoch = floor(events(end).latency/EEG.pnts)+1;
                        end
                        events(end).duration   = eventData{iEvent,2};   % convert to samples
                        bids.eventInfo = {'onset' 'latency'; 'duration' 'duration'}; % order in events.tsv: onset duration
                        if ~isempty(indSample)
                            events(end).sample = eventData{iEvent,indSample} + 1;
                            bids.eventInfo(end+1,:) = {'sample' 'sample'};
                        end
                        for iField = 1:length(eventData(1,:))
                            if ~any(strcmpi(eventData{1,iField}, {'onset', 'duration', 'sample', opt.eventtype}))
                                events(end).(eventData{1,iField}) = eventData{iEvent,iField};
                                bids.eventInfo(end+1,:) = { eventData{1,iField} eventData{1,iField} };
                            end
                        end
                        if ~isempty(indTrial)
                            events(end).type = eventData{iEvent,indTrial};
                            bids.eventInfo(end+1,:) = { opt.eventtype 'type' };
                        end                           
                        if size(eventData,2) > 3 && strcmpi(eventData{1,4}, 'response_time') && ~strcmpi(eventData{iEvent,4}, 'n/a')
                            events(end+1).type   = 'response';
                            events(end).latency  = (eventData{iEvent,1}+eventData{iEvent,4}); % convert to samples
                            events(end).duration = 0;
                        end
                    end
                    EEG.event = events;
                    
                    % check consistency
                    EEG = eeg_checkset(EEG, 'eventconsistency');


                end

                % copy information inside dataset
                EEG.subject = self.subject.name;
                EEG.session = iFold;
                EEG.run = iRun;
                EEG.task = task(6:end); % task is currently of format "task-<Task name>"

                % build `EEG.BIDS` from `bids`
                BIDS.gInfo = bids.dataset_description;
                BIDS.gInfo.README = bids.README;
                BIDS.pInfoDesc = bids.participantsJSON;
                BIDS.eInfo = bids.eventInfo;
                BIDS.tInfo = infoData;
                try
                    i = find(strcmp(self.subject.name, bids.participants(:, 1)));
                    BIDS.demographics.name = bids.participants{i, 1};
                    BIDS.demographics.age = bids.participants{i, 2};
                    BIDS.demographics.sex = bids.participants{i, 3};
                catch ME
                    ME.message
                end
                EEG.BIDS = BIDS;

            end
        end 
    end
end



% check BIDS data field present
% -----------------------------
function res = checkBIDSfield(bids, fieldName)
res = false;
if isfield(bids.data, fieldName)
    fieldContent = { bids.data.(fieldName) };
    fieldContent(cellfun(@isempty, fieldContent)) = [];
    if ~isempty(fieldContent), res = true; end
end

% Import full text file
% ---------------------
function str = importalltxt(fileName)

str = [];
fid =fopen(fileName, 'r');
while ~feof(fid)
    str = [str 10 fgetl(fid) ];
end
str(1) = [];

% search parent folders (outward search) for the file of given fileName
% ---------------------
function outFile = searchparent(folder, fileName)
% search nestedly outward
% only get exact match and filter out hidden file
outFile = '';
parent = folder;
while ~any(arrayfun(@(x) strcmp(lower(x.name),'dataset_description.json'), dir(parent))) && isempty(outFile) % README indicates root BIDS folder
    outFile = filterHiddenFile(folder, dir(fullfile(parent, fileName)));
    parent = fileparts(parent);
end
if isempty(outFile)
    outFile = filterHiddenFile(parent, dir(fullfile(parent, fileName)));
end

function fileList = filterHiddenFile(folder, fileList)
isGoodFile = true(1,numel(fileList));
% loop to identify hidden files
for iFile = 1:numel(fileList) %'# loop only non-dirs
    % on OSX, hidden files start with a dot
    isGoodFile(iFile) = logical(~strcmp(fileList(iFile).name(1),'.'));
    if isGoodFile(iFile) && ispc
        % check for hidden Windows files - only works on Windows
        [~,stats] = fileattrib(fullfile(folder,fileList(iFile).name));
        if stats.hidden
            isGoodFile(iFile) = false;
        end
    end
end

% remove bad files
fileList = fileList(isGoodFile);

% Filter files
% ------------
function fileList = filterFiles(fileList, taskList)

keepInd = zeros(1,length(fileList));
for iFile = 1:length(fileList)
    if ~isempty(strfind(fileList(iFile).name, taskList))
        keepInd(iFile) = 1;
    end
end
fileList = fileList(logical(keepInd));

% import JSON or TSV file
% -----------------------
function data = loadfile(localFile, globalFile)
[~,~,ext] = fileparts(localFile);
data = [];
localFile = dir(localFile);
if ~isempty(localFile)
    if strcmpi(ext, '.tsv')
        data = importtsv( fullfile(localFile(1).folder, localFile(1).name));
    else
        if exist('jsondecode.m','file')
            data = jsondecode( importalltxt( fullfile(localFile(1).folder, localFile(1).name) ));
        else
            data = jsonread(fullfile(localFile(1).folder, localFile(1).name));
        end
    end        
elseif ~isempty(globalFile)
    if strcmpi(ext, '.tsv')
        data = importtsv( fullfile(globalFile(1).folder, globalFile(1).name));
    else
        if exist('jsondecode.m','file')
            data = jsondecode( importalltxt( fullfile(globalFile(1).folder, globalFile(1).name) ));
        else
            data = jsonread(fullfile(globalFile(1).folder, globalFile(1).name));
        end
    end
end

% set structure
% -------------
function sdata = setallfields(sdata, indices, newdata)
if isempty(newdata), return; end
if ~isstruct(newdata), error('Can only assign structures'); end
if length(indices) < 3, error('Must have 3 indices'); end
allFields = fieldnames(newdata);
for iField = 1:length(allFields)
    sdata(indices(1), indices(2), indices(3)).(allFields{iField}) = newdata.(allFields{iField});
end

% Import tsv file
% ---------------
function res = importtsv( fileName)

res = loadtxt( fileName, 'verbose', 'off', 'delim', 9);

for iCol = 1:size(res,2)
    % search for NaNs in numerical array
    indNaNs = cellfun(@(x)strcmpi('n/a', x), res(:,iCol));
    if ~isempty(indNaNs)
        allNonNaNVals = res(find(~indNaNs),iCol);
        allNonNaNVals(1) = []; % header
        testNumeric   = cellfun(@isnumeric, allNonNaNVals);
        if all(testNumeric)
            res(find(indNaNs),iCol) = { NaN };
        elseif ~all(~testNumeric)
            % Convert numerical value back to string
            res(:,iCol) = cellfun(@num2str, res(:,iCol), 'uniformoutput', false);
        end
    end
end