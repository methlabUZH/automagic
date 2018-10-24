classdef RecommendedParameters
    %RecommendedParameters is a class containing recommended parameters for
    %   different preprocessing steps. This is different from the
    %   DefaultParameters.m in the sense that there is a recommended value
    %   even for preprocessing steps that are not used by default: These
    %   structures must have all the possible fields for each parameter
    %   (with the exception of PrepParams), so that they are used later in
    %   the GUI or other places where no default parameter is given but
    %   another recommendation is needed. 
    %
    %   Please do not change anything in this file unless you are sure what
    %   you are doing.
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
       FilterParams = struct('notch',    struct('freq', 50),...
                             'high',     struct('freq', 0.5,...
                                                 'order', []),... % Default
                             'low',      struct('freq', 30,...
                                                 'order', []))    % Default
                            
        CRDParams = struct('ChannelCriterion',     0.85,...
                           'LineNoiseCriterion',   4,...
                           'BurstCriterion',       5,...
                           'WindowCriterion',      0.25, ...
                           'Highpass',             [0.25 0.75]);
        
        PrepParams = struct();                           % Default by prep
        
        HighvarParams = struct('sd', 25);
        
        InterpolationParams = struct('method', 'spherical');
        
        RPCAParams = struct('lambda', [], ...  % Default lambda by alm_rpca
                            'tol', 1e-7, ...
                            'maxIter', 1000);
        
        MARAParams = struct('chanlocMap', containers.Map, ...
                            'largeMap', 0, ...
                            'high',        struct('freq', 1.0,...
                                                  'order', []))
                    
        EOGRegressionParams = struct();
                        
        ChannelReductionParams = struct('tobeExcludedChans', []);
                                      
                                      
        EEGSystem = struct('name', 'EGI',...
                           'sys10_20', 0, ...
                           'locFile', '', ...
                           'refChan', [], ...
                           'fileLocType', '',...
                           'eog_channels', []);
         
        Settings = struct('trackAllSteps', 0, ...
                          'pathToSteps', '/allSteps.mat');
    end
end