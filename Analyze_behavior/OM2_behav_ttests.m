
%%
clc

% clear 
close all
root = '/usr/local/serenceslab/maggie/OM2_OSF/';


load([root filesep 'OM2_behavior/OM2_allsub_behav_ana.mat']);

%% compare stim set d': pairwise t-test within each cond
  
for cc=1:2
    
    fprintf('\nTask %d: \n',cc)

    
    
    group1=[];
    group2=[];

    sinds = unique(runlist(runlist(:,2)==1,1));
    
    for su=1:nSubj
        if ismember(su,sinds)
            group1 = [group1 mean(alld(runlist(:,3)==cc & runlist(:,1)==su))];
        else
            group2 = [group2 mean(alld(runlist(:,3)==cc & runlist(:,1)==su))];
        end
    end
    
    [h,p] = ttest2(group1,group2);
    fprintf(' Mean dprime (averaged w/in sub) for set 1: %.2f +/- %.2f\n Mean dprime (averaged w/in sub) for set 2: %.2f +/- %.2f\n p (2 sample test) = %.4f\n',mean(group1),std(group1)/sqrt(nSubj),mean(group2),std(group2)/sqrt(nSubj),p);

end

%% compare stim set RT: pairwise t-test within each cond
  
for cc=1:2
    
    fprintf('\nTask %d: \n',cc)

    
    
    group1=[];
    group2=[];

    sinds = unique(runlist(runlist(:,2)==1,1));
    
    for su=1:nSubj
        if ismember(su,sinds)
            group1 = [group1 mean(allRT(runlistRT(:,3)==cc & runlistRT(:,1)==su & allRT~=0))];
        else
            group2 = [group2 mean(allRT(runlistRT(:,3)==cc & runlistRT(:,1)==su & allRT~=0))];
        end
    end
    
    [h,p] = ttest2(group1,group2);
    fprintf(' Mean RT (averaged w/in sub) for set 1: %.2f +/- %.2f\n Mean RT (averaged w/in sub) for set 2: %.2f +/- %.2f\n p (2 sample test) = %.4f\n',mean(group1),std(group1)/sqrt(nSubj),mean(group2),std(group2)/sqrt(nSubj),p);

end
%% compare task d': pairwise t-test of all subs
  
group1=[];
group2=[];

for su=1:nSubj

    group1 = [group1 mean(alld(runlist(:,3)==1 & runlist(:,1)==su))];
    group2 = [group2 mean(alld(runlist(:,3)==2 & runlist(:,1)==su))];

end

fprintf('\nAll subjects:\n')
    
[h,p] = ttest(group1-group2);
fprintf(' Mean dprime (averaged w/in sub) for task 1: %.2f +/- %.2f\n Mean dprime (averaged w/in sub) for task 2: %.2f +/- %.2f\n p (paired test) = %.4f\n',mean(group1),std(group1)/sqrt(nSubj),mean(group2),std(group2)/sqrt(nSubj),p);

%% compare task RT: pairwise t-test of all subs
  
group1=[];
group2=[];

for su=1:nSubj

    group1 = [group1 mean(allRT(runlistRT(:,3)==1 & runlistRT(:,1)==su & allRT~=0))];
    group2 = [group2 mean(allRT(runlistRT(:,3)==2 & runlistRT(:,1)==su & allRT~=0))];

end
fprintf('\nAll subjects:\n')
    
[h,p] = ttest(group1-group2);
fprintf(' Mean RT (averaged w/in sub) for task 1: %.2f +/- %.2f\n Mean RT (averaged w/in sub) for task 2: %.2f +/- %.2f\n p (paired test) = %.4f\n',mean(group1),std(group1)/sqrt(nSubj),mean(group2),std(group2)/sqrt(nSubj),p);



