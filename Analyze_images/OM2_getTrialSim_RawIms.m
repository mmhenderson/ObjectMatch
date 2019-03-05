% use weights from V1 model (pixel values for each image) to predict the 
% "similarity" between any pair of images. 
% Use this to get a value for similarity which maps onto each
% individual trial based on the current image and the previous image. We
% then will look at the distribution of these similarity values based on
% whether the trial was a match or a non-match in whichever feature is
% being classified.

% MMH 3/21/18
%%
clear
close all;

% set this root to wherever your main folder directory is
root = 'Z:\People\Maggie\OM2\';
addpath(genpath(root));


% imfolder = 'Category_stims';
savedir = 'OM2_corrMat';

subj={'AI','AP','AV','BB','BC','BJ','BO','BR','BU','BW'};

nSubj=length(subj);

locstr='ObjectLoc';
locSignStr='posVoxOnly';

nCond = 2;

for ss=1:nSubj

    trialSim = [];


    %% load original trial data
    trialDataAll_fn = sprintf('%sOM2_trialData/%s_%s_%s', root,subj{ss},locstr,locSignStr);
    load(trialDataAll_fn);

    %% load pixel values for these images
    % contains a struct pc with the pixel intensity values (1,000,000 pixels) 
    % for each of 24 images shown to this subject
    fns = [root savedir filesep subj{ss} '_imagesRaw.mat'];
    load(fns)
 
    %% go through all trials and calculate the image similarity between current and prev image
   
    for cc=1:nCond
    
        thistaskinds = find(trialData(1).tasklabelsTBT==cc);
        
        alltriallabs = trialData(1).predlabelsTBT(thistaskinds,:);
        % list current and prev object info
        alloblabs = [alltriallabs(2:end,1:3),alltriallabs(1:end-1,1:3)];
      
        allresplabs = alltriallabs(2:end,8);

        allcatormatchlabs = alltriallabs(2:end,4)==1 & alltriallabs(2:end,6)==1;
        
        if cc==1
            allmatchlabs = alltriallabs(2:end,4) & alltriallabs(2:end,5);
        else
            allmatchlabs = alltriallabs(2:end,6);
        end
        
        % select the trials to use - not the first in a run

        firstinds = trialData(1).predlabelsTBT(thistaskinds(2:end),7)==1;
       
        inds2use = ~firstinds;
   
        oblabs = alloblabs(inds2use,:);        
      
        trialSim.subResp(cc).subResp = allresplabs(inds2use);
        trialSim.obList(cc).obList = oblabs;
        trialSim.obList(cc).isCatOrMatch = allcatormatchlabs(inds2use,:);
        trialSim.obList(cc).isMatch = allmatchlabs(inds2use,:);
        
        for tt=1:size(oblabs,1)
            
            currInd = find(ismember(pc.obList,oblabs(tt,1:3),'rows'));
            prevInd = find(ismember(pc.obList,oblabs(tt,4:6),'rows'));
                       
            trialSim.obList(cc).obList_inds(tt,:) = [currInd,prevInd];
    
            mycorr = corrcoef(pc.score(currInd,:),pc.score(prevInd,:));
            
            trialSim.imCorr(cc).imCorr(tt,1) = mycorr(1,2);
        end
        
    end
    
    fns = [root savedir filesep subj{ss} '_trialSim_RawIms.mat'];
    fprintf('saving to %s\n',fns);
    save(fns,'trialSim');
        
end
