%% This script starts automagic and unzips required libraries

% unzip EEGLAB once
eeglabdir = dir('./matlab_scripts/eeglab13_6_5b/');
if isempty(eeglabdir)
    unzip('./matlab_scripts/eeglab13_6_5b.zip','./matlab_scripts/');
end

% Unzip inexact ALM once
eeglabdir = dir('./matlab_scripts/inexact_alm_rpca/');
if isempty(eeglabdir)
    unzip('./matlab_scripts/inexact_alm_rpca.zip','./matlab_scripts/');
end

addpath(genpath('.'))
mainGUI

