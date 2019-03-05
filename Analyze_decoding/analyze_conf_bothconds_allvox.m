% Analyze results of classifier confidence estimation (from run_decWithConf...)
% Compare average confidence between correct and incorrect test set trials

%% define subjects and flags for what to do

clear

% set this to your main dir
% root = 'Z:\People\Maggie\OM2\';
root = '/usr/local/serenceslab/maggie/OM2_OSF/';
addpath(genpath(root));

rndseed = 231345;
rng(rndseed);

subj={'AI','AP','AV','BB','BC','BJ','BO','BR','BU','BW'};
VOIs={'V1','V2','V3','V4','LO','pFus','V3AB','IPS0-1','IPS2-3','poCS','sPCS','iPCS','AI-FO','IFS'};

nSubj=length(subj);
nVOIs=length(VOIs);

typestr = 'classify_target_bothCond_behavNormEuc';

statstr = 'TStat_subMean2';

voxStr = 'allVox';

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

ntrials = zeros(nSubj,2,2);

for ss=1:nSubj   

    fnsreal=sprintf('%s%s%s%s_%s_%s_%s.mat',root,folder,filesep,subj{ss},typestr,statstr,voxStr);

    load(fnsreal);

    d_allsub(:,ss,1) = allD;
    accs_allsub(:,ss,1) = allaccs;

    for vv=1:nVOIs
        slist = [slist;repmat(ss,length(allcorrlabs),1)];
        vlist = [vlist;repmat(vv,length(allcorrlabs),1)];
        matchlist = [matchlist;allmatchlabs];
        subcorrectlist = [subcorrectlist;allcorrlabs];
        classcorrectlist = [classcorrectlist;allmatchlabs==allpredlabs(vv,:)'];
        predlist = [predlist;allpredlabs(vv,:)'];
        meanEuclist = [meanEuclist;squeeze(alldisteuc(vv,:,:))];


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

pValsCorrDiff = nan(nVOIs,1);

meanEucdiffs = zeros(nVOIs,nSubj,2);

for ss=1:nSubj
    for vv=1:nVOIs

            for cc = 1:2                    
                dat = meandifflist(vlist==vv & slist==ss & subcorrectlist==cc,:);
                meanEucdiffs(vv,ss,cc) = nanmean(dat);
                if nanmean(dat)==-inf
                    meanEucdiffs(vv,ss,cc) = -realmax;
                end
                if nanmean(dat) == inf
                    meanEucdiffs(vv,ss,cc) =  realmax;
                end
            end

    end

end

for vv=1:nVOIs

        dat1 = squeeze(meanEucdiffs(vv,:,1));
        dat2 = squeeze(meanEucdiffs(vv,:,2));

        realDiffs = dat1-dat2;
        realDiff = nanmean(realDiffs);
        nullDiffs = zeros(nIter,1);

        for xx=1:nIter
            randSwap = boolean(randi([0,1],size(realDiffs)));
            randDiffs=realDiffs;
            randDiffs(randSwap)=-randDiffs(randSwap);
            nullDiffs(xx) = nanmean(randDiffs);
        end

        pValsCorrDiff(vv) = min([mean(realDiff<nullDiffs),mean(realDiff>nullDiffs)]);

end
%% FDR correct  

sigLevels = [0.05,0.01];

isSigCorrDiff = zeros([size(pValsCorrDiff),2]);
for aa=1:length(sigLevels)
        
    [~,isSigCorrDiff(:,aa)] = fdr(pValsCorrDiff,sigLevels(aa));
    
end   
%% save result

fnsave=sprintf('%s%s%sAllsubs_%s_%s_%s_bothconds_compareCorrTTest.mat',root,folder,filesep,typestr,voxStr,statstr);

save(fnsave,'meanEucdiffs','pValsCorrDiff','isSigCorrDiff');

