## Preprocessing

The preprocessing folder is a standalone folder which can be used independently from GUI. 

The main function is `preprocess.m`. You can run the preprocessing on a loaded EEGLab data structure as follows:
```Matlab
params = struct();
[EEG_out, plots] = preprocess(EEG_in, params);
```
In the example above, `EEG_in` is an EEGLab data strucutre on which the preprocessing is performed. The output `EEG_out` is the preprocessed EEG with additional fields (ie. `EEG_out.automagic`). 
`params` specifies the preprocessing parameters. If it's left empty `params = struct()` then the default values are taken from `DefaultParameters.n`. For more information on how to construct and modify parameters please see the comments section of `preprocess.m` or type `help preprocess.m`.

The preprocessing steps look as follows. The gray areas are not performed by deafult. 

![alt tag](https://github.com/methlabUZH/automagic/blob/master/automagic_resources/AutomagicWorkflow.jpg)

Below are some **Very Important** points about the steps above:
* Although each of the steps can be activated or deactivated, there can be only *RPCA* or *MARA ICA* at the same time. 
* In case of using **Artefact Subspace Reconstruction** (criterias *BurstCriterion* and *WindowCriterion* ) the cleaned EEG result will be high pass filtered with the corresponding paramters of `clean_rawdata()`. You have to take this into consideration because at a later step by default another high pass filtering may be applied on this same result. A smart choice would be to deactivate the high pass filtering of `performFilter.m` if **Artefact Subspace Reconstruction** is used. This can be done with GUI or simply with parameters: `FilterParams.high = struct([])`. Or you could also deactivate the high pass filter of `clean_rawdata()`: `CRDParams.Highpass='off'`. Please note that both *BurstCriterion* and *WindowCriterion* are by default `'off'` and you don't need to worry about this.
* **PREP** pipeline uses by default cleanline which can interfere if you also activate the notch filter of `performFilter.m`. Please keep this in mind.
* 
