% generate Figure 6 (target classification confidence on correct and
% incorrect trials, using both conditions)

clear

% change this to your main directory
root = 'Z:\People\Maggie\OM2\';
addpath(genpath(root));

%% define subjects and flags for what to do

subj={'AI','AP','AV','BB','BC','BJ','BO','BR','BU','BW'};
VOIs={'V1','V2','V3','V4','LO','pFus','V3AB','IPS0-1','IPS2-3','poCS','sPCS','iPCS','AI-FO','IFS'};

vorder2plot = [1:3,7,4:6,8:14];

nSubj=length(subj);
nVOIs=length(VOIs);

typestr='classify_target_bothCond_behavNormEuc';

statstr = 'TStat_subMean2';

voxStr = 'allVox';

close all;

%% set up file info, other params


folder='OM2_classif_final';

nCond=2;
figFolder='OM2_figs';
ext='epsc';

yrange = [-0.2,0.4];
%%

fntest=sprintf('%s%s%sAllsubs_%s_%s_%s_bothconds_compareCorrTTest.mat',root,folder,filesep,typestr,voxStr,statstr);
load(fntest);

%% plot the LL difference on correct and incorrect trials
 

legStrs = {'subj corr','subj incorr'};

barMeans=squeeze(nanmean(squeeze(meanEucdiffs(:,:,:)),2));

if nSubj>1
    barErrs=squeeze(nanstd(squeeze(meanEucdiffs(:,:,:)),[],2)./sqrt(nSubj));
else
    barErrs=nan(size(barMeans));
end

fh = plot_barsAndStars(barMeans(vorder2plot,:),barErrs(vorder2plot,:),...
    [],squeeze(isSigCorrDiff(vorder2plot,:)),0,yrange,VOIs(vorder2plot),...
    legStrs,'Classifier confidence',['Classifier confidence for the correct label: all trials']);
