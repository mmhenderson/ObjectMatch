% Generate Figure 3 (Mean signal in each ROI compared between
% match/nonmatch trials)

clear

% set this root to the main directory
% root='/usr/local/serenceslab/maggie/OM2/';
root = 'Z:\People\Maggie\OM2\';
addpath(genpath(root));

%% define subjects and flags for what to do


subj={'AI','AP','AV','BB','BC','BJ','BO','BR','BU','BW'};
% subj = subj([1:7,9:10]);
VOIs={'V1','V2','V3','V4','LO','pFus','V3AB','IPS0-1','IPS2-3','poCS','sPCS','iPCS','AI-FO','IFS'};

vorder2plot = [1:3,7,4:6,8:14];

nSubj=length(subj);
nVOIs=length(VOIs);

condStrs = {'attId','attOr'};
nCond= length(condStrs);

groupStrs = {'Match','Nonmatch'};
nGroups = length(groupStrs);

locstr='ObjectLoc';
locSignStr='posVoxOnly';

folder='OM2_anova';

%what kind of anova?
typestr = 'targetPredWithinCond';
titleStr = 'Target';

statstr = 'raw';
sigLevels = [0.05,0.01];

spacer=0.147;

plotT = 1;
plotMeans=1;

saveFig = 1;
figFolder='OM2_figs';
ext='epsc';


horspacer=0.147;
verspacerbig = 0.05;
verspacersmall = 0.01;
markersize = 3;

yrange = [0,3];

close all

%% loop over subs
nVoxTot = 0;
     
allT = zeros(nSubj,nVOIs,nCond);
allP = zeros(nSubj,nVOIs,nCond);

meanAct = zeros(nSubj,nVOIs,nCond,nGroups);

for ss=1:nSubj

    fn=sprintf('%s%s%s%s_meanSigROIs_%s_%s.mat',root,folder,filesep,subj{ss},typestr,statstr);
      
    load(fn);
   
    for vv=1:length(VOIs)
        
        for cc=1:nCond
        
            allT(ss,vv,cc) = vt(vv,cc).tstat;
            allP(ss,vv,cc) = vt(vv,cc).p;

            meanAct(ss,vv,cc,1) = vt(vv,cc).meanMatch;
            meanAct(ss,vv,cc,2) = vt(vv,cc).meanNonmatch;

            nVoxTot = nVoxTot + length(vt(vv,cc).tstat);
            
        end
               
    end
    
end
    
%% load the results of bootstrapped t-test between conds, do FDR correction

fntest=sprintf('%s%s%sAllsubs_%s_%s_meanSigROIsTTest.mat',root,folder,filesep,typestr,statstr);
load(fntest);

isSig_condDiff = zeros(nVOIs,nCond,length(sigLevels));

for cc=1:nCond

    for aa=1:length(sigLevels)
        alpha=sigLevels(aa);

        [p_fdr, p_masked] = fdr(pVals_allsub_condDiff(:,cc), alpha);
        isSig_condDiff(:,cc,aa) = p_masked;
    end

end

for cc=1:nCond



    %% plot the mean activation in each cond


    barMeans=squeeze(nanmean(squeeze(meanAct(:,:,cc,:)),1));

    if nSubj>1
        barErrs=squeeze(nanstd(squeeze(meanAct(:,:,cc,:)),[],1)./sqrt(nSubj));
    else
        barErrs=nan(size(barMeans));
    end

    fh = plot_barsAndStars(barMeans(vorder2plot,:),barErrs(vorder2plot,:),...
        [],squeeze(isSig_condDiff(vorder2plot,cc,:)),0,yrange,VOIs(vorder2plot),...
        groupStrs,'beta weight',['Mean beta weight: ', condStrs{cc}]);
   
end
