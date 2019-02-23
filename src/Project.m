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
            addParameter(p,'MARAParams', defs.MARAParams, @isstruct);
            addParameter(p,'ICLabelParams', defs.ICLabelParams, @isstruct);
            addParameter(p,'InterpolationParams', defs.InterpolationParams, @isstruct);
            addParameter(p,'EOGRegressionParams', defs.EOGRegressionParams, @isstruct);
            addParameter(p,'ChannelReductionParams', defs.ChannelReductionParams, @isstruct);
            addParameter(p,'DetrendingParams', defs.DetrendingParams, @isstruct);
            addParameter(p,'Settings', defs.Settings, @isstruct);
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
                block = Block(self, subject, '', '');
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

            fprintf('*******Start preprocessing all dataset*******\n');
            startTime = cputime;
            for i = 1:length(self.blockList)
                uniqueName = self.blockList{i};
                block = self.blockMap(uniqueName);
                block.updateAddresses(self.dataFolder, self.resultFolder);
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
                
                % preprocess the file
                [EEG, automagic] = block.preprocess();

                if( isempty(EEG) || isfield(automagic, 'error_msg'))
                    message = automagic.error_msg;
                    self.writeToLog(block.sourceAddress, message);
                   continue; 
                end
                
                if( self.current == -1)
                    self.current = 1; 
                end
                self.saveProject();
            end
            
            self.updatemainGUI();
            endTime = cputime - startTime;
            fprintf(['*******Pre-processing finished. Total elapsed '...
                'time: ', num2str(endTime),'***************\n'])         
        end
        
        function self = interpolateSelected(self)
            % Interpolate all the channels selected to be interpolated
            if(isempty(self.interpolateList))
                popup_msg('No subjects to interpolate. Please first rate.',...
                    'Error');
                return;
            end

            fprintf('*******Start Interpolation**************\n');
            startTime = cputime;
            intList = self.interpolateList;
            for i = 1:length(intList)
                index = intList(i);
                uniqueName = self.blockList{index};
                block = self.blockMap(uniqueName);
                block.updateAddresses(self.dataFolder, self.resultFolder);

                fprintf(['Processing file ', block.uniqueName ,' ...', '(file ', ...
                    int2str(i), ' out of ', int2str(length(intList)), ')\n']); 
                assert(strcmp(block.rate, self.CGV.RATINGS.Interpolate) == 1);

                block.interpolate();
                
                self.alreadyInterpolated = [self.alreadyInterpolated index];
                self.saveProject();
            end
            endTime = cputime - startTime;
            self.updatemainGUI();
            fprintf(['Interpolation finished. Total elapsed time: ', ...
                num2str(endTime), '\n'])
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
                            block = Block(self, subject, fileName, filePath);
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
                    popup_msg(['New preprocessed results have been added'...
                        ' to the project folder.'], 'More results');
                else
                    popup_msg(['New preprocessed results have been added'...
                        'to the project folder.'], 'More results');
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
        
        function applyQualityRatings(self, cutoffs, applyToManuallyRated)
            % Modify all the blocks to have the new ratings given by this
            % cutoffs. If applyToManuallyRated, then apply to every single
            % block. Otherwise, don't apply on the blocks for which the
            % rating has been manually selected in the ratingGUI.
            % cutoffs - The cutoffs for which the quality ratings are
            % returned
            % applyToManuallyRated - boolean indicating whether to apply on
            % all blocks or only those that are not manually rated.
            
            files = self.processedList;
            blocks = self.blockMap;
            for i = 1:length(files)
                file = files{i};
                block = blocks(file);
                newRate = rateQuality(block.getCurrentQualityScore(), self.CGV, cutoffs);
                if (applyToManuallyRated || ~ block.isManuallyRated)
                    block.setRatingInfoAndUpdate(struct('rate', newRate{:}));
                    block.saveRatingsToFile();
                end
            end
            self.qualityCutoffs = cutoffs;
        end
        
        function self = updateAddressesFormStateFile(self, ...
                pFolder, dataFolder)
            % This method must be called only when this project is a new
            % project loaded from a state file. The loaded project
            % may have not been created from this operating system, thus addresses
            % to the folders (which can be on the server as well) could be 
            % different on this system, and they must be updated.
            % pFolder - the new address of the resultFolder
            % dataFolder - the new address of the dataFolder
            
            self = self.setDataFolder(dataFolder);
            self = self.setResultFolder(pFolder);
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
        
        function exportToBIDS(self, folder, makeRaw, makeDerivatives)
            if ~ (makeDerivatives || makeRaw)
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

            fileNames = self.blockMap.keys;
            for i = 1:length(fileNames)
                if(usejava('Desktop') && ishandle(h))
                    waitbar((i-1) / length(self.processedList), h)
                end
                
                fileName = fileNames{i};
                block = self.blockMap(fileName);
                relativeAddress = extractBetween(block.sourceAddress, ...
                    block.subject.name, [block.fileName block.fileExtension]);
                isBIDS = (length(relativeAddress{1}) > 2);
                
                if length(block.subject.name) > 4 && strcmp(block.subject.name(1:4), 'sub-')
                    subjectName = block.subject.name;
                else
                    subjectName = ['sub-' block.subject.name];
                end
                
                der_fol = [folder 'derivatives' slash];
                raw_fol = [folder 'raw' slash];
                automagic_fol = [der_fol 'automagic-pipeline' slash];
                code_fol = [folder 'code' slash];
                newResSubAdd = [automagic_fol subjectName relativeAddress{1}];
                newRawSubAdd = [raw_fol subjectName relativeAddress{1}];
                
                if ~ isBIDS
                    newResSubAdd = strcat(newResSubAdd, 'eeg', slash);
                    newRawSubAdd = strcat(newRawSubAdd, 'eeg', slash);
                end
                
                if ~ exist(newResSubAdd, 'dir') && makeDerivatives
                    mkdir(newResSubAdd);
                end
                if ~ exist(newRawSubAdd, 'dir') && makeRaw
                    mkdir(newRawSubAdd);
                end
                
                newResFile = [newResSubAdd fileName '_eeg.mat'];
                newJSONFile = [newResSubAdd fileName '_automagic_eeg.json'];
                newlogFile = [newResSubAdd fileName '_log.txt'];
                newRawFile = [newRawSubAdd fileName]; %#ok<NASGU>
                
                if makeRaw
                    EEG = block.loadEEGFromFile(); %#ok<NASGU>
                    [~, ~] = evalc('pop_writebva(EEG, newRawFile)');
                end
                
                if exist(block.resultAddress, 'file') && makeDerivatives
                    % Result file
                    copyfile(block.resultAddress, newResFile);
                    
                    % Automagic field
                    preprocessed = matfile(block.resultAddress,'Writable',true);
                    autStruct = preprocessed.automagic;
                    if ~ strcmp('Others', autStruct.EEGSystem.params.name)
                        bidsStruct.CapManufacturer = autStruct.EEGSystem.params.name;
                    end
                    bidsStruct.EEGChannelCount = autStruct.EEGChannelCount;
                    bidsStruct.EOGChannelCount = length(autStruct.channelReduction.usedEOGChannels);
                    bidsStruct.PowerLineFrequency = autStruct.params.EEGSystem.powerLineFreq;
                    bidsStruct.SamplingFrequency = autStruct.SamplingFrequency;
                    bidsStruct.RecordingDuration = autStruct.RecordingDuration;
                    bidsStruct.RemoveDCOffset = 'Yes';
                    bidsStruct.EEGReference = autStruct.EEGReference;
                    bidsStruct.ExcludedChannels = autStruct.channelReduction.excludedChannels;
                    bidsStruct.EEGChannels = autStruct.channelReduction.usedEEGChannels;
                    bidsStruct.EOGChannels = autStruct.channelReduction.usedEOGChannels;
                    bidsStruct.PreprocessingSoftware.Name = ['Automagic ' self.CGV.VERSION];
                    bidsStruct.PreprocessingSoftware.ToolboxReference = 'Pedroni, Andreas & Bahreini, Amirreza & Langer, Nicolas. (2018). AUTOMAGIC: Standardized Preprocessing of Big EEG Data. 10.1101/460469.';
                    bidsStruct.BadChannelInterpolation.Method = autStruct.params.InterpolationParams.method;
                    bidsStruct.BadChannelInterpolation.Performed = 'No';
                    bidsStruct.BadChannelInterpolation.BadChannels = autStruct.tobeInterpolated;
                    if autStruct.isInterpolated
                        bidsStruct.BadChannelInterpolation.Performed = 'Yes';
                        bidsStruct.BadChannelInterpolation.InterpolatedBadChannels = autStruct.finalBadChans;
                    end
                    
                    bidsStruct.BadChannelIdentification = struct;
                    if ~isempty(autStruct.params.PrepParams)
                        bidsStruct.BadChannelIdentification.PREP.IdentifcationMethod= 'PREP pipeline';
                        bidsStruct.BadChannelIdentification.PREP.ToolboxReference = 'Bigdely-Shamlo N, Mullen T, Kothe C, Su K-M and Robbins KA (2015)';
                        bidsStruct.BadChannelIdentification.PREP.ToolboxVersion = '0.55.3 Released 10/19/2017';
                        bidsStruct.BadChannelIdentification.PREP.BadChannels = autStruct.prep.badChans;
                        bidsStruct.BadChannelIdentification.PREP.BadChannelCriteria.ExtremeAmplitudes.RobustDeviationThreshold = autStruct.prep.params.reference.robustDeviationThreshold;
                        bidsStruct.BadChannelIdentification.PREP.BadChannelCriteria.LackOfCorrelation.correlationWindowSeconds = autStruct.prep.params.reference.correlationWindowSeconds;
                        bidsStruct.BadChannelIdentification.PREP.BadChannelCriteria.LackOfCorrelation.correlationThreshold = autStruct.prep.params.reference.correlationThreshold;
                        bidsStruct.BadChannelIdentification.PREP.BadChannelCriteria.LackOfPredictability.ransacSampleSize = autStruct.prep.params.reference.ransacSampleSize;
                        bidsStruct.BadChannelIdentification.PREP.BadChannelCriteria.LackOfPredictability.ransacChannelFraction = autStruct.prep.params.reference.ransacChannelFraction;
                        bidsStruct.BadChannelIdentification.PREP.BadChannelCriteria.LackOfPredictability.ransacUnbrokenTime = autStruct.prep.params.reference.ransacUnbrokenTime;
                        bidsStruct.BadChannelIdentification.PREP.BadChannelCriteria.LackOfPredictability.ransacWindowSeconds = autStruct.prep.params.reference.ransacWindowSeconds;
                        bidsStruct.BadChannelIdentification.PREP.BadChannelCriteria.LackOfPredictability.ransacCorrelationThreshold = autStruct.prep.params.reference.ransacCorrelationThreshold;
                        bidsStruct.BadChannelIdentification.PREP.BadChannelCriteria.HighFrequencyNoise.highFrequencyNoiseThreshold = autStruct.prep.params.reference.highFrequencyNoiseThreshold;
                        
                    end
                    
                    if ~isempty(autStruct.params.CRDParams)
                        bidsStruct.BadChannelIdentification.CRD.IdentifcationMethod= 'clean_rawdata()';
                        bidsStruct.BadChannelIdentification.CRD.ToolboxReference = 'Christian Kothe http://sccn.ucsd.edu/wiki/Plugin_list_process';
                        bidsStruct.BadChannelIdentification.CRD.ToolboxVersion = '0.34';
                        bidsStruct.BadChannelIdentification.CRD.BadChannels = autStruct.crd.badChans;
                        if isfield(autStruct.crd.params, 'FlatlineCriterion') && ...
                         ~ strcmp(pars.FlatlineCriterion , 'off') 
                            flatLine = autStruct.crd.params.FlatlineCriterion;
                            bidsStruct.BadChannelIdentification.CRD.BadChannelCriteria.FlatChannels.Used = 'Yes';
                            bidsStruct.BadChannelIdentification.CRD.BadChannelCriteria.FlatChannels.FlatLine = flatLine;
                        elseif isfield(autStruct.crd.params, 'FlatlineCriterion') && ...
                                strcmp(pars.FlatlineCriterion , 'off') 
                            bidsStruct.BadChannelIdentification.CRD.BadChannelCriteria.FlatChannels.Used = 'No';
                        else
                            flatLine = 5; % the default is HARDCODED
                            bidsStruct.BadChannelIdentification.CRD.BadChannelCriteria.FlatChannels.Used = 'Yes';
                            bidsStruct.BadChannelIdentification.CRD.BadChannelCriteria.FlatChannels.FlatLine = flatLine;
                        end
                        
                        if ~ strcmp(autStruct.crd.params.LineNoiseCriterion, 'off')
                            bidsStruct.BadChannelIdentification.CRD.BadChannelCriteria.ExceedingNoise.Used = 'Yes';
                            bidsStruct.BadChannelIdentification.CRD.BadChannelCriteria.ExceedingNoise.Criterion = flatLine;
                        else
                            bidsStruct.BadChannelIdentification.CRD.BadChannelCriteria.ExceedingNoise.Used = 'No';
                        end
                        
                        if ~ strcmp(autStruct.crd.params.ChannelCriterion, 'off')
                            if isfield(autStruct.crd.params, 'ChannelCriterionMaxBadTime')
                                MaxBrokenTime = autStruct.crd.params.ChannelCriterionMaxBadTime;
                            else
                                MaxBrokenTime = 0.4; % the default is HARDCODED
                            end

                            bidsStruct.BadChannelIdentification.CRD.BadChannelCriteria.LackOfPredictability.Used = 'Yes';
                            bidsStruct.BadChannelIdentification.CRD.BadChannelCriteria.LackOfPredictability.MaxBrokenTime = MaxBrokenTime;
                            bidsStruct.BadChannelIdentification.CRD.BadChannelCriteria.LackOfPredictability.ChannelCriterion = autStruct.crd.params.ChannelCriterion;
                        else
                            bidsStruct.BadChannelIdentification.CRD.BadChannelCriteria.LackOfPredictability.Used = 'No';
                        end
                    end
                    
                    if ~isempty(autStruct.params.HighvarParams)
                        bidsStruct.BadChannelIdentification.HighVar.IdentifcationMethod= 'High variance rejection';
                        bidsStruct.BadChannelIdentification.HighVar.ToolboxReference = '';
                        bidsStruct.BadChannelIdentification.HighVar.ToolboxVersion = '';
                        bidsStruct.BadChannelIdentification.HighVar.BadChannels = autStruct.highVarianceRejection.badChans;
                        bidsStruct.BadChannelIdentification.HighVar.BadChannelCriteria.sd = autStruct.highVarianceRejection.sd;
                    end
                    
                    if ~isempty(autStruct.params.FilterParams)
                        if ~isempty(autStruct.params.FilterParams.high)
                            bidsStruct.SoftwareFilters.Highpass.FilterType = 'highpass fir using pop_eegfiltnew()';
                            bidsStruct.SoftwareFilters.Highpass.HighCutoff = autStruct.filtering.highpass.freq;
                            bidsStruct.SoftwareFilters.Highpass.HighCutoffDefinition = 'half-amplitude (-6dB)';
                            bidsStruct.SoftwareFilters.Highpass.FilterOrder = autStruct.filtering.highpass.order;
                            bidsStruct.SoftwareFilters.Highpass.TransitionBandwidth = autStruct.filtering.highpass.transitionBandWidth;
                        end
                        
                        if ~isempty(autStruct.params.FilterParams.low)
                            bidsStruct.SoftwareFilters.Lowpass.FilterType = 'lowpass fir using pop_eegfiltnew()';
                            bidsStruct.SoftwareFilters.Lowpass.LowCutoff = autStruct.filtering.lowpass.freq;
                            bidsStruct.SoftwareFilters.Lowpass.LowCutoffDefinition = 'half-amplitude (-6dB)';
                            bidsStruct.SoftwareFilters.Lowpass.FilterOrder = autStruct.filtering.lowpass.order;
                            bidsStruct.SoftwareFilters.Lowpass.TransitionBandwidth = autStruct.filtering.lowpass.transitionBandWidth;
                        end
                        
                        if ~isempty(autStruct.params.FilterParams.notch)
                            bidsStruct.SoftwareFilters.Notch.FilterType = 'notch fir using pop_eegfiltnew()';
                            bidsStruct.SoftwareFilters.Notch.NotchCutoff = autStruct.filtering.notch.freq;
                            bidsStruct.SoftwareFilters.Notch.NotchCutoffDefinition = 'half-amplitude (-6dB)';
                            bidsStruct.SoftwareFilters.Notch.FilterOrder = autStruct.filtering.notch.order;
                            bidsStruct.SoftwareFilters.Notch.TransitionBandwidth = autStruct.filtering.notch.transitionBandWidth;
                        end
                    end
                    if ~isempty(autStruct.params.EOGRegressionParams)
                        bidsStruct.ArtifactCorrection.EOGRegression.Used = 'Yes';
                        bidsStruct.ArtifactCorrection.EOGRegression.ToolboxReference = 'Parra, Lucas C., Clay D. Spence, Adam D. Gerson, and Paul Sajda. 2005. “Recipes for the Linear Analysis of EEG.” NeuroImage 28 (2): 326–41';
                    end
                    
                    if ~isempty(autStruct.params.MARAParams)
                        bidsStruct.ArtifactCorrection.MARA.RemovedBadICs = autStruct.mara.ICARejected;
                        bidsStruct.ArtifactCorrection.MARA.PosteriorArtefactProbability = autStruct.mara.postArtefactProb;
                        bidsStruct.ArtifactCorrection.MARA.RetainedVariance = autStruct.mara.retainedVariance;
                        bidsStruct.ArtifactCorrection.MARA.ToolboxReference = 'Winkler, Irene, Stefan Haufe, and Michael Tangermann. 2011. “Automatic Classification of Artifactual ICA-Components for Artifact Removal in EEG Signals.” Behavioral and Brain Functions: BBF 7 (August): 30';
                    end
                    
                    if ~isempty(autStruct.params.RPCAParams)
                        bidsStruct.ArtifactCorrection.RPCA.RPCALambda = autStruct.rpca.lambda;
                        bidsStruct.ArtifactCorrection.RPCA.Tolerance = autStruct.rpca.tol;
                        bidsStruct.ArtifactCorrection.RPCA.MaxIterations = autStruct.rpca.maxIter;
                        bidsStruct.ArtifactCorrection.RPCA.ToolboxReference = 'Lin, Zhouchen, Minming Chen, and Yi Ma. 2010. “The Augmented Lagrange Multiplier Method for Exact Recovery of Corrupted Low-Rank Matrices.” arXiv [math.OC]. arXiv. http://arxiv.org/abs/1009.5055';
                    end
                    bidsStruct.QualityRating.QualityThresholds.OverallHighAmplitudeThreshold = autStruct.qualityThresholds.overallThresh;
                    bidsStruct.QualityRating.QualityThresholds.TimepointsHighVarianceThreshold = autStruct.qualityThresholds.timeThresh;
                    bidsStruct.QualityRating.QualityThresholds.ChannelsHighVarianceThreshold = autStruct.qualityThresholds.chanThresh;
                    bidsStruct.QualityRating.QualityScores.OverallHighAmplitude = autStruct.qualityScores.OHA;
                    bidsStruct.QualityRating.QualityScores.TimepointsHighVariance = autStruct.qualityScores.THV;
                    bidsStruct.QualityRating.QualityScores.ChannelsHighVariance = autStruct.qualityScores.CHV;
                    bidsStruct.QualityRating.QualityScores.MeanAbsoluteVoltage = autStruct.qualityScores.MAV;
                    bidsStruct.QualityRating.QualityScores.RatioOfBadChannels = autStruct.qualityScores.RBC;
                    bidsStruct.QualityRating.SelectedQualityScore.OverallHighAmplitude = autStruct.selectedQualityScore.OHA;
                    bidsStruct.QualityRating.SelectedQualityScore.TimepointsHighVariance = autStruct.selectedQualityScore.THV;
                    bidsStruct.QualityRating.SelectedQualityScore.ChannelsHighVariance = autStruct.selectedQualityScore.CHV;
                    bidsStruct.QualityRating.SelectedQualityScore.MeanAbsoluteVoltage = autStruct.selectedQualityScore.MAV;
                    bidsStruct.QualityRating.SelectedQualityScore.RatioOfBadChannels = autStruct.selectedQualityScore.RBC;
                    bidsStruct.QualityRating.CurrentRating = autStruct.rate;
                    bidsStruct.QualityRating.ManuallyRated = autStruct.isManuallyRated;
                    
                    jsonwrite(newJSONFile, bidsStruct, struct('indent','  '));
                    
                    % log file
                    logFile = [block.subject.resultFolder slash block.fileName '_log.txt'];
                     copyfile(logFile, newlogFile);
                    
                    % JPEG files
                    images = dir([block.subject.resultFolder slash block.fileName '_orig.jpg']);
                    images = [images dir([block.subject.resultFolder slash block.fileName '.jpg'])];
                    for imIdx = 1:length(images)
                        image = images(imIdx);
                        imageAddress = [image.folder slash image.name];
                        imageName = image.name;
                        newImageName = strrep(imageName, '.jpg', '_photo.jpg');
                        newImageAdd = [newResSubAdd newImageName];
                        copyfile(imageAddress, newImageAdd);
                    end
                end
            end
            paramsJSON = [der_fol 'automagic_params.json'];
            jsonwrite(paramsJSON, self.params, struct('indent','  '));
         
            
            params = self.params; 
            vParams = self.vParams;
            if ~ exist(code_fol, 'dir')
                    mkdir(code_fol);
            end
            save([code_fol 'params.mat'], 'params');
            save([code_fol 'vParams.mat'], 'vParams');
            reproduceCode = getCodeHistoryStruct();
            fid = fopen([code_fol 'automagic-preprocess.m'], 'wt');
            fprintf(fid, reproduceCode.create, self.name, self.dataFolder, self.name, self.fileExtension);
            fprintf(fid, reproduceCode.interpolate);
            fclose(fid);
            
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
                        block = Block(self, subject, fileName, filePath);
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
            fprintf(fileID, [datestr(datetime('now')) ' The data file ' sourceAddress ...
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

