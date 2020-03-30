function filesizeboxplotter(handles)
resultsFolder = handles.resultsfolder{1};
fileSizeList = [];
subjFolders = dir(resultsFolder);
for subj = 3 : size(subjFolders,1)
    subjName = subjFolders(subj).name;
    filepath = [resultsFolder subjName];
    subjFiles = dir(filepath);
    for file = 3 : size(subjFiles,1)
        fileSize = subjFiles(file).bytes/1050000;
        fileSizeList = [fileSizeList; fileSize];
    end
end
fileSizeList = round(fileSizeList,3,'significant');
figure;
boxplot(fileSizeList);
ylabel('File Size (MBytes)');
title('Boxplot of whole dataset file sizes');
end

