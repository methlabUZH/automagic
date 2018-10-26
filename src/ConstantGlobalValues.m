classdef ConstantGlobalValues
    %ConstantGlobalValues is a class containing all constant values used
    %throughout the application.
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
    properties(Constant)

        VERSION = '2.0';
            
        DEFAULT_KEYWORD = 'Default';
                
        NONE_KEYWORD = 'None';
        
        NEW_PROJECT = struct('LIST_NAME', 'Create New Project...', ...
            'NAME', 'Type the name of your new project...', ...
            'DATA_FOLDER', 'Choose where your raw data is...', ...
            'FOLDER', 'Choose where you want the results to be saved...');
        
        LOAD_PROJECT = struct('LIST_NAME', 'Load an existing project...');
        
        PREFIX_PATTERN = '^[gobni]i?p_';
        
        RATINGS = struct('Good',        'Good', ...
                         'Bad',          'Bad', ...
                         'OK',           'OK', ...
                         'Interpolate',  'Interpolate', ...
                         'NotRated',     'Not Rated');
        
        EXTENSIONS = struct('mat', '.mat', ...
                            'text', {'.txt', '.asc', '.csv'}, ...
                            'fif', '.fif',...
                            'set', '.set')
        
        KEYBOARD_SHORTCUTS = struct('GOOD',         {'g', '1'}, ...
                                    'OK',           {'o', '2'}, ...
                                    'BAD',          {'b', '3'}, ...
                                    'INTERPOLATE',  {'i', '4'}, ...
                                    'NOTRATED',     {'n', '5'}, ...
                                    'NEXT',         'rightarrow', ...
                                    'PREVIOUS',     'leftarrow')
                                 
    end
    
    properties(SetAccess=private)
        DefaultParams
        
        DefaultVisualisationParams
        
        RecParams
        
        PreprocessingCsts
       
        AUTOMAGIC_PATH
        
        LIBRARY_PATH
        
        SRC_PATH
        
        GUI_PATH
        
        PREPROCESSING_PATH
    end
    
    methods
        function self = ConstantGlobalValues
            if ispc
                slash = '\';
                seperator = ';';
            else
                slash = '/';
                seperator = ':';
            end
            automagic = 'automagic'; % Folder name of automagic
            libName = 'matlab_scripts'; 
            srcFolder = 'src'; 
            guiFolder = 'gui';
            preproFolder = 'preprocessing';
            
            matlabPaths = matlabpath;
            parts = strsplit(matlabPaths, seperator);
            Index = not(~contains(parts, automagic));
            automagicPath = parts{Index};
            automagicPath = strcat(automagicPath, '/');
            automagicPath = regexp(automagicPath, ['.*' automagic '.*?/'], 'match');
            automagicPath = automagicPath{1};
            automagicPath = [automagicPath slash];
            libPath = [automagicPath libName slash];
            srcPath = [automagicPath srcFolder slash];
            guiPath = [automagicPath guiFolder slash];
            prepproPath = [automagicPath preproFolder slash];
            
            self.AUTOMAGIC_PATH = automagicPath;
            self.LIBRARY_PATH = libPath;
            self.SRC_PATH = srcPath;
            self.GUI_PATH = guiPath;
            self.PREPROCESSING_PATH = prepproPath;
            
            addpath(automagicPath);
            addpath(libPath);
            addpath(srcPath);
            addpath(genpath(guiPath));
            addpath(prepproPath);
            addPreprocessingPaths();
            
            
            self.DefaultParams = DefaultParameters;
            self.DefaultVisualisationParams = DefaultVisualisationParameters;
            self.RecParams = RecommendedParameters;
            self.PreprocessingCsts = PreprocessingConstants;
        end
    end
    
    methods(Static)
        function stateFile = stateFile()
            if ispc
                home = [getenv('HOMEDRIVE') getenv('HOMEPATH')];
                slash = '\';
            else
                home = getenv('HOME');
                slash = '/';
            end
            
            stateFile = struct('NAME', 'state.mat', ...
                               'PROJECT_NAME', 'project_state.mat', ...
                               'FOLDER', [home slash 'automagicConfigs' slash], ...
                               'ADDRESS', [home slash 'automagicConfigs' slash 'state.mat']);
        end
    end
end
