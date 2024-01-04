function OHA = calcOHA(EEG, settings)

tmpData = EEG.data;

% remove channels with NaNs
tmpData(any(isnan(tmpData), 2), :) = [];

c = size(tmpData,2);
t = size(tmpData,2);

% if average reference
if settings.avRef 
    tmpData = tmpData - repmat(mean(tmpData,1,'omitnan'), size(tmpData, 1),1);
end


% calculate OHA
OHA = nansum(abs(tmpData(:)) > settings.overallThresh)./(t.*c);

end