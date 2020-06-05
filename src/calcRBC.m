function RBC = calcRBC(bad_chans, chanNum)
RBC = numel(bad_chans)./chanNum;
end