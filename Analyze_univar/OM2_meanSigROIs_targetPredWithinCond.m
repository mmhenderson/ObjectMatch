% compare mean signal in ROIs between target and nontarget trials, within
% each task separately

clear

% set this to your main directory
root='/usr/local/serenceslab/maggie/OM2/';

%% define subjects and flags for what to do

subj={'AI','AP','AV','BB','BC','BJ','BO','BR','BU','BW'};
VOIs={'V1','V2','V3','V4','LO','pFus','V3AB','IPS0-1','IPS2-3','poCS','sPCS','iPCS','AI-FO','IFS'};

nSubj=length(subj);
nVOIs=length(VOIs);

condStrs = {'attId','attOr'};

locstr='ObjectLoc';
locSignStr='posVoxOnly';

folder='OM2_anova';

statstr = 'raw';

%what kind of anova?
typestr = 'targetPredWithinCond';

nCond = 2;

%% loop over subs
for ss=1:nSubj

    trialDataAll_fn = sprintf('%sOM2_trialData/%s_%s_%s', root,subj{ss},locstr,locSignStr);
    load(trialDataAll_fn);
    
    fn=sprintf('%s%s%s%s_meanSigROIs_%s_%s.mat',root,folder,filesep,subj{ss},typestr,statstr);
      
    for vv=1:length(VOIs)
        
        for cc=1:nCond

            alldat=trialData(vv).betasTARG;
            allse=trialData(vv).seTARG;

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

            inds2use = trialData(vv).tasklabels_TARG==cc;
    
            alldat = alldat(inds2use,:);
            
            group = trialData(vv).predlabelsTARG(inds2use);

            group1 = mean(alldat(group==1,:),2);
            group2 = mean(alldat(group==0,:),2);

            [h,p,c,s] = ttest2(group1,group2,'Vartype','unequal'); 
            % positive t means that group 1 is larger

            vt(vv,cc).meanMatch = mean(group1);
            vt(vv,cc).meanNonmatch = mean(group2);
            vt(vv,cc).tstat = s.tstat;
            vt(vv,cc).sd = s.sd;
            vt(vv,cc).p = p;
        
        end

    end
    
    save(fn,'vt');
    fprintf('saving to %s\n',fn);
end
    
