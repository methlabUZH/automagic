function [EEG_out, EOG_out] = performPrep(EEG_in, EOG_in, prepParams, refChan)
% performPrep  applies the prep robust average referenceing and its channel
% rejection on the input EEG
%   This function applies the prep on EEG and keeps the rejected channels 
%   for later removal. Note that the output EEG is NOT  average referenced.
%   Bad channel rejection is done only on EEG and not EOG. EOG is only used 
%   for calculations.
%   
%   [EEG_out, EOG_out] = performPrep(EEG_in, EOG_in, prepParams, refChan)
%
%   EEG_in is the input EEG structure.
%
%   EOG_in is the input EOG structure.
%
%   prepPrams is the parameters as they are required by PREP library. A
%   simple way of using this is to give prepPrams = struct() where the
%   default values will be used.
%
%   refChan indicates the index of the reference channel in the EEG input.
%
%   If params is ommited default values are used. If any field of params
%   are ommited, corresponding default values are used. If params is empty:
%   params= struct([]), prep is deactivated and is skipped.
%
%   Default values are specified by PREP library.
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


EEG_out = EEG_in;
EOG_out = EOG_in;
EEG_out.automagic.prep.performed = 'no';
if isempty(prepParams)
    return; end

toRemove = EEG_in.automagic.preprocessing.toRemove;
removedMask = EEG_in.automagic.preprocessing.removedMask;
[s, ~] = size(EEG_in.data);
badChansMask = false(1, s); clear s;
if ~isempty(refChan)
    refChan = refChan.idx;
else
    refChan = [];
end

fprintf(sprintf('Running Prep...\n'));
% Remove the refChan containing zeros from prep preprocessing
eeg_chans = setdiff(1:EEG_in.nbchan, refChan);
eog_chans = setdiff(1: EEG_in.nbchan + EOG_in.nbchan, eeg_chans); %#ok<NASGU>
if isfield(prepParams, 'referenceChannels')
    prepParams.referenceChannels =  ...
        setdiff(prepParams.referenceChannels, refChan);
else
    prepParams.referenceChannels = eeg_chans;
end

if isfield(prepParams, 'evaluationChannels')
    prepParams.evaluationChannels =  ...
        setdiff(prepParams.evaluationChannels, refChan);
else
    prepParams.evaluationChannels = eeg_chans;
end

if isfield(prepParams, 'rereference')
    prepParams.rereference =  ...
        setdiff(prepParams.rereference, refChan);
else
    prepParams.rereference = eeg_chans;
end

if isfield(prepParams, 'lineFrequencies')
    if length(prepParams.lineFrequencies) == 1
        freq = prepParams.lineFrequencies(1);
        prepParams.lineFrequencies = freq:freq:((EEG_in.srate/2)-1);
    end
end

if isfield(prepParams, 'discardNotch')
    discardNotch = prepParams.discardNotch;
else
    discardNotch = 0;
end


% Combine both EEG and EOG for the analysis
new_EEG = EEG_in;
if not(isempty(EOG_in.data))
    new_EEG.data = cat(1, EEG_in.data, EOG_in.data);
    new_EEG.chanlocs = [EEG_in.chanlocs, EOG_in.chanlocs];
    new_EEG.nbchan = EEG_in.nbchan + EOG_in.nbchan;
end
[new_EEG, ~, ~] = prepPipeline(new_EEG, prepParams);


userData = struct('boundary', [], 'detrend', [], ...
    'lineNoise', [], 'reference', [], ...
    'report', [],  'postProcess', []);
stepNames = fieldnames(userData);
for k = 1:length(stepNames)
    defaults = getPrepDefaults(new_EEG, stepNames{k});
    [theseValues, errors] = checkDefaults(prepParams, prepParams, defaults);
    if ~isempty(errors)
        popup_msg(['Wrong parameters for prep: ', ...
            sprintf('%s', errors{:})], 'Error');
        return;
    end
    userData.(stepNames{k}) = theseValues;
end


% Separate EEG from EOG
[~, EEG_out] = evalc('pop_select( new_EEG , ''channel'', eeg_chans)');
[~, EOG_out] = evalc('pop_select( new_EEG , ''channel'', eog_chans)');

%get data back if no notch filter is wanted
if discardNotch
    EEG_out.data=EEG_in.data;
end

info = new_EEG.etc.noiseDetection;
% Cancel the interpolation and referecing of prep (only if data isnt
% restored above anyway)
if isfield(info.reference, 'referenceSignal') & ~discardNotch
    EEG_out.data = bsxfun(@plus, EEG_out.data, info.reference.referenceSignal);
end

% Get list of channels to be removed/interpolated later
badChans = union(union(info.stillNoisyChannelNumbers, ...
                          info.interpolatedChannelNumbers), ...
                          info.removedChannelNumbers);

% Integrate the bad channel indices to the entire pipeline bad channels
badChansMask(badChans) = true;
newMask = removedMask;
oldMask = removedMask;
newMask(~newMask) = badChansMask;
badChans = setdiff(find(newMask), find(oldMask));

% Add the info to the output structure
EEG_out.automagic.prep.performed = 'yes';
if isfield(prepParams, 'lineFrequencies')
    EEG_out.automagic.prep.lineFrequencies = prepParams.lineFrequencies;
end
EEG_out.automagic.prep.badChans = badChans;
EEG_out.automagic.prep.params = userData;

% .preprocessing field is used for internal purposes and will be removed at
% the end of the preprocessing
EEG_out.automagic.preprocessing.toRemove = union(badChans, toRemove);