function parts = addPreprocessingPaths(varargin)
% addPreprocessingPaths Unzip and add all the required packages to the path
%   
%   parts = addPreprocessingPaths(varargin)
%   Where varargin is an optional parameter. When given, it should be a
%   struct with optional fields PrepParams, CRDParams, RPCAParams and 
%   MARAParams corresponding to PREP parameters, clean_rawdata() parameters, 
%   RPCA parameters and MARA parameters. These arguments are only needed to
%   make sure that the packages are indeed required. If one of this steps
%   is deavtivated, then the package does not to be added to the path.
%   
%   If varargin is ommited, default values are used. If any fields of
%   varargin is ommited, corresponsing default value is used. Please see
%   DefaultParameters.m for more information on default parameters.
%
%   parts: All the paths in EEGLAB folder.
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
CSTS = PreprocessingConstants;
defaults = DefaultParameters;
p = inputParser;
addParameter(p,'PrepParams', defaults.PrepParams, @isstruct);
addParameter(p,'CRDParams', defaults.CRDParams, @isstruct);
addParameter(p,'RPCAParams', defaults.RPCAParams, @isstruct);
addParameter(p,'MARAParams', defaults.MARAParams, @isstruct);
addParameter(p,'ICLabelParams', defaults.ICLabelParams, @isstruct);
parse(p, varargin{:});
PrepParams = p.Results.PrepParams;
CRDParams = p.Results.CRDParams;
RPCAParams = p.Results.RPCAParams;
MARAParams = p.Results.MARAParams;
ICLabelParams = p.Results.ICLabelParams;
libraryPath = CSTS.LIBRARY_PATH;

addpath(libraryPath);

parts = addEEGLab();

% Check and unzip if PREP does not exist
if ~isempty(PrepParams)
    addPREP();
end

% Check and unzip if cleanrawdata() does not exist
if ~isempty(CRDParams) 
    addCRD();
end

% Check and unzip if RPCA() does not exist
if ~isempty(RPCAParams) 
    addRPCA();
end

% Check and unzip if MARA() does not exist
if ~isempty(MARAParams)
    addMARA();
end

% Check and unzip if IClabel() does not exist
if ~isempty(ICLabelParams)
%     addICLabel();
end

addNoiseTools();

addCbrewer();
end