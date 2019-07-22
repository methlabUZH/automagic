function code = getCodeHistoryStruct()
% getCodeHistoryStruct  Return a structure containing lines of code
% necessary to reproduce the preprocessing. 
%
%   The text is hardcoded and need to be changed accordingly if anything in
%   the concept is changed. 
%
% Copyright (C) 2018  Amirreza Bahreini, methlabuzh@gmail.com
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

code = struct('create', ['p = load(''params.mat'');\n' ...
                         'vp = load(''vParams.mat'');\n'...
                         'Params = p.params;\n'...
                         'VisualisationParams = vp.vParams;\n\n'...
                         'project = Project(''%s'', ''%s'', ''newResultsFolder_%s_results'', ''%s'', Params, VisualisationParams);\n'...
                         'project.preprocessAll();\n'], ...
              'interpolate', 'project.interpolateSelected();\n'...
              );
end