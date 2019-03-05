% analyze the results of decoding within each VOI: compute mean accuracy and
% significance at subject level, FDR correct the p-vals across all
% conditions

clear

% set this to main directory
root = 'Z:\People\Maggie\OM2\';
addpath(genpath(root));

%% define subjects and flags for what to do

rndseed = 256904;
rng(rndseed);

subj={'AI','AP','AV','BB','BC','BJ','BO','BR','BU','BW'};
VOIs={'V1','V2','V3','V4','LO','pFus','V3AB','IPS0-1','IPS2-3','poCS','sPCS','iPCS','AI-FO','IFS'};

vorder2plot = [1:3,7,4:6,8:14];

nSubj=length(subj);
nVOIs=length(VOIs);

typestr1='classify_target_withinCond';
typestr2='classify_targetIrrelevant_withinCond';

titlestr='Decode each type of target';

classstr = 'normEucDist';

condStrs = {'Attend ID','Attend OR'};

legStrs ={'Relevant','Irrelevant'};
nCond= length(condStrs);

% 2 levels of relevance (relevant or irrelevant)
nRel=2;

statstr = 'TStat_subMean2';
voxStr = 'allVox';

% voxStr = 'fixVoxNum_50';

chanceVal=1/2;
accrange = [0,1];

drange=[-.5,1.5];

%% set up file info, other params

nIter=1000;
sigLevels=[0.05,0.01];
folder='OM2_classif_final';

% arrays to store acc and d' for correct, incorrect, and pooled
realAccs=nan(nVOIs,nCond,nRel,nSubj);
nullAccs=nan(nVOIs,nCond,nRel,nSubj,nIter);
realD=nan(nVOIs,nCond,nRel,nSubj);
nullD=nan(nVOIs,nCond,nRel,nSubj,nIter);

%% loop over subs
for ss=1:nSubj   
        

        fnsreal1=sprintf('%s%s%s%s_%s_%s_%s_%s.mat',root,folder,filesep,subj{ss},typestr1,classstr,statstr,voxStr);
        fnsrand1=sprintf('%s%s%s%s_%s_%s_%s_%s_Rand.mat',root,folder,filesep,subj{ss},typestr1,classstr,statstr,voxStr);

        load(fnsreal1);
        load(fnsrand1,'allaccs_shuffDataLabs','allD_shuffDataLabs');


        realAccs(:,:,1,ss) = allaccs;
        nullAccs(:,:,1,ss,1:size(allaccs_shuffDataLabs,3)) = allaccs_shuffDataLabs;

        realD(:,:,1,ss) = allD;
        nullD(:,:,1,ss,1:size(allD_shuffDataLabs,3)) = allD_shuffDataLabs;
 
        
        fnsreal2=sprintf('%s%s%s%s_%s_%s_%s_%s.mat',root,folder,filesep,subj{ss},typestr2,classstr,statstr,voxStr);
        fnsrand2=sprintf('%s%s%s%s_%s_%s_%s_%s_Rand.mat',root,folder,filesep,subj{ss},typestr2,classstr,statstr,voxStr);

        load(fnsreal2);
        load(fnsrand2,'allaccs_shuffDataLabs','allD_shuffDataLabs');


        realAccs(:,:,2,ss) = allaccs;
        nullAccs(:,:,2,ss,1:size(allaccs_shuffDataLabs,3)) = allaccs_shuffDataLabs;

        realD(:,:,2,ss) = allD;
        nullD(:,:,2,ss,1:size(allD_shuffDataLabs,3)) = allD_shuffDataLabs;
 
        
end

%% now do t-tests to compare the means of bars

% first compare the difference between relevant and irrelevant match,
% within each condition separately

pVals_accDiffRelevance = zeros(nVOIs,nCond);
pVals_dDiffRelevance = zeros(nVOIs,nCond);

% now compare the difference between each condition, for relevant and
% irrelevant separately

pVals_accDiffCondition = zeros(nVOIs,nRel);
pVals_dDiffCondition = zeros(nVOIs,nRel);

for ii=1:2

    % call a function that uses a randomized permutation test
    [pVals_accDiffRelevance(:,ii),~,~] = getSigDiff_ttest(squeeze(realAccs(:,ii,:,:)),nIter,chanceVal,sigLevels);
    [pVals_dDiffRelevance(:,ii),~,~] = getSigDiff_ttest(squeeze(realD(:,ii,:,:)),nIter,0,sigLevels);
    
    % careful with the indexes
    [pVals_accDiffCondition(:,ii),~] = getSigDiff_ttest(squeeze(realAccs(:,:,ii,:)),nIter,chanceVal,sigLevels);
    [pVals_dDiffCondition(:,ii),~,~] = getSigDiff_ttest(squeeze(realD(:,:,ii,:)),nIter,0,sigLevels);
    
end

%% now FDR correct everything (across all conditions and relevance dims)
isSig_accDiffRelevance = zeros([size(pVals_accDiffRelevance),length(sigLevels)]);
isSig_accDiffCondition = zeros([size(pVals_accDiffCondition),length(sigLevels)]);

isSig_dDiffRelevance = zeros([size(pVals_accDiffRelevance),length(sigLevels)]);
isSig_dDiffCondition = zeros([size(pVals_accDiffCondition),length(sigLevels)]);

for aa=1:length(sigLevels)
    
    
    [~,isSig_accDiffRelevance(:,:,aa)] = fdr(pVals_accDiffRelevance,sigLevels(aa));
    [~,isSig_accDiffCondition(:,:,aa)] = fdr(pVals_accDiffCondition,sigLevels(aa));
    
    [~,isSig_dDiffRelevance(:,:,aa)] = fdr(pVals_dDiffRelevance,sigLevels(aa));
    [~,isSig_dDiffCondition(:,:,aa)] = fdr(pVals_dDiffCondition,sigLevels(aa));
    
    
end

%% FDR correct individual significance values

isSigAcc = zeros(nVOIs,2,2,2);
isSigD = zeros(nVOIs,2,2,2);

for ii=1:2
    for jj=1:2

        [~,isSigAcc(:,ii,jj,:)] = getSig_fdr(squeeze(realAccs(:,ii,jj,:)),squeeze(nullAccs(:,ii,jj,:,:)),chanceVal,sigLevels);
        [~,isSigD(:,ii,jj,:)] = getSig_fdr(squeeze(realD(:,ii,jj,:)),squeeze(nullD(:,ii,jj,:,:)),0,sigLevels);

   end
end
%% save the results
fnsave=sprintf('%s%s%sAllsubs_bothTargetsWithinCond_%s_%s_%s_FDRcorrectedAcrossAll.mat',root,folder,filesep,classstr,voxStr,statstr);
        
save(fnsave,'isSigAcc','isSigD','isSig_accDiffRelevance','isSig_accDiffCondition',...
    'isSig_dDiffRelevance','isSig_dDiffCondition','realAccs','realD');

fprintf('saving to %s\n',fnsave);