classdef Block < handle
    %Block is a class representing each raw file and its corresponding
    %preprocessed file in dataFolder and resultFolder respectively.
    %   A Block contains the entire relevant information of each raw file
    %   and its corresponding preprocessed file.
    %   This information include a uniqueName for each block, the name of
    %   the rawFile, its extension, its corresponding Subject, the prefix
    %   of the preprocessed file, parameters of preprocessing and many
    %   more.
    %
    %   Block is a subclass of handle, meaning it's a refrence to an
    %   object. Use accordingly.
    %
    %Block Methods:
    %   Block - To create a project following arguments must be given:
    %   myBlock = Block(project, subject, fileName)
    %   where project is the project to which this block belongs, subject 
    %   is an instance of class Subject which specifies the Subject to 
    %   which this block belongs to and fileName is the name of the
    %   rawFile corresponding to this block.
    %
    %   preprocess - Preprocess this block and updates structures
    %   accordingly
    %
    %   interpolate - Interpolate this block (if rated as to be 
    %   interpolated) and update structures accordingly
    %
    %   getCurrentQualityScore - Return the current quality score pointed
    %   by self.project.qualityScoreIdx
    %
    %   updateRatingInfoFromFile - Check if any corresponding
    %   preprocessed file exists, if it's the case import the rating data
    %   to this block, initialise otherwise.
    %
    %   potentialResultAddress - Check in the result folder for a
    %   corresponding preprocessed file with any prefix that respects the
    %   standard pattern (See prefix).
    %   
    %   updateAddresses - The method is to be called to update addresses
    %   in case the project is loaded from another operating system and may
    %   have a different path to the dataFolder or resultFolder. This can
    %   happen either because the data is on a server and the path to it is
    %   different on different systems, or simply if the project is loaded
    %   from a windows to an iOS or vice versa. The best practice is to call
    %   this method before accessing a block to make sure it's synchronised
    %   with its project.
    %
    %   setRatingInfoAndUpdate - This method must be called to set and
    %   update the new rating information of this block (For example when 
    %   user changes the rating within the ratingGui).
    %
    %   saveRatingsToFile - Save all rating information to the
    %   corresponding preprocessed file
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

    %% Properties
    properties
        
        % Index of this block in the block list of the project.
        index 
        
        % The address of the corresponding raw file
        sourceAddress
        
        % The address of the corresponding preprocessed file. It has the
        % form /root/project/subject/prefix_uniqueName.mat (ie. np_subject1_001).
        resultAddress
        
        resultFolder
        
        % The address of the corresponding reduced file. The reduced file is
        % a downsampled file of the preprocessed file. Its use is only to be
        % plotted on the ratingGui. It is downsampled to speed up the
        % plotting in ratingGui
        reducedAddress
        
        qualityScores
    end

    properties(SetAccess=private)
        
        % The instance of the roject to which this block belongs
        project
        
        % Instance of the Subject. The corresponding subject that contains
        % this block.
        subject
        
        % uniqueName of this block. It has the form
        % subjectName_rawFileName (ie. subject1_001).
        uniqueName
        
        % Name of the raw file of this block
        fileName
        
        % File extension of the raw file (ie. .raw).
        fileExtension
        
        % Downsampling rate of the project. This is used to downsample and
        % obtain the reduced file.
        dsRate
        
        sRate 
        
        % Parameters of the preprocessing. To learn more please see
        % preprocessing/preprocess.m
        params

        % Prefix of the corresponding preprocessed file. Prefix has the
        % pattern '^[gobni]i?p': It could be any of the following:
        %   np - preprocessed file not rated
        %   gp - preprocessed file rated as Good
        %   op - preprocessed file rated as OK
        %   bp - preprocessed file rated as Bad
        %   ip - preprocessed file rated as Interpolate
        %   nip - preprocessed file not rated but interpoalted at least
        %   once
        %   gip - preprocessed file rated as Good and interpolated at least
        %   once
        %   oip - preprocessed file rated as OK and interpolated at least
        %   once
        %   bip - preprocessed file rated as Bad and interpolated at least
        %   once
        %   iip - preprocessed file rated as Interpolated and interpolated 
        %   at least once
        prefix
        
        % Number of times commit button has been applied on this block. The
        % initial number is -1. Everytime the block is preprocessed then
        % this number is set to the initial -1 and commited immediately and
        % thus it becomes 0. After preprocessing everytime the commit
        % button is clicked then it increments by 1.
        commitedNb
        
        % List of the channels chosen by the user in the gui to be 
        % interpolated.
        tobeInterpolated
        
        % rate of this block: Good, Bad, OK, Interpolate, Not Rated
        rate
        
        % List of the channels that have been interpolated by the manual
        % inspection in interpolateSelected. Note that this is not a set,
        % If a channel is interpolated n times, there will be n instances 
        % of this channel in the list.  
        finalBadChans
        
        % List of the channels that have been selected as bad channels during
        % the preprocessing. Note that they are not necessarily interpolated.
        autoBadChans
        
        % is true if the block has been already interpolated at least once.
        isInterpolated
        
        isManuallyRated

        CGV
        
        vParams
    end
    
    properties(Dependent)
        
        % The address of the plots obtained during the preprocessing
        imageAddress
        
        logAddress
    end
    
    %% Constructor
    methods   
        function self = Block(project, subject, fileName, address, CGV)
  
            self.CGV = CGV;
            
            self.project = project;
            self.subject = subject;
            self.fileName = fileName;
            
            self.fileExtension = project.fileExtension;
            self.dsRate = project.dsRate;
            self.params = project.params;
            self.sRate = project.sRate;
            
            self.uniqueName = self.extractUniqueName(address, subject, fileName);
            self.sourceAddress = address;
            self = self.updateRatingInfoFromFile();
            self.vParams = project.vParams;
        end
    end
    
    %% Public Methods
    methods
        
        function self = updateRatingInfoFromFile(self)
            % Check if any corresponding preprocessed file exists, if it's 
            % the case and that file has been already rated import the 
            % rating data to this block, initialise otherwise.
            
            if( exist(self.potentialResultAddress(), 'file'))
                preprocessed = matfile(self.potentialResultAddress());
                automagic = preprocessed.automagic;
                
                autParams = automagic.params;
                autFields = fieldnames(autParams);
                idx = ismember(autFields, fieldnames(self.params));
                autParams = struct2cell(autParams);
                autParams = cell2struct(autParams(idx), autFields(idx));
                if( ~ isequal(autParams, self.params))
                    msg = ['Preprocessing parameters of the ',...
                        self.fileName, ' does not correspond to ', ... 
                        'the preprocessing parameters of this ', ...
                        'project. This file can not be merged.'];
                    popup_msg(msg, 'Error');
                    ME = MException('Automagic:Block:parameterMismatch', msg);
                    throw(ME);
                end 
            end
            % Find the preprocessed file if any (empty char if there is no
            % file).
            extractedPrefix = self.extractPrefix(...
                self.potentialResultAddress());
            
            % If the prefix indicates that the block has been already rated
            if(self.hasInformation(extractedPrefix) && ...
                    exist(self.potentialResultAddress(), 'file'))
                preprocessed = matfile(self.potentialResultAddress());
                automagic = preprocessed.automagic;
                self.rate = automagic.rate;
                self.tobeInterpolated = automagic.tobeInterpolated;
                self.isInterpolated = automagic.isInterpolated;
                self.autoBadChans = automagic.autoBadChans;
                self.finalBadChans = automagic.finalBadChans;
                self.qualityScores = automagic.qualityScores;
                self.isManuallyRated = automagic.isManuallyRated;
                self.commitedNb = automagic.commitedNb;
                
                if isempty(self.project.qualityScoreIdx)
                    qScore = self.qualityScores;
                    qScoreIdx.OHA = arrayfun(@(x) ceil(length(x.OHA)/2), qScore);
                    qScoreIdx.THV = arrayfun(@(x) ceil(length(x.THV)/2), qScore);
                    qScoreIdx.CHV = arrayfun(@(x) ceil(length(x.CHV)/2), qScore);
                    qScoreIdx.MAV = arrayfun(@(x) ceil(length(x.MAV)/2), qScore);
                    qScoreIdx.RBC = arrayfun(@(x) ceil(length(x.RBC)/2), qScore);
                    self.project.qualityScoreIdx = qScoreIdx; 
                end
                if automagic.version ~= self.CGV.VERSION
                    warning(['Version of Automagic is not the same as the' ...
                        ' one which produced this result file.'])
                end
            else
                self.rate = ConstantGlobalValues.RATINGS.NotRated;
                self.tobeInterpolated = [];
                self.autoBadChans = [];
                self.finalBadChans = [];
                self.isInterpolated = false;
                self.qualityScores = nan;
                self.isManuallyRated = 0;
                self.commitedNb = -1;
            end
            
            % Build prefix and adress based on ratings
            self = self.updateResultAddress();
        end
        
        function resultAddress = potentialResultAddress(self)
            % Check in the result folder for a corresponding preprocessed 
            % file with any prefix that respects the standard pattern (See prefix).
            slash = filesep;
            if ispc
                splits = strsplit(self.sourceAddress, [slash slash self.subject.name slash]);
            else
                splits = strsplit(self.sourceAddress, [slash self.subject.name slash]);
            end
            relAdd = splits{2};
            
            if ~isempty(relAdd)
                splits = strsplit(relAdd, [self.fileName, self.fileExtension]);
                relAdd = splits{1};
            end
            
            pattern = '^[gobni]+i?p_';
            fileData = dir(strcat(self.subject.resultFolder, slash, relAdd));                                        
            fileNames = {fileData.name};  
            idx = regexp(fileNames, strcat(pattern, self.fileName, '.mat')); 
            inFiles = fileNames(~cellfun(@isempty,idx));
            assert(length(inFiles) <= 1);
            if(~ isempty(inFiles))
                resultAddress = strcat(self.subject.resultFolder, slash, relAdd, ...
                    inFiles{1});
            else
                resultAddress = '';
            end
        end
       
        function self = updateAddresses(self, newDataPath, ...
                newProjectPath, varargin)
            % The method is to be called to update addresses in case the 
            % project is loaded from another operating system and may have 
            % a different path to the dataFolder or resultFolder. This can
            % happen either because the data is on a server and the path 
            % to it is different on different systems, or simply if the 
            % project is loaded from a windows to a iOS or vice versa. 
            % newDataPath - Set the data path to this path
            % newProjectPath - Set the project path to this path
            % varargin - It could contain the path to the channel location
            % if the previous file does not exist anymore
            
            slash = filesep;
            self.subject = self.subject.updateAddresses(newDataPath, ...
                newProjectPath);
            
            if ispc
                splits = strsplit(self.sourceAddress, [slash slash self.subject.name slash]);
            else
                splits = strsplit(self.sourceAddress, [slash self.subject.name slash]);
            end
            relAdd = splits{2};
            self.sourceAddress = [self.subject.dataFolder slash relAdd];
            
            if ~isempty(relAdd)
                relAdd = strsplit(relAdd, [self.fileName, self.fileExtension]);
                relAdd = relAdd{1};
            end
            self.resultFolder = [self.subject.dataFolder slash relAdd];
            
            if ~exist(self.resultFolder, 'dir')
                mkdir(self.resultFolder);
            end
            
            if ~ isempty(varargin) && ~ isempty(varargin{1})
                self.params.EEGSystem.locFile = varargin{1};
            end
            self = self.updateResultAddress();
        end
        
        function self = setRatingInfoAndUpdate(self, updates)
            % Set the new rating information
            % updates - A structure with following optional fields: rate,
            % qualityScores, tobeInterpolated, finalBadChans and 
            % isInterpolated. If a field is not given, the previous value
            % is kept. 
            
            if isfield(updates, 'qualityScores')
                self.qualityScores  = updates.qualityScores;
            end
            
            if isfield(updates, 'rate')
                self.rate = updates.rate;
%                 thisRate = rateQuality(self.getCurrentQualityScore(), self.CGV, self.project.qualityCutoffs);
%                 self.isManuallyRated = ~ strcmp(updates.rate, thisRate{:});
                if ~ strcmp(self.rate, self.CGV.RATINGS.Interpolate)
                    if ~ isfield(updates, 'tobeInterpolated')
                        % If new rate is not Interpolate and no (empty) list 
                        % of interpolation is given then make the list empty
                        self.tobeInterpolated = [];
                    end
                end
                
            end
            
            if isfield(updates, 'isManuallyRated')
                thisRate = rateQuality(self.getCurrentQualityScore(), self.CGV, self.project.qualityCutoffs);
                if updates.isManuallyRated && ~ strcmp(updates.rate, thisRate{:})
                    self.isManuallyRated = 1;
                elseif ~ updates.isManuallyRated
                    self.isManuallyRated = 0;
                end
            end
            
            if isfield(updates, 'tobeInterpolated')
                self.tobeInterpolated = updates.tobeInterpolated;
                if ~ isempty(updates.tobeInterpolated)
                    self.rate = self.CGV.RATINGS.Interpolate;
                else
                    % This can happen when user removes the interpolation
                    % channel while choosing them
                end
            end
            
            if isfield(updates, 'finalBadChans')
                if isempty(updates.finalBadChans)
                    self.finalBadChans = updates.finalBadChans;
                else
                    self.finalBadChans = ...
                        [self.finalBadChans, updates.finalBadChans]; 
                end
            end
            
            if isfield(updates, 'isInterpolated')
                self.isInterpolated = updates.isInterpolated;
            end
            
            if isfield(updates, 'commit') && updates.commit == 1
               % Update the result address and rename if necessary
               self.commitedNb = self.commitedNb + 1;
               self = self.updatePrefix();
               self = self.updateResultAddress();
            end
            
            % Update the rating list structure of the project
            self.project.updateRatingLists(self);
        end
        
        function [EEG, automagic] = preprocess(self)
            % Preprocess the block and update the structures
          
            % Load the file
            data = self.loadEEGFromFile();

            if(any(strcmp({self.CGV.EXTENSIONS.fif}, self.fileExtension))) 
                self.params.ORIGINAL_FILE = self.sourceAddress;
            end
            
            if ~isempty(self.params.Settings) && ...
                    isfield(self.params.Settings, 'trackAllSteps') && ...
                    self.params.Settings.trackAllSteps
                PrepCsts = self.CGV.PreprocessingCsts;
                pathToSteps = strcat(self.resultFolder, ...
                    PrepCsts.Settings.pathToSteps, '_', ...
                    self.fileName);
                if( exist(pathToSteps, 'file' ))
                    delete(pathToSteps);
                end
                self.params.Settings.pathToSteps = pathToSteps;
            end

            % Preprocess the file
            [EEG, fig1, fig2] = preprocess(data, self.params);

            if(any(strcmp({self.CGV.EXTENSIONS.fif}, self.fileExtension))) 
                self.params = rmfield(self.params, 'ORIGINAL_FILE');
            end
            
            % If there was an error
            if(isempty(EEG))
                return;
            end
            qScore  = calcQuality(EEG, unique(self.finalBadChans), ...
                self.project.qualityThresholds); 
            qScoreIdx.OHA = arrayfun(@(x) ceil(length(x.OHA)/2), qScore);
            qScoreIdx.THV = arrayfun(@(x) ceil(length(x.THV)/2), qScore);
            qScoreIdx.CHV = arrayfun(@(x) ceil(length(x.CHV)/2), qScore);
            qScoreIdx.MAV = arrayfun(@(x) ceil(length(x.MAV)/2), qScore);
            qScoreIdx.RBC = arrayfun(@(x) ceil(length(x.RBC)/2), qScore);
            self.project.qualityScoreIdx = qScoreIdx;
            self.commitedNb = -1;
            self.setRatingInfoAndUpdate(struct('rate', self.CGV.RATINGS.NotRated, ...
                'isManuallyRated', 0, ...
                'tobeInterpolated', EEG.automagic.autoBadChans, ...
                'finalBadChans', [], 'isInterpolated', false, ...
                'qualityScores', qScore, ...
                'commit', 1));
            
            
            automagic = EEG.automagic;
            EEG = rmfield(EEG, 'automagic');
            
            automagic.tobeInterpolated = automagic.autoBadChans;
            automagic.finalBadChans = self.finalBadChans;
            automagic.isInterpolated = self.isInterpolated;
            automagic.version = self.CGV.VERSION;
            automagic.qualityScores = self.qualityScores;
            automagic.qualityThresholds = self.project.qualityThresholds;
            automagic.selectedQualityScore = self.getCurrentQualityScore();
            automagic.rate = self.rate;
            automagic.isManuallyRated = self.isManuallyRated;
            automagic.commitedNb = self.commitedNb;
            
            automagic.EEGChannelCount = size(EEG.data,1);
            automagic.SamplingFrequency = EEG.srate;
            automagic.RecordingDuration = size(EEG.data,2);
            if ~isempty(automagic.channelReduction.newRefChan)
                refChan = automagic.channelReduction.newRefChan.idx;
                automagic.EEGReference = EEG.chanlocs(refChan).labels;
            else
                automagic.EEGReference = [];
            end
            if isfield(EEG.chaninfo, 'filename')
                automagic.ChannelLocationFile = EEG.chaninfo.filename;
            else
                automagic.ChannelLocationFile = [];
            end
            self.saveFiles(EEG, automagic, fig1, fig2);
            self.writeLog(automagic);
        end
        
        function interpolate(self)
            % Interpolate the block and update the structures
            
            preprocessed = matfile(self.resultAddress,'Writable',true);
            EEG = preprocessed.EEG;
            automagic = preprocessed.automagic;
            
            interpolate_chans = self.tobeInterpolated;
            if(isempty(interpolate_chans))
                popup_msg(['The subject is rated to be interpolated but no',...
                    'channels has been chosen.'], 'Error');
                return;
            end
            
            % Put NaN channels to zeros so that interpolation works
            nanchans = find(all(isnan(EEG.data), 2));
            EEG.data(nanchans, :) = 0;

            if isempty(self.params) || ...
                    ~isfield(self.params, 'InterpolationParams') || ...
                    isempty(self.params.InterpolationParams)
                DefPar = self.CGV.DefaultParams;
                InterpolationParams = DefPar.InterpolationParams;
            else
                InterpolationParams = self.params.InterpolationParams;
            end
			
            %save old ica data which gets corrupted in eeg_interp method:
            orig_icasphere=EEG.icasphere;
            orig_icachansind=EEG.icachansind;
            orig_icaweights=EEG.icaweights;
            orig_icawinv=EEG.icawinv;
            
            EEG = eeg_interp(EEG ,interpolate_chans , InterpolationParams.method);
            
			%put the original icadata back into the structure
            EEG.icasphere=orig_icasphere;
            EEG.icachansind=orig_icachansind;
            EEG.icaweights= orig_icaweights;
            EEG.icawinv=orig_icawinv;

            qScore  = calcQuality(EEG, ...
                unique([self.finalBadChans interpolate_chans]), ...
                self.project.qualityThresholds);
            qScoreIdx.OHA = arrayfun(@(x) ceil(length(x.OHA)/2), qScore);
            qScoreIdx.THV = arrayfun(@(x) ceil(length(x.THV)/2), qScore);
            qScoreIdx.CHV = arrayfun(@(x) ceil(length(x.CHV)/2), qScore);
            qScoreIdx.MAV = arrayfun(@(x) ceil(length(x.MAV)/2), qScore);
            qScoreIdx.RBC = arrayfun(@(x) ceil(length(x.RBC)/2), qScore);
            self.project.qualityScoreIdx = qScoreIdx;

            % Put the channels back to NaN if they were not to be interpolated
            % originally
            original_nans = setdiff(nanchans, interpolate_chans);
            EEG.data(original_nans, :) = NaN;

            % Downsample the new file and save it
            PrepCsts = self.CGV.PreprocessingCsts;
            reduced.data = (downsample(EEG.data', self.dsRate))'; %#ok<STRNU>
            save(self.reducedAddress, ...
                PrepCsts ...
                .GeneralCsts.REDUCED_NAME, '-v6');

            % Setting the new information
            self.setRatingInfoAndUpdate(struct('rate', self.CGV.RATINGS.NotRated, ...
                'isManuallyRated', 0, ...
                'tobeInterpolated', [], ...
                'finalBadChans', interpolate_chans, ...
                'isInterpolated', true, ...
                'qualityScores', qScore));
            
            automagic.interpolation.channels = interpolate_chans;
            automagic.interpolation.params = InterpolationParams;
            automagic.qualityScores = self.qualityScores;
            automagic.selectedQualityScore = self.getCurrentQualityScore();
            automagic.rate = self.rate;
            
            preprocessed = matfile(self.resultAddress,'Writable',true);
            preprocessed.EEG = EEG;
            preprocessed.automagic = automagic;
            self.saveRatingsToFile();
            self.writeLog(automagic);
        end
        
        function saveRatingsToFile(self)
            % Save all rating information to the corresponding preprocessed 
            % file
            
            preprocessed = matfile(self.resultAddress,'Writable',true);
            automagic = preprocessed.automagic;
            automagic.tobeInterpolated = self.tobeInterpolated;
            automagic.rate = self.rate;
            automagic.autoBadChans = self.autoBadChans;
            automagic.isInterpolated = self.isInterpolated;
            automagic.isManuallyRated = self.isManuallyRated;
            automagic.qualityScores = self.qualityScores;
            automagic.selectedQualityScore = self.getCurrentQualityScore();
            automagic.commitedNb = self.commitedNb;
            
            % It keeps track of the history of all interpolations.
            automagic.finalBadChans = self.finalBadChans;
            preprocessed.automagic = automagic;
            self.writeLog(automagic);
        end
        
        function writeLog(self, automagic)
            text = getLogTextStruct();
            matVer = ver('MATLAB');
            fileID = fopen([self.imageAddress '_log.txt'],'w');
       
            fprintf(fileID, sprintf(text.info.automagic, self.CGV.VERSION));
            fprintf(fileID, sprintf(text.info.matlab, matVer.Version, ...
                matVer.Release, matVer.Date));
            fprintf(fileID, sprintf(text.info.fileName, self.fileName, ...
                self.subject.name, self.project.name));
            fprintf(fileID, sprintf(text.info.time, datetime));
            fprintf(fileID, '\n');
            fprintf(fileID, '\n');
            fprintf(fileID, '\n');
            
            if isfield(automagic, 'error_msg')
                fprintf(fileID, sprintf(text.error.desc, automagic.error_msg));
                fprintf(fileID, '\n');
                fprintf(fileID, '\n');
                fprintf(fileID, '\n');
            end
            
            
            if(isfield(automagic, 'prep'))
                if strcmp(automagic.prep.performed, 'yes')
                    pars = automagic.prep.params;
                    fprintf(fileID, sprintf(text.prep.desc));
                    fprintf(fileID, sprintf(text.prep.detrend, ...
                        pars.detrend.detrendCutoff, ...
                        pars.detrend.detrendStepSize, ...
                        pars.detrend.detrendType));
                    fprintf(fileID, sprintf(text.prep.lineNoise, ...
                        pars.lineNoise.fPassBand, sprintf('%d ', ...
                        pars.lineNoise.lineFrequencies), ...
                        pars.lineNoise.fScanBandWidth, ...
                        pars.lineNoise.maximumIterations));
                    fprintf(fileID, sprintf(...
                        text.prep.reference.robDevThres, ...
                        pars.reference.robustDeviationThreshold));
                    fprintf(fileID, sprintf(text.prep.reference.corr, ...
                        pars.reference.correlationWindowSeconds, ...
                        pars.reference.correlationThreshold));
                    fprintf(fileID, sprintf(text.prep.reference.ransac, ...
                        pars.reference.ransacSampleSize, ...
                        pars.reference.ransacChannelFraction, ...
                        pars.reference.ransacUnbrokenTime, ...
                        pars.reference.ransacWindowSeconds, ...
                        pars.reference.ransacCorrelationThreshold));
                    fprintf(fileID, sprintf(...
                        text.prep.reference.highFreqNoise, ...
                        pars.reference.highFrequencyNoiseThreshold));
                    fprintf(fileID, sprintf(text.prep.reference.maxIter, ...
                        pars.reference.maxReferenceIterations));
                    fprintf(fileID, '\n');
                end
            end
            
            if(isfield(automagic, 'crd'))
                if strcmp(automagic.crd.performed, 'yes')
                    pars = automagic.crd.params;
                    fprintf(fileID, sprintf(text.clean_rawdata.desc));
                    
                    % First flat-line channels
                    if isfield(pars, 'FlatlineCriterion') && ...
                         ~ strcmp(pars.FlatlineCriterion , 'off') 
                     
                        flatLine = pars.FlatlineCriterion;
                        fprintf(fileID, sprintf(...
                            text.clean_rawdata.flatLine, ...
                            flatLine));
                    else
                        flatLine = 5; % the default is HARDCODED
                        fprintf(fileID, sprintf(...
                            text.clean_rawdata.flatLine, ...
                            flatLine));
                    end
                    
                    % Second (temp) high pass filter
                    if ~ strcmp(pars.Highpass , 'off')
                        if strcmp(pars.BurstCriterion , 'off') 
                            fprintf(fileID, sprintf(...
                                text.clean_rawdata.noASRFilter, ...
                                pars.Highpass));
                        else
                            fprintf(fileID, sprintf(...
                                text.clean_rawdata.ASRFilter, ...
                                pars.Highpass));
                        end
                    end
                    
                    % Thirds and fourth are line noise and ransac
                    if ~ strcmp(pars.LineNoiseCriterion, 'off')
                        fprintf(fileID, sprintf(...
                            text.clean_rawdata.lineNoise, ...
                            pars.LineNoiseCriterion));
                    end
                    
                    if ~ strcmp(pars.ChannelCriterion, 'off')
                        if isfield(pars, 'ChannelCriterionMaxBadTime')
                            MaxBrokenTime = pars.ChannelCriterionMaxBadTime;
                        else
                            MaxBrokenTime = 0.4; % the default is HARDCODED
                        end
                        
                        fprintf(fileID, sprintf(...
                            text.clean_rawdata.ransac, MaxBrokenTime, ...
                            pars.ChannelCriterion));
                    end
                    
                    % Last Busrt and window
                    if ~ strcmp(pars.BurstCriterion, 'off')
                        fprintf(fileID, sprintf(...
                            text.clean_rawdata.burst, ...
                            pars.BurstCriterion));
                    end
                    
                    if ~ strcmp(pars.WindowCriterion, 'off')
                        fprintf(fileID, sprintf(...
                            text.clean_rawdata.window, ...
                            pars.WindowCriterion));
                    end
                    fprintf(fileID, '\n');
                end
            end
            
            if(isfield(automagic, 'filtering'))
                if strcmp(automagic.filtering.performed, 'yes')
                    pars = automagic.filtering;
                    fprintf(fileID, sprintf(text.filtering.desc));
                    if (isfield(pars, 'highpass') && ...
                            strcmp(pars.highpass.performed, 'yes'))
                        fprintf(fileID, sprintf(text.filtering.high, ...
                            pars.highpass.freq, pars.highpass.order, ...
                            pars.highpass.transitionBandWidth));
                    end
                    
                    if (isfield(pars, 'lowpass') && ...
                            strcmp(pars.lowpass.performed, 'yes'))
                        fprintf(fileID, sprintf(text.filtering.low, ...
                            pars.lowpass.freq, pars.lowpass.order, ...
                            pars.lowpass.transitionBandWidth));
                    end
                    
                    if (isfield(pars, 'notch') && ...
                            strcmp(pars.notch.performed, 'yes'))
                        fprintf(fileID, sprintf(text.filtering.notch, ...
                            pars.notch.freq, pars.notch.order, ...
                            pars.notch.transitionBandWidth));
                    end
                    fprintf(fileID, '\n');
                end
            end
            
            fprintf(fileID, sprintf(text.badchans.desc, ...
                length(automagic.autoBadChans)));
            if strcmp(automagic.prep.performed, 'yes')
                fprintf(fileID, sprintf(text.badchans.prep, ...
                    length(automagic.prep.badChans)));
            end
            
            if strcmp(automagic.crd.performed, 'yes')
                fprintf(fileID, sprintf(text.badchans.crd, ...
                    length(automagic.crd.badChans)));
            end
            
            if strcmp(automagic.highVarianceRejection.performed, 'yes')
                fprintf(fileID, sprintf(text.badchans.flatline, ...
                    length(automagic.highVarianceRejection.badChans)));
            end
            fprintf(fileID, '\n');
            
            if(isfield(automagic, 'EOGRegression'))
                if strcmp(automagic.EOGRegression.performed, 'yes')
                    fprintf(fileID, sprintf(text.eog.desc));
                    fprintf(fileID, '\n');
                end
            end
            
            if(isfield(automagic, 'mara'))
                if strcmp(automagic.mara.performed, 'yes')
                    pars = automagic.mara;
                    fprintf(fileID, sprintf(text.mara.desc));
                    
                    if strcmp(pars.highpass.performed, 'yes')
                        fprintf(fileID, sprintf(text.mara.filtering, ...
                            pars.highpass.freq, pars.highpass.order, ...
                            pars.highpass.transitionBandWidth));
                    end
                    
                    fprintf(fileID, sprintf(text.mara.reject, ...
                        length(pars.ICARejected), pars.retainedVariance));
                    fprintf(fileID, sprintf(text.mara.remove));
                    fprintf(fileID, '\n');
                end
            end
            
            if(isfield(automagic, 'rpca'))
                if strcmp(automagic.rpca.performed, 'yes')
                    pars = automagic.rpca;
                    fprintf(fileID, sprintf(text.rpca.desc));
                    fprintf(fileID, sprintf(text.rpca.params, ...
                        pars.lambda, pars.tol, pars.maxIter));
                    fprintf(fileID, '\n');
                end
            end
         
            fprintf(fileID, sprintf(text.dc.desc));
            fprintf(fileID, '\n');
            
            if strcmp(automagic.highVarianceRejection.performed, 'yes')
                fprintf(fileID, sprintf(text.highvar.desc, ...
                    automagic.highVarianceRejection.sd));
                fprintf(fileID, '\n');
            end
            committedOHAThresh = automagic.qualityThresholds.overallThresh(find(automagic.qualityScores.OHA==automagic.selectedQualityScore.OHA));
            committedTHVThresh = automagic.qualityThresholds.timeThresh(find(automagic.qualityScores.THV==automagic.selectedQualityScore.THV));
            committedCHVThresh = automagic.qualityThresholds.chanThresh(find(automagic.qualityScores.CHV==automagic.selectedQualityScore.CHV));
            fprintf(fileID, sprintf(text.quality.OHA,...
                sprintf('%0.0f ', automagic.qualityThresholds.overallThresh),...
                sprintf('%0.7f ',automagic.qualityScores.OHA),...
                sprintf('%0.0f ', committedOHAThresh),...
                sprintf('%0.7f ', automagic.selectedQualityScore.OHA),...
                sprintf('%0.7f ', self.vParams.RateQualityParams.overallGoodCutoff),...
                sprintf('%0.7f ', self.vParams.RateQualityParams.overallBadCutoff)));
            fprintf(fileID, '\n');
            fprintf(fileID, sprintf(text.quality.THV,...
                sprintf('%0.0f ', automagic.qualityThresholds.timeThresh),...
                sprintf('%0.7f ',automagic.qualityScores.THV),...
                sprintf('%0.0f ', committedTHVThresh),...
                sprintf('%0.7f ',automagic.selectedQualityScore.THV),...
                sprintf('%0.7f ', self.vParams.RateQualityParams.timeGoodCutoff),...
                sprintf('%0.7f ', self.vParams.RateQualityParams.timeBadCutoff)));
            fprintf(fileID, '\n');
            fprintf(fileID, sprintf(text.quality.CHV,...
                sprintf('%0.0f ', automagic.qualityThresholds.chanThresh),...
                sprintf('%0.7f ',automagic.qualityScores.CHV),...
                sprintf('%6f ', committedCHVThresh),...
                sprintf('%0.7f ',automagic.selectedQualityScore.CHV),...
                sprintf('%0.7f ', self.vParams.RateQualityParams.channelGoodCutoff),...
                sprintf('%0.7f ', self.vParams.RateQualityParams.channelBadCutoff)));
            fprintf(fileID, '\n');
            fprintf(fileID, sprintf(text.quality.RBC,...
                sprintf('%0.7f ', automagic.qualityScores.RBC),...
                sprintf('%0.7f ', self.vParams.RateQualityParams.BadChannelGoodCutoff),...
                sprintf('%0.7f ', self.vParams.RateQualityParams.BadChannelBadCutoff)));
            fprintf(fileID, '\n');
            
            if isfield(automagic, 'interpolation')
                fprintf(fileID, sprintf(text.interpolate.desc, ...
                    automagic.interpolation.params.method));
                fprintf(fileID, '\n');
            end
            
            fclose(fileID);
        end
        
        
        function qScore = getCurrentQualityScore(self)
            % Return the quality score pointed by self.project.qualityScoreIdx
            qScore = self.getIdxQualityScore(self.qualityScores, ...
                self.project.qualityScoreIdx);
        end
        
        function img_address = get.imageAddress(self)
            % The name and address of the obtained plots during
            % preprocessing
            slash = filesep;
            img_address = [self.resultFolder slash self.fileName];
        end
        
        function bool = isInterpolate(self)
            % Return to true if this block is rated as Interpolate
            bool = strcmp(self.rate, ConstantGlobalValues.RATINGS.Interpolate);
            bool = bool &&  (~ self.isNull);
        end
        
        function bool = isGood(self)
            % Return to true if this block is rated as Good
            bool = strcmp(self.rate, ConstantGlobalValues.RATINGS.Good);
            bool = bool &&  (~ self.isNull);
        end
        
        function bool = isOk(self)
            % Return to true if this block is rated as OK
            bool = strcmp(self.rate, ConstantGlobalValues.RATINGS.OK);
            bool = bool &&  (~ self.isNull);
        end
        
        function bool = isBad(self)
            % Return to true if this block is rated as Bad
            bool = strcmp(self.rate, ConstantGlobalValues.RATINGS.Bad);
            bool = bool &&  (~ self.isNull);
        end
        
        function bool = isNotRated(self)
            % Return to true if this block is rated as Not Rated
            bool = strcmp(self.rate, ConstantGlobalValues.RATINGS.NotRated);
            bool = bool &&  (~ self.isNull);
        end
        
        function bool = isNull(self)
            % Return true if this block is a mock block
            bool = (self.index == -1);
        end
        
        function data = loadEEGFromFile(self)
            
            addEEGLab();
            
            % Case of .mat file
            if( any(strcmp(self.fileExtension(end-3:end), ...
                    {self.CGV.EXTENSIONS.mat})))
                data = load(self.sourceAddress);
                data = data.EEG;
                
            % case of .txt file
            elseif(any(strcmp(self.fileExtension, ...
                    {self.CGV.EXTENSIONS.text})))
                [~, data] = ...
                    evalc(['pop_importdata(''dataformat'',''ascii'',' ...
                    '''data'', self.sourceAddress,''sRate'', self.sRate,' ...
                    '''pnts'',0,''xmin'',0)']);
                
            % case of .set file 
            elseif(any(strcmp(self.fileExtension, ...
                    {self.CGV.EXTENSIONS.set})))
                [~ , data] = evalc('pop_loadset(self.sourceAddress)');
                
            % case of .edf file
            elseif(any(strcmp(self.fileExtension, ...
                    {self.CGV.EXTENSIONS.edf})))
                [~, data] = evalc('pop_biosig(self.sourceAddress)');
                
            else
                [~ , data] = evalc('pop_fileio(self.sourceAddress)');
            end 
        end
    end
    
    %% Private Methods
    methods(Access=private)

        function saveFiles(self, EEG, automagic, fig1, fig2) %#ok<INUSL>
            % Save results of preprocessing
            
            % Delete old results
            if( exist(self.reducedAddress, 'file' ))
                delete(self.reducedAddress);
            end
            if( exist(self.resultAddress, 'file' ))
                delete(self.resultAddress);
            end
            if( exist([self.imageAddress, '.tif'], 'file' ))
                delete([self.imageAddress, '.tif']);
            end
            
            % save results
            set(fig1,'PaperUnits','inches','PaperPosition',[0 0 10 8])
            print(fig1, self.imageAddress, '-djpeg', '-r200');
            close(fig1);
            print(fig2, strcat(self.imageAddress, '_orig'), '-djpeg', '-r100');
            close(fig2);

            reduced.data = downsample(EEG.data',self.dsRate)'; %#ok<STRNU>
            fprintf('Saving results...\n');
            PrepCsts = self.CGV.PreprocessingCsts;
            save(self.reducedAddress, ...
                PrepCsts.GeneralCsts.REDUCED_NAME, ...
                '-v6');
            
            [~,gitHashString] = system('git rev-parse HEAD');
            automagic.commitID = gitHashString;
            save(self.resultAddress, 'EEG', 'automagic','-v7.3');
        end
        
        function self = updatePrefix(self)
            % Update the prefix based in the rating information. This must 
            % be set after rating info are set. See the below function.
            
            p = 'p';
            if (self.isInterpolated)
                i = 'i';
            else
                i = '';
            end
            r = lower(self.rate(1));
            if isempty(self.prefix) || self.commitedNb == 0 || ...
                    self.commitedNb == 1
                self.prefix = strcat(r, i, p);
            else
                self.prefix = strcat(r, self.prefix(1:end-1), i, p);
            end
            
        end

        % TODO 20.03.2019: Is this even necessary now that we don't
        % updatePredix inside it anymore?
        function self = updateResultAddress(self)
            % Update addresses based on the rating
            % information. This must be called once rating info are set. 
            % Then the address and prefix are set based on rating info.
            slash = filesep;
            self = self.updatePrefix();
            
            if ispc
                splits = strsplit(self.sourceAddress, [slash slash self.subject.name slash]);
            else
                splits = strsplit(self.sourceAddress, [slash self.subject.name slash]);
            end
            relAdd = splits{2};
            if ~isempty(relAdd)
                relAdd = strsplit(relAdd, [self.fileName, self.fileExtension]);
                relAdd = relAdd{1};
            end
            self.resultFolder = [self.subject.resultFolder, slash, relAdd];
            self.resultAddress = strcat(self.resultFolder, self.prefix, '_', self.fileName, '.mat');
            self.reducedAddress = self.extractReducedAddress(...
                self.resultAddress, self.dsRate);
            
            if ~exist(self.resultFolder, 'dir')
                mkdir(self.resultFolder);
            end
            % Rename the file if it doesn't correspond to the actual rating
            if( ~ strcmp(self.resultAddress, self.potentialResultAddress))
                if( ~ isempty(self.potentialResultAddress) )
                    movefile(self.potentialResultAddress, ...
                        self.resultAddress);
                end
            end
        end
    end
    
    %% Private utility static methods
    methods(Static, Access=private)
        
        function prefix = extractPrefix(resultAddress)
                % Given the resultAddress, take the prefix out of it and
                % return. If results_adsress = '', then returns prefix = ''. 
                slash = filesep;
                splits = strsplit(resultAddress, slash);
                name_with_ext = splits{end};
                splits = strsplit(name_with_ext, '.');
                prefixed_name = splits{1};
                splits = strsplit(prefixed_name, '_');
                prefix = splits{1};

                if( ~ Block.isValidPrefix(prefix) )
                    popup_msg('Not a valid prefix.','Error');
                    return;
                end
         end
        
        function qScore = getIdxQualityScore(qScore, qScoreIdx)
            qScore.OHA = qScore.OHA(qScoreIdx.OHA);
            qScore.THV = qScore.THV(qScoreIdx.THV);
            qScore.CHV = qScore.CHV(qScoreIdx.CHV);
            qScore.MAV = qScore.MAV(qScoreIdx.MAV);
            qScore.RBC = qScore.RBC(qScoreIdx.RBC);
        end
        
        function reducedAddress = extractReducedAddress(...
                resultAddress, dsRate)
            % Return the address of the reduced file
            
            pattern = '[gobni]+i?p_';
            reducedAddress = regexprep(resultAddress,pattern,...
                strcat('reduced', int2str(dsRate), '_'));
        end
        
        function uniqueName = extractUniqueName(address, subject, fileName)
            % Return the uniqueName of this block. The uniqueName is the
            % concatenation of the subject's name and this raw file's name
            
            slash = filesep;
            if ispc
                splits = strsplit(address, [slash slash subject.name slash]);
            else
                splits = strsplit(address, [slash subject.name slash]);
            end
            relAdd = splits{2};
            
            if ~isempty(relAdd)
                splits = strsplit(relAdd, [fileName, '.']);
                relAdd = splits{1};
            end
            
            if ~isempty(relAdd)
                relAdd = strrep(relAdd, slash, '_');
            end
            
            uniqueName = strcat(subject.name, '_', relAdd, fileName);
        end

        function bool = hasInformation(prefix)
            % Return true if the prefix indicates that this preprocessed
            % file has been already rated.
            
            bool = true;
            
            % If the length is 3, there must be an "i" in it, which
            % indicates it's already been rated and interpolated.
            if(length(prefix) >= 3)
                return;
            end
            
            switch Block.getRateFromPrefix(prefix)
                case ConstantGlobalValues.RATINGS.NotRated
                    bool = true;
                case ''
                    bool = false;
            end
        end
        
        function type = getRateFromPrefix(prefix)
            % Extract the rating information from the prefix. The first
            % character of the prefix indicates the rating. 
            
            if( strcmp(prefix, ''))
                type = ConstantGlobalValues.RATINGS.NotRated;
                return;
            end
            
            type = '';
            switch prefix(1)
                case 'g'
                    type = ConstantGlobalValues.RATINGS.Good;
                case 'o'
                    type = ConstantGlobalValues.RATINGS.OK;
                case 'b'
                    type = ConstantGlobalValues.RATINGS.Bad;
                case 'i'
                    type = ConstantGlobalValues.RATINGS.Interpolate;
                case 'n'
                    type = ConstantGlobalValues.RATINGS.NotRated;
            end
        end

        function bool = isValidPrefix(prefix)
            % Return true if the prefix respects the standard pattern
            
            pattern = '^[gobni]+i?p$';
            reg = regexp(prefix, pattern, 'match');
            bool = ~ isempty(reg) || strcmp(prefix, '');
        end
        

    end
    
end


