classdef DefaultVisualisationParameters
    %DefaultVisualisationParameters is a class containing default parameters for
    %   different visualisation steps
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


        COLOR_SCALE = 100;
        
        dsRate = 2
        
        CalcQualityParams = struct('overallThresh',    20:5:40, ...
                                    'timeThresh',       5:5:25,...
                                    'chanThresh',       5:5:25,...   
                                    'avRef',            1);
                                        
                                   
         RateQualityParams = struct('overallGoodCutoff',   0.1,...
                                     'overallBadCutoff',    0.2,... 
                                     'timeGoodCutoff',      0.1,...
                                     'timeBadCutoff',       0.2,...                                        
                                     'channelGoodCutoff',   0.15,...
                                     'channelBadCutoff',    0.3,...   
                                     'BadChannelGoodCutoff',0.15,...
                                     'BadChannelBadCutoff', 0.3,...  
                                     'Qmeasure',['THV','OHA','CHV','RBC']) 
                                 
    end
end
