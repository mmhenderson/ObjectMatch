# ObjectMatch

This repository contains all code necessary to reproduce the analyses reported in the article "Human frontoparietal cortex represents behaviorally-relevant target status based on abstract object features" (2019), Journal of Neurophysiology.\
Folder structure:
+ OM2_trialData - contains data for each subject and ROI, consisting of a beta weight corresponding to each trial event [nTrials x nVoxels], as well as labels for each trial. Data for each subject is stored as a structure array, where each element of the array corresponds to one ROI. 
+ OM2_behavior - contains all behavioral data collected during each scan run, in .mat format
+ Analyze_behavior - all code needed to analyze subject performance on all tasks
+ Run_decoding - all scripts needed to run the classifier analysis with real and shuffled data labels, saving output as .mat files
+ Voxel_selection - code to identify informative voxels for classifier analyses
+ OM2_classif_final - saved results of classifier analyses (.mat files), which are loaded by other scripts to perform additional analyses
+ Analyze_decoding - code to load saved classifier results, process into a tabular format
+ 
