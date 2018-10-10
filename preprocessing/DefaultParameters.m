classdef DefaultParameters
    %DefaultParameters is a class containing default parameters for
    %   different preprocessing steps.
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
                              'low',      struct([]))      % Deactivated
                            
        ASRParams = struct('ChannelCriterion',     0.85,...
                            'LineNoiseCriterion',   4,...
                            'BurstCriterion',       'off',...
                            'WindowCriterion',      'off', ...
                            'Highpass',             [0.25 0.75]);
        
        PrepParams = struct([]);                           % Deactivated
        
        HighvarParams = struct('sd', 25);
        
        InterpolationParams = struct('method', 'spherical');
        
        PCAParams = struct([]);                            % Deactivated
        
        ICAParams = struct('chanlocMap', containers.Map, ...
                            'largeMap',   0, ...
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