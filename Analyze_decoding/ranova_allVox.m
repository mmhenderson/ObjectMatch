% repeated measures ANOVA for factors of ROI x Task x Relevancy 
% (for d' of target decoding)
% using RMAOV33 (in my Anova tools folder)
% find a main effect of ROI, relevancy, and an ROI x relevancy interaction.
% no main effect of task or interactions related to task. 

% MMH 2/6/18

%% define subjects and flags for what to do


subj={'AI','AP','AV','BB','BC','BJ','BO','BR','BU','BW'};
% subj = subj([1:7,9:10]);
VOIs={'V1','V2','V3','V4','LO','pFus','V3AB','IPS0-1','IPS2-3','poCS','sPCS','iPCS','AI-FO','IFS'};


nSubj=length(subj);
nVOIs=length(VOIs);
% tirange=[1];

typestr1='classify_target_withinCond';
typestr2='classify_targetIrrelevant_withinCond';

% classstr = 'classify_diaglinear';
classstr = 'normEucDist';
statstr = 'TStat_subMean2';

% nVox2Use=50;
% voxStr = 'fixVoxNum_50';

% nVox2Use=[];
voxStr = 'allVox';

nIter = 1000;
%% set up file info, other params

root='/usr/local/serenceslab/maggie/OM2_OSF/';

condStrs = {'attId','attOr'};
nCond= length(condStrs);

relStrs = {'relevant target','irrelevant target'};
nRel = length(relStrs);

sigLevel=0.01;

% nBootIter=1000;
% bootSampSize=100;

folder='OM2_classif_final';

% arrays to store acc and d' for correct, incorrect, and pooled
accs_allsub=nan(nVOIs,nSubj,nCond,nRel);
% nullAccs=nan(nVOIs,nCond,2,nSubj,nIter);
d_allsub=nan(nVOIs,nSubj,nCond,nRel);
% nullD=nan(nVOIs,nCond,2,nSubj,nIter);

%% loop over subs
for ss=1:nSubj   
        

        fnsreal1=sprintf('%s%s%s%s_%s_%s_%s_%s.mat',root,folder,filesep,subj{ss},typestr1,classstr,statstr,voxStr);
%         fnsrand1=sprintf('%s%s%s%s_%s_%s_%s_%s_Rand.mat',root,folder,filesep,subj{ss},typestr1,classstr,statstr,voxStr);

        load(fnsreal1);
%         load(fnsrand1,'allaccs_shuffDataLabs','allD_shuffDataLabs');


        accs_allsub(:,ss,:,1) = allaccs;
%         nullAccs(:,:,1,ss,1:size(allaccs_shuffDataLabs,3)) = allaccs_shuffDataLabs;

        d_allsub(:,ss,:,1) = allD;
%         nullD(:,:,1,ss,1:size(allD_shuffDataLabs,3)) = allD_shuffDataLabs;
 
        
        fnsreal2=sprintf('%s%s%s%s_%s_%s_%s_%s.mat',root,folder,filesep,subj{ss},typestr2,classstr,statstr,voxStr);
%         fnsrand2=sprintf('%s%s%s%s_%s_%s_%s_%s_Rand.mat',root,folder,filesep,subj{ss},typestr2,classstr,statstr,voxStr);

        load(fnsreal2);
%         load(fnsrand2,'allaccs_shuffDataLabs','allD_shuffDataLabs');


        accs_allsub(:,ss,:,2) = allaccs;
%         nullAccs(:,:,2,ss,1:size(allaccs_shuffDataLabs,3)) = allaccs_shuffDataLabs;

        d_allsub(:,ss,:,2) = allD;
%         nullD(:,:,2,ss,1:size(allD_shuffDataLabs,3)) = allD_shuffDataLabs;
 
        
end
   
    
   %% re-structure data into a 2D matrix

   X = zeros(numel(d_allsub),5);
   startind=0;
   for vv=1:nVOIs
       for cc=1:nCond
           for rr=1:nRel
               X(startind+1:startind+nSubj,1) = d_allsub(vv,:,cc,rr);
    %            X(startind+1:startind+nSubj,1) = accs_allsub(vv,:,cc);
               X(startind+1:startind+nSubj,2) = vv;
               X(startind+1:startind+nSubj,3) = cc;
               X(startind+1:startind+nSubj,4) = rr;
               X(startind+1:startind+nSubj,5) = 1:nSubj;

               startind=startind+nSubj;
           end
       end
   end
   
   alpha=sigLevel;
   
   
%% Method 1: remove subject BR (number 8 in this list) 

    ii=0;
    roiCells = [];
    taskCells = [];
    relCells = [];
    varNames = [];
    data = zeros(nSubj-1,nVOIs*2*2);
    for vv=1:nVOIs
       for cc=1:nCond
           for rr=1:nRel   
                ii=ii+1;
                roiCells{ii} = VOIs{vv};
                taskCells{ii} = condStrs{cc};
                relCells{ii} = relStrs{rr}; 
                thisdat =  X(X(:,2)==vv & X(:,3)==cc & X(:,4)==rr,1);
                data(:,ii) = thisdat([1:7,9:10]);
                varNames{ii} = sprintf('Y%d',ii);
           end      
        end
    end

    % Create a table storing the respones
    % varNames = {'Y1','Y2','Y3','Y4','Y5','Y6','Y7','Y8','Y9','Y10',...
    %     'Y11','Y12','Y13','Y14','Y15','Y16','Y17','Y18','Y19','Y20'};
    t = array2table(data,'VariableNames',varNames);
    % Create a table reflecting the within subject factors 'TestCond', 'Attention', and 'TMS' and their levels
    factorNames = {'ROI','Task','Relevance'};

    within = table(roiCells',taskCells',relCells','VariableNames',factorNames);

    % fit the repeated measures model
    rm = fitrm(t,'Y1-Y56~1','WithinDesign',within);

    % run my repeated measures anova here
    [ranovatbl1] = ranova(rm, 'WithinModel','ROI*Task*Relevance')
    
    % does the data violate sphericity assumption?
    mauchly_tbl = mauchly(rm);

%% Method 2: remove sPCS ROI 

    ii=0;
    roiCells = [];
    taskCells = [];
    relCells = [];
    varNames = [];
    data = zeros(nSubj,(nVOIs-1)*2*2);
    for vv=[1:10,12:14]
       for cc=1:nCond
           for rr=1:nRel   
                ii=ii+1;
                roiCells{ii} = VOIs{vv};
                taskCells{ii} = condStrs{cc};
                relCells{ii} = relStrs{rr}; 
                thisdat =  X(X(:,2)==vv & X(:,3)==cc & X(:,4)==rr,1);
                data(:,ii) = thisdat;
                varNames{ii} = sprintf('Y%d',ii);
           end      
        end
    end

    % Create a table storing the respones
    % varNames = {'Y1','Y2','Y3','Y4','Y5','Y6','Y7','Y8','Y9','Y10',...
    %     'Y11','Y12','Y13','Y14','Y15','Y16','Y17','Y18','Y19','Y20'};
    t = array2table(data,'VariableNames',varNames);
    % Create a table reflecting the within subject factors 'TestCond', 'Attention', and 'TMS' and their levels
    factorNames = {'ROI','Task','Relevance'};

    within = table(roiCells',taskCells',relCells','VariableNames',factorNames);

    % fit the repeated measures model
    rm = fitrm(t,'Y1-Y52~1','WithinDesign',within);

    % run my repeated measures anova here
    [ranovatbl2] = ranova(rm, 'WithinModel','ROI*Task*Relevance')
    
    % does the data violate sphericity assumption?
    mauchly_tbl = mauchly(rm);

%% Method 3: interpolate missing values
    
    
    %% interpolate to insert values for the missing ones
    
    % find how far this subject was from distribution of other subjects, in
    % each cond and voi
    tvals = zeros(nVOIs,nCond,nRel);
    sind = 8;
    othersubinds = [1:7,9:10];
    vind = 11;
    othervinds = [1:10,12:14];
    for vv=othervinds
        for cc=1:nCond
            for rr=1:nRel
                thissub = squeeze(d_allsub(vv,sind,cc,rr));
                othersubs = squeeze(d_allsub(vv,othersubinds,cc,rr));           
                tvals(vv,cc,rr) = (thissub-mean(othersubs))./(std(othersubs)/sqrt((length(othersubinds))));
            end
        end
    end
    
    % this is the average t for this subject (independent of cond, voi)
    avgt = mean(tvals(:));
    
    % now use this t to get interpolated values for the missing ones.
    for cc=1:2
        for rr=1:2
            othersubs = squeeze(d_allsub(vind,othersubinds,cc,rr));
            d_allsub(vind,sind,cc,rr) = avgt*(std(othersubs)/sqrt(length(othersubinds))) + mean(othersubs);
        end
    end

   X = zeros(numel(d_allsub),5);
   startind=0;
   for vv=1:nVOIs
       for cc=1:nCond
           for rr=1:nRel
               X(startind+1:startind+nSubj,1) = d_allsub(vv,:,cc,rr);
    %            X(startind+1:startind+nSubj,1) = accs_allsub(vv,:,cc);
               X(startind+1:startind+nSubj,2) = vv;
               X(startind+1:startind+nSubj,3) = cc;
               X(startind+1:startind+nSubj,4) = rr;
               X(startind+1:startind+nSubj,5) = 1:nSubj;

               startind=startind+nSubj;
           end
       end
   end

    ii=0;
    roiCells = [];
    taskCells = [];
    relCells = [];
    varNames = [];
    data = zeros(nSubj,nVOIs*2*2);
    for vv=1:nVOIs
       for cc=1:nCond
           for rr=1:nRel   
                ii=ii+1;
                roiCells{ii} = VOIs{vv};
                taskCells{ii} = condStrs{cc};
                relCells{ii} = relStrs{rr}; 
                data(:,ii) = X(X(:,2)==vv & X(:,3)==cc & X(:,4)==rr,1);
                varNames{ii} = sprintf('Y%d',ii);
           end      
        end
    end

    % Create a table storing the respones
    % varNames = {'Y1','Y2','Y3','Y4','Y5','Y6','Y7','Y8','Y9','Y10',...
    %     'Y11','Y12','Y13','Y14','Y15','Y16','Y17','Y18','Y19','Y20'};
    t = array2table(data,'VariableNames',varNames);
    % Create a table reflecting the within subject factors 'TestCond', 'Attention', and 'TMS' and their levels
    factorNames = {'ROI','Task','Relevance'};

    within = table(roiCells',taskCells',relCells','VariableNames',factorNames);

    % fit the repeated measures model
    rm = fitrm(t,'Y1-Y56~1','WithinDesign',within);

    % run my repeated measures anova here
    [ranovatbl3] = ranova(rm, 'WithinModel','ROI*Task*Relevance')
