function [acc,dprime,predLabs,failedInds] = my_classifier_balance(dat,reallabs,runlabs,classstr,nBalanceIter,nVox2Keep,voxStatTable,resamp)
% classify voxel activation patterns, balancing the training set w/r/t
% labels that are specified in reallabs

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

% MMH 2/9/18

%%
unruns=unique(runlabs);
nruns=length(unruns);

if any(size(voxStatTable)~=[size(dat,2),nruns])
    error('voxStatTable must be [nVox x nRuns]')
end

ntesttrialseachrun=nan(nruns,1);

if isempty(nVox2Keep)
    nVox2Keep = size(dat,2);
end

if nVox2Keep<1 || nVox2Keep>size(dat,2)
    error('nVox2Keep must be in range 1-nVox')
end

balgroups = sort(unique(reallabs));

failedInds = zeros(length(runlabs),1);

for cv=1:nruns
 
%     fprintf('real data: %d of %d\n',cv,nruns)
    
    tstinds=runlabs==unruns(cv);
    trninds=runlabs~=unruns(cv);
    
    trndat = dat(trninds,:);
    tstdat = dat(tstinds,:);
    trnlabs = reallabs(trninds,:);
    tstlabs = reallabs(tstinds,:);
    
    un=unique(trnlabs);
    
    if resamp>0

        ntesttrialseachrun(cv)=sum(tstinds);

        %see if there's an unbalanced set
        un=unique(trnlabs);

        numeach = sum(repmat(trnlabs,1,numel(un))==repmat(un',length(trnlabs),1));

    %     numeach=zeros(length(un),1);
    %     for ii=1:length(un)
    %         numeach(ii)=sum(trnlabs==un(ii));
    %     end

        %check if any groups are missing entirely
        if numel(balgroups)~=numel(un) || any(balgroups~=sort(un)); 
            failedInds(tstinds,:) = 1;
            continue;
        end

        nMax=max(numeach);
        nMin=min(numeach);

        if any(numeach~=nMax)
            doBalance=1;
        else
            doBalance=0;
        end

    else
        doBalance = 0;
    end
    

    for bb=1:nBalanceIter

        if bb==1 || (bb>1 && doBalance)
            

            if resamp==1

                %get one possible balanced training set
                useinds=[];

                for ii=1:length(un)

                    theseinds=find(trnlabs==un(ii));
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
                    theseinds=find(trnlabs==un(ii));
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
            
             %use it to predict on test set
            if strcmp(classstr,'svmtrain_lin');    
                obj=svmtrain(trnlabsuse,trnuse,'-t 0 -q');         
                thesepredlabs=svmpredict(tstlabs,tstuse,obj);
            elseif strcmp(classstr,'svmtrain_poly');    
                obj=svmtrain(trnlabsuse,trnuse,'-t 1 -q'); 
                thesepredlabs=svmpredict(tstlabs,tstuse,obj);
            elseif strcmp(classstr,'svmtrain_RBF');    
                obj=svmtrain(trnlabsuse,trnuse,'-t 2 -q'); 
                thesepredlabs=svmpredict(tstlabs,tstuse,obj);
            elseif strcmp(classstr,'svmtrain_sig');    
                obj=svmtrain(trnlabsuse,trnuse,'-t 3 -q'); 
                thesepredlabs=svmpredict(tstlabs,tstuse,obj);
            elseif strcmp(classstr,'fitcdiscr');                 
                obj=fitcdiscr(trnuse,trnlabsuse);
                thesepredlabs=predict(obj,tstuse);
            elseif strcmp(classstr,'classify_diaglinear')
                thesepredlabs = classify(tstuse,trnuse,trnlabsuse,'diagLinear');
            elseif strcmp(classstr,'classify_mahal')
                thesepredlabs = classify(tstuse,trnuse,trnlabsuse,'mahalanobis');   
            elseif strcmp(classstr,'eucDist')
                [thesepredlabs,~] = eucDistClass(trnuse,tstuse,trnlabsuse);
            elseif strcmp(classstr,'idealObs')
                [thesepredlabs,~] = ideal_observer(trnuse,tstuse,trnlabsuse);
            elseif strcmp(classstr,'normEucDist')
                [thesepredlabs,~] = normEucDistClass(trnuse,tstuse,trnlabsuse);
            end

            allclasspredlabs(cv,bb).predlabs = thesepredlabs;
        else
            allclasspredlabs(cv,bb).predlabs = allclasspredlabs(cv,1).predlabs;
          
        end
      
    end
        
end
%% to get d' and accuracy: reassemble the predicted labels from all cross-validations, compute d' for entire test set at once

accAll = nan(nBalanceIter,1);
dAll = nan(nBalanceIter,1);

allpredlabs=nan(length(reallabs),nBalanceIter);

runlabsorig = runlabs;

reallabs = reallabs(~failedInds);
runlabs = runlabs(~failedInds);

for bb=1:nBalanceIter

    thesepredlabs = nan(length(runlabsorig),1);
    for cv=1:nruns
        theseinds = runlabsorig == unruns(cv);
        if any(failedInds(theseinds))
            thesepredlabs(theseinds) = zeros(sum(theseinds),1);
        else            
            thesepredlabs(theseinds) = allclasspredlabs(cv,bb).predlabs;
        end
    end
    if any(isnan(thesepredlabs))
        error('mistake in prediction labels')
    end
    allpredlabs(:,bb) = thesepredlabs;

    thesepredlabs=thesepredlabs(~failedInds);

    accAll(bb) = mean(thesepredlabs==reallabs);
    dAll(bb) = get_dprime(thesepredlabs,reallabs,un);

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