function [ tvals ] = get_tscore_nans(rawvals,expval)
% calculate a t-statistic for the distance of a sample group from an
% expected value (for instance, a set of classifier accuracies that are
% compared to 0.50)

% ignore any values that are nan (like a nanmean)

% rawvals is nVals x nSubj
% tvals is nVals x 1
% expval is 1x1

% MMH 5/8/17

nSubj=sum(~isnan(rawvals(1,:)));

meanvals = nanmean(rawvals-expval,2);

if nSubj>1
    sevals = nanstd(rawvals,[],2)./sqrt(nSubj);
else
    sevals = ones(size(meanvals));
end

tvals = meanvals./sevals;

end

