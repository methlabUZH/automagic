## Preprocessing

The preprocessing folder is a [standalone folder which can be used independently from GUI](https://github.com/methlabUZH/automagic/wiki/Standalone-preprocessing-code). 

The main function is `preprocess.m`. You can run the preprocessing on a loaded EEGLab data structure as follows:
```Matlab
params = struct();
[EEG_out, plots] = preprocess(EEG_in, params);
```
In the example above, `EEG_in` is an EEGLab data strucutre on which the preprocessing is performed. The output `EEG_out` is the preprocessed EEG with additional fields (ie. `EEG_out.automagic`). 
`params` specifies the preprocessing parameters. If it's left empty `params = struct()` then the default values are taken from `DefaultParameters.n`. For more information on how to construct and modify parameters please see the comments section of `preprocess.m` or type `help preprocess.m`.
