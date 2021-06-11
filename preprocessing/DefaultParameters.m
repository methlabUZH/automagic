classdef DefaultParameters
    %DefaultParameters is a class containing default parameters for
    %   different preprocessing steps.
    %
    %   struct([]) desactivate the corresponding operation.
    %   struct() will be the default parameters used in the corresponding
    %   operation.
    %   If a field has [] as value, then the default value in the 
    %   corresponding function is used.
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
    properties(Constant)  
        

        FilterParams = struct('notch',    struct([]),...
                             'zapline',  struct([]),...
                             'high',     struct([]),...
                             'low',      struct([]), ...
                             'firws',    struct([]))
                            
        CRDParams = struct([]);             % Clean raw data parameters
        
        PrepParams = struct();
        
        HighvarParams = struct([]);
        
        MinvarParams = struct([]);
        
        InterpolationParams = struct('method', 'spherical');
        
        RPCAParams = struct([]);
        
        MARAParams = struct([]);
        
        TrimDataParams = struct();
        
        TrimOutlierParams = struct();
        
        AMICAParams = struct('numprocs', 1, 'max_threads', 1, 'num_models',1, 'max_iter', 2000);
        
        ICLabelParams = struct('brainTher', [], ...
                               'muscleTher', [0.8 1], ...
                               'eyeTher', [0.8 1], ...
                               'heartTher', [0.8 1], ...
                               'lineNoiseTher', [0.8 1], ...
                               'channelNoiseTher', [0.8 1], ...
                               'otherTher', [], ...
                               'includeSelected', 0, ...
                               'keep_comps', 0, ...
                               'high',     struct('freq', 2.0,...
                                                  'order', []));
                    
        EOGRegressionParams = struct();
                        
        ChannelReductionParams = struct();
        
        DetrendingParams = struct([]);
                                      
        EEGSystem = struct('name', 'Others',...
                           'sys10_20', 0, ...
                           'locFile', '', ...
                           'refChan', struct('idx', []), ...
                           'fileLocType', '',...
                           'eogChans', [],...
                           'powerLineFreq', []);          
                       
        % Additonal parameters of the preprocessing
        Settings = struct('trackAllSteps', 0,...
                          'pathToSteps', '/allSteps.mat',...
                          'colormap','Default', ...
                          'sortChans', 0); 
                      
        
                           
    end
end