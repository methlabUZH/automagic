function BidsTools()
% addBidsTools  Unzip and add the BidsTools package
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
% along with this program.  If not, see <http://www.gnu.org/licenses/>

CSTS = PreprocessingConstants;
ZIPName = CSTS.BidsToolsCsts.ZIP;
libraryPath = CSTS.LIBRARY_PATH;

parts = strsplit(ZIPName, '.zip');
folderName = parts{1};

folderName = [libraryPath folderName];
ZIPName = [libraryPath ZIPName];

if ~ exist(folderName, 'dir')
    unzip(ZIPName, libraryPath);
end
BidsToolsCsts_paths = genpath(folderName);

parts = strsplit(BidsToolsCsts_paths, pathsep);
% Exclude paths which create conflicts
Index = contains(parts, 'compatibility');
parts(Index) = [];
BidsToolsCsts_paths = strjoin(parts, pathsep);
addpath(BidsToolsCsts_paths);
    
end