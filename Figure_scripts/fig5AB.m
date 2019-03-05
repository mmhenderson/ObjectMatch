% Control Analysis, Figure 5 (Panels A and B)

%% define subjects and flags for what to do
clear

% change this to your main directory
root = 'Z:\People\Maggie\OM2\';
addpath(genpath(root));

subj={'AI','AP','AV','BB','BC','BJ','BO','BR','BU','BW'};

VOIs={'V1','V2','V3','V4','LO','pFus','V3AB','IPS0-1','IPS2-3','poCS','sPCS','iPCS','AI-FO','IFS'};

vorder2plot = [1:3,7,4:6,8:14];

nSubj=length(subj);
nVOIs=length(VOIs);
titlestr='Decode each type of target';

classstr = 'normEucDist';

condStrs = {'AttendID','AttendOR'};

legStrs ={'Relevant','Irrelevant'};
nCond= length(condStrs);

statstr = 'TStat_subMean2';
voxStr = 'allVox';

chanceVal=1/2;
accrange = [0,1];

drange=[-.5,1.5];

close all

%% set up file info, other params

nIter=1000;
sigLevels=[0.05,0.01];
folder='OM2_classif_final';

fnsave=sprintf('%s%s%sAllsubs_bothTargetsWithinCond_noOrCatMatch_%s_%s_%s_FDRcorrectedAcrossAll.mat',root,folder,filesep,classstr,voxStr,statstr);

load(fnsave);

for tt=1:nCond

    %% plot dprime

    barMeans=nanmean(squeeze(realD(:,tt,:,:)),3);

    if nSubj>1
        barErrs=nanstd(squeeze(realD(:,tt,:,:)),[],3)./sqrt(nSubj);
    else
        barErrs=nan(size(barMeans));
    end

    fh = plot_barsAndStars(barMeans(vorder2plot,:),barErrs(vorder2plot,:),...
        squeeze(isSigD(vorder2plot,tt,:,:)),squeeze(isSig_dDiffRelevance(vorder2plot,tt,:)),0,drange,VOIs(vorder2plot),...
        legStrs,'dprime',[condStrs{tt} '- ' titlestr]);

end


