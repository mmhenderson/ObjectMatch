%  Create Supplementary Figure 6 (Same analysis as Figure 6, but performed
%  within each condition separately)

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

typestr = 'classify_target_withinCond_behavNormEuc';

statstr = 'TStat_subMean2';

voxStr = 'allVox';

yrange = [-0.2,.4];

close all;

%% set up file info, other params

folder='OM2_classif_final';

nCond=2;

%%

fntest=sprintf('%s%s%sAllsubs_%s_%s_%s_sepconds_compareCorrTTest.mat',root,folder,filesep,typestr,voxStr,statstr);
load(fntest);

%%
    
condStrs = {'AttID','AttOR'};

legStrs = {'sub corr','sub incorr'};

for tt=1:2
    
    barMeans=squeeze(nanmean(squeeze(meanEucdiffs(:,:,tt,:)),2));

    if nSubj>1
        barErrs=squeeze(nanstd(squeeze(meanEucdiffs(:,:,tt,:)),[],2)./sqrt(nSubj));
    else
        barErrs=nan(size(barMeans));
    end

    fh = plot_barsAndStars(barMeans(vorder2plot,:),barErrs(vorder2plot,:),...
        [],squeeze(isSigCorrDiff(vorder2plot,tt,:)),0,yrange,VOIs(vorder2plot),...
        legStrs,'Classifier confidence (Euclidean dist)',['Classifier confidence for the correct label: ' condStrs{tt} ', all trials']);

end
