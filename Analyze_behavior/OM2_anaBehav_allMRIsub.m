% function OM2_anaBehav_allMRIsub(subName,makePlot)
% process behavior for scanner subjects - compare performance of two stim
% set groups

%%
clear 
close all

root = '/usr/local/serenceslab/maggie/OM2_OSF/';

subj={'AI','AP','AV','BB','BC','BJ','BO','BR','BU','BW'};
% sessionsExp = [1,2,2,1,1,1,2];
subsIgnore = {'BC211'};

nSubj = length(subj);

expName = 'OM2';
expPrefix = {'attId','attOr'};
nCond = length(expPrefix);

allaccs = [];
runlist = [];

allRT = [];
runlistRT = [];

dlims = [-1,5];
acclims = [50,100];

alld = [];

alld_withincat = [];
alld_acrosscat = [];

alliswithincat  =[];
alliscorr = [];

numNoResp = zeros(nSubj,1);
numTrialsTotal = zeros(nSubj,1);
for ss=1:nSubj
    subName=subj{ss};
   
    sessfolders = dir([root 'OM2_behavior' filesep subj{ss} '*']);
    
    for ff=1:length(sessfolders)
        if ~any(strcmp(subsIgnore, sessfolders(ff).name))            
  
            for tt=1:length(expPrefix)

                subName = sessfolders(ff).name;
                
                taskStr = sprintf('Task%02.f',tt);    

                behavRoot=[root 'OM2_behavior' filesep subName filesep];

                %count the runs, then loop over them
                fn=dir([behavRoot,subName(1:5),'_' expName, '_Run*_', taskStr, '.mat']);
                [nRuns,~]=size(fn);

                fprintf('Subj %s: found %.f runs for %s\n',subName,nRuns,expPrefix{tt});

                for rr=1:nRuns

                    thisfn = [behavRoot fn(rr).name];
%                     fprintf('loading %s...\n',thisfn);
                    load(thisfn);

                    allaccs = cat(1,allaccs,p.accuracy);

                    %get d' for this run - responses on all trials after the first,
                    %where a response was made
                    predlabs = p.resp(2:end);
                    reallabs = p.correctresp(2:end);
                    iswithincat = p.isMatch(2:end,1)==1;
                    iscorr = p.correct(2:end,1)== 1;
                    
                    if any(predlabs==0)
                        numNoResp(ss) = numNoResp(ss) + sum(predlabs==0);
                        numTrialsTotal(ss) = numTrialsTotal(ss) + length(predlabs);
                        predlabs = predlabs(predlabs~=0);
                        reallabs = reallabs(predlabs~=0);
                        iswithincat = iswithincat(predlabs~=0);
                        iscorr = iscorr(predlabs~=0);
                        
                    end

                    thisd = get_dprime(predlabs,reallabs,unique(reallabs));
                    alld = cat(1,alld,thisd);

                    thisd_withincat = get_dprime(predlabs(iswithincat),reallabs(iswithincat),unique(reallabs(iswithincat)));
                    thisd_acrosscat = get_dprime(predlabs(~iswithincat),reallabs(~iswithincat),unique(reallabs(~iswithincat)));
                    
                    alld_withincat = cat(1,alld_withincat,thisd_withincat);
                    alld_acrosscat = cat(1,alld_acrosscat,thisd_acrosscat);
                    
                    % the below things are trial by trial
                    alliswithincat = cat(1,alliswithincat,iswithincat);
                    alliscorr = cat(1,alliscorr,iscorr);
                    
                    
                    thisRT = p.respTimeFromOnset(2:end);
                    thisRT = thisRT(thisRT~=0);
                    allRT = cat(1,allRT,thisRT);
                          
                    runlistRT= cat(1,runlistRT,repmat([ss,p.stimSet,p.task,ff,rr],length(thisRT),1));
                    
                    runlist = cat(1,runlist,[ss,p.stimSet,p.task,ff,rr]);

                end


            end
        end
    end
       
end

save([root filesep 'OM2_behavior/OM2_allsub_behav_ana.mat']);
