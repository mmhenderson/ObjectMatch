# ObjectMatch

This repository contains code pertaining to:<p>
Henderson, M.M. & Serences, J.T. (2019). Human frontoparietal cortex represents behaviorally-relevant target status based on abstract object features. <em>Journal of Neurophysiology.</em> <https://doi.org/10.1152/jn.00015.2019><p> Data and larger analysis files, as well as the novel object stimuli used in this experiment, are found at 
<https://osf.io/rzx5s/><p>
### Folders in this repository
+ Analyze_behavior
    + Analyze subject performance on all tasks.
+ Analyze_decoding
    +  Load saved classifier results from the folder OM2_classif_final, calculate mean and standard error of classifier performance in each area, and FDR correct all significance values, saving output which will be loaded by figure-generation scripts. 
    +  Also contains code to run repeated-measures ANOVA analyses. 
+ Analyze_images
    + Compute pixelwise similarity between pairs of images.
+ Analyze_univar
    + Compute mean signal in each ROI during match and nonmatch trials.
+ Figure_scripts 
    + Generate all figures and supplementary figures from the text.
+ OM2_behavior
    + All behavioral data collected during scan runs, in .mat format.
+ OM2_corrMat
    + Contains results (.mat files) of the analyses in Analyze_images, including pairwise similarity between all images viewed by each subject.
+ Run_decoding
    + Run all classifier analyses with real and shuffled data labels, saving output as .mat files.
+ Voxel_selection
    + Identify informative voxels for classifier analyses, using training set data only.
+ Note that many of these scripts will load .mat files that are the results of previous analysis stages. These files can all be found on OSF (see below). Alternatively, if you download just the data files from OSF (OM2_trialData), the scripts in Run_decoding and Analyze_decoding will re-generate and save all the other files.
  
### Folders in the OSF repository
- stimuli
    - Contains the complete novel object stimulus set. This includes 6 categories of objects, labeled as "a", "b", "c", "d", "e", "f". 
    - In the text, the categories a-c are refered to as stimulus set A, the categories d-f are referred to as stimulus set B.
    - Each category includes 36 exemplars (varying in peripheral feature shapes). In the experiment, each subject viewed only two exemplars in each category during scanning.
    - Each exemplar is rendered at 144 viewpoints (12 rotation steps about two different axes).
    - Each folder consists of images of a single exemplar at each viewpoint - for instance, folder "astim36_rot" contains the 144 images of exemplar 36 in category "a".
+ OM2_anova
    + Results (.mat files) of voxel selection procedures that are used to identify informative voxels, saved out by the scripts in Voxel_selection folder
    + Also contains the results of nonparametric t-tests comparing the univariate signal between conditions.
+ OM2_trialData
    + Data (.mat files) for each subject and ROI, consisting of a beta weight corresponding to each trial event [nTrials x nVoxels], as well as labels for the condition and image properties for each trial. 
    + Data for each subject is stored as a structure array, where each element of the array corresponds to one ROI. 
+ OM2_classif_final
    + Contains results of classifier analyses (.mat files), which are generated and saved the the scripts in Run_decoding, and used by the scripts in Analyze_decoding.

