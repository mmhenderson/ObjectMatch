% compare mean signal in ROIs between target and nontarget trials, within
% each task separately

% run t-test

clear

% set this to your main directrory
root = 'Z:\People\Maggie\OM2\';
addpath(genpath(root));

rndseed = 987451;
rng(rndseed);

%% define subjects and flags for what to do

subj={'AI','AP','AV','BB','BC','BJ','BO','BR','BU','BW'};
VOIs={'V1','V2','V3','V4','LO','pFus','V3AB','IPS0-1','IPS2-3','poCS','sPCS','iPCS','AI-FO','IFS'};

nSubj=length(subj);
nVOIs=length(VOIs);

folder='OM2_anova';

%what kind of anova?
typestr = 'targetPredWithinCond';

statstr = 'raw';

%% set up file info, other params

condStrs = {'attId','attOr'};
nCond= length(condStrs);

nBootIter=1000;

nGroups = 2;

meanAct = zeros(nSubj,nVOIs,nCond,nGroups);

%% loop over subs
for ss=1:nSubj   

    fn=sprintf('%s%s%s%s_meanSigROIs_%s_%s.mat',root,folder,filesep,subj{ss},typestr,statstr);

    load(fn);
    
    for vv=1:nVOIs
        
        for cc=1:nCond

            meanAct(ss,vv,cc,1) = vt(vv,cc).meanMatch;
            meanAct(ss,vv,cc,2) = vt(vv,cc).meanNonmatch;
            
        end
        
    end

end

 %% compare between conditions, within each ROI separately

pVals_allsub_condDiff = zeros(nVOIs,1);

for vv=1:nVOIs
    
    for cc=1:nCond

        group1 = meanAct(:,vv,cc,1)';
        group2 = meanAct(:,vv,cc,2)';

        realDiffs = group1-group2;        
        realT = get_tscore_nans(realDiffs,0);

        % iterate over nBootIters
        nullT = zeros(nBootIter,1);
        for ii=1:nBootIter

            %swap the order on some of these with 50% prob (this is
            %equivalent to assuming there is no difference between the two
            %attention conds, but keeping subjects as a fixed factor)
            randSwap = boolean(randi([0,1],size(realDiffs)));
            randDiffs=realDiffs;
            randDiffs(randSwap)=-randDiffs(randSwap);

            nullT(ii) = get_tscore_nans(randDiffs,0);

        end

        pVals_allsub_condDiff(vv,cc) = min([mean(realT<nullT),mean(realT>nullT)]);
    end
    
end

%% save result

fnsave=sprintf('%s%s%sAllsubs_%s_%s_meanSigROIsTTest.mat',root,folder,filesep,typestr,statstr);

save(fnsave,'pVals_allsub_condDiff');

