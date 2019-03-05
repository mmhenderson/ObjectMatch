% Run target decoding analysis, using normalized Euclidean distance to
% estimate classifier confidence on each test set trial
% Use trials from both conditions, all voxels

%% define subjects and flags for what to do
clear

% change this to your main directory
root = 'Z:\People\Maggie\OM2\';
addpath(genpath(root));
        
rndseed = 215645;
rng(rndseed);

nShuffIter = 1000;
% nBalanceIter1 is for the real classifiation, nBalanceIter2 is for the
% permutation test.
nBalanceIter1 = 1000;
% we'll use fewer iterations of balancing for the shuffled data just to
% speed the process up.
nBalanceIter2 = 100;

nVox2Use = [];

voxStr = 'allVox';

VOIs={'V1','V2','V3','V4','LO','pFus','V3AB','IPS0-1','IPS2-3','poCS','sPCS','iPCS','AI-FO','IFS'};

subj = {'AI','AP','AV','BB','BC','BJ','BO','BR','BU','BW'};

nSubj=length(subj);
nVOIs=length(VOIs);

typestr = 'classify_target_bothCond_behavNormEuc';

statstr = 'TStat_subMean2';

resamp = 1;

%% set up file info, other params

condStrs = {'attId','attOr'};
nCond= length(condStrs);

locstr='ObjectLoc';
locSignStr='posVoxOnly';

folder='OM2_classif_final';

%% loop over subs
for ss=1:nSubj
      
    fnsreal=sprintf('%s%s%s%s_%s_%s_%s.mat',root,folder,filesep,subj{ss},typestr,statstr,voxStr);
    fnsrand=sprintf('%s%s%s%s_%s_%s_%s_Rand.mat',root,folder,filesep,subj{ss},typestr,statstr,voxStr);
   
    allaccs=nan(nVOIs,1);   
    allD = nan(nVOIs,1);
  
    
    allaccs_shuffDataLabs=nan(nVOIs,nShuffIter);   
    allD_shuffDataLabs = nan(nVOIs,nShuffIter);
    

    nVox=nan(nVOIs);
                    
    trialDataAll_fn = sprintf('%sOM2_trialData/%s_%s_%s', root,subj{ss},locstr,locSignStr);
    load(trialDataAll_fn);

    for vv=1:length(VOIs)

        
        if size(trialData(vv).betasTBT,2)==0
            % if there is no data - leave the fields as NaN (should only be
            % for BR-sPCS)
            continue
        end
        
      
        
        nVox(vv) = size(trialData(vv).betasTBT,2);
        
%         for cc=1:nCond
        
            fprintf('processing subj %s, area %s, both cond\n',subj{ss},VOIs{vv})
        
            
            %% look at data for this sub, VOI, cond
            

            alldat = trialData(vv).betasTBT;
            allse=trialData(vv).seTBT;         
            
            if strcmp(statstr,'TStat')
                alldat =  alldat./allse;
            elseif strcmp(statstr,'raw')
                alldat = alldat;
            elseif strcmp(statstr,'TStat_subMean2')
                alldat = alldat./allse;
                alldat = alldat-repmat(mean(alldat,2),1,size(alldat,2));
            else
                error('statstr not found')
            end
            
            %% select the trials to use - not the first in a run
            
            firstinds = trialData(vv).predlabelsTBT(:,7)==1;

            % use all the correct/incorrect inds for this analysis
            inds2use = ~firstinds;
                      
            dat = alldat(inds2use,:);
                           
            runlabs = trialData(vv).scanlabelsTBT(inds2use,:);
                       
            ortaskinds = trialData(vv).tasklabelsTBT(inds2use,:)==2;
            ormatchinds = trialData(vv).predlabelsTBT(inds2use,6)==1;
            
            idtaskinds = trialData(vv).tasklabelsTBT(inds2use,:)==1;
            idmatchinds = trialData(vv).predlabelsTBT(inds2use,4)==1 & trialData(vv).predlabelsTBT(inds2use,5)==1;
             
            reallabs = zeros(size(runlabs));
            % label the 4 groups
            reallabs(idmatchinds & idtaskinds) = 1;
            reallabs(~idmatchinds & idtaskinds) = 2;
            reallabs(ormatchinds & ortaskinds) = 1;
            reallabs(~ormatchinds & ortaskinds) = 2;
            
            matchlabs = reallabs;
            correctlabs = trialData(vv).predlabelsTBT(inds2use,9);

            if (sum(reallabs==1) + sum(reallabs==2)) ~= length(reallabs)
                error('error assigning group labels')
            end
            
            if vv==1 
                %column 1 is match, 2 is nonmatch
                alldisteuc = nan(nVOIs,length(correctlabs),2);
                allpredlabs = nan(nVOIs,length(correctlabs),1);
                allcorrlabs = correctlabs;
                allmatchlabs = matchlabs;
            end
            
            %% do the classification

            if nVox2Use>size(dat,2)                            
                nVox2Use_now = size(dat,2);
            else
                nVox2Use_now = nVox2Use;
            end
            
            if vv==1
                unruns = unique(runlabs);
                trialnums = zeros(numel(unruns),2);
                for rr=1:numel(unruns)
                    trialnums(rr,1) = sum(reallabs==1 & runlabs~=unruns(rr));
                    trialnums(rr,2) = sum(reallabs==0 & runlabs~=unruns(rr));
                end
                
                alltrialnums = trialnums;
                
            end
                
              
            pTable = zeros(size(dat,2),length(unruns));
        
            
            [acc,dprime,predLabs,distEuc,failedInds] = my_classifier_normEucDist_balance2(dat,reallabs,correctlabs,runlabs,nBalanceIter1,nVox2Use_now,pTable,resamp);

            if sum(failedInds)>0
                error('    %d trials in test set were not classified due to un-balanceable training set\n',sum(failedInds));               
            end
            
            allaccs(vv) = acc;
            allD(vv) = dprime;
            
            allpredlabs(vv,:) = predLabs;
            alldisteuc(vv,:,:) = squeeze(mean(distEuc,2));

            %%
            
            fprintf('finished real,starting shuffle\n');
            predLabsRand = zeros(length(reallabs),nShuffIter);
            distEucRand = zeros(length(reallabs),2,nShuffIter);
            
            parfor ii=1:nShuffIter
                
                randlabs=nan(length(reallabs),1);
               
                % shuffle within run, and within correct/incorrect, so that
                % the balancing stays same
                for cv=1:length(unruns)
                    blabs = [1,0];
                    for bb=1:2
                        theseinds=runlabs==unruns(cv) & correctlabs==blabs(bb);
                        theselabs=reallabs(theseinds);
                        randlabs(theseinds)=theselabs(randperm(length(theselabs)));
                    end
                end
                [acc,dprime,predLabs,distEuc,failedInds] = my_classifier_normEucDist_balance2(dat,randlabs,correctlabs,runlabs,nBalanceIter2,nVox2Use_now,pTable,resamp);

                if sum(failedInds)>0
                    error('    %d trials in test set were not classified due to un-balanceable training set\n',sum(failedInds));               
                end
                
                allaccs_shuffDataLabs(vv,ii) = acc;
                allD_shuffDataLabs(vv,ii) = dprime;
                
                predLabsRand(:,ii) = predLabs;
                distEucRand(:,:,ii) = squeeze(mean(distEuc,2));
                
            end
            
            allpredlabs_shuffDataLabs(vv).predLabsRand = predLabsRand;
            alldisteuc_shuffDataLabs(vv).distEucRand = distEucRand;

%         end
    end
    
    save(fnsreal,'allaccs','allD','allcorrlabs','allmatchlabs','allpredlabs','alldisteuc','alltrialnums');
    save(fnsrand,'allaccs_shuffDataLabs','allD_shuffDataLabs','allpredlabs_shuffDataLabs','alldisteuc_shuffDataLabs','-v7.3');

end
    
    
% end
  
