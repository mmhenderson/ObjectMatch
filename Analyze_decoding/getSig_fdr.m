function [pVals,isSig,pFDRthresh] = getSig_fdr(realVals,nullVals,chanceVal,sigLevels)
% calculate p-values for subject mean based on null distribution for each
% subject. Last dimension of realVals is subject.
% FDR correct over entire p table.

%REQUIRED: 
% realVals - at least 2 dimensions, with subjects as last dimension. Can
    % have more than 2 dimensions, for example [nVOIs x nCond x nSubj], but
    % subj must be last.
% nullVals - same dim as realVals, except has one additional dim for
    % iterations of shuffling (last dim)
% chanceVal - value [0-1] that specifies expected chance value - for instance,
    % for classification accuracy on a two-way classifier, 0.50

%OPTIONAL
%sigLevels - number of significance levels to do FDR correction over (if
    %not specified, then 0.01
    
%%

realDims = size(realVals);
nullDims = size(nullVals);

if any(realDims~=nullDims(1:end-1))
    error('first n-1 dims of nullVals dims must match dims of realVals')
end

if ~exist('sigLevels','var') || isempty(sigLevels)
    sigLevels = 0.01;
end

nIter = nullDims(end);

nElements2Avg= prod(realDims(1:end-1));
nSubj = realDims(end);

%reshape in case there are >2 dims
realVals = reshape(realVals,[nElements2Avg,nSubj]);
nullVals = reshape(nullVals,[nElements2Avg,nSubj,nIter]);
    
pVals = zeros(nElements2Avg,1);

for ee=1:nElements2Avg

        %% all trials
        real = squeeze(realVals(ee,:));
        null = squeeze(nullVals(ee,:,:));
        
        if nSubj>1
            realT = get_tscore_nans(real,chanceVal);
            nullT = get_tscore_nans(null',chanceVal);
        else
            realT = real;
            nullT = null;
        end
        
        if length(nullT)~=nIter 
            error('wrong number of values in null distrib')
        end
         
        pVals(ee) = 2*min([mean(realT<nullT),mean(realT>nullT)]);

end


%% FDR correction
isSig = zeros(nElements2Avg,length(sigLevels));
pFDRthresh = zeros(length(sigLevels),1);

for aa=1:length(sigLevels)
    alpha=sigLevels(aa);

    [p_fdr, p_masked] = fdr( pVals, alpha);
    isSig(:,aa)=p_masked; 
    pFDRthresh(aa) = p_fdr;
    
end    

%% put back to original shape

isSig = reshape(isSig,[realDims(1:end-1),length(sigLevels)]);
pVals = squeeze(reshape(pVals,[realDims(1:end-1),1]));

