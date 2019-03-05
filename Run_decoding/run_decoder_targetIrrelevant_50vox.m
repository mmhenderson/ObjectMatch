% Run decoding analysis for target status - focusing on the IRRELEVANT
% target (ID during Viewpoint task, and VIEW during Identity task)
% Using 50 voxels per ROI.

clear

rndseed = 878754;
rng(rndseed);

% change this to home directory
root = 'Z:\People\Maggie\OM2\';
addpath(genpath(root));

%% define subjects and flags for what to do

nShuffIter = 1000;
% nBalanceIter1 is for the real classifiation, nBalanceIter2 is for the
% permutation test.
nBalanceIter1 = 1000;
% we'll use fewer iterations of balancing for the shuffled data just to
% speed the process up.
nBalanceIter2 = 100;

nVox2Use = 50;

if isempty(nVox2Use)
    voxStr = 'allVox';
else
    voxStr = sprintf('fixVoxNum_%.0f',nVox2Use);
end

VOIs={'V1','V2','V3','V4','LO','pFus','V3AB','IPS0-1','IPS2-3','poCS','sPCS','iPCS','AI-FO','IFS'};
subj = {'AI','AP','AV','BB','BC','BJ','BO','BR','BU','BW'};

nSubj=length(subj);
nVOIs=length(VOIs);

typestr = 'classify_targetIrrelevant_withinCond';
classstr = 'normEucDist';

statstr = 'TStat_subMean2';

anovafolder = 'OM2_anova';
anovatypestr = 'matchTargIrrel_crossval';

resamp = 1;

%% set up file info, other params
condStrs = {'attId','attOr'};
nCond= length(condStrs);

locstr='ObjectLoc';
locSignStr='posVoxOnly';

folder='OM2_classif_final';

%% loop over subs
for ss=1:nSubj
      
    anovafn=sprintf('%s%s%s%s_anova2_%s_%s.mat',root,anovafolder,filesep,subj{ss},anovatypestr,statstr);
    load(anovafn) 
    
    fnsreal=sprintf('%s%s%s%s_%s_%s_%s_%s.mat',root,folder,filesep,subj{ss},typestr,classstr,statstr,voxStr);
    fnsrand=sprintf('%s%s%s%s_%s_%s_%s_%s_Rand.mat',root,folder,filesep,subj{ss},typestr,classstr,statstr,voxStr);
         
    %leaving out one or at a time, nComp pairwise comparisons of cats
    allaccs=nan(nVOIs,nCond);  
    allD = nan(nVOIs,nCond);
   
    allaccs_shuffDataLabs=nan(nVOIs,nCond,nShuffIter);   
    allD_shuffDataLabs = nan(nVOIs,nCond,nShuffIter);
            
    trialDataAll_fn = sprintf('%sOM2_trialData/%s_%s_%s', root,subj{ss},locstr,locSignStr);
    load(trialDataAll_fn);

    for vv=1:length(VOIs)
        
        if size(trialData(vv).betasTBT,2)==0
            % if there is no data - leave the fields as NaN (should only be
            % for BR-sPCS)
            continue
        end
        
        pTable = an(vv).p;
                
        for cc=1:nCond
        
            fprintf('processing subj %s, area %s, %s\n',subj{ss},VOIs{vv},condStrs{cc})
            
            %% look at data for this sub, VOI, cond
            % remove the first trials from every run
            
            correctinds = trialData(vv).predlabelsTBT(:,9);
            firstinds = trialData(vv).predlabelsTBT(:,7); 
            
%             orCatMatch = trialData(vv).predlabelsTBT(:,4)==1 & trialData(vv).predlabelsTBT(:,6)==1;
                        
            thistask = trialData(vv).tasklabelsTBT==cc;

            indsuse = correctinds & ~firstinds & thistask;

            dat=trialData(vv).betasTBT(indsuse,:);
            se=trialData(vv).seTBT(indsuse,:);             
                      
            if strcmp(statstr,'TStat')
                dat = dat./se;
            elseif strcmp(statstr,'raw')
                dat = dat;
            elseif strcmp(statstr,'TStat_subMean2')
                dat = dat./se;
                dat = dat-repmat(mean(dat,2),1,size(dat,2));
            else
                error('statstr not found')
            end
      
            runlabs=trialData(vv).scanlabelsTBT(indsuse,:);

            % define each type of match, use the relevant feature as the
            % target
            IDmatchlabels=double(trialData(vv).predlabelsTBT(indsuse,4)==1 & trialData(vv).predlabelsTBT(indsuse,5)==1);
            ORmatchlabels = double(trialData(vv).predlabelsTBT(indsuse,6)==1);
            
            allmatchlabels = [ORmatchlabels,IDmatchlabels];
            
            reallabs = allmatchlabels(:,cc);

            allreallabs(vv,cc).realLabs = reallabs;
            
            %% do the classification
            
            if nVox2Use>size(dat,2)                            
                nVox2Use_now = size(dat,2);
            else
                nVox2Use_now = nVox2Use;
            end
              
            % count the number of trials that we have originally on each CV
            if vv==1
                unruns = unique(runlabs);
                trialnums = zeros(numel(unruns),2);
                for rr=1:numel(unruns)
                    trialnums(rr,1) = sum(reallabs==1 & runlabs~=unruns(rr));
                    trialnums(rr,2) = sum(reallabs==0 & runlabs~=unruns(rr));
                end
                
                alltrialnums(cc).trialnums= trialnums;                
            end
            
            [acc,dprime,predLabs,failedInds] = my_classifier_balance(dat,reallabs,runlabs,classstr,nBalanceIter1,nVox2Use_now,pTable(:,unruns),resamp);

            if sum(failedInds)>0
                error('    %d trials in test set were not classified due to un-balanceable training set\n',sum(failedInds));               
            end
            
            allaccs(vv,cc) = acc;
            allD(vv,cc) = dprime;
            
            allpredlabs(vv,cc).predLabs = predLabs;
            
            %% do the shuffled classification

            fprintf('finished real,starting shuffle\n');
            predLabsRand = zeros(length(reallabs),nShuffIter);
            
            parfor ii=1:nShuffIter
                
                %shuffle the labels (within runs, to maintain a balanced set
%                 unruns=unique(runlabs_trn);

                %shuffle separately within the training and testing, so tha
                %we keep the ratios of match/non trials in each group fixed
                %this is possibly not necessary (?)
                randlabs=nan(length(reallabs),1);
               
                for cv=1:length(unruns)
                    
                    theseinds=runlabs==unruns(cv);
                    theselabs=reallabs(theseinds);
                    randlabs(theseinds)=theselabs(randperm(length(theselabs)));                   
                
                end
                [accRand,dRand,predLabs,failedInds] = my_classifier_balance(dat,randlabs,runlabs,classstr,nBalanceIter2,nVox2Use_now,pTable(:,unruns),resamp);

                if sum(failedInds)>0
                    error('    %d trials in test set were not classified due to un-balanceable training set\n',sum(failedInds));               
                end
                
                allaccs_shuffDataLabs(vv,cc,ii) = accRand;
                allD_shuffDataLabs(vv,cc,ii) = dRand;

                predLabsRand(:,ii) = predLabs;
                
            end

            allpredlabs_shuffDataLabs(vv,cc).predLabsRand = predLabsRand;
        end
    end

    save(fnsreal,'allaccs','allD','allreallabs','allpredlabs','alltrialnums');
    save(fnsrand,'allaccs_shuffDataLabs','allD_shuffDataLabs','allpredlabs_shuffDataLabs');

end
    

