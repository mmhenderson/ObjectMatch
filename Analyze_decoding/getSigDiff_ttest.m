function [pVals,isSig,pFDRthresh] = getSigDiff_ttest(meanVals,nBootIter,chanceVal,sigLevels)
% perform a t-test comparing pairs of values across 2 conditions (for
% instance, compare classifier performance in each VOI across 2 conds
% also return FDR corrected table

% returns:
    % pVals [size(meanVals,1),1]
    % isSig [size(meanVals,1),length(sigLevels)];
    % pFDRthresh [length(sigLevels),1]
    
% REQUIRED:
% meanVals: [nLevels x 2] (e.g. VOI x cond)
% chanceVal: within range 0-1, for instance if you are plotting accuracy in
    % a two-way classification, use 0.5 
% nBootIter: default is 1000

% OPTIONAL:
% sigLevels: specify 1 or more alphas to do FDR correction over 
    % (default 0.01)

%%

if size(meanVals,2)~=2
    error('factor 2 has to have 2 levels for t-test')
end
nLevels = size(meanVals,1);

if ~exist('sigLevels','var') || isempty(sigLevels)
    sigLevels = 0.01;
end

%%

pVals = zeros(nLevels,1);

for ll=1:nLevels

    group1 = squeeze(meanVals(ll,1,:));
    group2 = squeeze(meanVals(ll,2,:));

    realDiffs = group1-group2;        
    realT = get_tscore_nans(realDiffs',chanceVal);

    % iterate over nBootIters
    nullT = zeros(nBootIter,1);

    for ii=1:nBootIter

        %swap the order on some of these with 50% prob (this is
        %equivalent to assuming there is no difference between the two
        %attention conds, but keeping subjects as a fixed factor)
        randSwap = boolean(randi([0,1],size(realDiffs)));
        randDiffs=realDiffs;
        randDiffs(randSwap)=-randDiffs(randSwap);

        nullT(ii) = get_tscore_nans(randDiffs',chanceVal);

    end

    pVals(ll) = min([mean(realT<nullT),mean(realT>nullT)]);

end

%% FDR correction

isSig = zeros(nLevels,length(sigLevels));
pFDRthresh = zeros(length(sigLevels),1);

for aa=1:length(sigLevels)
    
    alpha = sigLevels(aa);
    
    [p_fdr, p_masked] = fdr(pVals, alpha);
    isSig(:,aa) = p_masked;
    pFDRthresh(:,aa) = p_fdr;
    
end

