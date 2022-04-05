function ratings = rateQuality (qualityScores, CGV,varargin)
% rates datasets, based on quality measures calculated with calcQuality()
% Inputs: A structure Q with the following fields:

% OHA   - The ratio of data points that exceed the absolute value a certain
%         voltage amplitude
% THV   - The ratio of time points in which % the standard deviation of the
%         voltage measures across all channels exceeds a certain threshold
% CHV   - The ratio of channels in which % the standard deviation of the
%         voltage measures across all time points exceeds a certain threshold
% MAV   - unthresholded mean absolute voltage of the dataset (not used in
%         the current version)
% RBC   - ratio of bad channels
%
%   The input is an EEG structure with optional parameters that can be
%   passed within a structure: (e.g. struct('',50))
%   'Qmeasures'           - a cell array indicating on which metrics the
%                           datasets should be rated {'OHA','THV','CHV'}
%   'overallGoodCutoff'      - cutoff for "Good" quality based on OHA [0.1]
%   'overallBadCutoff'       - cutoff for "Bad" quality based on OHA [0.2]
%   'timeGoodCutoff'         - cutoff for "Good" quality based on THV [0.1]
%   'timeBadCutoff'          - cutoff for "Bad" quality based on THV [0.2]
%   'channelGoodCutoff'      - cutoff for "Good" quality based on CHV [0.15]
%   'channelBadCutoff'       - cutoff for "Bad" quality based on CHV [0.3]
%   'badChannelGoodCutoff'   - cutoff for "Good" quality based on RBC[0.15]
%   'badChannelBadCutoff'    - cutoff for "Bad" quality based on RBC[0.3]
%
% Copyright (C) 2018  Andreas Pedroni, anpedroni@gmail.com
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
% Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
defVis = CGV.DefaultVisualisationParams;
defaults = defVis.RateQualityParams;
rating_strs = CGV.RATINGS;

p = inputParser;
addParameter(p,'overallGoodCutoff', defaults.overallGoodCutoff,@isnumeric );
addParameter(p,'overallBadCutoff', defaults.overallBadCutoff,@isnumeric );

addParameter(p,'timeGoodCutoff', defaults.timeGoodCutoff,@isnumeric );
addParameter(p,'timeBadCutoff', defaults.timeBadCutoff,@isnumeric );

addParameter(p,'channelGoodCutoff', defaults.channelGoodCutoff,@isnumeric );
addParameter(p,'channelBadCutoff', defaults.channelBadCutoff,@isnumeric );

addParameter(p,'BadChannelGoodCutoff', defaults.BadChannelGoodCutoff,@isnumeric );
addParameter(p,'BadChannelBadCutoff', defaults.BadChannelBadCutoff,@isnumeric );


addParameter(p,'Qmeasure', defaults.Qmeasure, @isstr );

parse(p, varargin{:});
settings = p.Results;

if nargin < 1
    disp('No quality metrics to base a rating on')
end

Qs = qualityScores;

% create empty cells
ratings = cell(length(Qs),1);

% Categorize wrt OHA
OHAGoodIdx = zeros(1, length(Qs));
OHAOKIdx = zeros(1, length(Qs));
OHABadIdx = zeros(1, length(Qs));
if any(strfind(settings.Qmeasure,'OHA'))
    OHAGoodIdx = [Qs.OHA] < settings.overallGoodCutoff;
    OHAOKIdx = [Qs.OHA] >= settings.overallGoodCutoff & [Qs.OHA] < settings.overallBadCutoff;
    OHABadIdx = ~(OHAGoodIdx | OHAOKIdx);
end

% Categorize wrt THV
THVGoodIdx = zeros(1, length(Qs));
THVOKIdx = zeros(1, length(Qs));
THVBadIdx = zeros(1, length(Qs));
if any(strfind(settings.Qmeasure,'THV'))
    THVGoodIdx = [Qs.THV] < settings.timeGoodCutoff;
    THVOKIdx = [Qs.THV] >= settings.timeGoodCutoff & [Qs.THV] < settings.timeBadCutoff;
    THVBadIdx = ~(THVGoodIdx | THVOKIdx);
end

% Categorize wrt CHV
CHVGoodIdx = zeros(1, length(Qs));
CHVOKIdx = zeros(1, length(Qs));
CHVBadIdx = zeros(1, length(Qs));
if any(strfind(settings.Qmeasure,'CHV'))
    CHVGoodIdx = [Qs.CHV] < settings.channelGoodCutoff;
    CHVOKIdx = [Qs.CHV] >= settings.channelGoodCutoff & [Qs.CHV] < settings.channelBadCutoff;
    CHVBadIdx = ~(CHVGoodIdx | CHVOKIdx);
end

% Categorize wrt RBC
RBCGoodIdx = zeros(1, length(Qs));
RBCOKIdx = zeros(1, length(Qs));
RBCBadIdx = zeros(1, length(Qs));
if any(strfind(settings.Qmeasure,'RBC'))
    RBCGoodIdx = [Qs.RBC] < settings.BadChannelGoodCutoff;
    RBCOKIdx = [Qs.RBC] >= settings.BadChannelGoodCutoff & [Qs.RBC] < settings.BadChannelBadCutoff;
    RBCBadIdx = ~(RBCGoodIdx | RBCOKIdx);
end


% combine RATINGS with the rule that the rating depends on the worst rating
badRating = RBCBadIdx | CHVBadIdx | THVBadIdx | OHABadIdx;
OKRating = RBCOKIdx | CHVOKIdx | THVOKIdx | OHAOKIdx;
GoodRating = RBCGoodIdx | CHVGoodIdx | THVGoodIdx | OHAGoodIdx;
ratings(:) = {rating_strs.NotRated};
ratings(GoodRating) = {rating_strs.Good};
ratings(OKRating) = {rating_strs.OK};
ratings(badRating) = {rating_strs.Bad};

end