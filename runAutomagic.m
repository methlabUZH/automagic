%% start Automagic
restoredefaultpath;

mainGuiFile = 'mainGUI.m';

addAutomagicPaths();
[hFig] = loadingScreen();
run(mainGuiFile);
close(hFig)