function parts = downloadAndAddPaths(varargin)
% downloadAndAddPaths  Add path and download required packages
%   If a required package is not in the path, it adds or downloads them to
%   the path.
%   A very naive approach is taken to see if the library is in path or not: 
%   simply check if one of their files exists or not.
%   
%   parts = downloadAndAddPaths(varargin)
%   Where varargin is an optional parameter. When given, it should be a
%   struct with optional fields PrepParams and PCAParams corresponding to
%   PREP parameters and PCA parameters.
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

defaults = DefaultParameters;
p = inputParser;
addParameter(p,'PrepParams', defaults.PrepParams, @isstruct);
addParameter(p,'PCAParams', defaults.PCAParams, @isstruct);
parse(p, varargin{:});
PrepParams = p.Results.PrepParams;
PCAParams = p.Results.PCAParams;

parts = [];
if(~exist('pop_fileio', 'file'))
    parts = addEEGLab();
end

% Check and download if Robust Average Referencing does not exist
if( ~isempty(PrepParams) && ~ exist('performReference.m', 'file'))
    downloadRAR();
end

% Check and download if Artifact Subspace Reconstruction does not exist
if( ~ exist('clean_artifacts.m', 'file'))
    downloadASR();
end
    
end