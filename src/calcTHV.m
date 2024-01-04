function THV = calcTHV(EEG, settings)

tmpData = EEG.data;

t = size(tmpData,2);

% if average reference
if settings.avRef 
    tmpData = tmpData - repmat(mean(tmpData,1,'omitnan'), size(tmpData, 1),1);
end


% calculate THV
THV = nansum(bsxfun(@gt, std(tmpData,[],1,'omitnan')', settings.timeThresh), 1) ./t;

end