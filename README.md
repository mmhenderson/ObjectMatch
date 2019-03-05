# ObjectMatch

This repository contains all code necessary to reproduce the analyses reported in the article "Human frontoparietal cortex represents behaviorally-relevant target status based on abstract object features" (2019), Journal of Neurophysiology.\
Folder structure:
+ Analyze_behavior - contains code needed to analyze subject performance on all tasks.
+ Analyze_decoding - contains code to load saved classifier results from the folder OM2_classif_final, calculate mean and standard error of classifier performance in each area, and FDR correct all significance values, saving output which will be loaded by figure-generation scripts. Also contains code to run repeated-measures ANOVA analyses. Note that some of this code won't run immediately since it will look for files that haven't been uploaded here due to space constraints. The scripts in Run_decoding will re-generate and save all the necessary files.
+ Analyze_images - compute pixelwise similarity between pairs of images.
+ Analyze_univar - compute mean signal in each ROI during match and nonmatch trials.
+ Figure_scripts - generate all figures and supplementary figures from the text.
+ OM2_anova - contains the results (.mat files) of voxel selection procedures that are used to identify informative voxels, saved out by the scripts in Voxel_selection folder. Also contains the results of nonparametric t-tests comparing the univariate signal between conditions.
+ OM2_behavior - contains all behavioral data collected during each scan run, in .mat format
+ OM2_classif_final - contains results of classifier analyses (.mat files), which are loaded by other scripts to perform additional analyses. In order to save space, not all classifier results are uploaded here. All files can be re-generated and saved using the scripts found in Run_decoding. 
+ OM2_corrMat - contains results (.mat files) of the analyses in Analyze_images, including pairwise similarity between all images viewed by each subject.
+ OM2_trialData - contains data (.mat files) for each subject and ROI, consisting of a beta weight corresponding to each trial event [nTrials x nVoxels], as well as labels for the condition and image properties for each trial. Data for each subject is stored as a structure array, where each element of the array corresponds to one ROI. 
+ Run_decoding - all scripts needed to run the classifier analysis with real and shuffled data labels, saving output as .mat files.
+ Voxel_selection - code to identify informative voxels for classifier analyses, making sure to use training set data only.





