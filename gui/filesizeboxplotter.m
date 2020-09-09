function filesizeboxplotter(handles)
resultsFolder = handles.resultsfolder{1};
fileSizeList = [];
subjFolders = dir(resultsFolder);
ext = handles.params.extedit.String;
slash = filesep;

for subj = 3 : size(subjFolders,1)
    subjName = subjFolders(subj).name;
    filepath = [resultsFolder subjName];
    subjFiles = dir([filepath slash '*' ext]);
    
    for file = 3 : size(subjFiles,1)
        fileSize = subjFiles(file).bytes/1e+6;
        fileSizeList = [fileSizeList; fileSize];
    end
end
fileSizeList = round(fileSizeList,3,'significant');
figure;
boxplot(fileSizeList);
ylabel('File Size (MBytes)');
title('Boxplot of whole dataset file sizes');
end

