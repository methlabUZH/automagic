## Preprocessing

The preprocessing folder is a standalone folder which can be used independently from GUI. 

The preprocessing steps look as follows. The gray areas are not performed by deafult. 

* **Very Important**: Note that although each of the steps can be activated or deactivated, there can be only *PCA* or *ICA* at the same time. Also please be aware that in case of using **Artefact Subspace Reconstruction** (criterias *BurstCriterion* and *WindowCriterion*) the cleaned EEG result will be high pass filtered with the corresponding paramters. You have to take this into consideration because at a later step by default another high pass filtering may be applied on this same result.

![alt tag](https://github.com/amirrezaw/automagic/blob/master/automagic_resources/AutomagicWorkflow.jpg)
