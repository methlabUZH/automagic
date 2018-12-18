function EOGregressed = performEOGRegression(EEG, EOG, varargin)
% performEOGRegression  perform EOG regression from EOG channels
%   EOGregressed = performEOGRegression(EEG, EOG, params)
%   Both EEG and EOG are input EEGLAB data structure. EOGregressed is the
%   output EEG structure after EOG regression. params is a structure.
%   If params = struct(), then the EOG regression is performed. If params =
%   struct([]), then EOG regression is skipped and not performed.
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
EOGregressed = EEG;
EOGregressed.automagic.EOGRegression.performed = 'no';
if isempty(varargin{:})
    return; end

CSTS = PreprocessingConstants.EOGRegressionCsts;
display(CSTS.RUN_MESSAGE);

eeg = EEG.data';
eog = EOG.data';

eegclean =  eeg - eog * (eog \ eeg);
EOGregressed.data = eegclean';

% Write back what has happened
EOGregressed.automagic.EOGRegression.performed = 'yes';
end