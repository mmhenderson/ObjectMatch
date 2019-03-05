% Generate Supplementary Figure 3 (Mean signal in each ROI, compared
% between tasks).

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

condStrs = {'attId','attOr'};
nCond= length(condStrs);

locstr='ObjectLoc';
locSignStr='posVoxOnly';

folder='OM2_anova';

%what kind of anova?
typestr = 'task';
titleStr = 'Task';

statstr = 'raw';
sigLevels = [0.01,0.01];

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
     
allT = zeros(nSubj,nVOIs);
allP = zeros(nSubj,nVOIs);

meanAct = zeros(nSubj,nVOIs,nCond);

for ss=1:nSubj
      
    fn=sprintf('%s%s%s%s_meanSigROIs_%s_%s.mat',root,folder,filesep,subj{ss},typestr,statstr);
      
    load(fn);
   
    for vv=1:length(VOIs)
        
        allT(ss,vv) = vt(vv).tstat;
        allP(ss,vv) = vt(vv).p;
                
        meanAct(ss,vv,1) = vt(vv).meanID;
        meanAct(ss,vv,2) = vt(vv).meanOR;
        
        nVoxTot = nVoxTot + length(vt(vv).tstat);
               
    end
    
end
    
%% load the results of bootstrapped t-test between conds

fntest=sprintf('%s%s%sAllsubs_%s_%s_meanSigROIsTTest.mat',root,folder,filesep,typestr,statstr);
load(fntest);

isSig_condDiff = zeros(nVOIs,2);

for aa=1:length(sigLevels)
    alpha=sigLevels(aa);

    [p_fdr, p_masked] = fdr(pVals_allsub_condDiff, alpha);
    isSig_condDiff(:,aa) = p_masked;
end



%% plot the mean activation in each cond

barMeans=squeeze(nanmean(squeeze(meanAct(:,:,:)),1));

if nSubj>1
    barErrs=squeeze(nanstd(squeeze(meanAct(:,:,:)),[],1)./sqrt(nSubj));
else
    barErrs=nan(size(barMeans));
end

fh = plot_barsAndStars(barMeans(vorder2plot,:),barErrs(vorder2plot,:),...
    [],isSig_condDiff(vorder2plot,:),0,yrange,VOIs(vorder2plot),...
    condStrs,'beta weight',['Mean beta weight']);
