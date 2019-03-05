% identify individual voxels that are selective for presence of the
% relevant target over all trials

% do the anova leaving out one run at a time: that way we can use this
% anova to select the best voxels in a classifier training set, in an
% independent way.

% balance the set with respect to correctness!

%% define subjects and flags for what to do
clear

root = 'Z:\People\Maggie\OM2\';
addpath(genpath(root));


rndseed = 321354;
rng(rndseed);

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
typestr = 'matchTarg_withinCond_crossval_balanceCorr';

statstr = 'TStat_subMean2';


nIter = 1000;

balgroups=(1:4)';


%% loop over subs
for ss=1:nSubj

    trialDataAll_fn = sprintf('%sOM2_trialData/%s_%s_%s', root,subj{ss},locstr,locSignStr);
    load(trialDataAll_fn);
    
    fn=sprintf('%s%s%s%s_anova2_%s_%s.mat',root,folder,filesep,subj{ss},typestr,statstr);
      
    for vv=1:length(VOIs)
        
        for cc=1:nCond
        
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


            firstinds = trialData(vv).predlabelsTBT(:,7);
            thistaskinds = trialData(vv).tasklabelsTBT==cc;
            indsuse = ~firstinds & thistaskinds;
            
            dat = double(alldat(indsuse,:));

            idmatch = double(trialData(vv).predlabelsTBT(indsuse,4)==1 & trialData(vv).predlabelsTBT(indsuse,5)==1);
            ormatch = double(trialData(vv).predlabelsTBT(indsuse,6)==1);

            group = double((idmatch & trialData(vv).tasklabelsTBT(indsuse,:)==1) | (ormatch & trialData(vv).tasklabelsTBT(indsuse,:)==2));

            scanlabs = trialData(vv).scanlabelsTBT(indsuse,1);

            corrlabs = trialData(vv).predlabelsTBT(indsuse,9);
            corrlabs(corrlabs==0) = 2;


            unruns = unique(scanlabs);
            nRuns = length(unruns);


            % calculate anova for each voxel in this VOI
            an(vv,cc).T = zeros(nVox,nRuns);
            an(vv,cc).p = zeros(nVox,nRuns);

            for rr=1:nRuns

                fprintf ('processing sub %s %s CV %d/%d\n',subj{ss},VOIs{vv},rr,nRuns);

                %leave out one run at a time
                theseinds = scanlabs~=unruns(rr);

                thisdat = dat(theseinds,:);
                thisgroup = group(theseinds,:);
                thiscorr = corrlabs(theseinds,:);

                Tdist = zeros(nIter,nVox);
                Pdist = zeros(nIter,nVox);

                % figure out what to balance over (correctness and match)           
                [C,ia,ic] = unique([thisgroup,thiscorr],'rows');
                thesebalgrouplabs = ic;

                un=unique(thesebalgrouplabs);
                numeach = sum(repmat(thesebalgrouplabs,1,numel(un))==repmat(un',length(thesebalgrouplabs),1));

                 %check if any groups are missing entirely
                if numel(balgroups)~=numel(un) || any(balgroups~=sort(un)) || any(numeach==0); 
                    error('cannot balance this training set')
                end

                nMin=min(numeach);
                parfor xx=1:nIter

                    %get one possible balanced training set
                    useinds=[];

                    for ii=1:length(un)

                        theseinds=find(thesebalgrouplabs==un(ii));
                        if numel(theseinds)>nMin
                            sampinds = datasample(theseinds,nMin,'Replace',false);
                            useinds = [useinds;sampinds];
                        else
                            useinds = [useinds;theseinds];                    
                        end
                    end

                    if length(useinds)~=nMin*length(un)
                        error('mistake in resampling')
                    end


                    thisdatbal = thisdat(useinds,:);
                    thisgroupbal = thisgroup(useinds);

                    thing1 = thisdatbal(thisgroupbal==0,:);
                    thing2 = thisdatbal(thisgroupbal==1,:);
                    
%                     tic
                    [h,p,ci,stats] = ttest2(thing1,thing2,'Vartype','unequal','Tail','both');
                    
                    
                    Tdist(xx,:) = stats.tstat;
                    Pdist(xx,:) = p;
                    
%                     toc          
                end

                an(vv,cc).T(:,rr) = mean(Tdist,1);
                an(vv,cc).p(:,rr) = mean(Pdist,1);
            end
        end
    end
    
    save(fn,'an');
    fprintf('saving to %s\n',fn);
end
    
    
% end
  
