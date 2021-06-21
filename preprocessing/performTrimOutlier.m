% performTrimOutlier() - rejects datapoints that are above the specified
%                 threshold. Point spread width [ms] determines the range
%                 for rejection.  

% Based on trimOutlier() from EEGlab
%
% Usage:
%   >> EEG = performTrimOutlier(EEG, amplitudeThreshold, pointSpreadWidth);

% History:
% 02/27/2019 Makoto. line 102 logical(ones(EEG.pnts,1)) fixed.
% 07/05/2018 Makoto. Cleaning mask saved under EEG.etc.trimOutlier
% 06/27/2014 ver 1.4 by Makoto and Clement. Drastic speed up by removing for loop (thanks Christian!) Displays log (requested by Kathleen VanBenthem)
% 04/17/2014 ver 1.3 by Makoto. min(badPntsStart)=1, zero not allowed.
% 04/01/2014 ver 1.2 by Makoto. Check inputs.
% 03/26/2014 ver 1.1 by Makoto. Debug and simplify datapoint rejection
% 03/07/2014 ver 1.0 by Makoto. Former firstpassOutlierTrimmer redesigned and renamed.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 09/06/2013 ver 1.5 by Makoto. No datapoint rejection reflects channel rejection.
% 08/05/2013 ver 1.4 by Makoto. Supported 3-D data (except for datapoint rejection)
% 06/27/2013 ver 1.3 by Makoto. Error message for inputting 3-D data.
% 06/13/2013 ver 1.2 by Makoto. Scalp topos added (when valid channel data exist)
% 05/22/2013 ver 1.1 by Makoto. Minor brush up.
% 05/16/2013 ver 1.0 by Makoto. Created.

% Author: Makoto Miyakoshi, SCCN,INC,UCSD 2013
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [EEG, EOG] = performTrimOutlier(EEG, EOG, TrimOutlierParams)

if ~(nargin==3)
    error('trimOutlier() requires 3 input arguments.')
end

% return if 3-D
if length(size(EEG.data))==3
    disp('Epoched data detected: datapoint rejection is skipped.')
    return
end

%%
amplitudeThreshold = str2double(TrimOutlierParams.AmpTresh);
pointSpreadWidth = str2double(TrimOutlierParams.rejRange);
numChans = str2double(TrimOutlierParams.numChans);
high = TrimOutlierParams.high;
high.freq = str2double(high.freq);
if strcmp(high.order, 'Default')
    high.order = [];
else
    high.order = str2double(high.order);
end

%% in case EEG has a 'sample' events instead of 'latency'
if isfield(EEG.event, 'sample')
    [EEG.event.latency] = EEG.event.sample;
end

%% temporary HP filter

if high.perform % temporary high-pass filter
    [~, EEGtemp, ~, b] = evalc('pop_eegfiltnew(EEG, high.freq, 0, high.order)');
    
    EEG.automagic.TrimOutlier.highpass.performed = 'yes';
    EEG.automagic.TrimOutlier.highpass.freq = high.freq;
    EEG.automagic.TrimOutlier.highpass.order = length(b)-1;
    EEG.automagic.TrimOutlier.highpass.transitionBandWidth = 3.3 / (length(b)-1) * EEG.srate;
else
    EEGtemp = EEG;
    EEG.automagic.TrimOutlier.highpass.performed = 'no';
end

%% remove bad datapoints

% obtain the window size
windowSize = pointSpreadWidth; % millisecond
windowSizeInFrame = round(windowSize/(1000/EEGtemp.srate)); % frame

% compute bad datapoints (old version)
% absMinMaxAllChan = max([abs(min(EEGtemp.data(:,:))); abs(max(EEGtemp.data(:,:)))],[],1);
% badPoints  = absMinMaxAllChan > amplitudeThreshold;

badPoints = 0;
% remove datapoints, if 'numChans' of the channels exceeds defined threshold (new version)
badPoints = squeeze(sum([(EEGtemp.data(:, :) > amplitudeThreshold) | (EEGtemp.data(:, :) < -amplitudeThreshold)],1) > numChans);


if any(badPoints)
    % expand badPoints
    badPointsExpanded = logical(conv(single(badPoints), ones(1,windowSizeInFrame), 'same'));
    
    % start Christian's impressive code
    rejectDataIntervals = reshape(find(diff([false badPointsExpanded false])),2,[])';
    rejectDataIntervals(:,2) = rejectDataIntervals(:,2)-1;
    
    % reject them
    EEG = pop_select(EEG, 'nopoint', [rejectDataIntervals(:,1) rejectDataIntervals(:,2)]);
    % remove also from EOG
    EOG = pop_select(EOG, 'nopoint', [rejectDataIntervals(:,1) rejectDataIntervals(:,2)]);
    
    % Save the clean data points.
    EEG.automagic.TrimOutlier.cleanDatapointMask = ~badPointsExpanded;
    
    % display log
    badPointsInSec = length(find(badPointsExpanded))*1000/EEG.srate/1000; %#ok<*NASGU>
    m = sprintf('\n%2.0fuV threshold with %2.0fms spreading rejected %2.1fsec data, added %1.0f boundaries.', amplitudeThreshold, windowSize, badPointsInSec, size(rejectDataIntervals,1));
    disp(m)
    EEG.automagic.TrimOutlier.message = m;
else
    % Save the clean data points.
    EEG.automagic.TrimOutlier.cleanDatapointMask = logical(ones(EEG.pnts,1));
    EEG.automagic.TrimOutlier.message = 'No datapoint rejected.';
    disp('No datapoint rejected.');
end

disp('trimOutlier done. The masks for clean data points are stored under EEG.automagic.TrimOutlier.')