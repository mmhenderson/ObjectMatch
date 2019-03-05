function fh = plot_barsAndStars(meanVals,seVals,isSig,isSigBetween,chanceVal,yrange,barLabs1,barLabs2,yLab,titlestr)
% make a bar plot containing up to two data series (for example, a set of 
% VOIs over 2 conditions)
% include significance stars for each bar and for comparisons

% REQUIRED:
% meanVals: [nLevels1 x nLevels2] (e.g. VOI x cond)

% OPTIONAL:
% seVals: [nLevels1 x nLevels2]
% isSig: [nLevels1 x nLevels2 x nSigLevels] (1 or 0, following FDR
    % correction.
    % nSigLevels can be 1 or 2
        % if 1, all significant values are plotted as closed circle
        % if 2, level 1 is plotted as open circle, 2 as closed (for
        % instance, could be 0.05 and 0.01 significance
% isSigBetween: [nLevels1 x nSigLevels] (e.g. within VOI comparison across
    % conditions
% chanceVal: within range 0-1, for instance if you are plotting accuracy in
    % a two-way classification, use 0.5 
% barLabs1: cell array of labels for factor 1 (e.g. VOI)
% barLabs2: cell array of labels for factor 2 (e.g condition)
% yLab: units of y axis (e.g d', accuracy)
% title: string for title

%%

plotSigEach = 1;
plotSigBetween = 1;

if size(meanVals,2)>2
    error('factor 2 can only have <=2 levels')
end
nLevels1 = size(meanVals,1);
nLevels2 = size(meanVals,2);

if ~exist('seVals','var') || isempty(seVals)
    seVals = nan(size(meanVals));
end

if ~exist('isSig','var') || isempty(isSig)
    plotSigEach=0;
    nSigLevelsEach = [];
else  
    sigValDims = size(isSig);
    if nLevels2==1
        if sigValDims(1)~=nLevels1
            error('meanVals and isSig must have same first dim')
        end
        if sigValDims(2)>2
            error('cannot plot more than 2 sig levels')
        end
        nSigLevelsEach = sigValDims(2);
    else
        if sigValDims(1)~=nLevels1 || sigValDims(2)~=nLevels2
            error('meanVals and isSig must have same first 2 dims')
        end
        if length(sigValDims)>2 && sigValDims(3)>2
            error('cannot plot more than 2 sig levels')
        elseif length(sigValDims)>2
            nSigLevelsEach = sigValDims(3);
        else
            nSigLevelsEach = 1;
        end
    end
end

if nLevels2>1
    if ~exist('isSigBetween','var') || isempty(isSigBetween)
        plotSigBetween = 0;
    elseif size(isSigBetween,1)~=nLevels1
        error('meanVals and isSigBetween must have same first dimension')
    elseif size(isSigBetween,2)>2
        error('cannot plot more than 2 sig levels')    
    else
        nSigLevelsBetween=size(isSigBetween,2);      
    end
else
    isSigBetween = [];
    plotSigBetween=  0;
    nSigLevelsBetween = [];
end

if ~exist('chanceVal','var') || isempty(chanceVal)
    chanceVal = 0;
end

horspacer=0.147;
if ~isempty(yrange)
    verspacerbig = range(yrange)/50;
else
    verspacerbig = (max(meanVals(:))-min(meanVals(:)))/50;
end
    
markersize = 3;

if nLevels2==2
    barPos = [(1:size(meanVals,1))-horspacer;(1:size(meanVals,1))+horspacer]';
else
    barPos = (1:size(meanVals,1))';
end

%% make the figure

fh = figure;hold all;
          
colormap('jet')
bar(meanVals);
for ll=1:nLevels2
    errorbar(barPos(:,ll),meanVals(:,ll),seVals(:,ll),'Marker','none',...
            'LineStyle','none','LineWidth',1,'Color',[0,0,0]);
end

set(gca,'XTick', 1:nLevels1)
line([0,nLevels1+1],[chanceVal,chanceVal],'Color','k');

%% plot significance values for condition differences (pairs of bars)

if plotSigBetween

    % below code works only if we have nLevels2=2
    astLocsComp=nan(size(isSigBetween));

    for vv=1:nLevels1
        if isSigBetween(vv,1);
           [mx,maxind] = max(meanVals(vv,:));
           if mx<0
               % bars are negative; plot a line just  above the x axis
               astLocsComp(vv,1)=3*verspacerbig;
               plot([vv-2*horspacer,vv+2*horspacer],[2*verspacerbig,2*verspacerbig],'Color','k');
           else
               % bars are positive; plot a line above the pair of bars
               astLocsComp(vv,1)=meanVals(vv,maxind)+seVals(vv,maxind)+3*verspacerbig;                         
               plot([vv-2*horspacer,vv+2*horspacer],[meanVals(vv,maxind)+seVals(vv,maxind)+2*verspacerbig,meanVals(vv,maxind)+seVals(vv,maxind)+2*verspacerbig],'Color','k');
           end
        end
        if nSigLevelsBetween>1 && isSigBetween(vv,2);                
            astLocsComp(vv,2)=astLocsComp(vv,1);
        end
    end
    
    if nSigLevelsBetween>1
        plot((1:nLevels1),astLocsComp(:,1),'o','Color','k','MarkerSize',markersize);
        plot((1:nLevels1),astLocsComp(:,2),'o','Color','k','MarkerFaceColor','k','MarkerSize',markersize);
    else
        plot((1:nLevels1),astLocsComp(:,1),'o','Color','k','MarkerFaceColor','k','MarkerSize',markersize);
    end
end

%% plot significance for individual bars

if plotSigEach
    
    % reshape everything now to make plotting stars easier
    isSig = reshape(isSig,[nLevels1*nLevels2,nSigLevelsEach]);
    meanVals = meanVals(:);
    seVals = seVals(:);
    barPos = barPos(:);
    
    astLocsEach=nan(size(isSig));
    
    for ee=1:size(isSig,1);
        
        if isSig(ee,1)
            if meanVals(ee)>0
                astLocsEach(ee,1)=meanVals(ee)+seVals(ee)+verspacerbig;
            else
                astLocsEach(ee,1)=meanVals(ee)-seVals(ee)-verspacerbig;
            end
        end
        if nSigLevelsEach>1 && isSig(ee,2)
            astLocsEach(ee,2) = astLocsEach(ee,1);                    
        end
    end
    
    if nSigLevelsEach>1
        plot(barPos,astLocsEach(:,1),'o','Color','k','MarkerSize',markersize)
        plot(barPos,astLocsEach(:,2),'o','Color','k','MarkerFaceColor','k','MarkerSize',markersize)
    else
        plot(barPos,astLocsEach(:,1),'o','Color','k','MarkerFaceColor','k','MarkerSize',markersize)
    end
end

%% add labels if specified

if exist('barLabs1','var') && ~isempty(barLabs1)
    set(gca,'XTickLabel', barLabs1,'XTickLabelRotation',90);
end

if exist('barLabs2','var') && ~isempty(barLabs2)    
    legend(barLabs2,'Location','EastOutside');
end

if exist('yLab','var') && ~isempty(yLab)    
    ylabel(yLab)
end


if exist('yrange','var') && ~isempty(yrange)    
    set(gca,'YLim',yrange)
end

if exist('titlestr','var') && ~isempty(titlestr)
    title(titlestr)
end

end

