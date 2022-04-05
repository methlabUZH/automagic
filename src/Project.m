classdef Project < handle
    %Project is a class representing a project created in the mainGUI.
    %   A Project contains the entire relevant information for each
    %   project. This information include the name of the project, address
    %   of the dataFolder, resultFolder, list of all exisiting blocks,
    %   list of all preprocessed blocks, five different list of ratings
    %   corresponding to each rate and many more. Please see the properties
    %   for more information.
    %
    %   Project is a subclass of handle, meaning it's a refrence to an
    %   object. Use accordingly.
    %
    %Project Methods:
    %   Project - To create a project following arguments must be given:
    %   myProject = Project(name, dFolder, pFolder, ext, params, vParams, ...
    %                       varargin)
    %   where name is a char specifying the desired project name, dFolder
    %   is the address of the folder where raw data is placed, pFolder is
    %   the address of the folder where you want the results to be saved,
    %   ext is the fileExtension of raw files, params is a struct that
    %   contains parameters of preprocessing, vParams is a struct that
    %   contains parameters of visualisation and varargin is can be the
    %   sampling rate in case the extension file is .txt
    %
    %   preprocessAll - Start the preprocessing. It iterates on all the
    %   raw files in dataFolder, preprocess them all and put the results
    %   in resultFolder. If some files have been already preprocessed,
    %   user is asked to whether overwrite the previous results or just
    %   skip them and continue with the rest of unpreprocessed files.
    %
    %   interpolateSelected - Interpolate all the channels selected to be
    %   interpolated.
    %
    %   getCurrentBlock - Return the current selected block. Used mostly in
    %   ratingGUI for visualisation.
    %
    %   getNextIndex - Return the index of the next (not filtered) block
    %   in the list. Used mostly in ratingGUI for visualisation.
    %
    %   getPreviousIndex - Return the index of the prebious (not filtered)
    %   block in the list. Used mostly in ratingGUI for visualisation.
    %
    %   updateRatingStructures - Whenever changes has been made to the
    %   dataFolder or resultFolder, this method must be called to update
    %   the data structures accordingly. The process may take long time
    %   depending on the number of existing files in each folder. See the
    %   method to learn more on how it works.
    %
    %   updateRatingLists - Update the five rating lists. This is used each
    %   time the rating of a single block is changed.
    %
    %   updateAddressesFormStateFile - The method is to be called
    %   just after a project is "loaded" from a state file. The loaded
    %   project may have not been created from this operating system,
    %   therefore addresses to the folders (which can even be on a server)
    %   could be different on this system, and they must be updated.
    %
    %   getQualityratings - Return the quality ratings of
    %   all blocks given the cutoffs.
    %
    %   applyQualityratings - Apply the new quality ratings to all the blocks.
    %
    %   getRatedCount - Return the number of rated blocks in this
    %   project.
    %
    %   toBeInterpolatedCount - Return number of blocks rated to be
    %   interpolated in this project.
    %
    %   areFoldersChanged - Return a boolean. It's true if any of the
    %   dataFolder or resultFolder has been changed since the last update.
    %   It can be used to decide whether to call updateRatingStructures or
    %   not. Note that at this stage this method only returns based on the
    %   number of files in the folder.
    %
    %   saveProject - Save the entire project class in a .m file
    %
    %   getSubjectFilesList - List all folders in the dataFolder
    %
    %   getPreprocessedFilesList - List all folders in the resultFolder
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
    
    properties
        
        % The index of the current block that must be shown in ratingGUI.
        current
        
        % Maximum value for the X-axis in the plot. Needed for the visual
        % aspects of the plot.
        maxX
        
        % This determines the color scale in rating gui:
        % [-colorScale, colorScale]. Default is 100.
        colorScale
        
        qualityCutoffs
        
        qualityScoreIdx
        
        email
        
        manuallyExcludedRBCChans
    end
    
    properties(SetAccess=private)
        
        % Name of this project.
        name
        
        % Adress of the folder where raw data are stored.
        dataFolder
        
        % Address of the folder where results are (to be) saved.
        resultFolder
        
        % Sampling rate to create reduced files.
        dsRate
        
        % Sampling rate of the recorded data. This is necessary only in the
        % case of fileExtension = '.txt'
        sRate
        
        % File extension of the raw files in this project. (ie. .raw)
        fileExtension
        
        % All files with this mask at the end are loaded. It must include
        % the fileExtension in itself (ie. ***_EEG.raw)
        mask
        
        % Parameters of the preprocessing. To learn more please see
        % preprocessing/preprocess.m
        params
        
        % Visualisation parameters. These are used mainly in ratingGUI
        vParams
        
        % List of names of all preprocessed blocks so far.
        processedList
        
        % Map each block name to the block itself.
        blockMap
        
        qualityThresholds
        
        % Number of all existing blocks.
        nBlock
        
        % Number of all existing subjects.
        nSubject
        
        % Number of preprocessed blocks.
        nProcessedFiles
        
        % Number of preprocessed subjects.
        nProcessedSubjects
        
        % Address of the state file corresponding to this project. By
        % default it's in the resultFolder and is called project_state.mat.
        stateAddress
        
        % A boolean determinning if this project has been already
        % commmited. Once the commit button is clicked this will be set to
        % 1. Otherwise it is initialised to 0.
        committed
        
        % The cutoffs with which the project has been committed previously
        committedQualityCutoffs
        
    end
    
    properties(SetAccess=private, GetAccess=private)
        
        % List of names of all existing blocks in the dataDolder.
        blockList
        
        % List of indices of blocks that are rated as Interpolate.
        interpolateList
        
        % List of indices of blocks that are rated as Good.
        goodList
        
        % List of indices of blocks that are rated as Bad.
        badList
        
        % List of indices of blocks that are rated as OK.
        okList
        
        % List of indices of blocks that are not rated (or rated as Not Rated).
        notRatedList
        
        % List of indices of blocks that are already interpolated
        alreadyInterpolated
        
        % Constant Global Variables
        CGV
    end
    
    %% Constructor
    methods
        function self = Project(name, dFolder, pFolder, ext, params, ...
                vParams, varargin)
            
            self.CGV = ConstantGlobalValues();
            defs = self.CGV.DefaultParams;
            p = inputParser;
            addParameter(p,'EEGSystem', defs.EEGSystem, @isstruct);
            addParameter(p,'FilterParams', defs.FilterParams, @isstruct);
            addParameter(p,'PrepParams', defs.PrepParams, @isstruct);
            addParameter(p,'CRDParams', defs.CRDParams, @isstruct);
            addParameter(p,'RPCAParams', defs.RPCAParams, @isstruct);
            addParameter(p,'HighvarParams', defs.HighvarParams, @isstruct);
            addParameter(p,'MinvarParams', defs.MinvarParams, @isstruct);
            addParameter(p,'MARAParams', defs.MARAParams, @isstruct);
            addParameter(p,'ICLabelParams', defs.ICLabelParams, @isstruct);
            addParameter(p,'InterpolationParams', defs.InterpolationParams, @isstruct);
            addParameter(p,'EOGRegressionParams', defs.EOGRegressionParams, @isstruct);
            addParameter(p,'ChannelReductionParams', defs.ChannelReductionParams, @isstruct);
            addParameter(p,'DetrendingParams', defs.DetrendingParams, @isstruct);
            addParameter(p,'Settings', defs.Settings, @isstruct);
            addParameter(p,'TrimDataParams', defs.TrimDataParams, @isstruct);
            addParameter(p,'TrimOutlierParams', defs.TrimOutlierParams, @isstruct);
            addParameter(p,'addETdataParams', defs.addETdataParams, @isstruct);
            parse(p, params);
            params = p.Results;
            
            defVParam = self.CGV.DefaultVisualisationParams;
            p = inputParser;
            addParameter(p,'CalcQualityParams', defVParam.CalcQualityParams, @isstruct);
            addParameter(p,'dsRate', defVParam.dsRate, @isnumeric);
            addParameter(p,'RateQualityParams', defVParam.RateQualityParams, @isstruct);
            addParameter(p,'COLOR_SCALE', defVParam.COLOR_SCALE, @isnumeric);
            parse(p, vParams);
            vParams = p.Results;
            
            self = self.setName(name);
            self = self.setDataFolder(dFolder);
            self = self.setResultFolder(pFolder);
            self.stateAddress = self.makeStateAddress(self.resultFolder);
            
            extSplit = strsplit(ext, '.');
            self.fileExtension = strcat('.', extSplit{end});
            self.mask = ext;
            
            self.qualityThresholds = vParams.CalcQualityParams;
            self.dsRate = vParams.dsRate;
            self.qualityCutoffs = vParams.RateQualityParams;
            self.colorScale = vParams.COLOR_SCALE;
            self.manuallyExcludedRBCChans = [];
            
            self.committed = false;
            self.committedQualityCutoffs = struct([]);
            if ~ isempty(varargin{:})
                self.sRate = varargin{1};
            else
                if(any(strcmp(self.fileExtension, {self.CGV.EXTENSIONS.text})))
                    error('You need to provide sampling rate for the .txt extension.');
                end
            end
            
            self.params = params;
            self.vParams = vParams;
            self = self.createRatingStructure();
        end
    end
    
    %% Public Methods
    methods
        function block = getCurrentBlock(self)
            % Return the block pointed by the current index. If
            % current == -1, a mock block is returned.
            
            if( self.current == -1)
                subject = Subject('','');
                block = Block(self, subject, '', '', self.CGV);
                block.index = -1;
                return;
            end
            
            uniqueName = self.processedList{self.current};
            block = self.blockMap(uniqueName);
        end
        
        function next = getNextIndex(self, nextIdx, goodBool, okBool, ...
                badBool, interpolateBool, notratedBool)
            % Return the index of the next block in the list. The boolean
            % parameters indicate if the next block to be returned should
            % have the corresponding rating or not. These are so called
            % filters in the ratingGUI.
            % nextIdx - Return this block if no other next block exists in
            % the list. This should be usually the current index.
            % ***Bool - Whether to return the block if it has this rating
            % or not.
            
            block = self.getCurrentBlock();
            currentIndex = block.index;
            % If no rating is filtered, simply return the next one in the list.
            if( goodBool && okBool && badBool && ...
                    interpolateBool && notratedBool)
                next = min(self.current + 1, length(self.processedList));
                if( next == 0) % 'current' could be -1 if a mock block
                    next = next + 1;
                end
                return;
            end
            nextGood = [];
            nextOk = [];
            nextBad = [];
            nextInterpolate = [];
            nextNotrated = [];
            if(goodBool)
                possibleGoods = find(self.goodList > currentIndex, 1);
                if( ~ isempty(possibleGoods))
                    nextGood = self.goodList(possibleGoods(1));
                end
            end
            if(okBool)
                possibleOks = find(self.okList > currentIndex, 1);
                if( ~ isempty(possibleOks))
                    nextOk = self.okList(possibleOks(1));
                end
            end
            if(badBool)
                possibleBads = find(self.badList > currentIndex, 1);
                if( ~ isempty(possibleBads))
                    nextBad = self.badList(possibleBads(1));
                end
            end
            if(interpolateBool)
                possibleInterpolates = ...
                    find(self.interpolateList > currentIndex, 1);
                if( ~ isempty(possibleInterpolates))
                    nextInterpolate = ...
                        self.interpolateList(possibleInterpolates(1));
                end
            end
            if(notratedBool)
                possibleNotrateds = ...
                    find(self.notRatedList > currentIndex, 1);
                if( ~ isempty(possibleNotrateds))
                    nextNotrated = ...
                        self.notRatedList(possibleNotrateds(1));
                end
            end
            next = min([nextGood nextOk nextBad nextInterpolate nextNotrated]);
            if( isempty(next))
                next = nextIdx;
            end
        end
        
        function previous = getPreviousIndex(self, previousIdx, goodBool, ...
                okBool, badBool, interpolateBool, notratedBool)
            % Return the index of the prebious block in the list. The boolean
            % parameters indicate if the previous block to be returned should
            % have the corresponding rating or not. These are so called
            % filters in the ratingGUI.
            % previousIdx - Return this block if no other previous block
            %   exists in the list. This should be usually the current index.
            % ***Bool - Whether to return the block if it has this rating
            % or not.
            
            % Get the current project and file
            block =  self.getCurrentBlock();
            currentIndex = block.index;
            
            % If nothing is filtered simply return the previous in the list
            if( goodBool && okBool && badBool && ...
                    interpolateBool && notratedBool)
                previous = max(self.current - 1, 1);
                return;
            end
            
            % Now for each rating, find the possible choices, and then
            % choose the closest one
            previousGood = [];
            previousOk = [];
            previousBad = [];
            previousInterpolate = [];
            previousNotrated = [];
            if(goodBool)
                possibleGoods = ...
                    find(self.goodList < currentIndex, 1, 'last');
                if( ~ isempty(possibleGoods))
                    previousGood = self.goodList(possibleGoods(end));
                end
            end
            if(okBool)
                possibleOks = find(self.okList < currentIndex, 1, 'last');
                if( ~ isempty(possibleOks))
                    previousOk = self.okList(possibleOks(end));
                end
            end
            if(badBool)
                possibleBads = find(self.badList < currentIndex, 1, 'last');
                if( ~ isempty(possibleBads))
                    previousBad = self.badList(possibleBads(end));
                end
            end
            if(interpolateBool)
                possibleInterpolates = ...
                    find(self.interpolateList < currentIndex, 1, 'last');
                if( ~ isempty(possibleInterpolates))
                    previousInterpolate = ...
                        self.interpolateList(possibleInterpolates(end));
                end
            end
            if(notratedBool)
                possibleNotrateds = ...
                    find(self.notRatedList < currentIndex, 1, 'last');
                if( ~ isempty(possibleNotrateds))
                    previousNotrated = ...
                        self.notRatedList(possibleNotrateds(end));
                end
            end
            previous = max([previousGood previousOk previousBad ...
                previousInterpolate previousNotrated]);
            if( isempty(previous))
                previous = previousIdx;
            end
            
        end
        
        function self = preprocessAll(self)
            % Preprocesse all the files in the dataFolder of this project
            
            assert(exist(self.resultFolder, 'dir') > 0 , ...
                'The project folder does not exist or is not reachable.' );
            
            % Ask to overwrite the existing preprocessed files, if any
            skip = self.checkExistings();
            
            % Check for a file size exclusion list
            excluLoc = strcat(self.resultFolder,'exclusionList.mat');
            if exist(excluLoc,'file')
                excluList = load(strcat(self.resultFolder,'exclusionList.mat'));
            end
            
            % If ICLabel, check it's installed, then compile MEX files
            if ~isempty(self.params.ICLabelParams)
                parts = addEEGLab();
                ICLabelFolderIndex = find(~cellfun(@isempty,strfind(parts,'ICLabel')));
                found = ~isempty(ICLabelFolderIndex);
                if found == 0
                    disp('Installing ICLabel');
                    evalc('plugin_askinstall(''ICLabel'',[],true)');
                    close();
                end
                str = which('vl_nnconv.mexw64');
                mexFolder = strfind(str,filesep);
                mexFolder = str(1:mexFolder(end));
                addpath(mexFolder);
            end
            
            fprintf('*******Start preprocessing all dataset*******\n');
            startTime = datetime('now');
            for i = 1:length(self.blockList)
                uniqueName = self.blockList{i};
                block = self.blockMap(uniqueName);
                block.updateAddresses(self.dataFolder, self.resultFolder, ...
                    self.params.EEGSystem.locFile);
                subjectName = block.subject.name;
                
                fprintf(['Processing file ', block.uniqueName ,' ...', ...
                    '(file ', int2str(i), ' out of ', ...
                    int2str(length(self.blockList)), ')\n']);
                
                % Create the subject folder if it doesn't exist yet
                if(~ exist([self.resultFolder subjectName], 'dir'))
                    mkdir([self.resultFolder subjectName]);
                end
                
                % Don't preprocess the file if skip
                if skip && exist(block.potentialResultAddress, 'file')
                    fprintf(['Results already exits. Skipping '...
                        'prerocessing for this subject...\n']);
                    continue;
                end
                
                if exist('excluList')
                    if excluList.exclusionList(i)==1
                        fprintf(['File-size not in chosen range. Skipping '...
                        'prerocessing for this file...\n']);
                    message = 'File-size not in chosen range';
                    self.writeToLog(block.sourceAddress, message);
                    continue;
                    end
                end
                
                try
                    % preprocess the file
                    [EEG, automagic] = block.preprocess();
                    
                catch ME
                    ME.message
                    warning(['Error in file: ', ME.stack(1).file, ' (Line: ',  num2str(ME.stack(1).line), ') ...'])

                    
                    % save the ids to the txt file
                    if isfile(fullfile(self.resultFolder, 'errors.txt'))
                        dlmwrite(fullfile(self.resultFolder, 'errors.txt'), uniqueName, '-append', 'delimiter', '')
                    else
                        dlmwrite(fullfile(self.resultFolder, 'errors.txt'), uniqueName, 'delimiter', '')
                    end
                    
                    % init the vars, otherwise error
                    EEG = struct([]);
                    automagic = struct();
                    automagic.error_msg = ME.message;      
                end
                
                if( isempty(EEG) || isfield(automagic, 'error_msg'))
                    message = automagic.error_msg;
                    self.writeToLog(block.sourceAddress, message);
                    continue;
                end
                
                if (isfield(automagic,'badChanError'))
                    message = automagic.badChanError;
                    self.writeToLog(block.sourceAddress, message);
                end
                
                if( self.current == -1)
                    self.current = 1;
                end
                self.saveProject();
            end
            
            self.updatemainGUI();
            endTime = datetime('now') - startTime;
            fprintf(['******* Pre-processing finished. Total elapsed '...
                'time: ', char(endTime),'*********\n'])
        end
        
        function self = interpolateSelected(self)
            % Interpolate all the channels selected to be interpolated
            if(isempty(self.interpolateList))
                popup_msg('No subjects to interpolate. Please first rate.',...
                    'Error');
                return;
            end
            
            fprintf('*******Start Interpolation**************\n');
            startTime = datetime('now');
            intList = self.interpolateList;
            for i = 1:length(intList)
                index = intList(i);
                uniqueName = self.blockList{index};
                block = self.blockMap(uniqueName);
                block.updateAddresses(self.dataFolder, self.resultFolder, ...
                    self.params.EEGSystem.locFile);
                
                fprintf(['Processing file ', block.uniqueName ,' ...', '(file ', ...
                    int2str(i), ' out of ', int2str(length(intList)), ')\n']);
                assert(strcmp(block.rate, self.CGV.RATINGS.Interpolate) == 1);
                
                block.interpolate();
                
                self.alreadyInterpolated = [self.alreadyInterpolated index];
                self.saveProject();
            end
            endTime = datetime('now') - startTime;
            self.updatemainGUI();
            fprintf(['Interpolation finished. Total elapsed time: ', ...
                char(endTime), '\n'])
        end
        
        function self = updateRatingLists(self, block)
            % Update the five rating lists depending on the rating of the
            % given block. It removes the block from its previous rating
            % list and adds it to its new rating list.
            % block - The block fro which the rating has changed.
            
            switch block.rate
                case self.CGV.RATINGS.Good
                    if( ~ ismember(block.index, self.goodList ) )
                        self.goodList = [self.goodList block.index];
                        self.notRatedList(...
                            self.notRatedList == block.index) = [];
                        self.okList(self.okList == block.index) = [];
                        self.badList(self.badList == block.index) = [];
                        self.interpolateList(...
                            self.interpolateList == block.index) = [];
                        self.goodList = sort(unique(self.goodList));
                        
                    end
                case self.CGV.RATINGS.OK
                    if( ~ ismember(block.index, self.okList ) )
                        self.okList = [self.okList block.index];
                        self.notRatedList(...
                            self.notRatedList == block.index) = [];
                        self.goodList(self.goodList == block.index) = [];
                        self.badList(self.badList == block.index) = [];
                        self.interpolateList(...
                            self.interpolateList == block.index) = [];
                        self.okList = sort(unique(self.okList));
                    end
                case self.CGV.RATINGS.Bad
                    if( ~ ismember(block.index, self.badList ) )
                        self.badList = [self.badList block.index];
                        self.notRatedList(...
                            self.notRatedList == block.index) = [];
                        self.okList(self.okList == block.index) = [];
                        self.goodList(self.goodList == block.index) = [];
                        self.interpolateList(...
                            self.interpolateList == block.index) = [];
                        self.badList = sort(unique(self.badList));
                    end
                case self.CGV.RATINGS.Interpolate
                    if( ~ ismember(block.index, self.interpolateList ) )
                        self.interpolateList = ...
                            [self.interpolateList block.index];
                        self.notRatedList(...
                            self.notRatedList == block.index) = [];
                        self.okList(self.okList == block.index) = [];
                        self.badList(self.badList == block.index) = [];
                        self.goodList(self.goodList == block.index) = [];
                        self.interpolateList = ...
                            sort(unique(self.interpolateList));
                    end
                case self.CGV.RATINGS.NotRated
                    if( ~ ismember(block.index, self.notRatedList ) )
                        self.notRatedList = ...
                            [self.notRatedList block.index];
                        self.goodList(self.goodList == block.index) = [];
                        self.okList(self.okList == block.index) = [];
                        self.badList(self.badList == block.index) = [];
                        self.interpolateList(...
                            self.interpolateList == block.index) = [];
                        self.notRatedList = sort(unique(self.notRatedList));
                    end
            end
        end
        
        function self = updateRatingStructures(self)
            % Updates the data structures of this project. Look
            % createRatingStructure() for more info.
            % This method may be time consuming depending on the number of
            % files in both dataFolder and resultFolder as it goes
            % through every block and fetches relevant information.
            %
            % This functionality helps to merge different projects
            % together. As it goes through all files in the dataFolder and
            % resultFolder, it finds out the new files that are added to
            % these folders, and updates the data correspondigly. If
            % there are raw files added to the dataFolder only, it means some
            % new subjects are added. If there are raw files added to the
            % dataFolder and they have also their corresponding new
            % preprocessed files in the resultFolder, it means that some
            % data from another projects are added to this project. If
            % there are some new preprocessed files added to the
            % resultFolder only , they will be considered only if a
            % corresponding rawData in the dataFolder exist. Otherwise they
            % are ignored.
            % If on the other hand, any files is deleted from any of those
            % two folders, they are not copied to the new data structures
            % and considered as deleted files in the project.
            
            if usejava('Desktop')
                h = waitbar(0,'Updating project. Please wait...');
                h.Children.Title.Interpreter = 'none';
            else
                fprintf('Updating project. Please wait...\n');
            end
            slash = filesep;
            % Load subject folders
            subjects = self.listSubjectFiles();
            sCount = length(subjects);
            if all(startsWith(subjects, 'sub-'))
                isBIDS = 1;
            else
                isBIDS = 0;
            end
            
            nPreprocessedSubject = 0;
            ext = self.fileExtension;
            map = containers.Map;
            list = {};
            pList = {};
            iList = [];
            gList = [];
            bList = [];
            oList = [];
            nList = [];
            alreadyList = [];
            
            filesCount = 0;
            nPreprocessedFile = 0;
            for i = 1:length(subjects)
                if(usejava('Desktop') && ishandle(h))
                    waitbar((i-1) / length(subjects), h)
                end
                
                subjectName = subjects{i};
                subject = Subject([self.dataFolder subjectName], ...
                    [self.resultFolder subjectName]);
                
                rawFiles = [];
                if isBIDS
                    sessOrEEG = self.listSubjects(subject.dataFolder);
                    if ~isempty(startsWith(sessOrEEG, 'ses-')) && all(startsWith(sessOrEEG, 'ses-'))
                        for sesIdx = 1:length(sessOrEEG)
                            sessFile = sessOrEEG{sesIdx};
                            eegFold = [subject.dataFolder slash sessFile slash 'eeg' slash];
                            if exist(eegFold, 'dir')
                                rawFiles = [rawFiles self.dirNotHiddens([eegFold '*' self.mask])'];
                            end
                        end
                    elseif ~isempty(startsWith(sessOrEEG, 'ses-')) && any(startsWith(sessOrEEG, 'eeg'))
                        eegFold = [subject.dataFolder slash 'eeg' slash];
                        rawFiles = self.dirNotHiddens([eegFold '*' self.mask]);
                    else
                        rawFiles = self.dirNotHiddens(...
                            [self.dataFolder subjectName slash '*' self.mask]);
                    end
                else % Not BIDS format, the the raw files are in the subject folder itself
                    rawFiles = self.dirNotHiddens(...
                        [self.dataFolder subjectName slash '*' self.mask]);
                end
                
                temp = 0;
                for j = 1:length(rawFiles)
                    filesCount = filesCount + 1;
                    file = rawFiles(j);
                    filePath = [file.folder slash file.name];
                    nameTmp = file.name;
                    if ~contains(nameTmp, ext)
                        if all(isstrprop(ext(2:end), 'lower'))
                            ext = upper(ext);
                        elseif all(isstrprop(ext(2:end), 'upper'))
                            ext = lower(ext);
                        end
                        self.mask = strrep(self.mask, self.fileExtension, ext);
                        self.fileExtension = ext;
                    end
                    splits = strsplit(nameTmp, ext);
                    fileName = splits{1};
                    uniqueName = strcat(subjectName, '_', fileName);
                    
                    fprintf(['...Adding file ', fileName, '\n']);
                    if(usejava('Desktop') && ishandle(h))
                        waitbar((i-1) / length(subjects), h, ...
                            ['Setting up project. Please wait.', ...
                            ' Adding file ', fileName, '...'])
                    end
                    % Merge data and update blockList
                    if isKey(self.blockMap, uniqueName)
                        % File has been here
                        
                        block = self.blockMap(uniqueName);
                        % Add it to the new list anyways. So that if
                        % anything has been deleted, it's not copied to
                        % this new list.
                        map(block.uniqueName) = block;
                        list{filesCount} = block.uniqueName;
                        block.index = filesCount;
                        if (~ isempty(block.potentialResultAddress))
                            % Some results exist
                            
                            IndexC = strfind(self.processedList, uniqueName);
                            Index = find(not(cellfun('isempty', IndexC)), 1);
                            if( ~isempty(Index))
                                % Currently a result file exists. There has
                                % been a result file before as well. So
                                % don't do anything. Here we don't check
                                % whether the rating info has been changed.
                            else % The result is new
                                % Update the rating info of the block
                                try
                                    block.updateRatingInfoFromFile();
                                catch ME
                                    if ~contains(ME.identifier, 'Automagic')
                                        rethrow(ME);
                                    end
                                    list{filesCount} = [];
                                    filesCount = filesCount - 1;
                                    remove(map, block.uniqueName);
                                    
                                    warning(ME.message)
                                    self.writeToLog(...
                                        block.sourceAddress, ME.message);
                                    continue;
                                end
                            end
                        else
                            % In any case, no file exists, so resets the rating info
                            try
                                block.updateRatingInfoFromFile();
                            catch ME
                                if ~contains(ME.identifier, 'Automagic')
                                    rethrow(ME);
                                end
                                list{filesCount} = [];
                                filesCount = filesCount - 1;
                                remove(map, block.uniqueName);
                                
                                warning(ME.message)
                                self.writeToLog(block.sourceAddress, ...
                                    ME.message);
                                continue;
                            end
                        end
                    else
                        % File is new
                        
                        % Block creation extracts and updates automatically
                        % the rating information from the existing files,
                        % if any.
                        try
                            block = Block(self, subject, fileName, filePath, self.CGV);
                        catch ME
                            if ~contains(ME.identifier, 'Automagic')
                                rethrow(ME);
                            end
                            filesCount = filesCount - 1;
                            warning(ME.message)
                            if exist('block', 'var')
                                self.writeToLog(block.sourceAddress, ...
                                    ME.message);
                            else
                                self.writeToLog(fileName, ME.message);
                            end
                            continue;
                        end
                        map(block.uniqueName) = block;
                        list{filesCount} = block.uniqueName;
                        block.index = filesCount;
                    end
                    
                    % Update the processedList
                    if (~ isempty(block.potentialResultAddress))
                        
                        switch block.rate
                            case self.CGV.RATINGS.Good
                                gList = [gList block.index];
                            case self.CGV.RATINGS.OK
                                oList = [oList block.index];
                            case self.CGV.RATINGS.Bad
                                bList = [bList block.index];
                            case self.CGV.RATINGS.Interpolate
                                iList = [iList block.index];
                            case self.CGV.RATINGS.NotRated
                                nList = [nList block.index];
                        end
                        
                        if block.isInterpolated
                            alreadyList = [alreadyList block.index];
                        end
                        pList{end + 1} = block.uniqueName;
                        nPreprocessedFile = ...
                            nPreprocessedFile + 1;
                        temp = temp + 1;
                    end
                end
                if (~isempty(rawFiles) && temp == length(rawFiles))
                    nPreprocessedSubject = ...
                        nPreprocessedSubject + 1;
                end
            end
            if(usejava('Desktop') && ishandle(h))
                waitbar(1)
                close(h)
            end
            % Inform user if result folder has been modified
            if( nPreprocessedFile > self.nProcessedFiles || ...
                    nPreprocessedSubject > self.nProcessedSubjects)
                if( nPreprocessedSubject > self.nProcessedSubjects)
                    if isempty(self.email)
                        popup_msg(['New preprocessed results have been added'...
                            ' to the project folder.'], 'More results');
                    else
                        disp('New preprocessed results have been added to the project folder.')
                    end
                else
                    if isempty(self.email)
                        popup_msg(['New preprocessed results have been added'...
                            'to the project folder.'], 'More results');
                    else
                        disp('New preprocessed results have been added to the project folder.')
                    end
                end
            end
            if( nPreprocessedFile < self.nProcessedFiles || ...
                    nPreprocessedSubject < self.nProcessedSubjects)
                if( nPreprocessedSubject < self.nProcessedSubjects)
                    popup_msg(['Some preprocessed results have been'...
                        ' deleted from the project folder.'], ...
                        'Less results');
                else
                    popup_msg(['Some preprocessed results have been'...
                        ' deleted from the project folder.'], ...
                        'Less results');
                end
            end
            
            % Inform user if data folder has been modified
            if( filesCount > self.nBlock || ...
                    sCount > self.nSubject)
                if( sCount > self.nSubject)
                    popup_msg('New subjects are added to data folder.', ...
                        'New subjects');
                else
                    popup_msg('New files are added to data folder.', ...
                        'New results');
                end
            end
            
            if( filesCount < self.nBlock || ...
                    sCount < self.nSubject)
                if( sCount < self.nSubject)
                    popup_msg('You have lost some data files.', ...
                        'Less data');
                else
                    popup_msg('You have lost some data cosubjects.', ...
                        'Less data');
                end
            end
            self.nProcessedFiles = nPreprocessedFile;
            self.nProcessedSubjects = nPreprocessedSubject;
            self.processedList = pList;
            self.blockMap = map;
            self.blockList = list;
            self.nBlock = filesCount;
            self.nSubject = sCount;
            self.interpolateList = iList;
            self.goodList = gList;
            self.badList = bList;
            self.okList = oList;
            self.notRatedList = nList;
            self.alreadyInterpolated = alreadyList;
            
            % Assign current index
            if( isempty(self.processedList))
                self.current = -1;
            else
                if( self.current == -1)
                    self.current = 1;
                end
            end
            self.saveProject();
        end
        
        function ratings = getQualityRatings(self, cutoffs)
            % Return the quality ratings of all blocks given the cutoffs
            % cutoffs - the cutoffs for which the quality ratings are
            % returned
            
            blocks = values(self.blockMap, self.processedList);
            qScores = cellfun( @(block) block.getCurrentQualityScore(), blocks, 'uniform', 0);
            qScores = cell2mat(qScores);
            ratings = rateQuality(qScores, self.CGV, cutoffs)';
            ratings = cellfun( @self.makeRatingManually, blocks, ratings, 'uniform', 0);
        end
        
        function excludeChannelsFromRBC(self, exclude_chans)
            self.manuallyExcludedRBCChans = exclude_chans;
            blocks = values(self.blockMap, self.processedList);
            cellfun( @(block) block.excludeChannelsFromRBC(exclude_chans), blocks, 'uniform', 0);
        end
        
        function applyQualityRatings(self, cutoffs, applyToManuallyRated, keep_old)
            % Modify all the blocks to have the new ratings given by this
            % cutoffs. If applyToManuallyRated, then apply to every single
            % block. Otherwise, don't apply on the blocks for which the
            % rating has been manually selected in the ratingGUI.
            % cutoffs - The cutoffs for which the quality ratings are
            % returned
            % applyToManuallyRated - boolean indicating whether to apply on
            % all blocks or only those that are not manually rated.
            % keep_old - boolean indicating whether to recommit the old
            % files that are already commited, or only commit the newly
            % added files to the project
            assert (~ keep_old || isequaln(self.committedQualityCutoffs, cutoffs))
            
            files = self.processedList;
            blocks = self.blockMap;
            for i = 1:length(files)
                file = files{i};
                block = blocks(file);                
                if block.isInterpolated || isempty(block.tobeInterpolated)
                    % if the file is interpolated or there are no channels
                    % to interpolate:
                    disp(['Applying quality rating to ' files{i}])
                    newRate = rateQuality(block.getCurrentQualityScore(), self.CGV, cutoffs);
                    if (keep_old && block.commitedNb > 0)
                        % Do nothing. This block has been already commited and
                        % is not required to be commited again
                    else
                        if (applyToManuallyRated || ~ block.isManuallyRated)
                            block.setRatingInfoAndUpdate(struct('rate', newRate{:}, 'isManuallyRated', 0, 'commit', 1));
                            block.saveRatingsToFile();
                        else
                            block.setRatingInfoAndUpdate(struct('rate', block.rate, 'isManuallyRated', 1, 'commit', 1));
                            block.saveRatingsToFile();
                        end
                    end
                    
                else
                    disp(['File ', files{i}, ' not interpolated yet. Skipping... '])
                end
                    
            end
            
            self.committed = true;
            self.committedQualityCutoffs = cutoffs;
            self.qualityCutoffs = cutoffs;
        end
        
        function self = updateAddressesFormStateFile(self, ...
                pFolder, dataFolder, varargin)
            % This method must be called only when this project is a new
            % project loaded from a state file. The loaded project
            % may have not been created from this operating system, thus addresses
            % to the folders (which can be on the server as well) could be
            % different on this system, and they must be updated.
            % pFolder - the new address of the resultFolder
            % dataFolder - the new address of the dataFolder
            % varargin - It could contain the path to the channel location
            % if the previous file does not exist anymore
            
            self = self.setDataFolder(dataFolder);
            self = self.setResultFolder(pFolder);
            if ~ isempty(varargin) && ~ isempty(varargin{1})
                self.params.EEGSystem.locFile = varargin{1};
            end
            
            self.stateAddress = self.makeStateAddress(pFolder);
            self.saveProject();
        end
        
        function ratedCount = getRatedCount(self)
            % Return number of files that has been already rated
            ratedCount = length(self.processedList) - ...
                (length(self.notRatedList) + ...
                length(self.interpolateList));
        end
        
        function count = toBeInterpolatedCount(self)
            % Return the number of files that are rated as interpolate
            count = length(self.interpolateList);
        end
        
        function modified = areFoldersChanged(self)
            % Return True if any change has happended to dataFolder or
            % resultFolder since the last update. If it's true,
            % updateDataStructures must be called.
            
            dataChanged = self.isFolderChanged(self.dataFolder, ...
                self.nSubject, self.nBlock, self.mask, self.params.Settings.trackAllSteps);
            resultChanged = self.isFolderChanged(self.resultFolder, ...
                [], self.nProcessedFiles, self.CGV.EXTENSIONS(1).mat, self.params.Settings.trackAllSteps);
            modified = dataChanged || resultChanged;
        end
        
        function exportToBIDS(self, folder, makeRawBVA, makeDerivativesBVA, makeRawSET, makeDerivativesSET)
            % saves the preprocessed and/or raw eeg data and required 
            % metadata to a BIDS compatible folder structure.
            % if the source data is in bids format already, metadata will
            % be loaded and copied over to the derivatives set 
            % (inheritance principle).
            % 
            % current version: BIDS 1.6.0
            % link: https://bids-specification.readthedocs.io/en/stable/
            
            BIDS_bidsVersion = '1.6.0';
            % get version of automagic pipeline (would be better to fetch it from self!)
            BIDS_pipelineVersion = self.CGV.VERSION;
            % the following BIDS files will be searched and copied verbatim
            BIDS_recommendedFiles = {'*_events.*', '*_channels.*', '*_electrodes.*', '*_coordsystem.json', '*_photo.jpg', '*_scans.tsv'};

            % init
            if ~ (makeRawBVA || makeRawSET || makeDerivativesBVA || makeDerivativesSET)
                return;
            end
            slash = filesep;
            if ~exist(folder, 'dir')
                mkdir(folder);
            end
            
            if usejava('Desktop')
                h = waitbar(0,'Exporting to BIDS format. Please wait...');
                h.Children.Title.Interpreter = 'none';
            else
                fprintf('Exporting results folder to BIDS format. Please wait...\n');
            end
            
            % setup bids compatible folder structure 
            der_fol = fullfile(folder, 'derivatives', slash);
            raw_fol = fullfile(folder);
            automagic_fol = fullfile(der_fol, 'automagic', slash);
            code_fol = fullfile(automagic_fol, 'code', slash);
            
            % create folders if not already existing
            if ~ exist(code_fol, 'dir') && (makeDerivativesBVA || makeDerivativesSET)
                mkdir(code_fol);
            end
            if ~ exist(folder, 'dir') && (makeRawBVA || makeRawSET)
                mkdir(folder);
            end
                
            % try to load dataset_description.json (inheritance principle), 
            % otherwise start a new file
            BIDS_minimalDatasetDesc.Name = [self.name]; % REQUIRED
            BIDS_minimalDatasetDesc.BIDSVersion = [BIDS_bidsVersion]; % REQUIRED
            BIDS_minimalDatasetDesc.DatasetType = ['raw']; % RECOMMENDED
            BIDS_minimalDatasetDesc.License = ['n/a']; % RECOMMENDED
            BIDS_minimalDatasetDesc.Authors = ['n/a'];
            BIDS_minimalDatasetDesc.Acknowledgements = ['n/a'];
            BIDS_minimalDatasetDesc.HowToAcknowledge = ['n/a'];
            BIDS_minimalDatasetDesc.Funding = ['n/a'];
            BIDS_minimalDatasetDesc.ReferencesAndLinks = ['n/a'];
            BIDS_minimalDatasetDesc.DatasetDOI = ['n/a']; 
            
            BIDS_requiredDatasetDesc = {'Name', 'BIDSVersion'};
            
            try
                BIDS_dataset_description_raw = jsonread([self.dataFolder 'dataset_description.json']);
                for BIDS_required = BIDS_requiredDatasetDesc % check if required fields are present
                    BIDS_required = BIDS_required{1};
                    if ~isfield(BIDS_dataset_description_raw, BIDS_required)
                        BIDS_dataset_description_raw.(BIDS_required) = BIDS_minimalDatasetDesc.(BIDS_required);
                    end
                end
            catch
                BIDS_dataset_description_raw = BIDS_minimalDatasetDesc;                                              
            end
                        
            % add required fields for BIDS derivatives to dataset_description
            BIDS_dataset_description_der = BIDS_dataset_description_raw;
            BIDS_dataset_description_der.DatasetType = ['derivative'];
            BIDS_dataset_description_der.GeneratedBy = [struct('Name','automagic','Version',BIDS_pipelineVersion)];
            if (makeRawBVA || makeRawSET)
                BIDS_sourcedatasetURL = ['file://../'];
            else
                BIDS_sourcedatasetURL = [self.dataFolder];
            end
            BIDS_dataset_description_der.SourceDatasets = [struct('URL', BIDS_sourcedatasetURL)];
            
            % save dataset_description.json files
            datasetDescriptionFile_raw = [raw_fol 'dataset_description.json'];
            datasetDescriptionFile_deriv = [automagic_fol 'dataset_description.json'];
            if makeRawBVA || makeRawSET
                jsonwrite_new(datasetDescriptionFile_raw, BIDS_dataset_description_raw, struct('indent','  '));
            end
            if makeDerivativesSET || makeDerivativesBVA
                jsonwrite_new(datasetDescriptionFile_deriv, BIDS_dataset_description_der, struct('indent','  '));
            end
            
            % loop over all subjects/eeg files and create corresponding
            % files
            fileNames = self.blockMap.keys;
            for i = 1:length(fileNames)
                if(usejava('Desktop') && ishandle(h))
                    waitbar((i-1) / length(self.processedList), h)
                end
                
                fileName = fileNames{i};
                block = self.blockMap(fileName);
                
                
                % determine whether original filename is already bids compatible
                isBIDS = logical(regexp(block.fileName, regexptranslate('wildcard', 'sub-*_task-*_eeg'))); 
                
                % setup BIDS compatible filenames
                if isBIDS
                    fnameParts = strsplit(block.fileName, '_');
                    BIDS_subjectName = fnameParts{1};
                    BIDS_fnameRoot = strjoin(fnameParts(1:length(fnameParts)-1), '_');
                    for fnamePart = fnameParts
                        fnamePart = fnamePart{1};
                        if logical(regexp(fnamePart, regexptranslate('wildcard', 'task-*')))
                            BIDS_taskName = fnamePart(6:length(fnamePart));
                        end
                    end
                    if strcmp(fnameParts{2}(1:4), 'ses-')
                        newResSubAdd = fullfile(automagic_fol, BIDS_subjectName, slash, fnameParts{2}, slash, 'eeg', slash);
                        newRawSubAdd = fullfile(raw_fol, BIDS_subjectName, slash, fnameParts{2}, slash, 'eeg', slash);
                    else
                        newResSubAdd = fullfile(automagic_fol, BIDS_subjectName, slash, 'eeg', slash);
                        newRawSubAdd = fullfile(raw_fol, BIDS_subjectName, slash, 'eeg', slash);
                    end
                else
                    % no bids compatible filename so far..
                    if length(block.subject.name) > 4 && strcmp(block.subject.name(1:4), 'sub-')
                        BIDS_subjectName = block.subject.name;
                    else
                        BIDS_subjectName = ['sub-' block.subject.name];
                    end
                    BIDS_taskName = 'unspecified'; % default taskName
                    BIDS_fnameRoot = [BIDS_subjectName '_task-' BIDS_taskName];

                    newResSubAdd = fullfile(automagic_fol, BIDS_subjectName, slash, 'eeg', slash);
                    newRawSubAdd = fullfile(raw_fol, BIDS_subjectName, slash, 'eeg', slash);
                end
                
                % add automagic quality rating to optional 'desc' field of the BIDS filename
                BIDS_desc = block.prefix; 
                
                % final filenames for result files
                newResFile = [newResSubAdd BIDS_fnameRoot '_desc-' BIDS_desc '_eeg'];
                newResJSONFile = [newResSubAdd BIDS_fnameRoot '_desc-' BIDS_desc '_eeg.json'];
                newReslogFile = [newResSubAdd BIDS_fnameRoot '_desc-' BIDS_desc '_log.txt'];
                newResPhotoFiles = {
                    [newResSubAdd BIDS_fnameRoot '_desc-source_photo.jpg'], [newResSubAdd BIDS_fnameRoot '_desc-' BIDS_desc '_photo.jpg']
                    };

                newRawFile = [newRawSubAdd BIDS_fnameRoot '_eeg']; %#ok<NASGU>
                newRawJSONFile = [newRawSubAdd BIDS_fnameRoot '_eeg.json'];
               
                % create subject specific folders if not existing
                if ~ exist(newResSubAdd, 'dir') && (makeDerivativesBVA || makeDerivativesSET)
                    mkdir(newResSubAdd);
                end
                if ~ exist(newRawSubAdd, 'dir') && (makeRawBVA || makeRawSET)
                    mkdir(newRawSubAdd);
                end
                
                % define BIDS template for sidecar json (better to load itfrom template?)
                BIDS_minimalSidecar.TaskName = [BIDS_taskName]; % REQUIRED
                BIDS_minimalSidecar.EEGReference = ['n/a']; % REQUIRED
                BIDS_minimalSidecar.SamplingFrequency = [block.sRate]; % REQUIRED
                BIDS_minimalSidecar.PowerLineFrequency = block.params.EEGSystem.powerLineFreq; % REQUIRED
                BIDS_minimalSidecar.SoftwareFilters = []; % REQUIRED
                
                BIDS_requiredSidecar = {'TaskName', 'EEGReference', 'SamplingFrequency', 'PowerLineFrequency', 'SoftwareFilters'};

                % try to load sidecar json and other required BIDS files from source folder (see BIDS inheritance principle)
                try
                    [sourcepath, sourcefile, ~] = fileparts(block.sourceAddress);
                    BIDS_sidecar_raw = jsonread([sourcepath slash sourcefile '.json']);
                    % add required fields if missing
                    for BIDS_required = BIDS_requiredSidecar
                        BIDS_required = BIDS_required{1};
                        if ~isfield(BIDS_sidecar_raw, BIDS_required)
                            BIDS_sidecar_raw.(BIDS_required) = BIDS_minimalSidecar.(BIDS_required);
                        end
                    end
                catch
                    BIDS_sidecar_raw = BIDS_minimalSidecar;
                end
                
                % save source EEG data
                if makeRawSET
                    EEG = block.loadEEGFromFile(); %#ok<NASGU>
                    newRawFile1 = [newRawFile '.set'];
                    [~, ~] = evalc('pop_saveset(EEG,''filename'',newRawFile1,''version'',''7.3'')');
                end
                
                if makeRawBVA
                    EEG = block.loadEEGFromFile(); %#ok<NASGU>
                    newRawFile2 = [newRawFile '.dat']; 
                    [~, ~] = evalc('pop_writebva(EEG,newRawFile2)');
                end
                
                % save sidecar json for raw file
                if makeRawBVA || makeRawSET
                    jsonwrite_new(newRawJSONFile, BIDS_sidecar_raw, struct('indent','  '));
                end
                
              
                        
                % save preprocessed EEG files / derivatives
                if exist(block.resultAddress, 'file') && makeDerivativesBVA || makeDerivativesSET
                    % Result file
                    if makeDerivativesBVA
                        newResFile1 = [newResFile '.dat'];
                        EEG = load(block.resultAddress);
                        EEG = EEG.EEG;
                        [~, ~] = evalc('pop_writebva(EEG,newResFile1)');

                    end
                    
                    if makeDerivativesSET
                        EEG = load(block.resultAddress);
                        EEG = EEG.EEG;
                        newResFile2 = [newResFile '.set'];
                        [~, ~] = evalc('pop_saveset(EEG,''filename'',newResFile2,''version'',''7.3'')');
                    end
                    
                    % inherit data from existing sidecar json (or minimal template)
                    BIDS_sidecar_der = BIDS_sidecar_raw;

                    %  update sidecar json with Automagic fields
                    preprocessed = matfile(block.resultAddress,'Writable',true);
                    autStruct = preprocessed.automagic;
                    if ~ strcmp('Others', autStruct.EEGSystem.params.name)
                        BIDS_sidecar_der.CapManufacturer = autStruct.EEGSystem.params.name;
                    end
                    BIDS_sidecar_der.EEGChannelCount = autStruct.EEGChannelCount;
                    BIDS_sidecar_der.EOGChannelCount = length(autStruct.channelReduction.usedEOGChannels);
                    BIDS_sidecar_der.PowerLineFrequency = autStruct.params.EEGSystem.powerLineFreq;
                    BIDS_sidecar_der.SamplingFrequency = autStruct.SamplingFrequency;
                    BIDS_sidecar_der.RecordingDuration = autStruct.RecordingDuration;
                    if ~ isempty(autStruct.params.DetrendingParams)
                        BIDS_sidecar_der.Detrending = 'Constant';
                    else
                        BIDS_sidecar_der.Detrending = 'No Detrending';
                    end
                    BIDS_sidecar_der.EEGReference = autStruct.EEGReference;
                    BIDS_sidecar_der.ExcludedChannels = autStruct.channelReduction.excludedChannels;
                    BIDS_sidecar_der.EEGChannels = autStruct.channelReduction.usedEEGChannels;
                    BIDS_sidecar_der.EOGChannels = autStruct.channelReduction.usedEOGChannels;
                    BIDS_sidecar_der.PreprocessingSoftware.Name = ['Automagic ' self.CGV.VERSION];
                    BIDS_sidecar_der.PreprocessingSoftware.ToolboxReference = 'Pedroni, Andreas & Bahreini, Amirreza & Langer, Nicolas. (2018). AUTOMAGIC: Standardized Preprocessing of Big EEG Data. 10.1101/460469.';
                    BIDS_sidecar_der.BadChannelInterpolation.Method = autStruct.params.InterpolationParams.method;
                    BIDS_sidecar_der.BadChannelInterpolation.Performed = 'No';
                    BIDS_sidecar_der.BadChannelInterpolation.BadChannels = autStruct.tobeInterpolated;
                    if autStruct.isInterpolated
                        BIDS_sidecar_der.BadChannelInterpolation.Performed = 'Yes';
                        BIDS_sidecar_der.BadChannelInterpolation.InterpolatedBadChannels = autStruct.finalBadChans;
                    end
                    
                    BIDS_sidecar_der.BadChannelIdentification = struct;
                    if ~isempty(autStruct.params.PrepParams)
                        BIDS_sidecar_der.BadChannelIdentification.PREP.IdentifcationMethod= 'PREP pipeline';
                        BIDS_sidecar_der.BadChannelIdentification.PREP.ToolboxReference = 'Bigdely-Shamlo N, Mullen T, Kothe C, Su K-M and Robbins KA (2015)';
                        BIDS_sidecar_der.BadChannelIdentification.PREP.ToolboxVersion = '0.55.3 Released 10/19/2017';
                        BIDS_sidecar_der.BadChannelIdentification.PREP.BadChannels = autStruct.prep.badChans;
                        BIDS_sidecar_der.BadChannelIdentification.PREP.BadChannelCriteria.ExtremeAmplitudes.RobustDeviationThreshold = autStruct.prep.params.reference.robustDeviationThreshold;
                        BIDS_sidecar_der.BadChannelIdentification.PREP.BadChannelCriteria.LackOfCorrelation.correlationWindowSeconds = autStruct.prep.params.reference.correlationWindowSeconds;
                        BIDS_sidecar_der.BadChannelIdentification.PREP.BadChannelCriteria.LackOfCorrelation.correlationThreshold = autStruct.prep.params.reference.correlationThreshold;
                        BIDS_sidecar_der.BadChannelIdentification.PREP.BadChannelCriteria.LackOfPredictability.ransacSampleSize = autStruct.prep.params.reference.ransacSampleSize;
                        BIDS_sidecar_der.BadChannelIdentification.PREP.BadChannelCriteria.LackOfPredictability.ransacChannelFraction = autStruct.prep.params.reference.ransacChannelFraction;
                        BIDS_sidecar_der.BadChannelIdentification.PREP.BadChannelCriteria.LackOfPredictability.ransacUnbrokenTime = autStruct.prep.params.reference.ransacUnbrokenTime;
                        BIDS_sidecar_der.BadChannelIdentification.PREP.BadChannelCriteria.LackOfPredictability.ransacWindowSeconds = autStruct.prep.params.reference.ransacWindowSeconds;
                        BIDS_sidecar_der.BadChannelIdentification.PREP.BadChannelCriteria.LackOfPredictability.ransacCorrelationThreshold = autStruct.prep.params.reference.ransacCorrelationThreshold;
                        BIDS_sidecar_der.BadChannelIdentification.PREP.BadChannelCriteria.HighFrequencyNoise.highFrequencyNoiseThreshold = autStruct.prep.params.reference.highFrequencyNoiseThreshold;
                        
                    end
                    
                    if ~isempty(autStruct.params.CRDParams)
                        BIDS_sidecar_der.BadChannelIdentification.CRD.IdentifcationMethod= 'clean_rawdata()';
                        BIDS_sidecar_der.BadChannelIdentification.CRD.ToolboxReference = 'Christian Kothe http://sccn.ucsd.edu/wiki/Plugin_list_process';
                        BIDS_sidecar_der.BadChannelIdentification.CRD.ToolboxVersion = '0.34';
                        BIDS_sidecar_der.BadChannelIdentification.CRD.BadChannels = autStruct.crd.badChans;
                        if isfield(autStruct.crd.params, 'FlatlineCriterion') && ...
                                ~ strcmp(pars.FlatlineCriterion , 'off')
                            flatLine = autStruct.crd.params.FlatlineCriterion;
                            BIDS_sidecar_der.BadChannelIdentification.CRD.BadChannelCriteria.FlatChannels.Used = 'Yes';
                            BIDS_sidecar_der.BadChannelIdentification.CRD.BadChannelCriteria.FlatChannels.FlatLine = flatLine;
                        elseif isfield(autStruct.crd.params, 'FlatlineCriterion') && ...
                                strcmp(pars.FlatlineCriterion , 'off')
                            BIDS_sidecar_der.BadChannelIdentification.CRD.BadChannelCriteria.FlatChannels.Used = 'No';
                        else
                            flatLine = 5; % the default is HARDCODED
                            BIDS_sidecar_der.BadChannelIdentification.CRD.BadChannelCriteria.FlatChannels.Used = 'Yes';
                            BIDS_sidecar_der.BadChannelIdentification.CRD.BadChannelCriteria.FlatChannels.FlatLine = flatLine;
                        end
                        
                        if ~ strcmp(autStruct.crd.params.LineNoiseCriterion, 'off')
                            BIDS_sidecar_der.BadChannelIdentification.CRD.BadChannelCriteria.ExceedingNoise.Used = 'Yes';
                            BIDS_sidecar_der.BadChannelIdentification.CRD.BadChannelCriteria.ExceedingNoise.Criterion = flatLine;
                        else
                            BIDS_sidecar_der.BadChannelIdentification.CRD.BadChannelCriteria.ExceedingNoise.Used = 'No';
                        end
                        
                        if ~ strcmp(autStruct.crd.params.ChannelCriterion, 'off')
                            if isfield(autStruct.crd.params, 'ChannelCriterionMaxBadTime')
                                MaxBrokenTime = autStruct.crd.params.ChannelCriterionMaxBadTime;
                            else
                                MaxBrokenTime = 0.4; % the default is HARDCODED
                            end
                            
                            BIDS_sidecar_der.BadChannelIdentification.CRD.BadChannelCriteria.LackOfPredictability.Used = 'Yes';
                            BIDS_sidecar_der.BadChannelIdentification.CRD.BadChannelCriteria.LackOfPredictability.MaxBrokenTime = MaxBrokenTime;
                            BIDS_sidecar_der.BadChannelIdentification.CRD.BadChannelCriteria.LackOfPredictability.ChannelCriterion = autStruct.crd.params.ChannelCriterion;
                        else
                            BIDS_sidecar_der.BadChannelIdentification.CRD.BadChannelCriteria.LackOfPredictability.Used = 'No';
                        end
                    end
                    
                    if ~isempty(autStruct.params.HighvarParams)
                        BIDS_sidecar_der.BadChannelIdentification.HighVar.IdentifcationMethod= 'High variance rejection';
                        BIDS_sidecar_der.BadChannelIdentification.HighVar.ToolboxReference = '';
                        BIDS_sidecar_der.BadChannelIdentification.HighVar.ToolboxVersion = '';
                        BIDS_sidecar_der.BadChannelIdentification.HighVar.BadChannels = autStruct.highVarianceRejection.badChans;
                        BIDS_sidecar_der.BadChannelIdentification.HighVar.BadChannelCriteria.sd = autStruct.highVarianceRejection.sd;
                    end
                    
                    if ~isempty(autStruct.params.MinvarParams)
                        BIDS_sidecar_der.BadChannelIdentification.MinVar.IdentifcationMethod= 'Minimum variance rejection';
                        BIDS_sidecar_der.BadChannelIdentification.MinVar.ToolboxReference = '';
                        BIDS_sidecar_der.BadChannelIdentification.MinVar.ToolboxVersion = '';
                        BIDS_sidecar_der.BadChannelIdentification.MinVar.BadChannels = autStruct.minVarianceRejection.badChans;
                        BIDS_sidecar_der.BadChannelIdentification.MinVar.BadChannelCriteria.sd = autStruct.minVarianceRejection.sd;
                    end
                    
                    if ~isempty(autStruct.params.FilterParams)
                        if ~isempty(autStruct.params.FilterParams.high)
                            BIDS_sidecar_der.SoftwareFilters.Highpass.FilterType = 'highpass fir using pop_eegfiltnew()';
                            BIDS_sidecar_der.SoftwareFilters.Highpass.HighCutoff = autStruct.filtering.highpass.freq;
                            BIDS_sidecar_der.SoftwareFilters.Highpass.HighCutoffDefinition = 'half-amplitude (-6dB)';
                            BIDS_sidecar_der.SoftwareFilters.Highpass.FilterOrder = autStruct.filtering.highpass.order;
                            BIDS_sidecar_der.SoftwareFilters.Highpass.TransitionBandwidth = autStruct.filtering.highpass.transitionBandWidth;
                        end
                        
                        if ~isempty(autStruct.params.FilterParams.low)
                            BIDS_sidecar_der.SoftwareFilters.Lowpass.FilterType = 'lowpass fir using pop_eegfiltnew()';
                            BIDS_sidecar_der.SoftwareFilters.Lowpass.LowCutoff = autStruct.filtering.lowpass.freq;
                            BIDS_sidecar_der.SoftwareFilters.Lowpass.LowCutoffDefinition = 'half-amplitude (-6dB)';
                            BIDS_sidecar_der.SoftwareFilters.Lowpass.FilterOrder = autStruct.filtering.lowpass.order;
                            BIDS_sidecar_der.SoftwareFilters.Lowpass.TransitionBandwidth = autStruct.filtering.lowpass.transitionBandWidth;
                        end
                        
                        if ~isempty(autStruct.params.FilterParams.notch)
                            BIDS_sidecar_der.SoftwareFilters.Notch.FilterType = 'notch fir using pop_eegfiltnew()';
                            BIDS_sidecar_der.SoftwareFilters.Notch.NotchCutoff = autStruct.filtering.notch.freq;
                            BIDS_sidecar_der.SoftwareFilters.Notch.NotchCutoffDefinition = 'half-amplitude (-6dB)';
                            BIDS_sidecar_der.SoftwareFilters.Notch.FilterOrder = autStruct.filtering.notch.order;
                            BIDS_sidecar_der.SoftwareFilters.Notch.TransitionBandwidth = autStruct.filtering.notch.transitionBandWidth;
                        end
                        if ~isempty(autStruct.params.FilterParams.zapline)
                            BIDS_sidecar_der.SoftwareFilters.Zapline.FilterType = 'ZapLine fir using nt_zapline()';
                            BIDS_sidecar_der.SoftwareFilters.Zapline.NotchCutoff = autStruct.filtering.zapline.freq;
%                             bidsStruct.SoftwareFilters.Zapline.NotchCutoffDefinition = 'half-amplitude (-6dB)';
%                             bidsStruct.SoftwareFilters.Zapline.FilterOrder = autStruct.filtering.notch.order;
%                             bidsStruct.SoftwareFilters.Zapline.TransitionBandwidth = autStruct.filtering.notch.transitionBandWidth;
                        end
                    end
                    if ~isempty(autStruct.params.EOGRegressionParams)
                        BIDS_sidecar_der.ArtifactCorrection.EOGRegression.Used = 'Yes';
                        BIDS_sidecar_der.ArtifactCorrection.EOGRegression.ToolboxReference = 'Parra, Lucas C., Clay D. Spence, Adam D. Gerson, and Paul Sajda. 2005. ???Recipes for the Linear Analysis of EEG.???? NeuroImage 28 (2): 326???41';
                    end
                    
                    if ~isempty(autStruct.params.MARAParams) && ~strcmp(autStruct.mara.performed,'FAILED')
                        BIDS_sidecar_der.ArtifactCorrection.MARA.RemovedBadICs = autStruct.mara.ICARejected;
                        BIDS_sidecar_der.ArtifactCorrection.MARA.PosteriorArtefactProbability = autStruct.mara.postArtefactProb;
                        BIDS_sidecar_der.ArtifactCorrection.MARA.RetainedVariance = autStruct.mara.retainedVariance;
                        BIDS_sidecar_der.ArtifactCorrection.MARA.ToolboxReference = 'Winkler, Irene, Stefan Haufe, and Michael Tangermann. 2011. ???Automatic Classification of Artifactual ICA-Components for Artifact Removal in EEG Signals.???? Behavioral and Brain Functions: BBF 7 (August): 30';
                    end
                    
                    if ~isempty(autStruct.params.RPCAParams)
                        BIDS_sidecar_der.ArtifactCorrection.RPCA.RPCALambda = autStruct.rpca.lambda;
                        BIDS_sidecar_der.ArtifactCorrection.RPCA.Tolerance = autStruct.rpca.tol;
                        BIDS_sidecar_der.ArtifactCorrection.RPCA.MaxIterations = autStruct.rpca.maxIter;
                        BIDS_sidecar_der.ArtifactCorrection.RPCA.ToolboxReference = 'Lin, Zhouchen, Minming Chen, and Yi Ma. 2010. ???The Augmented Lagrange Multiplier Method for Exact Recovery of Corrupted Low-Rank Matrices.???? arXiv [math.OC]. arXiv. http://arxiv.org/abs/1009.5055';
                    end
                    BIDS_sidecar_der.QualityRating.QualityThresholds.OverallHighAmplitudeThreshold = autStruct.qualityThresholds.overallThresh;
                    BIDS_sidecar_der.QualityRating.QualityThresholds.TimepointsHighVarianceThreshold = autStruct.qualityThresholds.timeThresh;
                    BIDS_sidecar_der.QualityRating.QualityThresholds.ChannelsHighVarianceThreshold = autStruct.qualityThresholds.chanThresh;
                    BIDS_sidecar_der.QualityRating.QualityScores.OverallHighAmplitude = autStruct.qualityScores.OHA;
                    BIDS_sidecar_der.QualityRating.QualityScores.TimepointsHighVariance = autStruct.qualityScores.THV;
                    BIDS_sidecar_der.QualityRating.QualityScores.ChannelsHighVariance = autStruct.qualityScores.CHV;
                    BIDS_sidecar_der.QualityRating.QualityScores.MeanAbsoluteVoltage = autStruct.qualityScores.MAV;
                    BIDS_sidecar_der.QualityRating.QualityScores.RatioOfBadChannels = autStruct.qualityScores.RBC;
                    BIDS_sidecar_der.QualityRating.SelectedQualityScore.OverallHighAmplitude = autStruct.selectedQualityScore.OHA;
                    BIDS_sidecar_der.QualityRating.SelectedQualityScore.TimepointsHighVariance = autStruct.selectedQualityScore.THV;
                    BIDS_sidecar_der.QualityRating.SelectedQualityScore.ChannelsHighVariance = autStruct.selectedQualityScore.CHV;
                    BIDS_sidecar_der.QualityRating.SelectedQualityScore.MeanAbsoluteVoltage = autStruct.selectedQualityScore.MAV;
                    BIDS_sidecar_der.QualityRating.SelectedQualityScore.RatioOfBadChannels = autStruct.selectedQualityScore.RBC;
                    BIDS_sidecar_der.QualityRating.CurrentRating = autStruct.rate;
                    BIDS_sidecar_der.QualityRating.ManuallyRated = autStruct.isManuallyRated;
                    
                    % save sidecar json
                    jsonwrite_new(newResJSONFile, BIDS_sidecar_der, struct('indent','  '));  
                             
                    % copy log file
                    logFile = [block.resultFolder slash block.fileName '_log.txt'];
                    copyfile(logFile, newReslogFile);
                    
                    % copy JPEG files
                    images = dir([block.resultFolder slash block.fileName '_orig.jpg']);
                    images = [images dir([block.resultFolder slash block.fileName '.jpg'])];
                    for imIdx = 1:length(images)
                        image = images(imIdx);
                        imageAddress = [image.folder slash image.name];
                        newImageAdd = newResPhotoFiles{imIdx};
                        copyfile(imageAddress, newImageAdd);
                    end
                    
                end
                
                % try copying recommended BIDS files (inheritance prinicple)
                BIDS_folderSource = fileparts(block.sourceAddress);
                BIDS_filesSource = {dir(BIDS_folderSource) dir(fileparts(BIDS_folderSource))};
                BIDS_filesSource = {BIDS_filesSource{1}.name BIDS_filesSource{2}.name};
                for BIDS_fileSource = BIDS_filesSource
                    tmp = regexp(BIDS_fileSource{1}, regexptranslate('wildcard', BIDS_recommendedFiles));
                    if [tmp{:}]
                        warning(['copying BIDS file ' BIDS_fileSource{1} ' verbatim - please check whether any of the content needs to be updated!'])
                        if makeDerivativesBVA || makeDerivativesSET
                            try
                                copyfile([BIDS_folderSource slash BIDS_fileSource{1}], [newResSubAdd BIDS_fileSource{1}])
                            catch % _scans.tsv is one folder level up
                                copyfile([fileparts(BIDS_folderSource) slash BIDS_fileSource{1}], [fileparts(newResSubAdd(1:end-1)) slash BIDS_fileSource{1}])
                            end
                        end
                        if makeRawBVA || makeRawSET
                            try
                                copyfile([BIDS_folderSource slash BIDS_fileSource{1}], [newRawSubAdd BIDS_fileSource{1}])
                            catch
                                copyfile([fileparts(BIDS_folderSource) slash BIDS_fileSource{1}], [fileparts(newRawSubAdd(1:end-1)) slash BIDS_fileSource{1}])
                            end
                        end
                    end
                end
            end
            
            % save pipeline parameter and matlab code to reproduce
            % preprocessing
            if makeDerivativesBVA || makeDerivativesSET
                paramsJSON = [code_fol 'automagic_params.json'];
                jsonwrite_new(paramsJSON, self.params, struct('indent','  '));
            
            
                params = self.params;
                vParams = self.vParams;
                params.samplingrate = block.sRate;

                save([code_fol 'params.mat'], 'params');
                save([code_fol 'vParams.mat'], 'vParams');
                reproduceCode = getCodeHistoryStruct();
                fid = fopen([code_fol 'automagic_preprocess.m'], 'wt');
                fprintf(fid, reproduceCode.create, self.name, self.dataFolder, self.name, self.fileExtension);
                fprintf(fid, reproduceCode.interpolate);
                fclose(fid);
            
            end
            
            if(usejava('Desktop') && ishandle(h))
                waitbar(1)
                close(h)
            end
        end
        
        function saveProject(self)
            % Save this class to the state file
            save(self.stateAddress, 'self');
        end
        
        function list = listSubjectFiles(self)
            % List all folders in the dataFolder
            list = self.listSubjects(self.dataFolder);
        end
        
        function list = listPreprocessedSubjects(self)
            % List all folders in the resultFolder
            list = self.listSubjects(self.resultFolder);
        end
        
    end
    
    %% Private Methods
    methods(Access=private)
        function self = createRatingStructure(self)
            % This method is called from the constructor to create and
            % initialise all data structures based on the data on both
            % dataFolder and resultFolder. This method may be time
            % consuming depending on the number of files in both
            % dataFolder and resultFolder as it goes through every block
            % and fetches relevant information.
            % In case there are already preprocessed files in the
            % resultFolder, the rating data structures are initialised
            % based on those preprocessed blocks and their corresponding
            % ratings.
            %
            % The following properties are created/updated:
            %   blockList
            %   processedList
            %   blockMap
            %   nProcessedSubjects
            %   nProcessedFiles
            %   nBlock
            %   current
            %   interpolateList
            %   goodList
            %   badList
            %   okList
            %   notRatedList
            %   (Look at their corresponding docs for more info)
            %
            % Why are there 5 lists for each rating ?
            % The rate of each block is not only saved in its corresponding
            % instance of the class Block, but there is also one list
            % corresponding to that rate which contains the list of
            % indices of all blocks that have this rate. This helps to
            % speed up the operations getNextIdx and getPreviousIdx
            % whenver a filter on ratings is applied.
            
            % How this works ?
            % The method goes through every single exising block in the
            % dataFolder, then tries to find the corresponding
            % preprocessed file in the resultFolder, if any. Then updates
            % the data structure based on the preprocessed result.
            if usejava('Desktop')
                h = waitbar(0,'Setting up project. Please wait...');
                h.Children.Title.Interpreter = 'none';
            else
                fprintf('Setting up project. Please wait...\n');
            end
            slash = filesep;
            % Load subject folders
            subjects = self.listSubjectFiles();
            sCount = length(subjects);
            
            if all(startsWith(subjects, 'sub-'))
                isBIDS = 1;
            else
                isBIDS = 0;
            end
            
            map = containers.Map;
            list = {};
            self.maxX = 0;
            ext = self.fileExtension;
            pList = {};
            iList = [];
            gList = [];
            bList = [];
            oList = [];
            nList = [];
            alreadyList = [];
            
            filesCount = 0;
            nPreprocessedFile = 0;
            nPreprocessedSubject = 0;
            for i = 1:length(subjects)
                if(usejava('Desktop') && ishandle(h))
                    waitbar((i-1) / length(subjects), h)
                end
                subjectName = subjects{i};
                fprintf(['Adding subject ', subjectName, '\n']);
                subject = Subject([self.dataFolder subjectName], ...
                    [self.resultFolder subjectName]);
                
                rawFiles = [];
                if isBIDS
                    sessOrEEG = self.listSubjects(subject.dataFolder);  
                    if ~isempty(startsWith(sessOrEEG, 'ses-')) && all(startsWith(sessOrEEG, 'ses-'))
                        for sesIdx = 1:length(sessOrEEG)
                            sessFile = sessOrEEG{sesIdx};
                            eegFold = [subject.dataFolder slash sessFile slash 'eeg' slash];
                            if exist(eegFold, 'dir')
                                rawFiles = [rawFiles self.dirNotHiddens([eegFold '*' self.mask])'];
                            end
                        end
                    elseif ~isempty(startsWith(sessOrEEG, 'ses-')) && any(startsWith(sessOrEEG, 'eeg'))
                        eegFold = [subject.dataFolder slash 'eeg' slash];
                        rawFiles = self.dirNotHiddens([eegFold '*' self.mask]);
                    else
                        rawFiles = self.dirNotHiddens(...
                            [self.dataFolder subjectName slash '*' self.mask]);
                    end
                else % Not BIDS format, the the raw files are in the subject folder itself
                    rawFiles = self.dirNotHiddens(...
                        [self.dataFolder subjectName slash '*' self.mask]);
                end
                
                temp = 0;
                for j = 1:length(rawFiles)
                    filesCount = filesCount + 1;
                    file = rawFiles(j);
                    filePath = [file.folder slash file.name];
                    nameTemp = file.name;
                    if ~contains(nameTemp, ext)
                        if all(isstrprop(ext(2:end), 'lower'))
                            ext = upper(ext);
                        elseif all(isstrprop(ext(2:end), 'upper'))
                            ext = lower(ext);
                        end
                        self.mask = strrep(self.mask, self.fileExtension, ext);
                        self.fileExtension = ext;
                    end
                    splits = strsplit(nameTemp, ext);
                    fileName = splits{1};
                    fprintf(['...Adding file ', fileName, '\n']);
                    if(usejava('Desktop') && ishandle(h))
                        waitbar((i-1) / length(subjects), h, ...
                            ['Setting up project. Please wait.', ...
                            ' Adding file ', fileName, '...'])
                    end
                    % Block creation extracts and updates automatically
                    % the rating information from the existing files, if any.
                    try
                        block = Block(self, subject, fileName, filePath, self.CGV);
                    catch ME
                        if ~contains(ME.identifier, 'Automagic')
                            rethrow(ME);
                        end
                        filesCount = filesCount - 1;
                        warning(ME.message)
                        if exist('block', 'var')
                            self.writeToLog(block.sourceAddress, ...
                                ME.message);
                        else
                            self.writeToLog(fileName, ME.message);
                        end
                        continue;
                    end
                    map(block.uniqueName) = block;
                    list{filesCount} = block.uniqueName;
                    block.index = filesCount;
                    
                    if ( ~ isempty(block.potentialResultAddress))
                        
                        switch block.rate
                            case self.CGV.RATINGS.Good
                                gList = [gList block.index];
                            case self.CGV.RATINGS.OK
                                oList = [oList block.index];
                            case self.CGV.RATINGS.Bad
                                bList = [bList block.index];
                            case self.CGV.RATINGS.Interpolate
                                iList = [iList block.index];
                            case self.CGV.RATINGS.NotRated
                                nList = [nList block.index];
                        end
                        
                        if block.isInterpolated
                            alreadyList = [alreadyList block.index];
                        end
                        pList{end + 1} = block.uniqueName;
                        nPreprocessedFile = ...
                            nPreprocessedFile + 1;
                        temp = temp + 1;
                    end
                end
                if (~isempty(rawFiles) && temp == length(rawFiles))
                    nPreprocessedSubject = ...
                        nPreprocessedSubject + 1;
                end
            end
            if(usejava('Desktop') && ishandle(h))
                waitbar(1)
                close(h)
            end
            
            self.processedList = pList;
            self.nProcessedFiles = nPreprocessedFile;
            self.nProcessedSubjects = nPreprocessedSubject;
            self.nBlock = filesCount;
            self.nSubject = sCount;
            self.blockMap = map;
            self.blockList = list;
            self.interpolateList = iList;
            self.goodList = gList;
            self.badList = bList;
            self.okList = oList;
            self.notRatedList = nList;
            self.alreadyInterpolated = alreadyList;
            % Assign current index
            if( ~ isempty(self.processedList))
                self.current = 1;
            else
                self.current = -1;
            end
            self.saveProject();
        end
        
        function self = setName(self, name)
            % Set the name of this project
            
            % Name must be a valid file name
            if (~isempty(regexp(name, '[/\*:?"<>|]', 'once')))
                popup_msg(['Please enter a valid name not containing'
                    ' any of the following: '...
                    '/ \ * : ? " < > |'], 'Error');
                return;
            end
            self.name = name;
        end
        
        function self = setDataFolder(self, dataFolder)
            % Set the address of the dataFolder
            
            if(~ exist(dataFolder, 'dir') && isunix)
                popup_msg(strcat(['This data folder does not exist: ', ...
                    dataFolder]), 'Error');
                return;
            end
            
            self.dataFolder = self.addSlash(dataFolder);
        end
        
        function self = setResultFolder(self, resultFolder)
            % Set the address of the resultFolder
            
            if(~ exist(resultFolder, 'dir'))
                mkdir(resultFolder);
            end
            
            self.resultFolder = self.addSlash(resultFolder);
        end
        
        function skip = checkExistings(self)
            % If there is already at least one preprocessed file in the
            % resultFolder, ask the user whether to overwrite them or
            % skip them
            
            skip = 1;
            if( self.nProcessedFiles > 0)
                
                if ~ usejava('Desktop')
                    fprintf(['Already existing preprocessing files are skipped ',...
                        'and not preprocessed again. If you wish to preprocess ',...
                        'them again, please remove the files and run the ', ...
                        'preprocessing again.\n']);
                    return;
                end
                
                handle = findobj(allchild(0), 'flat', 'Tag', 'mainGUI');
                main_pos = get(handle,'position');

                if ~isempty(main_pos)
                    screen_size = get( groot, 'Screensize' );
                    choice = MFquestdlg(...
                        [main_pos(3)/2/screen_size(3) main_pos(4)/2/screen_size(4)], ...
                        ['Some files are already processed. Would ',...
                        'you like to overwrite them or skip them ?'], ...
                        'Pre-existing files in the project folder.',...
                        'Over Write', 'Skip','Over Write');
                    switch choice
                        case 'Over Write'
                            skip = 0;
                        case 'Skip'
                            skip = 1;
                    end
                end
            end
        end
        
        function writeToLog(self, sourceAddress, msg)
            % Write special events happenned during preprocessing into the
            % log file.
            % sourceAddress - The block file for which the error is
            % printed
            % msg - The msg to be written in the log file.
            
            logFileAddress = [self.resultFolder 'preprocessing.log'];
            if( exist(logFileAddress, 'file'))
                fileID = fopen(logFileAddress,'a');
            else
                fileID = fopen(logFileAddress,'w');
            end
            subjectFileName = find('\'== sourceAddress);
            if isempty(subjectFileName)
                subjectFileName = find('/'== sourceAddress);
            end
            subjectFileName = subjectFileName(end-1);
            subjectFileName = sourceAddress(subjectFileName+1:end);
            fprintf(fileID, [datestr(datetime('now')) ' The data file ' subjectFileName ...
                ' could not be preprocessed:' msg '\n']);
            fclose(fileID);
        end
        
        function updatemainGUI(self)
            % Update the main gui's data
            
            if ~ usejava('Desktop')
                return
            end
            
            h = findobj(allchild(0), 'flat', 'Tag', 'mainGUI');
            if( isempty(h))
                h = mainGUI;
            end
            handle = guidata(h);
            handle.projectList(self.name) = self;
            guidata(handle.mainGUI, handle);
            mainGUI();
        end
    end
    
    %% Public static methods
    methods(Static)
        function folder = addSlash(folder)
            % Add "\" if not exists already ("/" for windows)
            slash = filesep;
            if( ~ isempty(folder) && ...
                    isempty(regexp( folder ,['\' slash '$'],'match')))
                folder = strcat(folder, slash);
            end
        end
        
        function addAutomagicPaths()
            CGV = ConstantGlobalValues;
            addpath(CGV.AUTOMAGIC_PATH);
            addpath(CGV.SRC_PATH);
            addpath(CGV.PREPROCESSING_PATH);
            addpath(genpath(CGV.GUI_PATH));
        end
        
        function address = makeStateAddress(p_folder)
            % Return the address of the state file
            
            address = strcat(p_folder, ...
                ConstantGlobalValues.stateFile.PROJECT_NAME);
        end
    end
    
    %% Private utility static methods
    methods(Static, Access=private)
        function rate = makeRatingManually(block, qRate)
            % Return qRate if the block is not rated manually. If
            % it is rated manually return 'Manually Rated'. This is used
            % only for visualisation in ratingGUI
            % block - block for which the rate is returned
            % qRate - the rate to be returned
            if block.isManuallyRated
                rate = 'Manually Rated';
            else
                rate = qRate;
            end
        end
        
        function subjects = listSubjects(rootFolder)
            % Return the    list of subjects (dirs) in the folder
            % rootFolder    the folder in which subjects are looked for
            
            subs = dir(rootFolder);
            isub = [subs(:).isdir];
            subjects = {subs(isub).name}';
            subjects(ismember(subjects,{'.','..'})) = [];
        end
        
        function files = dirNotHiddens(folder)
            % Return the list of files in the folder. Exclude the hidden
            % files
            % folder    The files in this filder are listed
            
            files = dir(folder);
            idx = ~startsWith({files.name}, '.');
            files = files(idx);
        end
        
        function modified = isFolderChanged(folder, folder_counts, ...
                nBlocks, ext, allSteps)
            % Return true if the number of files or folders in the
            % folder are changed since the last update.
            % NOTE: This is a very naive way of checking if changes
            % happened. There could be changes in files, but not number of
            % files, which are not detected. Use with cautious.
            slash = filesep;
            modified = false;
            subjects = Project.listSubjects(folder);
            nSubject = length(subjects);
            if ~isempty(startsWith(subjects, 'sub-')) && all(startsWith(subjects, 'sub-'))
                isBIDS = 1;
            else
                isBIDS = 0;
            end
            
            if( ~ isempty(folder_counts) )
                if( nSubject ~= folder_counts )
                    modified = true;
                    return;
                end
            end
            
            nBlock = 0;
            for i = 1:nSubject
                subject = subjects{i};
                if isBIDS
                    sessOrEEG = Project.listSubjects([folder subject]);
                    if ~isempty(startsWith(sessOrEEG, 'ses-')) && all(startsWith(sessOrEEG, 'ses-'))
                        for sesIdx = 1:length(sessOrEEG)
                            sessFile = sessOrEEG{sesIdx};
                            eegFold = [folder subject slash sessFile slash 'eeg' slash];
                            if exist(eegFold, 'dir')
                                files = dir([eegFold ,'*' ,ext]);
                                nBlock = nBlock + length(files);
                            end
                        end
                    elseif ~isempty(startsWith(sessOrEEG, 'ses-')) && any(startsWith(sessOrEEG, 'eeg'))
                        eegFold = [folder subject slash 'eeg' slash];
                        if exist(eegFold, 'dir')
                            files = dir([eegFold ,'*' ,ext]);
                            nBlock = nBlock + length(files);
                        end
                    else
                        files = dir([folder, subject ,'/*' ,ext]);
                        nBlock = nBlock + length(files);
                    end
                else
                    files = dir([folder, subject ,'/*' ,ext]);
                    nBlock = nBlock + length(files);
                end
            end
            
            % NOTE: Very risky. The assumption is that for each result
            % file, there is a corresponding reduced file as well.
            if isempty(folder_counts) % Case of results folder
                if allSteps
                    if( nBlock / 3 ~= nBlocks)
                        modified = true;
                    end
                else
                    if( nBlock / 2 ~= nBlocks)
                        modified = true;
                    end
                end
            else
                if(nBlock ~= nBlocks)
                    modified = true;
                end
            end
        end
        
    end
    
    
end

