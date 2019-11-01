% pop_clean_rawdata(): Launches GUI to collect user inputs for clean_artifacts().
%                      ASR stands for artifact subspace reconstruction.
%                      To disable method(s), enter -1.
% Usage:
%   >>  EEG = pop_clean_rawdata(EEG);
%
% ------------------ below is from clean_artifacts (modified)-----------------------
%
% This function removes flatline channels, low-frequency drifts, noisy channels, short-time bursts
% and incompletely repaird segments from the data. Tip: Any of the core parameters can also be
% passed in as [] to use the respective default of the underlying functions, or as 'off' to disable
% it entirely.
%
% Hopefully parameter tuning should be the exception when using this function -- however, there are
% 3 parameters governing how aggressively bad channels, bursts, and irrecoverable time windows are
% being removed, plus several detail parameters that only need tuning under special circumstances.
%
%   FlatChannel:       Maximum tolerated flatline duration. In seconds. If a channel has a longer
%                      flatline than this, it will be considered abnormal. Default: 5
%
%   Highpass :         Transition band for the initial high-pass filter in Hz. This is formatted as
%                      [transition-start, transition-end]. Default: [0.25 0.75].
%
%   PoorCorrelationChannel : Correlation threshold. If a channel is correlated at less than this value
%                            to its robust estimate (based on other channels), it is considered abnormal in
%                            the given time window. Default: 0.8.
%
%   LineNoiseChannel:  If a channel has more line noise relative to its signal than this value, in
%                      standard deviations from the channel population mean, it is considered abnormal.
%                      Default: 4.
%
%   BurstCriterion : Standard deviation cutoff for removal of bursts (via ASR). Data portions whose
%                    variance is larger than this threshold relative to the calibration data are
%                    considered missing data and will be removed. The most aggressive value that can
%                    be used without losing much EEG is 3. For new users it is recommended to at
%                    first visually inspect the difference between the original and cleaned data to
%                    get a sense of the removed content at various levels. A quite conservative
%                    value is 5. Default: 5.
%
%   WindowCriterion :  Criterion for removing time windows that were not repaired completely. This may
%                      happen if the artifact in a window was composed of too many simultaneous
%                      uncorrelated sources (for example, extreme movements such as jumps). This is
%                      the maximum fraction of contaminated channels that are tolerated in the final
%                      output data for each considered window. Generally a lower value makes the
%                      criterion more aggressive. Default: 0.5. Reasonable range: 0.05 (very
%                      aggressive) to 0.3 (very lax).
%
% see also: clean_artifacts

% Author: Makoto Miyakoshi and Christian Kothe, SCCN,INC,UCSD
% History:
% 04/26/2017 Makoto. Deletes existing EEG.etc.clean_channel/sample_mask. Try-catch to skip potential error in vis_artifact.
% 07/18/2014 ver 1.4 by Makoto and Christian. New channel removal method supported. str2num -> str2num due to str2num([a b]) == NaN.
% 11/08/2013 ver 1.3 by Makoto. Menu words changed. asr_process() line 168 bug fixed. 
% 10/07/2013 ver 1.2 by Makoto. Help implemented. History bug fixed.
% 07/16/2013 ver 1.1 by Makoto and Christian. Minor update for help and default values.
% 06/26/2013 ver 1.0 by Makoto. Created.

% Copyright (C) 2013, Makoto Miyakoshi and Christian Kothe, SCCN,INC,UCSD
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

function EEG = pop_clean_rawdata(EEG)

% Obtain user inputs.
userInput = inputgui('title', 'pop_clean_rawdata()', 'geom', ...
   {{2 7 [0 0] [1 1]}   {2 7 [1 0] [1 1]} ...
    {2 7 [0 1] [1 1]}   {2 7 [1 1] [1 1]} ...
    {2 7 [0 2] [1 1]}   {2 7 [1 2] [1 1]} ...
    {2 7 [0 3] [1 1]}   {2 7 [1 3] [1 1]} ...
    {2 7 [0 4] [1 1]}   {2 7 [1 4] [1 1]} ...
    {2 7 [0 5] [1 1]}   {2 7 [1 5] [1 1]} ...
    {2 7 [0 6] [1 1]}   {2 7 [1 6] [1 1]} ... 
    {6 7 [0 9] [1 1]}},...
'uilist',...
   {{'style' 'text' 'string' 'Remove channel if flat more than [sec|-1->off]'} {'style' 'edit' 'string' '5','tooltipstring', wordwrap('If a channel has a longer flatline than this, it will be removed. In seconds.',80)} ...
    {'style' 'text' 'string' 'High-pass filt tran band width [F1 F2|-1->off]'} {'style' 'edit' 'string' '0.25 0.75','tooltipstring', wordwrap('The first number is the frequency below which everything is removed, and the second number is the frequency above which everything is retained. There is a linear transition in between. For best performance of subsequent processing steps the upper frequency should be close to 1 or 2 Hz, but you can go lower if certain activities need to be retained.',80)} ...
    {'style' 'text' 'string' 'Remove poorly correlated channels [0-1|-1->off]'}   {'style' 'edit' 'string' '0.8', 'tooltipstring', wordwrap('If a channel has lower correlation than this to an estimate of its activity based on other channels, and this applies to more than half of the recording, the channel will be removed. This method requires that channel locations are available and roughly correct; otherwise a fallback criterion will tried used using a default setting; you can customize the fallback method by directly calling clean_channels_nolocs in the command line.',80)} ...
    {'style' 'text' 'string' 'Remove line-noisy channels [std|-1->off]'}   {'style' 'edit' 'string' '4', 'tooltipstring', wordwrap('If a channel has more line noise relative to its signal than this value, in standard deviations relative to the overall channel population, it will be removed.',80)} ...
    {'style' 'text' 'string' 'Repair bursts using ASR [std|-1->off]'}  {'style' 'edit' 'string' '5','tooltipstring', wordwrap('Standard deviation cutoff for removal of bursts. Data portions whose variance is larger than this threshold relative to the calibration data are considered missing data and will be removed. The most aggressive value that can be used without losing much EEG is 3. A reasonably conservative value is 5, but some extreme EEG bursts (e.g., sleep spindles) can cross even 5. For new users it is recommended to at first visually inspect the difference between the original and cleaned data to get a sense of the removed content at various levels.',80)} ...
    {'style' 'text' 'string' 'Remove time windows [0-1|''off'']'}   {'style' 'edit' 'string' '0.5','tooltipstring', wordwrap('If a time window has a larger fraction of simultaneously corrupted channels than this (after the other cleaning attempts), it will be cut out of the data. This can happen if a time window was corrupted beyond the point where it could be recovered.',80)} ...
    {'style' 'text' 'string' 'Show results for comparison? (beta version)'}    {'style' 'popupmenu' 'string' 'Yes|No'}...
    {'style', 'pushbutton', 'string', 'Help', 'callback', 'pophelp(''pop_clean_rawdata'');'}});

% Return error if no input.
if isempty(userInput)
    error('Operation terminated by user.')
end

% Convert user inputs into numerical variables.
arg_flatline = str2num(userInput{1,1}); %#ok<*ST2NM>
arg_highpass = str2num(userInput{1,2});
arg_channel  = str2num(userInput{1,3});
arg_noisy    = str2num(userInput{1,4});
arg_burst    = str2num(userInput{1,5});
arg_window   = str2num(userInput{1,6});
arg_visartfc = userInput{1,7};

% Delete EEG.etc.clean_channel_mask and EEG.etc.clean_sample_mask if present.
if isfield(EEG.etc, 'clean_channel_mask')
    EEG.etc = rmfield(EEG.etc, 'clean_channel_mask');
    disp('EEG.etc.clean_channel_mask present: Deleted.')
end
if isfield(EEG.etc, 'clean_sample_mask')
    EEG.etc = rmfield(EEG.etc, 'clean_sample_mask');
    disp('EEG.etc.clean_sample_mask present: Deleted.')
end

% Perform Christian's functions.
cleanEEG = clean_rawdata(EEG, arg_flatline, arg_highpass, arg_channel, arg_noisy, arg_burst, arg_window);

% Perform Christian's before and after comparison visualization.
if arg_visartfc == 1;
    try
        vis_artifacts(cleanEEG,EEG);
    catch
        warning('vis_artifacts failed. Skipping visualization.')
    end
end

% Update EEG.
EEG = cleanEEG;

% Output eegh.
com = sprintf('EEG = clean_rawdata(EEG, %s, [%s], %s, %s, %s, %s);', userInput{1,1}, userInput{1,2}, userInput{1,3}, userInput{1,4}, userInput{1,5}, userInput{1,6});
EEG = eegh(com, EEG);

% Display the ending message.
disp('Done.')



function outtext = wordwrap(intext,nChars)
outtext = '';    
while ~isempty(intext)
    if length(intext) > nChars
        cutoff = nChars+find([intext(nChars:end) ' ']==' ',1)-1;
        outtext = [outtext intext(1:cutoff-1) '\n']; %#ok<*AGROW>
        intext = intext(cutoff+1:end);
    else 
        outtext = [outtext intext];
        intext = '';
    end
end
outtext = sprintf(outtext);
