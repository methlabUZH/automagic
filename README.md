# Automagic

<img src="https://github.com/methlabUZH/automagic/blob/master/automagic_resources/automagic.jpg" width="100">

## What is Automagic ?

**Automagic** is a MATLAB based toolbox for preprocessing of EEG-datasets. It has been developed with the intention to offer a user-friendly pre-processing software for big (and small) EEG datasets. The software can be controlled with a graphical user interface (GUI) and does not require any knowledge about programming. It runs on Matlab (R2016b and newer releases). Due to the fact that the applications is compiled of several matlab functions that are compatible with EEGLAB (Delorme & Makeig 2004), one of the most used opens-source frameworks for EEG analysis) more experienced users can extend Automagic to their specific needs.

To give a short orientation, Automagic contains three basic sections, the **project** section, the **configuration** section, and the **quality assessment** section. A typical workflow involves the following steps: In the **project** section, the user defines the input and output folders of the processing and information about the EEG data, such as the format, channel locations or electrooculogram (EOG)- channels. The **configuration** section allows to select various preprocessing steps with their settings that are applied to the EEG. After the preprocessing of the data and the interpolation of bad channels, the user can review the quality of the pre-processing in the **quality assessment** section. Here, EEG datasets can be displayed as heatmaps (with dimensions of channels and time) or classical EEG channel plots (using the eegplot function of EEGLAB), allowing the user to obtain a quick overview of the data quality. In addition, various quality criteria are computed such as the ratio of interpolated channels, remaining time windows of high voltage amplitudes  and percentage of retained variance after ICA artifact correction. The user can finally set cutoffs for these quality criteria to objectively include datasets of good quality and exclude datasets of too poor quality.

## 1. Setup

You need MATLAB installed and activated on your system to use **Automagic**. **Automagic** was developed and tested in MATLAB R2016b and newer releases.

1. Download and unzip **_automagic-master_** to your favorite place on your hard drive. 

## 2. Run automagic 
1. To run automagic, start Matlab and change your working directory to the root folder `automagic-master`. 
   * Please do **NOT** add **Automagic** to Matlab path manually. 
2. Type _runAutomagic_ in Matlab command window.

## 3. Manual
For a comprehensive explanation on how to start and use **Automagic** please see the [wiki](https://github.com/methlabUZH/automagic/wiki) page.

## Further information and user manual
Further information about **Automagic**, a user manual and some example datasets can be found:
https://www.psychologie.uzh.ch/de/bereiche/nec/plafor/automagic.html

## Contact us
You can find us [here](http://www.psychologie.uzh.ch/de/fachrichtungen/plafor.html).
If you have any questions, feedbacks please email us at amirreza [dot] bahreini [at] uzh [dot] ch
