# ObjectMatch

This repository contains all code necessary to reproduce the analyses reported in the article "Human frontoparietal cortex represents behaviorally-relevant target status based on abstract object features" (2019), Journal of Neurophysiology.\
Folder structure:
+ OM2_trialData - contains data for each subject and ROI, consisting of a beta weight corresponding to each trial event [nTrials x nVoxels], as well as labels the condition and image properties for each trial. Data for each subject is stored as a structure array, where each element of the array corresponds to one ROI. 
+ OM2_behavior - contains all behavioral data collected during each scan run, in .mat format
+ Analyze_behavior - all code needed to analyze subject performance on all tasks
+ Run_decoding - all scripts needed to run the classifier analysis with real and shuffled data labels, saving output as .mat files
+ Voxel_selection - code to identify informative voxels for classifier analyses
+ OM2_classif_final - saved results of classifier analyses (.mat files), which are loaded by other scripts to perform additional analyses. These files are not uploaded here in order to save space - the files can be generated and saved using the scripts found in Run_decoding.
+ Analyze_decoding - load saved classifier results, calculate mean and standard error of classifier performance in each area, and FDR correct all significance values, saving output which will be loaded by figure-generation scripts. Also contains code to run repeated-measures ANOVA analyses. 
+ OM2_anova - contains the results of voxel selection procedures that are used to identify informative voxels, saved out by the scripts in Voxel_selection folder. Also contains the results of nonparametric t-tests comparing the univariate signal between conditions.
+ Analyze_univar - compute mean signal in each ROI, compare signal between match and nonmatch trials.
