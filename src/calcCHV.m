function CHV = calcCHV(EEG, settings)

tmpData = EEG.data;

% if average reference
if settings.avRef 
    tmpData = tmpData - repmat(mean(tmpData,1,'omitnan'), size(tmpData, 1),1);
end

% remove timepoints of very high variance from channels (if this timepoints pose proportionally 
% less time than the chosen rejection ratio)
if settings.checkboxCutoff_CHV
    ignoreCutOff = settings.Cutoff_CHV;
    RejRatio = settings.RejRatio_CHV;
    ignoreMask = tmpData > ignoreCutOff | tmpData < -ignoreCutOff;
    OnesPerChan = sum(ignoreMask');
    OnesPerChan = OnesPerChan/size(tmpData,2);
    overRejRatio = OnesPerChan > RejRatio;
    ignoreMask(overRejRatio', :) = 0;
    tmpData(ignoreMask) = NaN; 
end

% calculate CHV
CHV = sum(nanstd(tmpData,[],2) > settings.chanThresh, 1)./ size(tmpData, 1);

end