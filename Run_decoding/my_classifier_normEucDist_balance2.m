function [acc,dprime,predLabs,distEuc,failedInds] = my_classifier_normEucDist_balance2(dat,reallabs,ballabs,runlabs,nBalanceIter,nVox2Keep,voxStatTable,resamp)
% classify voxel activation patterns - balancing the training set w/r/t two
% different sets of labels (e.g. target status and correctness)

% if resamp==1, will downsample larger set
% if resamp==2, will oversamp (leads to bias so probably don't do)
% if resamp==0, no resampling is done.

% dat is [trials x voxels]
% reallabs, runlabs are [trials x 1]
% runlabs stores the number of run for each trial (this is used to
% crossvalidate, leaving one run out and predicting based on the other
% runs)

% voxStatTable is a table of stats for each voxel, such as:
    % p-value from an anova (make sure from training set dat only)
    % 1/t-score of voxel in independent visual localizer
% it is always [nVox x nRuns], the run indicates which cross-validation
% fold to use it on (for localizer scores, the rows are identical)
% will always choose voxels by their MINIMUM value in this table (so high
% t-score = low 1/t-score, means it will be used)


% ballabs defines another label for the data which needs to be balanced in
% the training set, such as correctness or incorrectness of the trials. 
% note this works only if reallabs and ballabs each have 2 categories!

% MMH 2/9/18
%%
unruns=unique(runlabs);
nruns=length(unruns);

if any(size(voxStatTable)~=[size(dat,2),nruns])
    error('pTable must be [nVox x nRuns]')
end

ntesttrialseachrun=nan(nruns,1);

if isempty(nVox2Keep)
    nVox2Keep = size(dat,2);
end

if nVox2Keep<1 || nVox2Keep>size(dat,2)
    error('nVox2Keep must be in range 1-nVox')
end


un1 = sort(unique(reallabs));
un2 = sort(unique(ballabs));
if length(un1)~=2 || length(un2)~=2;
    error('reallabs1 and reallabs2 both need to have two classes')
end

balgroups=(1:4)';

failedInds = zeros(length(runlabs),1);

distEuc = zeros(length(runlabs),nBalanceIter,2);

allclasspredlabs = zeros(length(runlabs),nBalanceIter);

for cv=1:nruns
    
%     fprintf('real data: %d of %d\n',cv,nruns)
    
    tstinds=runlabs==unruns(cv);
    trninds=runlabs~=unruns(cv);
    
    trndat = dat(trninds,:);
    tstdat = dat(tstinds,:);
    
    trnlabs = reallabs(trninds,:);
%     tstlabs = reallabs(tstinds,:);
    
    trnlabs_bal = ballabs(trninds,:);
%     tstlabs2 = ballabs(tstinds,:);
        
    ntesttrialseachrun(cv)=sum(tstinds);
    
    %define a set of 1-4 labels for each "balancing group"
    
    [C,ia,ic] = unique([trnlabs,trnlabs_bal],'rows');
    thesebalgrouplabs = ic;

    %see if there's an unbalanced set
    un=unique(thesebalgrouplabs);
    numeach = sum(repmat(thesebalgrouplabs,1,numel(un))==repmat(un',length(thesebalgrouplabs),1));
    
    
    %check if any groups are missing entirely
    if numel(balgroups)~=numel(un) || any(balgroups~=sort(un)) || any(numeach==0); 
        failedInds(tstinds,:) = 1;
        continue;
    end
       
    
    nMax=max(numeach);
    nMin=min(numeach);
    
    theseclasspredlabs = zeros(sum(tstinds),nBalanceIter);
    thesedist = zeros(sum(tstinds),nBalanceIter,2);

    for bb=1:nBalanceIter
%         bb
%         if bb==1 || (bb>1 && doBalance)
            

            if resamp==1

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
                
            elseif resamp==2

                %get one possible balanced training set
                useinds=[];

                for ii=1:length(un)

                    %inds of the actual data
                    theseinds=find(thesebalgrouplabs==un(ii));
                    nOverSamp = nMax-numeach(ii);

                    %inds of the extra data, if any, to add on
                    sampinds = datasample(theseinds,nOverSamp);

                    useinds=[useinds;theseinds;sampinds];

                end
                
                 if length(useinds)~=nMax*length(un)
                    error('mistake in resampling')
                end
            end

           

            trnuse = trndat(useinds,:);
            trnlabsuse = trnlabs(useinds,:);

            if nVox2Keep<size(dat,2)
                % use the correct column of pTable to sort
                [~, ind] = sort(voxStatTable(:,cv), 'ascend'); 
                voxelindsuse = ind(1:nVox2Keep);
            else
                voxelindsuse = 1:size(dat,2);
            end

            %use the same vox (which are selected from only training dat) for training and testing                         
            trnuse = trnuse(:,voxelindsuse);
            tstuse = tstdat(:,voxelindsuse);

            [thesepredlabs,eucDistlabs] = normEucDistClass(trnuse,tstuse,trnlabsuse);

            theseclasspredlabs(:,bb) = thesepredlabs;
            thesedist(:,bb,:) = eucDistlabs;

    end
    
    allclasspredlabs(tstinds,:) = theseclasspredlabs;
    distEuc(tstinds,:,:) = thesedist;
        
end
%% to get d' and accuracy: reassemble the predicted labels from all cross-validations, compute d' for entire test set at once

accAll = nan(nBalanceIter,1);
dAll = nan(nBalanceIter,1);

allpredlabs=nan(length(reallabs),nBalanceIter);

runlabsorig = runlabs;

reallabs = reallabs(~failedInds);
% runlabs = runlabs(~failedInds);

for bb=1:nBalanceIter

    thesepredlabs = nan(length(runlabsorig),1);
    for cv=1:nruns
        theseinds = runlabsorig == unruns(cv);
        if any(failedInds(theseinds))
            thesepredlabs(theseinds) = zeros(sum(theseinds),1);
        else            
%             thesepredlabs(theseinds) = allclasspredlabs(cv,bb).predlabs;
            thesepredlabs(theseinds) = allclasspredlabs(theseinds,bb);
        end
    end
    if any(isnan(thesepredlabs))
        error('mistake in prediction labels')
    end
    allpredlabs(:,bb) = thesepredlabs;

    thesepredlabs=thesepredlabs(~failedInds);

    accAll(bb) = mean(thesepredlabs==reallabs);
    dAll(bb) = get_dprime(thesepredlabs,reallabs,unique(reallabs));

end

%% get mean over the balancing iterations

acc = mean(accAll);
dprime = mean(dAll);

%% get predicted labels
% the category that the classifier assigned on most iterations

[predLabs,f,c] = mode(allpredlabs,2);

if any(cellfun('length',c)>1)
    %there was a tie, resolve randomly
    tieinds = find(cellfun('length',c)>1);
    for tt=1:length(tieinds)
        predLabs(tieinds(tt)) = datasample(c{tieinds(tt)},1);
    end
end

end