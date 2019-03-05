% make Supplementary Figure 2 (Image similarity analysis)

% use the script in Analyze_images to generate the structure that is
% loaded
%%
clear

close all;

% change thisto your main directory
% root = 'Z:\People\Maggie\OM2\';
root = '/usr/local/serenceslab/maggie/OM2_OSF/';
addpath(genpath(root));

% imfolder = 'Category_stims';
savedir = 'OM2_corrMat';

subj={'AI','AP','AV','BB','BC','BJ','BO','BR','BU','BW'};

sets = [3,1,1,2,4,2,2,2,1,1];

nSubj=length(subj);

locstr='ObjectLoc';
locSignStr='posVoxOnly';

condStrs ={'Identity','Viewpoint'};

nCond = 2;

allp_actual = zeros(nSubj,2);
allp_resp = zeros(nSubj,2,2);

for ss=1:nSubj

    for cc=1:2
        
         fns = [root savedir filesep subj{ss} '_trialSim_RawIms.mat'];

        load(fns)

        allcorr = trialSim.imCorr(cc).imCorr;

        actual = double(trialSim.obList(cc).isMatch);

        actual(actual==0) = 2;


        catormatchlabs = trialSim.obList(cc).isCatOrMatch;

%% find the p-value for bias in the image sets - across all trials

        dat1 = allcorr(actual==1 & catormatchlabs==0);
        dat2 = allcorr(actual==2 & catormatchlabs==0);

        alldat{ss,cc,1} = dat1;
        alldat{ss,cc,2} = dat2;
        
        [h,p] = ttest2(dat1,dat2,'Tail','right','Vartype','unequal');
        
        allp_actual(ss,cc) = p;

    end
        
end

[thresh, allp_FDR] = fdr(allp_actual,0.01);

%% make plot

for cc=1:2

figure;hold all;
cols = jet(2);
lh = [];
for se = 1:2

    % all subjects in set 1 or 2
    thesesubs = find(3-(mod(sets,2)+1)==se);
    thiscol = cols(se,:);
    dat2plot = [];
    for ss=1:length(thesesubs)
        
        dat1 = alldat{thesesubs(ss),cc,1};
        dat2 = alldat{thesesubs(ss),cc,2};
   
        if allp_actual(thesesubs(ss),cc)<0.01               
            lh = [lh,plot([1,2],[mean(dat1),mean(dat2)],'-o','Color',thiscol,'MarkerFaceColor',thiscol,'MarkerSize',10)];
        else
            lh = [lh,plot([1,2],[mean(dat1),mean(dat2)],'-o','Color',thiscol,'MarkerSize',10)];
        end
        
    end
    
    
end
legend(lh(1,[1,6]),{'Set A','Set B'});
set(gca,'XLim',[.5,2.5],'YLim',[0.15,0.30],'XTick',[1,2],'XTickLabel',{'Match','Nonmatch'});
ylabel('Mean Image Correlation')
title(condStrs{cc});

end