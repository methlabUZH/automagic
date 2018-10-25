function parts = addPreprocessingPaths(varargin)
% addPreprocessingPaths  Unzip and add required paths
%   If a required package is not in the path, it adds them to the path.
%   A very naive approach is taken to see if the library is in path or not: 
%   simply check if one of their files exists or not.
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
%   parts: TODO
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
CSTS = PreprocessingConstants;
defaults = DefaultParameters;
p = inputParser;
addParameter(p,'PrepParams', defaults.PrepParams, @isstruct);
addParameter(p,'CRDParams', defaults.CRDParams, @isstruct);
addParameter(p,'RPCAParams', defaults.RPCAParams, @isstruct);
addParameter(p,'MARAParams', defaults.MARAParams, @isstruct);
parse(p, varargin{:});
PrepParams = p.Results.PrepParams;
CRDParams = p.Results.CRDParams;
RPCAParams = p.Results.RPCAParams;
MARAParams = p.Results.MARAParams;
libraryPath = CSTS.LIBRARY_PATH;

addpath(libraryPath);

parts = [];
if(~exist('pop_fileio.m', 'file'))
    parts = addEEGLab();
end

% Check and download if PREP does not exist
if( ~isempty(PrepParams) && ~ exist('performReference.m', 'file'))
    addPREP();
end

% Check and download if cleanrawdata() does not exist
if( ~isempty(CRDParams) && ~ exist('clean_artifacts.m', 'file'))
    addCRD();
end

% Check and download if cleanrawdata() does not exist
if( ~isempty(RPCAParams) && ~ exist('inexact_alm_rpca.m', 'file'))
    addRPCA();
end

% Check and download if cleanrawdata() does not exist
if( ~isempty(MARAParams) && ~ exist('MARA.m', 'file'))
    addMARA();
end
    
end