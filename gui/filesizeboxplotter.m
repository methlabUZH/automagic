function filesizeboxplotter(handles)
resultsFolder = handles.resultsfolder{1};
% cd(resultsFolder);
fileSizeList = [];
subjFolders = dir(resultsFolder);
for subj = 3 : size(subjFolders,1)
%     disp(subj-2)
    subjName = subjFolders(subj).name;
    filepath = [resultsFolder subjName];
%     cd(filepath);
    subjFiles = dir(filepath);
    for file = 3 : size(subjFiles,1)
        fileSize = subjFiles(file).bytes;
        fileSizeList = [fileSizeList; fileSize];
    end
end

% fakeSet = 1000*randn(100,1)+mean(fileSizeList);

figure;
boxplot(fileSizeList);
ylabel('File Size (Bytes)');
title('Boxplot of whole dataset file sizes');

% absCase = 1;
% madCase = 1;
% iqrCase = 0; 
% 
% 
% if absCase
%     absThr = (1/10)*mean(fileSizeList);
%     absList = fakeSet<absThr;
% else
%     absList = zeros(numel(fakeSet),1);
% end
%     
% if madCase
%     madThr = mad(fakeSet,1); % median 
%     madList = fakeSet>madThr+median(fakeSet);
% else
%     madList = zeros(numel(fakeSet),1);    
% end
% 
% if iqrCase
%     iqrThr = [quantile(fakeSet,0.25),quantile(fakeSet,0.75)];
%     iqrList = [fakeSet<iqrThr(:,1),fakeSet>iqrThr(:,2)];
%     iqrList = iqrList(:,1)|iqrList(:,2);
% else
%     iqrList = zeros(numel(fakeSet),1);    
% end
% 
% exclusionList = absList | madList | iqrList;
% percentExcluded = 100*sum(exclusionList)/length(exclusionList);
% % disp(percentExcluded);
end

