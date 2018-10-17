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
       FilterParams = struct('notch',    struct([]),...
                             'high',     struct([]),...
                             'low',      struct([]))
                            
        CRDParams = struct([]);             % Clean raw data parameters
        
        PrepParams = struct();
        
        HighvarParams = struct([]);
        
        InterpolationParams = struct('method', 'spherical');
        
        RPCAParams = struct([]);
        
        MARAParams = struct('chanlocMap', containers.Map, ...
                            'largeMap',   0, ...
                            'high',       struct('freq', 1.0,...
                                                 'order', []))
                    
        EOGRegressionParams = struct();
                        
        ChannelReductionParams = struct();
                                      
                                      
        EEGSystem = struct('name', 'EGI',...
                           'sys10_20', 0, ...
                           'locFile', '', ...
                           'refChan', [], ...
                           'fileLocType', '',...
                           'eogChans', []);
                       
        Settings = struct('trackAllSteps', 0);
                        
    end
end