function [data, noise] = performPCA(data, varargin)
% perform_pca  perform pca on the data 
%   [data, noise] = perform_pca(data, params) where data is the EEGLAB data
%   structure. params is an optional parameter which must be a structure
%   with optional fields 'lambda', 'tol', and 'maxIter' to specify
%   corresponding parameters in inexact_alm_rpca.m. To learn more about
%   these three parameters please see inexact_alm_rpca.m.
%
%   If varargin is ommited, default values are used. If any fields of
%   varargin is ommited or are [], corresponsing default value is used.
%
%   Default values are specified in DefaultParameters.m. If they are empty
%   then [] is given to inexact_alm_rpca.m which implies to use defaults.
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

[~ , m] = size(data.data);

defaults = DefaultParameters.PCAParams;
constants = PreprocessingConstants.PCACsts;
recs = RecommendedParameters.PCAParams;
% Check if defaults are not empty. If they are empty, override it with
% defaults of inexact_alm_rpca.m: -1.
if isempty(defaults)
    defaults = recs;
end

p = inputParser;
addParameter(p,'lambda', defaults.lambda, @isnumeric);
addParameter(p,'tol', defaults.tol, @isnumeric);
addParameter(p,'maxIter', defaults.maxIter, @isnumeric);
parse(p, varargin{:});

lambda = p.Results.lambda;
tol = p.Results.tol; %#ok<NASGU>
maxIter = p.Results.maxIter; %#ok<NASGU>

if( isempty( lambda) )
    lambda = 1 / sqrt(m); %#ok<NASGU>
end

eeg = double(data.data)'; %#ok<NASGU>

% Run robust PCA
display(constants.RUN_MESSAGE);
[~, A_hat, E_hat, ~] = evalc('inexact_alm_rpca(eeg, lambda, tol, maxIter)');
sig  = A_hat'; % data
data.data = sig;
noise = E_hat';  % noise

data.automagic.pca.performed = 'yes';
data.automagic.pca.lambda = lambda;
data.automagic.pca.tol = tol;
data.automagic.pca.maxIter = maxIter;
end