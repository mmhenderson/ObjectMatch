% Control Analysis, Figure 5 (Panels A and B)

%% define subjects and flags for what to do
clear

% change this to your main directory
% root = 'Z:\People\Maggie\OM2\';
root = '/mnt/neurocube/local/serenceslab/maggie/OM2_OSF/';
addpath(genpath(root));

% subj={'AI','AP','AV','BB','BC','BJ','BO','BR','BU','BW'};
% this order of subjects matches the full table of ROIs
subj = {'BR','BC','AI','AV','AP','BB','BO','BJ','BU','BW'};
sets = [2, 2, 1, 1, 1, 2, 2, 2, 1, 1];

% sets = [3,1,1,2,4,2,2,2,1,1];

% subj = subj(sets~=1 & sets~=3);


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

figFolder='OM2_figs';
ext='epsc';

close all

%% set up file info, other params

nIter=1000;
sigLevels=[0.05,0.01];
folder='OM2_classif_final';

fnsave=sprintf('%s%s%sAllsubs_bothTargetsWithinCond_noOrCatMatch_%s_%s_%s_FDRcorrectedAcrossAll.mat',root,folder,filesep,classstr,voxStr,statstr);

load(fnsave);
 %% plot dprime
 
 
for tt=1:nCond

   

    barMeans=nanmean(squeeze(realD(:,tt,:,:)),3);

    if nSubj>1
        barErrs=nanstd(squeeze(realD(:,tt,:,:)),[],3)./sqrt(nSubj);
    else
        barErrs=nan(size(barMeans));
    end

%     fh = plot_barsAndStars(barMeans(vorder2plot,:),barErrs(vorder2plot,:),...
%         squeeze(isSigD(vorder2plot,tt,:,:)),squeeze(isSig_dDiffRelevance(vorder2plot,tt,:)),0,[],VOIs(vorder2plot),...
%         legStrs,'dprime',[condStrs{tt} '- ' titlestr]);

  
    figure;
    hold all;
    
    h=bar(barMeans(vorder2plot,1), 'FaceColor','k','BarWidth',0.2)
    set(gca,'XTick',1:length(vorder2plot));
    set(gca,'XTickLabel', VOIs(vorder2plot),'XTickLabelRotation',90);
    errorbar(1:length(vorder2plot),barMeans(vorder2plot,1),barErrs(vorder2plot,1),'Marker','none',...
            'LineStyle','none','LineWidth',1,'Color',[0,0,0]);
    ylim([-1,2]);
    ylabel('dprime')
    ll={};
    
    ind1 = 0;
    ind2 = 0;
    cols = jet(2);
    for se = 1:2
       inds = sets==se;
       dat =  squeeze(realD(vorder2plot,tt,1,inds));
       xaxis = repmat(1:length(vorder2plot), 5,1)';
       h=[h,plot(xaxis(:),dat(:),'.','Color',cols(se,:),'MarkerSize',8)];
%         plot((1:length(vorder2plot))+0.147, realD(vorder2plot,tt,2,ss),'.','Color',cols(ss,:));
    end
    legend(h,[legStrs(1),{'Object Set A','Object Set B'}],'Location','EastOutside');
    
    saveas(gca,sprintf('Supplementary2_task%d.epsc',tt),ext)
end


