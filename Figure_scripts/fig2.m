% create Figure 2 A and B (subject d' and RT for Identity and Viewpoint Tasks)

clear

close all

% set this root to wherever your main folder directory is
% root = '/usr/local/serenceslab/maggie/mFiles/OM2/OSF/';
% change this to your main directory
root = '/usr/local/serenceslab/maggie/OM2_OSF/';
addpath(genpath(root));

load([root '/OM2_behavior/OM2_allsub_behav_ana.mat']);

%% plot subject average d-prime, both sets

figure;hold all;

title(sprintf('D-prime'));

mysymbols = {'-r^','-bx'};
fh = [];

allvals = [];

for ss=1:2
    
    sinds = unique(runlist(runlist(:,2)==ss,1));
    
    for su = 1:length(sinds)
        group1 = alld(runlist(:,3)==1 & runlist(:,2)==ss & runlist(:,1)==sinds(su));
        group2 = alld(runlist(:,3)==2 & runlist(:,2)==ss & runlist(:,1)==sinds(su));
       
        
        thisfh = plot([mean(group1),mean(group2)],mysymbols{ss});
        allvals = [allvals;[mean(group1),mean(group2)]];
        if su==1
            fh = [fh,thisfh];
        end
    end
    
    
    set(gca, 'XLim',[.5,2.5],'XTick', 1:2, 'YLim',dlims,...
                    'XTickLabel', expPrefix,'XTickLabelRotation',90);

end

errorbar(mean(allvals,1),std(allvals)./sqrt(10-1));
legend(fh,{'Set 1','Set 2'},'Location','EastOutside');

%% plot subject average RT, both sets

figure;hold all;

title(sprintf('RT'));

mysymbols = {'-r^','-bx'};
fh = [];

allvals = [];
for ss=1:2
    
     sinds = unique(runlist(runlist(:,2)==ss,1));
    
    for su = 1:length(sinds)
        group1 = allRT(runlistRT(:,2)==ss & runlistRT(:,1)==sinds(su) & runlistRT(:,3)==1);
        group2 = allRT(runlistRT(:,2)==ss & runlistRT(:,1)==sinds(su) & runlistRT(:,3)==2);

        group1 = group1(group1~=0);
        group2 = group2(group2~=0);
        
        thisfh = plot([mean(group1),mean(group2)],mysymbols{ss});
        allvals = [allvals;[mean(group1),mean(group2)]];
        if su==1
            fh = [fh,thisfh];
        end
    end

   
end

errorbar(mean(allvals),std(allvals)./sqrt(10-1));

set(gca, 'XLim',[.5,2.5],'XTick', 1:2,...
                    'XTickLabel', expPrefix,'XTickLabelRotation',90);

legend(fh,{'Set 1','Set 2'},'Location','EastOutside');
