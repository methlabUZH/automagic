classdef RecommendedParameters
    %RecommendedParameters is a class containing recommended parameters for
    %   different preprocessing steps. This is different from the
    %   DefaultParameters.m in the sense that there is a recommended value
    %   even for preprocessing steps that are not used by default. Note
    %   that when a step is not used, simply it has an empty structure as
    %   parameter, wheras here no empty parameter exists.
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
                            
        ASRParams = struct('ChannelCriterion',     0.85,...
                            'LineNoiseCriterion',   4,...
                            'BurstCriterion',       5,...
                            'WindowCriterion',      0.25, ...
                            'Highpass',             [0.25 0.75]);
        
        PrepParams = struct();                           % Default by prep
        
        HighvarParams = struct('sd', 25);
        
        InterpolationParams = struct('method', 'spherical');
        
        PCAParams = struct('lambda', [], ...  % Default lambda by alm_rpca
                            'tol', 1e-7, ...
                            'maxIter', 1000);
        
        ICAParams = struct('chanlocMap', containers.Map, ...
                            'largeMap', 0, ...
                            'high',        struct('freq', 1.0,...
                                                  'order', []))
                    
        EOGRegressionParams = struct('performEOGRegression', 1, ...
                                       'eogChans', '');
                        
        ChannelReductionParams = struct('performReduceChannels', 1, ...
                                          'tobeExcludedChans', '');
                                      
                                      
        EEGSystem = struct('name', 'EGI',...
                            'sys10_20', 0, ...
                            'locFile', '', ...
                            'refChan', [], ...
                            'fileLocType', '');
    end
end