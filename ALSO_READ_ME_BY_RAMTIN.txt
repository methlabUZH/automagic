The Automagic Toolbox included here is the "development" branch, which also includes ICLabel.


I found a couple of possible bugs, which I temporarily fixed myself, and reported in the Github issues (see https://github.com/methlabUZH/automagic/issues for details, my username on Github is "ramBrain"). Hence, until I'll receive the developer's feedback, my fixes remains "uncertified".

In addition, I included the possibility to choose interval thresholds for flagging artefactual components when performing ICLabel (the implementation on Automagic currently only allows to set a exclusion/inclusion > OR < threshold).

Briefly: CHANGES by RAMTIN MEHRARAM


- \preprocessing\performICLabel modified to consider interval thresholds

- \settingsGUI.m replace string to doubles for ICLabel inputs (around line 530)

- \preprocessing\performPrep line 67 added test for defining eog_chans as empty if no EOG channels is provided, and reference removal deleted everywhere, as    reference is already removed in preprocess.m

- \preprocessing\preprocess.m line 401 fixed index of bad channels following reference'

- \performCleanrawdata.m line 98 return the new cleaned EEG if ASR is used even if data is not rejected but only interpolated


For any clarification please contact me at: ramtin.mehraram@kuleuven.be