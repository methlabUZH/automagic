classdef PreprocessingConstants
    %PreprocessingConstants is a class containing static constant variables 
    % used throughout the preprocessing. 
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
        FilterCsts = struct('NOTCH_EU',      50, ...
                            'NOTCH_US',      60, ...
                            'NOTCH_OTHER',   [], ...
                            'RUN_MESSAGE', 'Perform Filtering...')
        
        EEGLabCsts = struct('ZIP', 'eeglab14_1_2b.zip')
                     
        CRDCsts = struct('URL', 'http://sccn.ucsd.edu/eeglab/plugins/clean_rawdata0.32.zip', ...
                         'ZIP', 'clean_rawdata0.32.zip', ...
                         'RUN_MESSAGE', 'Finding bad channels...');
                           
        PrepCsts = struct('URL', 'https://github.com/VisLab/EEG-Clean-Tools/archive/master.zip', ...
                          'ZIP', 'VisLab-EEG-Clean-Tools.zip')
        
        RPCACsts = struct(...
            'URL', 'http://perception.csl.illinois.edu/matrix-rank/Files/inexact_alm_rpca.zip', ...
            'ZIP', 'inexact_alm_rpca.zip', ...
            'RUN_MESSAGE', 'Performing Robust PCA  (this may take a while...)');
                        
        MARACsts = struct(...
            'ZIP', 'MARA-master.zip', ...
            'REQ_CHAN_LABELS', {{'C3','C4','Cz','F3','F4','F7','F8',...
            'Fp1','Fp2','Fz','LM','NAS','O1','O2','Oz','P3','P4','P7'...
            ,'P8','Pz','RM','T7','T8'}}, ...
            'RUN_MESSAGE', 'Performing MARA ICA  (this may take a while...)')
                    
        EOGRegressionCsts = ...
            struct('RUN_MESSAGE', 'Perform EOG Regression...');
                        
        GeneralCsts = struct('ORIGINAL_FILE', '', ...
                             'REDUCED_NAME', 'reduced');
                        
        EEGSystemCsts = ...
            struct('sys10_20_file', 'standard-10-5-cap385.elp',...
                   'EGI_NAME', 'EGI',...
                   'OTHERS_NAME', 'Others');
               
        Settings = struct('pathToSteps', '/allSteps');
                    
    end
    
    methods(Static)
        function path = LIBRARY_PATH()
            CSTS = PreprocessingConstants;
            if ispc
                slash = '\';
            else
                slash = '/';
            end
            
            libName = 'matlab_scripts'; 
            path = [CSTS.AUTOMAGIC_PATH libName slash];
        end
        
        function path = AUTOMAGIC_PATH()
            if ispc
                slash = '\';
                seperator = ';';
            else
                slash = '/';
                seperator = ':';
            end
            
            automagic = 'automagic'; % Folder name of automagic
            matlabPaths = matlabpath;
            parts = strsplit(matlabPaths, seperator);
            Index = not(~contains(parts, automagic));
            automagicPath = parts{Index};
            automagicPath = strcat(automagicPath, '/');
            automagicPath = regexp(automagicPath, ['.*' automagic '.*?/'], 'match');
            automagicPath = automagicPath{1};
            path = [automagicPath slash];
        end
    end
end