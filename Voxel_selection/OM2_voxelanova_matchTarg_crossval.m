
% identify individual voxels that are selective for presence of the
% relevant target over all trials

% do the anova leaving out one run at a time: that way we can use this
% anova to select the best voxels in a classifier training set, in an
% independent way.
clear

root = 'Z:\People\Maggie\OM2\';
addpath(genpath(root));


%% define subjects and flags for what to do

VOIs={'V1','V2','V3','V4','LO','pFus','V3AB','IPS0-1','IPS2-3','poCS','sPCS','iPCS','AI-FO','IFS'};

subj = {'AI','AP','AV','BB','BC','BJ','BO','BR','BU','BW'};

nSubj=length(subj);
nVOIs=length(VOIs);

% root='/usr/local/serenceslab/maggie/OM2/';

condStrs = {'attId','attOr'};
nCond= length(condStrs);

locstr='ObjectLoc';
locSignStr='posVoxOnly';

folder='OM2_anova';

%what kind of anova?
typestr = 'matchTarg_crossval';

statstr = 'TStat_subMean2';

% termStrs = {'task','target','int'};

%% loop over subs
for ss=1:nSubj
      
    trialDataAll_fn = sprintf('%sOM2_trialData/%s_%s_%s', root,subj{ss},locstr,locSignStr);
    load(trialDataAll_fn);
    
    fn=sprintf('%s%s%s%s_anova2_%s_%s.mat',root,folder,filesep,subj{ss},typestr,statstr);
      
    for vv=1:length(VOIs)
        nVox = size(trialData(vv).betasTBT,2);
        
        alldat=trialData(vv).betasTBT;
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
       
        correctinds = trialData(vv).predlabelsTBT(:,9);
        firstinds = trialData(vv).predlabelsTBT(:,7);
               
        indsuse = correctinds & ~firstinds;
        
        dat = double(alldat(indsuse,:));
        
        idmatch = double(trialData(vv).predlabelsTBT(indsuse,4)==1 & trialData(vv).predlabelsTBT(indsuse,5)==1);
        ormatch = double(trialData(vv).predlabelsTBT(indsuse,6)==1);

        group = double((idmatch & trialData(vv).tasklabelsTBT(indsuse,:)==1) | (ormatch & trialData(vv).tasklabelsTBT(indsuse,:)==2));
        
        scanlabs = trialData(vv).scanlabelsTBT(indsuse,1);
        
        unruns = unique(scanlabs);
        nRuns = length(unruns);
        
         
        % calculate anova for each voxel in this VOI
        an(vv).F = zeros(nVox,nRuns);
        an(vv).p = zeros(nVox,nRuns);
        
        
        for rr=1:nRuns
            
            fprintf ('processing sub %s %s CV %d/%d\n',subj{ss},VOIs{vv},rr,nRuns);
            
            %leave out one run at a time
            theseinds = scanlabs~=unruns(rr);
            
            thisdat = dat(theseinds,:);
            thisgroup = group(theseinds,:);

            for vx=1:nVox

                [~,stats] = anovan(thisdat(:,vx), {thisgroup},'model','full','display','off');
                thisP=cell2mat(stats(2,7));
                thisF=cell2mat(stats(2,6));

                an(vv).F(vx,rr) = thisF;
                an(vv).p(vx,rr) = thisP;

            end
        end

    end
    
    save(fn,'an');
    fprintf('saving to %s\n',fn);
end
    
    
end
  
