% Analyze results of classifier confidence estimation (from run_decWithConf...)
% Compare average confidence between correct and incorrect test set trials

%% define subjects and flags for what to do
clear

% set this to your main dir
root = 'Z:\People\Maggie\OM2\';
addpath(genpath(root));

rndseed = 364897;
rng(rndseed);

subj={'AI','AP','AV','BB','BC','BJ','BO','BR','BU','BW'};

VOIs={'V1','V2','V3','V4','LO','pFus','V3AB','IPS0-1','IPS2-3','poCS','sPCS','iPCS','AI-FO','IFS'};

nSubj=length(subj);
nVOIs=length(VOIs);

typestr = 'classify_target_withinCond_behavNormEuc';

statstr = 'TStat_subMean2';

voxStr = 'use50VoxBal';

nIter=10000;

close all;

%% set up file info, other params

folder='OM2_classif_final';

nCond=2;

accs_allsub=nan(nVOIs,nSubj,nCond);

d_allsub=nan(nVOIs,nSubj,nCond);

nVox_allsub = nan(nVOIs,nSubj);


slist=[];
vlist=[];
matchlist=[];
subcorrectlist=[];
classcorrectlist=[];
meanEuclist=[];
predlist=[];
tasklist=[];

ninf = zeros(nSubj,nVOIs,2,2);
ntrials = zeros(nSubj,2,2);

%% loop over subs
for ss=1:nSubj   

    fnsreal=sprintf('%s%s%s%s_%s_%s_%s.mat',root,folder,filesep,subj{ss},typestr,statstr,voxStr);

    load(fnsreal);

    d_allsub(:,ss,:) = allD;
    accs_allsub(:,ss,:) = allaccs;

    for vv=1:nVOIs
        slist = [slist;repmat(ss,length(allcorrlabs)*2,1)];
        vlist = [vlist;repmat(vv,length(allcorrlabs)*2,1)];

        tasklabs = repmat([1,2],length(allcorrlabs),1);
        tasklist=[tasklist;tasklabs(:)];

        matchlist = [matchlist;allmatchlabs(:)];
        subcorrectlist = [subcorrectlist;allcorrlabs(:)];

        thesepredlabs = squeeze(allpredlabs(vv,:,:))';
        predlist = [predlist;thesepredlabs(:)];

        classcorrlabs = squeeze(allmatchlabs==thesepredlabs);
        classcorrectlist = [classcorrectlist;classcorrlabs(:)];

        % these columns go - task 1 match, task 1 nontmatch, task 2
        % match, task 2 nonmatch
        meanEuclist = [meanEuclist;squeeze(alldisteuc(vv,1,:,:));squeeze(alldisteuc(vv,2,:,:,:))];

        for tt=1:2
            ntrials(ss,tt,1) = sum(subcorrectlist(slist==ss & vlist==vv & tasklist==tt,:)==1);
            ntrials(ss,tt,2) = sum(subcorrectlist(slist==ss & vlist==vv & tasklist==tt,:)==0);

            ninf(ss,vv,tt,:) = sum(meanEuclist(slist==ss & vlist==vv & tasklist==tt,:)==-inf);
        end

    end



end

meandifflist = -(diff(meanEuclist,[],2));

%compare this to the classifier output(slightly different, because we
%are taking a mean over all iterations, rather than getting a categorical value
%for each iteration and taking max)
pred2 = double(meandifflist<0);
pred2(pred2==0) = 2;
agreement = mean(pred2==predlist);

meandifflist_signed = meandifflist;

% interpret this as confidence of the classifier in direction of the
% correct decision
meandifflist(matchlist==1) = -meandifflist(matchlist==1);

subcorrectlist(subcorrectlist==0)=2;
classcorrectlist(classcorrectlist==0)=2;


%% within each VOI - is there a significant difference between subject correct and incorrect LL differences

pValsCorrDiff = nan(nVOIs,2);

meanEucdiffs = zeros(nVOIs,nSubj,2,2);

for ss=1:nSubj
    for vv=1:nVOIs

        for tt=1:2
            for cc = 1:2                    
                dat = meandifflist(vlist==vv & slist==ss & subcorrectlist==cc & tasklist==tt,:);
                meanEucdiffs(vv,ss,tt,cc) = nanmean(dat);
                if nanmean(dat)==-inf
                    meanEucdiffs(vv,ss,tt,cc) = -realmax;
                end
                if nanmean(dat) == inf
                    meanEucdiffs(vv,ss,tt,cc) =  realmax;
                end
            end
        end
    end

end

for vv=1:nVOIs

   for tt=1:2

        dat1 = squeeze(meanEucdiffs(vv,:,tt,1));
        dat2 = squeeze(meanEucdiffs(vv,:,tt,2));

        realDiffs = dat1-dat2;
        realDiff = nanmean(realDiffs);
        nullDiffs = zeros(nIter,1);

        for xx=1:nIter
            randSwap = boolean(randi([0,1],size(realDiffs)));
            randDiffs=realDiffs;
            randDiffs(randSwap)=-randDiffs(randSwap);
            nullDiffs(xx) = nanmean(randDiffs);
        end

        pValsCorrDiff(vv,tt) = min([mean(realDiff<nullDiffs),mean(realDiff>nullDiffs)]);
   end

end
 
%% FDR correct  

sigLevels = [0.05,0.01];

isSigCorrDiff = zeros([size(pValsCorrDiff),2]);
for aa=1:length(sigLevels)
        
    [~,isSigCorrDiff(:,:,aa)] = fdr(pValsCorrDiff,sigLevels(aa));
    
end
%% save result

fnsave=sprintf('%s%s%sAllsubs_%s_%s_%s_sepconds_compareCorrTTest.mat',root,folder,filesep,typestr,voxStr,statstr);

save(fnsave,'meanEucdiffs','pValsCorrDiff','isSigCorrDiff');

