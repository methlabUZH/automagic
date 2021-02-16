function [final_idx,f_idx,cp_idx,o_idx,len] = performSortChans(EEG)
% performSortChans  sorts channels based on (x,y) cartesian coordinates
%   
%   [final_idx,f_idx,cp_idx,o_idx,len] = performSortChans(EEG)
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



% sort based on EEG.chanlocs.x (do not confuse with X!)
T = struct2table(EEG.chanlocs); 

if ischar(EEG.chanlocs)
  [tmpeloc labels Th Rd indices] = readlocs(EEG.chanlocs);
elseif isstruct(EEG.chanlocs) 
  [tmpeloc labels Th Rd indices] = readlocs(EEG.chanlocs);
else
   error('loc_file must be a EEG.locs struct or locs filename');
end

% convert degress to radians
Th = pi / 180 * Th;
allchansind = 1 :length(Th);
% compute 2D coordinates
[x, y] = pol2cart(Th,Rd); 
% add them to table and sort
T.x = x';
T.y = y';
% sort by x
[sortedT, sort_idx] = sortrows(T, 'x','descend'); 
% divide on frontal, centro-parietal, occipital
frontal = sortedT(sortedT.x > 0.24, :);
f_idx = sort_idx(sortedT.x > 0.24);
cen_par = sortedT(sortedT.x <= 0.24 & sortedT.x > -0.31, :);
cp_idx = sort_idx(sortedT.x <= 0.24 & sortedT.x > -0.31);
occ = sortedT(sortedT.x <= -0.31, :);
o_idx = sort_idx(sortedT.x <= -0.31);
% sort by y => left and right
[temp, i1] = sortrows(frontal, 'y','ascend'); 
[temp, i2] = sortrows(cen_par, 'y','ascend'); 
[temp, i3] = sortrows(occ, 'y','ascend'); 
% sort indices
f_idx = f_idx(i1);
cp_idx = cp_idx(i2);
o_idx = o_idx(i3);

final_idx = [f_idx; cp_idx; o_idx];

len = size(EEG.data, 2);

end